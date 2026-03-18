/*
 * RTC STM32F746G-DISCO — Zephyr 4.2 / LVGL 9
 *
 * Horloge virtuelle :
 *   - Si RTC physique (PCF8563) présent  → il est PRIORITAIRE pour tout
 *   - Si RTC physique absent             → horloge logicielle en RAM
 *     Le PC peut lire/écrire via UART exactement comme avec le vrai RTC
 *     (CMD_SET_TIME, CMD_SET_DATE, CMD_SET_ALL, CMD_GET_TIME, ...)
 *
 * Règle simple :
 *   rtc_get_virtual()  → lit  PCF8563 si disponible, sinon lit  sw_clock
 *   rtc_set_virtual()  → écrit PCF8563 si disponible, sinon écrit sw_clock
 */

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/rtc.h>
#include <zephyr/drivers/uart.h>
#include <zephyr/drivers/display.h>
#include <zephyr/logging/log.h>
#include <zephyr/sys/atomic.h>   /* atomic_t : flags ISR/worker -> main   */
#include <lvgl.h>
#include <math.h>
#include <string.h>
#include <stdio.h>

LOG_MODULE_REGISTER(rtc_app, LOG_LEVEL_DBG);

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

/* ─── Devices ────────────────────────────────────────────────────────────── */
static const struct device *const rtc_dev  = DEVICE_DT_GET(DT_ALIAS(rtc));
static const struct device *const uart_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_console));
static bool rtc_available = false;

/* ═══════════════════════════════════════════════════════════════════════════
 *  Horloge virtuelle (RAM) — utilisée uniquement quand rtc_available=false
 * ══════════════════════════════════════════════════════════════════════════ */
static struct rtc_time sw_clock;          /* horloge logicielle             */
K_MUTEX_DEFINE(sw_clock_mutex);           /* protège sw_clock en multi-thread */
static bool sw_clock_set = false;         /* true si le PC a déjà envoyé l'heure */

/* Nombre de jours dans chaque mois (année non-bissextile) */
static const uint8_t days_in_month[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

/* Incrémente sw_clock d'une seconde (appelé par le worker toutes les 1000 ms) */
static void sw_clock_tick(void)
{
    k_mutex_lock(&sw_clock_mutex, K_FOREVER);
    sw_clock.tm_sec++;
    if (sw_clock.tm_sec >= 60) {
        sw_clock.tm_sec = 0;
        sw_clock.tm_min++;
        if (sw_clock.tm_min >= 60) {
            sw_clock.tm_min = 0;
            sw_clock.tm_hour++;
            if (sw_clock.tm_hour >= 24) {
                sw_clock.tm_hour = 0;
                sw_clock.tm_mday++;
                uint8_t max_day = days_in_month[sw_clock.tm_mon % 12];
                if (sw_clock.tm_mday > max_day) {
                    sw_clock.tm_mday = 1;
                    sw_clock.tm_mon++;
                    if (sw_clock.tm_mon >= 12) {
                        sw_clock.tm_mon = 0;
                        sw_clock.tm_year++;
                    }
                }
            }
        }
    }
    k_mutex_unlock(&sw_clock_mutex);
}

/* Lecture unifiée : RTC physique si dispo, sinon sw_clock */
static int rtc_get_virtual(struct rtc_time *tm)
{
    if (rtc_available) {
        return rtc_get_time(rtc_dev, tm);
    }
    k_mutex_lock(&sw_clock_mutex, K_FOREVER);
    *tm = sw_clock;
    k_mutex_unlock(&sw_clock_mutex);
    return 0;
}

/* Écriture unifiée : RTC physique si dispo, sinon sw_clock */
static int rtc_set_virtual(const struct rtc_time *tm)
{
    if (rtc_available) {
        return rtc_set_time(rtc_dev, tm);
    }
    k_mutex_lock(&sw_clock_mutex, K_FOREVER);
    sw_clock = *tm;
    sw_clock_set = true;
    k_mutex_unlock(&sw_clock_mutex);
    LOG_INF("SW clock set: %02d:%02d:%02d %02d/%02d/%d",
            tm->tm_hour, tm->tm_min, tm->tm_sec,
            tm->tm_mday, tm->tm_mon + 1, tm->tm_year + 1900);
    return 0;
}

/* ─── Protocole binaire ──────────────────────────────────────────────────── */
#define SOF_BYTE       0x55
#define ACK_BYTE       0x08
#define NACK_BYTE      0x09
#define CMD_GET_ALL    0x01
#define CMD_SET_ALL    0x02
#define CMD_GET_ALARM  0x03
#define CMD_SET_ALARM  0x04
#define CMD_GET_BAUD   0x05
#define CMD_SET_BAUD   0x06
#define CMD_GET_STATUS 0x07
#define CMD_ALARM_EVT  0x0A
#define CMD_TOGGLE_AL  0x0B
#define CMD_GET_TIME   0x11
#define CMD_SET_TIME   0x12
#define CMD_GET_DATE   0x13
#define CMD_SET_DATE   0x14

/* ─── FSM UART ───────────────────────────────────────────────────────────── */
K_SEM_DEFINE(cmd_sem, 0, 1);
typedef enum { IDLE, READ_CMD, READ_LEN, READ_PAYLOAD, READ_CRC } rx_state_t;
static rx_state_t rx_state = IDLE;
static uint8_t rx_cmd, rx_len, rx_payload_cnt, calc_crc;
static uint8_t rx_payload[15];

/* ─── Etat alarme ── protégé par alarm_mutex ─────────────────────────────────
 *
 * POURQUOI UN MUTEX ICI :
 *   al_on/sec/min/hour sont lus ET écrits depuis deux contextes différents :
 *     - worker thread  : process_command() (CMD_TOGGLE_AL, CMD_SET_ALARM)
 *                        et boucle de vérification alarme
 *     - main thread    : alarm_btn_event() (callback tactile LVGL)
 *                        et ui_update() (lecture pour affichage)
 *   Sans mutex, une modification depuis Python pendant un appui tactile
 *   simultané produit un état incohérent.
 */
K_MUTEX_DEFINE(alarm_mutex);
static uint8_t al_sec = 0, al_min = 0, al_hour = 7, al_on = 0;
static bool    alarm_already_triggered = false;

/* ─── Communication thread-safe worker/ISR → main ───────────────────────────
 *
 * ANCIEN CODE (incorrect) :
 *   static volatile bool ui_dirty = false;
 *   static volatile int  ui_h, ui_m, ui_s, ui_day, ui_mon, ui_year;
 *
 * PROBLÈME : le worker écrit 6 variables séquentiellement PUIS lève ui_dirty.
 *   Sans barrière mémoire, le compilateur ou le Cortex-M7 peut réordonner.
 *   main peut lire ui_dirty=true alors que seules 3 variables sur 6 sont à jour
 *   → "torn read" : heure correcte + date de la seconde précédente.
 *
 * SOLUTION : k_msgq — le message est une struct copiée atomiquement.
 *   Le worker fait k_msgq_put(&ui_time_q, &msg, K_NO_WAIT).
 *   main fait k_msgq_get(&ui_time_q, &msg, K_NO_WAIT).
 *   Pas de torn read possible : la copie est protégée en interne par Zephyr.
 */
struct ui_time_msg {
    int h, m, s;
    int day, mon, year;   /* mon : 1-12, year : 2 chiffres (26 = 2026) */
};
/* Taille 2 : si main est en retard d'un tick, il ne bloque pas le worker */
K_MSGQ_DEFINE(ui_time_q, sizeof(struct ui_time_msg), 2, 4);

/* ─── Flags simples ISR/worker → main ───────────────────────────────────────
 *
 * ANCIEN CODE (insuffisant) :
 *   static volatile bool ui_rx_flash = false;
 *
 * PROBLÈME : volatile garantit la visibilité en mémoire mais pas l'atomicité
 *   de la séquence test-and-clear. Si main lit "true" puis le remet à false
 *   en deux instructions séparées, l'ISR peut re-lever le flag entre les deux.
 *
 * SOLUTION : atomic_t + atomic_cas() (compare-and-swap en une instruction).
 *   Set   depuis ISR/worker : atomic_set(&flag, 1)
 *   Clear depuis main       : atomic_cas(&flag, 1, 0)  → retourne true si
 *                             le flag était bien à 1 (et l'efface atomiquement)
 */
static atomic_t ui_rx_flash    = ATOMIC_INIT(0);
static atomic_t ui_tx_flash    = ATOMIC_INIT(0);
static atomic_t ui_alarm_evt   = ATOMIC_INIT(0);
/*
 * ui_alarm_dirty : levé quand CMD_TOGGLE_AL *ou* CMD_SET_ALARM arrive via UART.
 * Déclenche la mise à jour du bouton ET du label heure d'alarme dans ui_update.
 */
static atomic_t ui_alarm_dirty = ATOMIC_INIT(0);

K_MUTEX_DEFINE(uart_tx_mutex);

static int clk_h = 0, clk_m = 0, clk_s = 0;

/* ─── Widgets LVGL ───────────────────────────────────────────────────────── */
static lv_obj_t *clock_obj;
static lv_obj_t *lbl_time;
static lv_obj_t *lbl_date;
static lv_obj_t *led_rx_w, *led_tx_w;
static bool      led_rx_state, led_tx_state;
static lv_obj_t *btn_alarm;
static lv_obj_t *lbl_alarm_time;
static lv_obj_t *lbl_alarm_evt_w;
static lv_obj_t *lbl_rtc_status;

static uint32_t rx_flash_ts, tx_flash_ts;
#define LED_FLASH_MS 80U

/* ─── Helpers UART TX ────────────────────────────────────────────────────── */
static void send_byte(uint8_t b)
{
    k_mutex_lock(&uart_tx_mutex, K_FOREVER);
    uart_poll_out(uart_dev, b);
    k_mutex_unlock(&uart_tx_mutex);
    atomic_set(&ui_tx_flash, 1);
}

static void send_ack(void)
{
    send_byte(SOF_BYTE); send_byte(ACK_BYTE);
    send_byte(0x00);     send_byte(ACK_BYTE);
}

static void send_nack(void)
{
    send_byte(SOF_BYTE); send_byte(NACK_BYTE);
    send_byte(0x00);     send_byte(NACK_BYTE);
}

static void send_nack_err(uint8_t e)
{
    uint8_t crc = NACK_BYTE ^ 0x01 ^ e;
    send_byte(SOF_BYTE); send_byte(NACK_BYTE);
    send_byte(0x01); send_byte(e); send_byte(crc);
}

static void force_valid_date(struct rtc_time *tm)
{
    tm->tm_sec   = 0;
    tm->tm_min   = 0;
    tm->tm_hour  = 0;
    tm->tm_mday  = 1;
    tm->tm_mon   = 0;
    tm->tm_year  = 126; /* 2026 */
    tm->tm_wday  = 0;
    tm->tm_yday  = 0;
    tm->tm_isdst = -1;
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  Traitement des commandes UART
 *  Toutes les lectures/écritures passent par rtc_get_virtual / rtc_set_virtual
 *  → compatibilité totale avec le programme Python, RTC branché ou non
 * ══════════════════════════════════════════════════════════════════════════ */
static void process_command(void)
{
    struct rtc_time tm;
    memset(&tm, 0, sizeof(tm));
    uint8_t crc;
    int err;

    switch (rx_cmd) {

    /* ── SET TIME (sec, min, hour) ────────────────────────────────── */
    case CMD_SET_TIME:
        if (rx_len != 3) break;
        /* On lit d'abord pour conserver la date existante */
        if (rtc_get_virtual(&tm) != 0) force_valid_date(&tm);
        tm.tm_sec  = rx_payload[0];
        tm.tm_min  = rx_payload[1];
        tm.tm_hour = rx_payload[2];
        err = rtc_set_virtual(&tm);
        (err == 0) ? send_ack() : send_nack_err((uint8_t)(-err));
        break;

    /* ── SET DATE (day, month, year_2digit) ───────────────────────── */
    case CMD_SET_DATE:
        if (rx_len != 3) break;
        if (rtc_get_virtual(&tm) != 0) { force_valid_date(&tm); }
        tm.tm_mday = rx_payload[0];
        tm.tm_mon  = rx_payload[1] - 1;
        tm.tm_year = rx_payload[2] + 100; /* année sur 2 chiffres → offset 100 */
        err = rtc_set_virtual(&tm);
        (err == 0) ? send_ack() : send_nack_err((uint8_t)(-err));
        break;

    /* ── SET ALL (sec, min, hour, day, month, year_2digit) ────────── */
    case CMD_SET_ALL:
        if (rx_len != 6) break;
        tm.tm_sec  = rx_payload[0];
        tm.tm_min  = rx_payload[1];
        tm.tm_hour = rx_payload[2];
        tm.tm_mday = rx_payload[3];
        tm.tm_mon  = rx_payload[4] - 1;
        tm.tm_year = rx_payload[5] + 100;
        tm.tm_isdst = -1;
        err = rtc_set_virtual(&tm);
        (err == 0) ? send_ack() : send_nack_err((uint8_t)(-err));
        break;

    /* ── SET ALARM (sec, min, hour) ───────────────────────────────── */
    case CMD_SET_ALARM:
        if (rx_len != 3) break;
        k_mutex_lock(&alarm_mutex, K_FOREVER);
        al_sec  = rx_payload[0];
        al_min  = rx_payload[1];
        al_hour = rx_payload[2];
        k_mutex_unlock(&alarm_mutex);
        /*
         * FIX : on lève aussi ui_alarm_dirty ici.
         * Avant ce correctif, CMD_SET_ALARM depuis Python mettait à jour
         * al_hour/min/sec mais le label lbl_alarm_time sur l'écran restait
         * figé à l'ancienne valeur jusqu'au prochain appui sur le bouton.
         */
        atomic_set(&ui_alarm_dirty, 1);
        send_ack();
        break;

    /* ── TOGGLE ALARM (0=off, 1=on) ───────────────────────────────── */
    case CMD_TOGGLE_AL:
        if (rx_len != 1) break;
        k_mutex_lock(&alarm_mutex, K_FOREVER);
        al_on = rx_payload[0];
        k_mutex_unlock(&alarm_mutex);
        atomic_set(&ui_alarm_dirty, 1);
        send_ack();
        break;

    /* ── GET TIME ─────────────────────────────────────────────────── */
    case CMD_GET_TIME:
        if (rtc_get_virtual(&tm) != 0) { tm.tm_sec = 0; tm.tm_min = 0; tm.tm_hour = 0; }
        crc = CMD_GET_TIME ^ 0x03 ^ tm.tm_sec ^ tm.tm_min ^ tm.tm_hour;
        send_byte(SOF_BYTE); send_byte(CMD_GET_TIME); send_byte(0x03);
        send_byte(tm.tm_sec); send_byte(tm.tm_min); send_byte(tm.tm_hour);
        send_byte(crc);
        break;

    /* ── GET DATE ─────────────────────────────────────────────────── */
    case CMD_GET_DATE:
        if (rtc_get_virtual(&tm) != 0) force_valid_date(&tm);
        {
            uint8_t d  = tm.tm_mday;
            uint8_t mo = tm.tm_mon  + 1;
            uint8_t y  = tm.tm_year - 100;
            crc = CMD_GET_DATE ^ 0x03 ^ d ^ mo ^ y;
            send_byte(SOF_BYTE); send_byte(CMD_GET_DATE); send_byte(0x03);
            send_byte(d); send_byte(mo); send_byte(y); send_byte(crc);
        }
        break;

    /* ── GET ALL ──────────────────────────────────────────────────── */
    case CMD_GET_ALL:
        if (rtc_get_virtual(&tm) != 0) { tm.tm_sec = 0; force_valid_date(&tm); }
        {
            uint8_t y2 = tm.tm_year - 100;
            uint8_t m2 = tm.tm_mon  + 1;
            crc = CMD_GET_ALL ^ 0x06
                ^ tm.tm_sec ^ tm.tm_min ^ tm.tm_hour
                ^ tm.tm_mday ^ m2 ^ y2;
            send_byte(SOF_BYTE); send_byte(CMD_GET_ALL); send_byte(0x06);
            send_byte(tm.tm_sec); send_byte(tm.tm_min); send_byte(tm.tm_hour);
            send_byte(tm.tm_mday); send_byte(m2); send_byte(y2); send_byte(crc);
        }
        break;

    /* ── GET ALARM ────────────────────────────────────────────────── */
    case CMD_GET_ALARM:
        crc = CMD_GET_ALARM ^ 0x03 ^ al_sec ^ al_min ^ al_hour;
        send_byte(SOF_BYTE); send_byte(CMD_GET_ALARM); send_byte(0x03);
        send_byte(al_sec); send_byte(al_min); send_byte(al_hour); send_byte(crc);
        break;

    /* ── GET STATUS : bit0=alarme on/off, bit1=RTC virtuel actif ──── */
    case CMD_GET_STATUS:
        {
            k_mutex_lock(&alarm_mutex, K_FOREVER);
            uint8_t local_on = al_on;
            k_mutex_unlock(&alarm_mutex);
            uint8_t status = local_on | (rtc_available ? 0x00 : 0x02);
            crc = CMD_GET_STATUS ^ 0x01 ^ status;
            send_byte(SOF_BYTE); send_byte(CMD_GET_STATUS); send_byte(0x01);
            send_byte(status); send_byte(crc);
        }
        break;

    /* ── GET BAUD ─────────────────────────────────────────────────── */
    case CMD_GET_BAUD:
        crc = CMD_GET_BAUD ^ 0x01 ^ 0x01;
        send_byte(SOF_BYTE); send_byte(CMD_GET_BAUD); send_byte(0x01);
        send_byte(0x01); send_byte(crc);
        break;

    /* ── SET BAUD ─────────────────────────────────────────────────── */
    case CMD_SET_BAUD:
        if (rx_len == 1) send_ack();
        break;
    }
}

/* ─── ISR UART ───────────────────────────────────────────────────────────── */
static void process_uart_rx(uint8_t byte)
{
    atomic_set(&ui_rx_flash, 1);
    switch (rx_state) {
    case IDLE:     if (byte == SOF_BYTE) rx_state = READ_CMD; break;
    case READ_CMD: rx_cmd = byte; calc_crc = byte; rx_state = READ_LEN; break;
    case READ_LEN:
        rx_len = byte; calc_crc ^= byte; rx_payload_cnt = 0;
        rx_state = (rx_len == 0) ? READ_CRC : READ_PAYLOAD;
        break;
    case READ_PAYLOAD:
        if (rx_payload_cnt < sizeof(rx_payload)) rx_payload[rx_payload_cnt] = byte;
        rx_payload_cnt++; calc_crc ^= byte;
        if (rx_payload_cnt >= rx_len) rx_state = READ_CRC;
        break;
    case READ_CRC:
        if (byte == calc_crc) k_sem_give(&cmd_sem);
        else                  send_nack();
        rx_state = IDLE;
        break;
    }
}

static void uart_cb(const struct device *dev, void *user_data)
{
    uint8_t byte;
    if (!uart_irq_update(dev)) return;
    if (uart_irq_rx_ready(dev))
        while (uart_fifo_read(dev, &byte, 1) == 1)
            process_uart_rx(byte);
}

/* ─── Thread worker : tick horloge + vérification alarme ────────────────── */
#define WORKER_STACK_SZ 1536
K_THREAD_STACK_DEFINE(worker_stack, WORKER_STACK_SZ);
static struct k_thread worker_tid;

static void worker_fn(void *a, void *b, void *c)
{
    struct rtc_time tm;
    /*
     * DEUX timers separes :
     *   last_tick : cadence du sw_clock_tick() (incremente sw_clock)
     *   last_read : cadence de lecture RTC -> mise a jour UI
     *
     * ANCIEN BUG : un seul last_rtc partage pour les deux.
     * sw_clock_tick() mettait last_rtc = now_ms, donc la condition de
     * lecture etait immediatement fausse -> ui_dirty jamais leve ->
     * horloge figee a 00:00:00 au demarrage.
     */
    uint64_t last_tick  = 0;
    uint64_t last_read  = 0;
    uint64_t last_alarm = 0;

    LOG_INF("Worker started - rtc_available=%d", rtc_available);

    while (1) {
        if (k_sem_take(&cmd_sem, K_MSEC(50)) == 0)
            process_command();

        uint64_t now_ms = k_uptime_get();

        /* Tick sw_clock chaque seconde (uniquement si RTC absent) */
        if (!rtc_available && (now_ms - last_tick) >= 1000U) {
            last_tick = now_ms;
            sw_clock_tick();
        }

        /* Lecture heure -> UI via k_msgq (pas de torn read possible) */
        if ((now_ms - last_read) >= 1000U) {
            last_read = now_ms;
            if (rtc_get_virtual(&tm) == 0) {
                struct ui_time_msg msg = {
                    .h    = tm.tm_hour,
                    .m    = tm.tm_min,
                    .s    = tm.tm_sec,
                    .day  = tm.tm_mday,
                    .mon  = tm.tm_mon  + 1,
                    .year = tm.tm_year - 100,
                };
                /* K_NO_WAIT : si la queue est pleine (main en retard),
                 * on purge l'ancien message et on met le nouveau */
                if (k_msgq_put(&ui_time_q, &msg, K_NO_WAIT) != 0) {
                    k_msgq_purge(&ui_time_q);
                    k_msgq_put(&ui_time_q, &msg, K_NO_WAIT);
                }
            }
        }

        /* Vérification alarme toutes les 500 ms — lecture sous mutex */
        uint8_t local_on, local_hour, local_min, local_sec;
        k_mutex_lock(&alarm_mutex, K_FOREVER);
        local_on   = al_on;
        local_hour = al_hour;
        local_min  = al_min;
        local_sec  = al_sec;
        k_mutex_unlock(&alarm_mutex);

        if (local_on && (now_ms - last_alarm) >= 500U) {
            last_alarm = now_ms;
            if (rtc_get_virtual(&tm) == 0) {
                if (tm.tm_hour == local_hour &&
                    tm.tm_min  == local_min  &&
                    tm.tm_sec  == local_sec) {
                    if (!alarm_already_triggered) {
                        send_byte(SOF_BYTE);
                        send_byte(CMD_ALARM_EVT);
                        send_byte(0x00);
                        send_byte(CMD_ALARM_EVT ^ 0x00);
                        alarm_already_triggered = true;
                        atomic_set(&ui_alarm_evt, 1);
                        LOG_INF("Alarm triggered!");
                    }
                } else {
                    alarm_already_triggered = false;
                }
            }
        }
    }
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  Dessin horloge analogique LVGL 9
 *  - lv_draw_line : p1/p2 dans le descripteur (pas en arguments)
 *  - M_PI défini manuellement
 * ══════════════════════════════════════════════════════════════════════════ */
static void draw_hand(lv_layer_t *layer,
                      int32_t cx, int32_t cy,
                      float angle_deg, int32_t length,
                      int32_t width, lv_color_t color)
{
    float rad = (angle_deg - 90.0f) * (float)M_PI / 180.0f;

    lv_draw_line_dsc_t dsc;
    lv_draw_line_dsc_init(&dsc);
    dsc.color       = color;
    dsc.width       = (lv_coord_t)width;
    dsc.round_start = 1;
    dsc.round_end   = 1;
    dsc.p1.x = (lv_value_precise_t)cx;
    dsc.p1.y = (lv_value_precise_t)cy;
    dsc.p2.x = (lv_value_precise_t)(cx + (int32_t)(length * cosf(rad)));
    dsc.p2.y = (lv_value_precise_t)(cy + (int32_t)(length * sinf(rad)));

    lv_draw_line(layer, &dsc);
}

static void clock_draw_cb(lv_event_t *e)
{
    lv_layer_t *layer = lv_event_get_layer(e);
    lv_obj_t   *obj   = lv_event_get_target(e);

    lv_area_t coords;
    lv_obj_get_coords(obj, &coords);

    int32_t cx = (coords.x1 + coords.x2) / 2;
    int32_t cy = (coords.y1 + coords.y2) / 2;
    int32_t r  = (coords.x2 - coords.x1) / 2 - 4;

    /* Graduations */
    for (int i = 0; i < 60; i++) {
        float ang   = (i * 6.0f - 90.0f) * (float)M_PI / 180.0f;
        bool  major = (i % 5 == 0);

        lv_draw_line_dsc_t tick;
        lv_draw_line_dsc_init(&tick);
        tick.color = major ? lv_color_hex(0xE6EDF3) : lv_color_hex(0x30363D);
        tick.width = major ? 2 : 1;
        tick.p1.x  = (lv_value_precise_t)(cx + (int32_t)((r - 2) * cosf(ang)));
        tick.p1.y  = (lv_value_precise_t)(cy + (int32_t)((r - 2) * sinf(ang)));
        tick.p2.x  = (lv_value_precise_t)(cx + (int32_t)((major ? r - 16 : r - 9) * cosf(ang)));
        tick.p2.y  = (lv_value_precise_t)(cy + (int32_t)((major ? r - 16 : r - 9) * sinf(ang)));
        lv_draw_line(layer, &tick);
    }

    /* Aiguilles */
    float h_ang = (float)(clk_h % 12) * 30.0f + (float)clk_m * 0.5f;
    draw_hand(layer, cx, cy, h_ang, r * 55 / 100, 5, lv_color_hex(0xE6EDF3));

    float m_ang = (float)clk_m * 6.0f + (float)clk_s * 0.1f;
    draw_hand(layer, cx, cy, m_ang, r * 78 / 100, 3, lv_color_hex(0x00D4AA));

    float s_ang = (float)clk_s * 6.0f;
    /* Trotteuse orange si RTC physique, grise si horloge virtuelle */
    lv_color_t sec_col = rtc_available ? lv_color_hex(0xFF6B35) : lv_color_hex(0x888888);
    draw_hand(layer, cx, cy, s_ang, r * 88 / 100, 1, sec_col);

    /* Pivot central */
    lv_draw_rect_dsc_t dot;
    lv_draw_rect_dsc_init(&dot);
    dot.bg_color = rtc_available ? lv_color_hex(0xFF6B35) : lv_color_hex(0x888888);
    dot.radius   = LV_RADIUS_CIRCLE;
    lv_area_t dot_area = { cx - 5, cy - 5, cx + 5, cy + 5 };
    lv_draw_rect(layer, &dot, &dot_area);
}

/* ─── Callback bouton alarme ─────────────────────────────────────────────── */
static void alarm_btn_event(lv_event_t *e)
{
    /* Lecture-modification-écriture de al_on sous mutex
     * (le worker peut lire al_on simultanément depuis la boucle alarme) */
    k_mutex_lock(&alarm_mutex, K_FOREVER);
    al_on = al_on ? 0 : 1;
    uint8_t local_on   = al_on;
    uint8_t local_hour = al_hour;
    uint8_t local_min  = al_min;
    uint8_t local_sec  = al_sec;
    k_mutex_unlock(&alarm_mutex);

    LOG_INF("Alarm toggled: %s", local_on ? "ON" : "OFF");

    uint8_t crc = CMD_TOGGLE_AL ^ 0x01 ^ local_on;
    send_byte(SOF_BYTE); send_byte(CMD_TOGGLE_AL);
    send_byte(0x01); send_byte(local_on); send_byte(crc);

    /* Mise à jour directe des widgets (on est dans le thread main/LVGL) */
    lv_obj_t *lbl = lv_obj_get_child(btn_alarm, 0);
    if (local_on) {
        lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0xFF6B35), LV_PART_MAIN);
        lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0xE05020), LV_STATE_PRESSED);
        lv_label_set_text(lbl, LV_SYMBOL_BELL "  ON ");
        lv_obj_set_style_text_color(lbl, lv_color_hex(0x0D1117), LV_PART_MAIN);
    } else {
        lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0x1E2633), LV_PART_MAIN);
        lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0x2A3344), LV_STATE_PRESSED);
        lv_label_set_text(lbl, LV_SYMBOL_BELL "  OFF");
        lv_obj_set_style_text_color(lbl, lv_color_hex(0x8B949E), LV_PART_MAIN);
    }
    lv_label_set_text_fmt(lbl_alarm_time, "%02d:%02d:%02d",
                          local_hour, local_min, local_sec);
}

/* ─── Construction interface LVGL ────────────────────────────────────────── */
static void ui_create(void)
{
    lv_obj_t *scr = lv_scr_act();
    lv_obj_set_style_bg_color(scr, lv_color_hex(0x0D1117), LV_PART_MAIN);

    /* ── Topbar 480x28 ───────────────────────────────────────────────── */
    lv_obj_t *topbar = lv_obj_create(scr);
    lv_obj_set_size(topbar, 480, 28);
    lv_obj_set_pos(topbar, 0, 0);
    lv_obj_set_style_bg_color(topbar, lv_color_hex(0x161B22), LV_PART_MAIN);
    lv_obj_set_style_border_width(topbar, 0, LV_PART_MAIN);
    lv_obj_set_style_radius(topbar, 0, LV_PART_MAIN);
    lv_obj_set_style_pad_all(topbar, 0, LV_PART_MAIN);
    lv_obj_clear_flag(topbar, LV_OBJ_FLAG_SCROLLABLE);

    lv_obj_t *lbl_title = lv_label_create(topbar);
    lv_label_set_text(lbl_title, "  " LV_SYMBOL_SETTINGS "  RTC  STM32F746G");
    lv_obj_set_style_text_color(lbl_title, lv_color_hex(0x00D4AA), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_title, &lv_font_montserrat_14, LV_PART_MAIN);
    lv_obj_align(lbl_title, LV_ALIGN_LEFT_MID, 0, 0);

    lv_obj_t *lbl_rx = lv_label_create(topbar);
    lv_label_set_text(lbl_rx, "RX");
    lv_obj_set_style_text_color(lbl_rx, lv_color_hex(0x8B949E), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_rx, &lv_font_montserrat_10, LV_PART_MAIN);
    lv_obj_align(lbl_rx, LV_ALIGN_RIGHT_MID, -96, 0);

    led_rx_w = lv_led_create(topbar);
    lv_led_set_color(led_rx_w, lv_color_hex(0x00FFCC));
    lv_obj_set_size(led_rx_w, 10, 10);
    lv_obj_align(led_rx_w, LV_ALIGN_RIGHT_MID, -74, 0);
    lv_led_off(led_rx_w);

    lv_obj_t *lbl_tx = lv_label_create(topbar);
    lv_label_set_text(lbl_tx, "TX");
    lv_obj_set_style_text_color(lbl_tx, lv_color_hex(0x8B949E), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_tx, &lv_font_montserrat_10, LV_PART_MAIN);
    lv_obj_align(lbl_tx, LV_ALIGN_RIGHT_MID, -52, 0);

    led_tx_w = lv_led_create(topbar);
    lv_led_set_color(led_tx_w, lv_color_hex(0xFF4500));
    lv_obj_set_size(led_tx_w, 10, 10);
    lv_obj_align(led_tx_w, LV_ALIGN_RIGHT_MID, -30, 0);
    lv_led_off(led_tx_w);

    /* ── Horloge analogique 240x244 ──────────────────────────────────── */
    clock_obj = lv_obj_create(scr);
    lv_obj_set_size(clock_obj, 240, 244);
    lv_obj_set_pos(clock_obj, 0, 28);
    lv_obj_set_style_bg_color(clock_obj, lv_color_hex(0x0D1117), LV_PART_MAIN);
    /*
     * Bordure teal si RTC physique, orange si horloge virtuelle
     * (sera mis à jour après init dans main)
     */
    lv_obj_set_style_border_color(clock_obj,
        rtc_available ? lv_color_hex(0x00D4AA) : lv_color_hex(0xFF6B35),
        LV_PART_MAIN);
    lv_obj_set_style_border_width(clock_obj, 2, LV_PART_MAIN);
    lv_obj_set_style_radius(clock_obj, LV_RADIUS_CIRCLE, LV_PART_MAIN);
    lv_obj_set_style_pad_all(clock_obj, 0, LV_PART_MAIN);
    lv_obj_clear_flag(clock_obj, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_add_event_cb(clock_obj, clock_draw_cb, LV_EVENT_DRAW_MAIN, NULL);

    /* ── Panneau droite 236x244 ──────────────────────────────────────── */
    lv_obj_t *panel = lv_obj_create(scr);
    lv_obj_set_size(panel, 236, 244);
    lv_obj_set_pos(panel, 244, 28);
    lv_obj_set_style_bg_color(panel, lv_color_hex(0x0D1117), LV_PART_MAIN);
    lv_obj_set_style_border_width(panel, 0, LV_PART_MAIN);
    lv_obj_set_style_radius(panel, 0, LV_PART_MAIN);
    lv_obj_set_style_pad_left(panel, 12, LV_PART_MAIN);
    lv_obj_set_style_pad_right(panel, 8, LV_PART_MAIN);
    lv_obj_set_style_pad_top(panel, 8, LV_PART_MAIN);
    lv_obj_clear_flag(panel, LV_OBJ_FLAG_SCROLLABLE);

    lbl_time = lv_label_create(panel);
    lv_label_set_text(lbl_time, "00:00:00");
    lv_obj_set_style_text_color(lbl_time, lv_color_hex(0x00D4AA), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_time, &lv_font_montserrat_32, LV_PART_MAIN);
    lv_obj_align(lbl_time, LV_ALIGN_TOP_MID, 0, 0);

    lbl_date = lv_label_create(panel);
    lv_label_set_text(lbl_date, "--/--/----");
    lv_obj_set_style_text_color(lbl_date, lv_color_hex(0x8B949E), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_date, &lv_font_montserrat_14, LV_PART_MAIN);
    lv_obj_align(lbl_date, LV_ALIGN_TOP_MID, 0, 44);

    /* Indicateur RTC physique ou virtuel */
    lbl_rtc_status = lv_label_create(panel);
    lv_label_set_text(lbl_rtc_status,
        rtc_available ? LV_SYMBOL_OK  " PCF8563 OK"
                      : LV_SYMBOL_WARNING " RTC virtuel");
    lv_obj_set_style_text_color(lbl_rtc_status,
        rtc_available ? lv_color_hex(0x00D4AA) : lv_color_hex(0xFF6B35),
        LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_rtc_status, &lv_font_montserrat_10, LV_PART_MAIN);
    lv_obj_align(lbl_rtc_status, LV_ALIGN_TOP_MID, 0, 62);

    lv_obj_t *sep = lv_obj_create(panel);
    lv_obj_set_size(sep, 210, 1);
    lv_obj_set_style_bg_color(sep, lv_color_hex(0x30363D), LV_PART_MAIN);
    lv_obj_set_style_border_width(sep, 0, LV_PART_MAIN);
    lv_obj_set_style_radius(sep, 0, LV_PART_MAIN);
    lv_obj_align(sep, LV_ALIGN_TOP_MID, 0, 76);

    lv_obj_t *lbl_ahdr = lv_label_create(panel);
    lv_label_set_text(lbl_ahdr, LV_SYMBOL_BELL "  ALARME");
    lv_obj_set_style_text_color(lbl_ahdr, lv_color_hex(0x8B949E), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_ahdr, &lv_font_montserrat_12, LV_PART_MAIN);
    lv_obj_align(lbl_ahdr, LV_ALIGN_TOP_MID, 0, 82);

    lbl_alarm_time = lv_label_create(panel);
    lv_label_set_text_fmt(lbl_alarm_time, "%02d:%02d:%02d", al_hour, al_min, al_sec);
    lv_obj_set_style_text_color(lbl_alarm_time, lv_color_hex(0xFF6B35), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_alarm_time, &lv_font_montserrat_20, LV_PART_MAIN);
    lv_obj_align(lbl_alarm_time, LV_ALIGN_TOP_MID, 0, 100);

    /* Bouton alarme — lv_button_create (LVGL 9) */
    btn_alarm = lv_button_create(panel);
    lv_obj_set_size(btn_alarm, 140, 38);
    lv_obj_align(btn_alarm, LV_ALIGN_TOP_MID, 0, 130);
    lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0x1E2633), LV_PART_MAIN);
    lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0x2A3344), LV_STATE_PRESSED);
    lv_obj_set_style_radius(btn_alarm, 8, LV_PART_MAIN);
    lv_obj_set_style_shadow_width(btn_alarm, 0, LV_PART_MAIN);
    lv_obj_add_event_cb(btn_alarm, alarm_btn_event, LV_EVENT_CLICKED, NULL);

    lv_obj_t *lbl_btn = lv_label_create(btn_alarm);
    lv_label_set_text(lbl_btn, LV_SYMBOL_BELL "  OFF");
    lv_obj_set_style_text_color(lbl_btn, lv_color_hex(0x8B949E), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_btn, &lv_font_montserrat_14, LV_PART_MAIN);
    lv_obj_center(lbl_btn);

    lbl_alarm_evt_w = lv_label_create(panel);
    lv_label_set_text(lbl_alarm_evt_w, "");
    lv_obj_set_style_text_color(lbl_alarm_evt_w, lv_color_hex(0xFF6B35), LV_PART_MAIN);
    lv_obj_set_style_text_font(lbl_alarm_evt_w, &lv_font_montserrat_12, LV_PART_MAIN);
    lv_obj_align(lbl_alarm_evt_w, LV_ALIGN_TOP_MID, 0, 180);
}

/* ─── Animation "secousse" alarme ────────────────────────────────────────── */
/*
 * Secoue l'horloge horizontalement via lv_anim (LVGL 9).
 * Amplitude : +/- 10 px, 8 aller-retours, 60 ms par demi-cycle.
 * En parallele : la bordure passe au rouge pendant la secousse.
 */
static void shake_exec_cb(void *obj, int32_t val)
{
    /* val oscille entre -10 et +10 via playback */
    lv_obj_set_x((lv_obj_t *)obj, val);
}

static void shake_ready_cb(lv_anim_t *a)
{
    /* Remet l'horloge a sa position d'origine et restaure la couleur */
    lv_obj_set_x(clock_obj, 0);
    lv_obj_set_style_border_color(clock_obj,
        rtc_available ? lv_color_hex(0x00D4AA) : lv_color_hex(0xFF6B35),
        LV_PART_MAIN);
}

static void trigger_alarm_shake(void)
{
    /* Bordure rouge pendant la secousse */
    lv_obj_set_style_border_color(clock_obj, lv_color_hex(0xFF0000), LV_PART_MAIN);

    lv_anim_t a;
    lv_anim_init(&a);
    lv_anim_set_var(&a, clock_obj);
    lv_anim_set_exec_cb(&a, shake_exec_cb);
    lv_anim_set_values(&a, -10, 10);
    lv_anim_set_duration(&a, 60);
    lv_anim_set_playback_duration(&a, 60);
    lv_anim_set_repeat_count(&a, 8);
    lv_anim_set_completed_cb(&a, shake_ready_cb);
    lv_anim_start(&a);
}


static uint32_t alarm_blink_end = 0;
static bool     alarm_blink_vis = false;

static void ui_update(void)
{
    uint32_t now = lv_tick_get();

    /* ── Heure/date depuis la message queue ────────────────────────────
     * k_msgq_get garantit qu'on lit une struct complète et cohérente.
     * Pas de torn read possible contrairement aux 6 volatiles précédents.
     */
    {
        struct ui_time_msg msg;
        if (k_msgq_get(&ui_time_q, &msg, K_NO_WAIT) == 0) {
            clk_h = msg.h; clk_m = msg.m; clk_s = msg.s;
            lv_obj_invalidate(clock_obj);
            char buf[20];
            snprintf(buf, sizeof(buf), "%02d:%02d:%02d", msg.h, msg.m, msg.s);
            lv_label_set_text(lbl_time, buf);
            snprintf(buf, sizeof(buf), "%02d/%02d/20%02d", msg.day, msg.mon, msg.year);
            lv_label_set_text(lbl_date, buf);
        }
    }

    /* ── LEDs RX/TX — atomic_cas : test ET clear en une opération ──────
     * Avant : if (ui_rx_flash) { ui_rx_flash = false; ... }
     *   → l'ISR peut re-lever le flag entre le test et le clear
     * Maintenant : atomic_cas(&flag, 1, 0) fait les deux atomiquement
     */
    if (atomic_cas(&ui_rx_flash, 1, 0)) {
        led_rx_state = true;
        lv_led_on(led_rx_w);
        rx_flash_ts  = now;
    } else if (led_rx_state && (now - rx_flash_ts) >= LED_FLASH_MS) {
        led_rx_state = false;
        lv_led_off(led_rx_w);
    }

    if (atomic_cas(&ui_tx_flash, 1, 0)) {
        led_tx_state = true;
        lv_led_on(led_tx_w);
        tx_flash_ts  = now;
    } else if (led_tx_state && (now - tx_flash_ts) >= LED_FLASH_MS) {
        led_tx_state = false;
        lv_led_off(led_tx_w);
    }

    /* ── Synchro bouton + heure alarme ─────────────────────────────────
     * Levé par le worker pour CMD_TOGGLE_AL ET CMD_SET_ALARM.
     * Correction du bug : avant, CMD_SET_ALARM ne levait pas ce flag
     * → le label heure d'alarme restait figé après un SET depuis Python.
     */
    if (atomic_cas(&ui_alarm_dirty, 1, 0)) {
        k_mutex_lock(&alarm_mutex, K_FOREVER);
        uint8_t local_on   = al_on;
        uint8_t local_hour = al_hour;
        uint8_t local_min  = al_min;
        uint8_t local_sec  = al_sec;
        k_mutex_unlock(&alarm_mutex);

        lv_obj_t *lbl = lv_obj_get_child(btn_alarm, 0);
        if (local_on) {
            lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0xFF6B35), LV_PART_MAIN);
            lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0xE05020), LV_STATE_PRESSED);
            lv_label_set_text(lbl, LV_SYMBOL_BELL "  ON ");
            lv_obj_set_style_text_color(lbl, lv_color_hex(0x0D1117), LV_PART_MAIN);
        } else {
            lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0x1E2633), LV_PART_MAIN);
            lv_obj_set_style_bg_color(btn_alarm, lv_color_hex(0x2A3344), LV_STATE_PRESSED);
            lv_label_set_text(lbl, LV_SYMBOL_BELL "  OFF");
            lv_obj_set_style_text_color(lbl, lv_color_hex(0x8B949E), LV_PART_MAIN);
        }
        lv_label_set_text_fmt(lbl_alarm_time, "%02d:%02d:%02d",
                              local_hour, local_min, local_sec);
    }

    if (atomic_cas(&ui_alarm_evt, 1, 0)) {
        alarm_blink_end = now + 3000U;
        alarm_blink_vis = true;
        lv_label_set_text(lbl_alarm_evt_w, "  " LV_SYMBOL_WARNING "  ALARME !");
        trigger_alarm_shake();
    }
    if (alarm_blink_end) {
        if (now < alarm_blink_end) {
            bool v = ((now / 400U) % 2U) == 0U;
            if (v != alarm_blink_vis) {
                alarm_blink_vis = v;
                lv_obj_set_style_text_color(lbl_alarm_evt_w,
                    v ? lv_color_hex(0xFF6B35) : lv_color_hex(0x0D1117),
                    LV_PART_MAIN);
            }
        } else {
            alarm_blink_end = 0;
            lv_label_set_text(lbl_alarm_evt_w, "");
        }
    }
}

/* ─── main ───────────────────────────────────────────────────────────────── */
int main(void)
{
    LOG_INF("=== RTC App starting ===");

    /* UART */
    if (device_is_ready(uart_dev)) {
        uart_irq_callback_user_data_set(uart_dev, uart_cb, NULL);
        uart_irq_rx_enable(uart_dev);
        LOG_INF("UART ready");
    } else {
        LOG_WRN("UART not ready");
    }

    /* RTC physique — NON FATAL */
    if (device_is_ready(rtc_dev)) {
        rtc_available = true;
        struct rtc_time tm;
        memset(&tm, 0, sizeof(tm));
        force_valid_date(&tm);
        rtc_set_time(rtc_dev, &tm);
        LOG_INF("RTC PCF8563 ready — hardware mode");
    } else {
        /* Initialise sw_clock à 00:00:00 01/01/2026 */
        force_valid_date(&sw_clock);
        LOG_WRN("RTC absent — virtual clock active (set via UART)");
    }

    /* Display — fatal */
    const struct device *display_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_display));
    if (!device_is_ready(display_dev)) {
        LOG_ERR("Display not ready — halting");
        return -2;
    }
    LOG_INF("Display ready");
    display_blanking_off(display_dev);

    ui_create();
    LOG_INF("UI created — RTC mode: %s",
            rtc_available ? "HARDWARE (PCF8563)" : "VIRTUAL (RAM)");

    k_thread_create(&worker_tid,
                    worker_stack, K_THREAD_STACK_SIZEOF(worker_stack),
                    worker_fn, NULL, NULL, NULL,
                    K_PRIO_PREEMPT(5), 0, K_NO_WAIT);
    k_thread_name_set(&worker_tid, "rtc_worker");

    while (1) {
        ui_update();
        lv_task_handler();
        k_sleep(K_MSEC(10));
    }

    return 0;
}
