import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import serial
import serial.tools.list_ports
import time
import datetime
import csv

# --- GESTION DU SON ---
try:
    import winsound
    HAS_SOUND = True
except ImportError:
    HAS_SOUND = False

def play_alarm_sound(target):
    if HAS_SOUND:
        if target == "FPGA":  winsound.Beep(1500, 800)
        elif target == "STM32": winsound.Beep(750, 800)

# --- CONSTANTES DU PROTOCOLE ---
SOF  = 0x55
ACK  = 0x08
NACK = 0x09

CMD_GET_ALL    = 0x01
CMD_SET_ALL    = 0x02
CMD_GET_ALARM  = 0x03
CMD_SET_ALARM  = 0x04
CMD_GET_BAUD   = 0x05
CMD_SET_BAUD   = 0x06
CMD_GET_STATUS = 0x07
CMD_ALARM_EVT  = 0x0A
CMD_TOGGLE_AL  = 0x0B
CMD_GET_TIME   = 0x11
CMD_SET_TIME   = 0x12
CMD_GET_DATE   = 0x13
CMD_SET_DATE   = 0x14

COMMANDS = {
    CMD_GET_ALL: "GET ALL", CMD_SET_ALL: "SET ALL",
    CMD_GET_ALARM: "GET ALARM", CMD_SET_ALARM: "SET ALARM",
    CMD_GET_BAUD: "GET BAUD RATE", CMD_SET_BAUD: "SET BAUD RATE",
    CMD_GET_STATUS: "GET STATUS", CMD_ALARM_EVT: "ALARM EVENT",
    CMD_TOGGLE_AL: "TOGGLE ALARM", CMD_GET_TIME: "GET TIME",
    CMD_SET_TIME: "SET TIME", CMD_GET_DATE: "GET DATE",
    CMD_SET_DATE: "SET DATE"
}

def calculate_crc(cmd, length, payload):
    crc = cmd ^ length
    for byte in payload:
        crc ^= byte
    return crc


class RTC_App:
    def __init__(self, root):
        self.root = root
        self.root.title("HW/SW Co-Design : FPGA vs STM32 - Data Logger Edition")
        self.root.geometry("1250x950")

        self.fpga_port  = None
        self.stm32_port = None
        self.hw_switch_local = False

        self.rx_buf_fpga  = bytearray()
        self.rx_buf_stm32 = bytearray()

        self.t_start    = time.time()
        self.t_last_req_fpga  = 0   # chrono latence FPGA independant
        self.t_last_req_stm32 = 0   # chrono latence STM32 independant
        self.lat_fpga   = None
        self.lat_stm32  = None
        self.drift_history = []
        self.full_log_data = []

        # Flags popup status
        self.force_status_popup       = False
        self.force_status_popup_stm32 = False   # NEW

        self.setup_gui()
        self.update_com_ports()

        self.root.after(50,  self.listen_fpga)
        self.root.after(50,  self.listen_stm32)
        self.root.after(500, self.auto_refresh_task)
        # Watchdog port : vérifie toutes les 2 s si les ports sont encore vivants
        self.root.after(2000, self.watchdog_ports)          # NEW

    # =========================================================
    # GUI
    # =========================================================
    def setup_gui(self):
        lcd_container = tk.Frame(self.root, bg="gray20")
        lcd_container.pack(fill="x", padx=10, pady=10)

        # FPGA
        frame_fpga_lcd = tk.Frame(lcd_container, bg="black", bd=5, relief="ridge")
        frame_fpga_lcd.pack(side="left", fill="both", expand=True, padx=5, pady=5)
        tk.Label(frame_fpga_lcd, text="📡 FPGA (Nexys A7)",
                 fg="lightgreen", bg="black", font=("Arial", 12, "bold")).pack(pady=5)
        self.lbl_time_f = tk.Label(frame_fpga_lcd, text="--:--:--",
                                   font=("Courier", 40, "bold"), fg="#00FF00", bg="black")
        self.lbl_time_f.pack()
        self.lbl_date_f = tk.Label(frame_fpga_lcd, text="--/--/----",
                                   font=("Courier", 20, "bold"), fg="#00AA00", bg="black")
        self.lbl_date_f.pack(pady=2)
        self.lbl_alarm_f = tk.Label(frame_fpga_lcd, text="🔔 Alarme: --:--:--",
                                    font=("Courier", 12), fg="#FF9900", bg="black")
        self.lbl_alarm_f.pack(pady=2)
        self.lbl_baud_f = tk.Label(frame_fpga_lcd, text="Baud Rate: INCONNU",
                                   font=("Arial", 10), fg="white", bg="black")
        self.lbl_baud_f.pack(anchor="se")

        # STM32
        frame_stm32_lcd = tk.Frame(lcd_container, bg="black", bd=5, relief="ridge")
        frame_stm32_lcd.pack(side="right", fill="both", expand=True, padx=5, pady=5)
        tk.Label(frame_stm32_lcd, text="⚙️ STM32 (Zephyr RTOS)",
                 fg="cyan", bg="black", font=("Arial", 12, "bold")).pack(pady=5)
        self.lbl_time_s = tk.Label(frame_stm32_lcd, text="--:--:--",
                                   font=("Courier", 40, "bold"), fg="#00FFFF", bg="black")
        self.lbl_time_s.pack()
        self.lbl_date_s = tk.Label(frame_stm32_lcd, text="--/--/----",
                                   font=("Courier", 20, "bold"), fg="#00AAAA", bg="black")
        self.lbl_date_s.pack(pady=2)
        self.lbl_alarm_s = tk.Label(frame_stm32_lcd, text="🔔 Alarme: --:--:--",
                                    font=("Courier", 12), fg="#FF9900", bg="black")
        self.lbl_alarm_s.pack(pady=2)
        # Indicateur RTC virtuel/physique (mis à jour par CMD_GET_STATUS STM32)
        self.lbl_rtc_mode_s = tk.Label(frame_stm32_lcd, text="",           # NEW
                                       font=("Arial", 9), fg="#FF9900", bg="black")
        self.lbl_rtc_mode_s.pack(pady=1)

        # --- CONNEXIONS ---
        conn_frame = tk.LabelFrame(self.root, text=" Connexions Matérielles (UART) ",
                                   padx=10, pady=5)
        conn_frame.pack(fill="x", padx=10, pady=5)

        tk.Label(conn_frame, text="FPGA COM :").grid(row=0, column=0, padx=5, pady=5)
        self.combo_fpga = ttk.Combobox(conn_frame, width=10)
        self.combo_fpga.grid(row=0, column=1, padx=5)
        self.btn_conn_fpga = tk.Button(conn_frame, text="Connecter FPGA",
                                       bg="lightgreen", command=self.toggle_fpga)
        self.btn_conn_fpga.grid(row=0, column=2, padx=10)
        self.lbl_st_fpga = tk.Label(conn_frame, text="Déconnecté", fg="red")
        self.lbl_st_fpga.grid(row=0, column=3, padx=10)

        tk.Label(conn_frame, text="STM32 COM :").grid(row=1, column=0, padx=5, pady=5)
        self.combo_stm32 = ttk.Combobox(conn_frame, width=10)
        self.combo_stm32.grid(row=1, column=1, padx=5)
        self.btn_conn_stm32 = tk.Button(conn_frame, text="Connecter STM32",
                                        bg="lightblue", command=self.toggle_stm32)
        self.btn_conn_stm32.grid(row=1, column=2, padx=10)
        self.lbl_st_stm32 = tk.Label(conn_frame, text="Déconnecté", fg="red")
        self.lbl_st_stm32.grid(row=1, column=3, padx=10)

        tk.Button(conn_frame, text="🔄 Rafraîchir les ports",
                  command=self.update_com_ports).grid(row=0, column=4, rowspan=2, padx=40)

        # --- COMMANDES + GRAPHIQUE ---
        master_cmd_frame = tk.Frame(self.root)
        master_cmd_frame.pack(fill="x", padx=10, pady=5)

        cmd_frame = tk.LabelFrame(master_cmd_frame,
                                  text=" Panneau de Contrôle Master ", padx=10, pady=10)
        cmd_frame.pack(side="left", fill="both", expand=True)

        row0 = tk.Frame(cmd_frame); row0.pack(fill="x", pady=5)
        tk.Button(row0, text="GET TIME",  width=12,
                  command=lambda: (self.send_fpga(CMD_GET_TIME, []),
                                   self.send_stm32(CMD_GET_TIME, []))).pack(side="left", padx=5)
        tk.Button(row0, text="GET DATE",  width=12,
                  command=lambda: (self.send_fpga(CMD_GET_DATE, []),
                                   self.send_stm32(CMD_GET_DATE, []))).pack(side="left", padx=5)
        tk.Button(row0, text="GET ALARM", width=12,
                  command=lambda: (self.send_fpga(CMD_GET_ALARM, []),
                                   self.send_stm32(CMD_GET_ALARM, []))).pack(side="left", padx=5)
        tk.Button(row0, text="GET ALL",   width=12, bg="#d9ead3",
                  command=lambda: (self.send_fpga(CMD_GET_ALL, []),
                                   self.send_stm32(CMD_GET_ALL, []))).pack(side="left", padx=5)
        tk.Button(row0, text="STATUS FPGA",  width=14, bg="#fff2cc",
                  command=lambda: self.send_fpga(CMD_GET_STATUS, [],
                                                  manual=True)).pack(side="left", padx=5)
        # NEW — bouton GET STATUS STM32
        tk.Button(row0, text="STATUS STM32", width=14, bg="#cce5ff",
                  command=self.get_status_stm32).pack(side="left", padx=5)

        row1 = tk.Frame(cmd_frame); row1.pack(fill="x", pady=5)
        tk.Button(row1, text="🔔 ALARME (ON)",  width=15, bg="#d9ead3", fg="darkgreen",
                  command=lambda: (self.send_fpga(CMD_TOGGLE_AL, [0x01]),
                                   self.send_stm32(CMD_TOGGLE_AL, [0x01]))).pack(side="left", padx=5)
        tk.Button(row1, text="🔕 ALARME (OFF)", width=15, bg="#f4cccc", fg="darkred",
                  command=lambda: (self.send_fpga(CMD_TOGGLE_AL, [0x00]),
                                   self.send_stm32(CMD_TOGGLE_AL, [0x00]))).pack(side="left", padx=5)
        tk.Label(row1, text=" | ").pack(side="left")
        tk.Button(row1, text="GET BAUD", width=10,
                  command=lambda: (self.send_fpga(CMD_GET_BAUD, []),
                                   self.send_stm32(CMD_GET_BAUD, []))).pack(side="left", padx=5)
        self.combo_baud = ttk.Combobox(row1, values=["115200", "9600"], width=8)
        self.combo_baud.current(0)
        self.combo_baud.pack(side="left", padx=5)
        tk.Button(row1, text="SET BAUD", bg="#e4d7f5",
                  command=self.set_baud_rate).pack(side="left", padx=5)

        set_frame = tk.Frame(cmd_frame); set_frame.pack(fill="x", pady=10)

        tk.Label(set_frame, text="Heure :").grid(row=0, column=0, sticky="e", pady=2)
        self.ent_hr  = tk.Entry(set_frame, width=3); self.ent_hr.insert(0, "12")
        self.ent_hr.grid(row=0, column=1)
        self.ent_min = tk.Entry(set_frame, width=3); self.ent_min.insert(0, "30")
        self.ent_min.grid(row=0, column=2)
        self.ent_sec = tk.Entry(set_frame, width=3); self.ent_sec.insert(0, "00")
        self.ent_sec.grid(row=0, column=3, padx=(0, 10))
        tk.Button(set_frame, text="SET FPGA",  bg="lightgreen",
                  command=lambda: self.set_time("FPGA")).grid(row=0, column=4, padx=2)
        tk.Button(set_frame, text="SET STM32", bg="cyan",
                  command=lambda: self.set_time("STM32")).grid(row=0, column=5, padx=2)

        tk.Label(set_frame, text="Date :").grid(row=1, column=0, sticky="e", pady=2)
        self.ent_day   = tk.Entry(set_frame, width=3); self.ent_day.insert(0, "25")
        self.ent_day.grid(row=1, column=1)
        self.ent_month = tk.Entry(set_frame, width=3); self.ent_month.insert(0, "12")
        self.ent_month.grid(row=1, column=2)
        self.ent_year  = tk.Entry(set_frame, width=3); self.ent_year.insert(0, "26")
        self.ent_year.grid(row=1, column=3, padx=(0, 10))
        tk.Button(set_frame, text="SET FPGA",  bg="lightgreen",
                  command=lambda: self.set_date("FPGA")).grid(row=1, column=4, padx=2)
        tk.Button(set_frame, text="SET STM32", bg="cyan",
                  command=lambda: self.set_date("STM32")).grid(row=1, column=5, padx=2)

        tk.Label(set_frame, text="Alarme :").grid(row=2, column=0, sticky="e", pady=2)
        self.ent_al_hr  = tk.Entry(set_frame, width=3); self.ent_al_hr.insert(0, "07")
        self.ent_al_hr.grid(row=2, column=1)
        self.ent_al_min = tk.Entry(set_frame, width=3); self.ent_al_min.insert(0, "00")
        self.ent_al_min.grid(row=2, column=2)
        self.ent_al_sec = tk.Entry(set_frame, width=3); self.ent_al_sec.insert(0, "00")
        self.ent_al_sec.grid(row=2, column=3, padx=(0, 10))
        tk.Button(set_frame, text="SET FPGA",  bg="lightgreen",
                  command=lambda: self.set_alarm("FPGA")).grid(row=2, column=4, padx=2)
        tk.Button(set_frame, text="SET STM32", bg="cyan",
                  command=lambda: self.set_alarm("STM32")).grid(row=2, column=5, padx=2)

        tk.Label(set_frame, text="SET ALL :",
                 font=("Arial", 9, "bold")).grid(row=3, column=0, sticky="e", pady=5)
        tk.Label(set_frame, text="(Heure + Date)",
                 fg="gray").grid(row=3, column=1, columnspan=3, sticky="w")
        tk.Button(set_frame, text="SET TOUT FPGA",  bg="#a2d149",
                  command=lambda: self.set_all("FPGA")).grid(row=3, column=4, padx=2)
        tk.Button(set_frame, text="SET TOUT STM32", bg="#009999", fg="white",
                  command=lambda: self.set_all("STM32")).grid(row=3, column=5, padx=2)
        tk.Button(set_frame, text="SET AUX DEUX (SIMULTANÉ)",
                  bg="#ffdb58", font=("Arial", 9, "bold"),
                  command=lambda: self.set_all("BOTH")).grid(row=3, column=6, padx=20)

        pro_frame = tk.Frame(cmd_frame); pro_frame.pack(fill="x", pady=5)
        tk.Button(pro_frame, text="⚙️ Sync Heure PC -> FPGA & STM32",
                  bg="#ffdb58", font=("Arial", 10, "bold"),
                  command=self.sync_pc_time).pack(side="left", padx=10)
        self.var_autorefresh = tk.BooleanVar(value=False)
        tk.Checkbutton(pro_frame,
                       text="Auto-Refresh LCD (Polling & Dérive Temporelle)",
                       variable=self.var_autorefresh,
                       fg="blue", font=("Arial", 10, "bold")).pack(side="left", padx=20)

        # Graphique
        graph_frame = tk.LabelFrame(master_cmd_frame,
                                    text=" 📉 Dérive / Latence (Zephyr vs VHDL) ",
                                    padx=5, pady=5)
        graph_frame.pack(side="right", fill="y", padx=5)

        self.canvas = tk.Canvas(graph_frame, width=320, height=190, bg="#111")
        self.canvas.pack()
        self.canvas.create_text(160, 95, text="En attente de l'Auto-Refresh...",
                                fill="gray", tags="wait")
        tk.Button(graph_frame,
                  text="💾 Exporter les Mesures (CSV / Excel)",
                  bg="#2a2a2a", fg="#00FF00", font=("Arial", 10, "bold"),
                  command=self.export_csv).pack(fill="x", pady=(5, 0))

        # Terminal
        log_frame = tk.LabelFrame(self.root,
                                  text=" Moniteur Série Unifié (Rx/Tx) ",
                                  padx=10, pady=5)
        log_frame.pack(fill="both", expand=True, padx=10, pady=5)
        tk.Button(log_frame, text="🧹 Effacer logs",
                  command=self.clear_logs).pack(anchor="ne", pady=2)
        self.txt_log = tk.Text(log_frame, height=12, state="disabled",
                               bg="#1e1e1e", font=("Consolas", 10))
        self.txt_log.pack(fill="both", expand=True)
        self.txt_log.tag_configure("fpga_rx",  foreground="#00ff00")
        self.txt_log.tag_configure("fpga_tx",  foreground="#a2d149")
        self.txt_log.tag_configure("stm32_rx", foreground="#00ffff")
        self.txt_log.tag_configure("stm32_tx", foreground="#009999")
        self.txt_log.tag_configure("sys",      foreground="#ffffff")
        self.txt_log.tag_configure("alert",    foreground="#ff3333")
        self.txt_log.tag_configure("warn",     foreground="#ffaa00")   # NEW

    # =========================================================
    # WATCHDOG PORTS — NEW
    # Vérifie toutes les 2 s que les ports série répondent encore.
    # Cas couverts :
    #   • Câble débranché physiquement
    #   • Port masqué par la VM (Windows perd les droits → OSError/PermissionError)
    #   • Device supprimé par le gestionnaire de périphériques
    # =========================================================
    def watchdog_ports(self):
        """
        Tente un CTS read (0 octet) sur chaque port ouvert.
        Une OSError / SerialException indique que Windows n'a plus accès
        au port (typiquement parce que la VM l'a pris).
        """
        if self.fpga_port and self.fpga_port.is_open:
            try:
                # getCTS() lève une exception si le port n'est plus accessible
                self.fpga_port.getCTS()
            except (serial.SerialException, OSError) as e:
                self.log(f"[WATCHDOG] ⚠️  Port FPGA perdu : {e}", "warn")
                self._force_disconnect_fpga()

        if self.stm32_port and self.stm32_port.is_open:
            try:
                self.stm32_port.getCTS()
            except (serial.SerialException, OSError) as e:
                self.log(f"[WATCHDOG] ⚠️  Port STM32 perdu : {e}", "warn")
                self._force_disconnect_stm32()

        self.root.after(2000, self.watchdog_ports)

    def _force_disconnect_fpga(self):
        """Déconnexion FPGA forcée (port perdu / masqué par VM)."""
        port_name = self.combo_fpga.get()
        try:
            self.fpga_port.close()
        except Exception:
            pass
        self.fpga_port = None
        self.var_autorefresh.set(False)
        self.btn_conn_fpga.config(text="Connecter FPGA", bg="lightgreen")
        self.lbl_st_fpga.config(text="⚠️ Port perdu !", fg="orange")
        # Tente une reconnexion auto toutes les 3 s
        self.root.after(3000, lambda: self._try_reconnect_fpga(port_name))

    def _try_reconnect_fpga(self, port_name):
        """Tente de rouvrir le port FPGA s'il est de nouveau disponible."""
        if self.fpga_port and self.fpga_port.is_open:
            return  # déjà reconnecté manuellement
        ports = [p.device for p in serial.tools.list_ports.comports()]
        if port_name in ports:
            try:
                self.fpga_port = serial.Serial(port_name, 115200, timeout=0.1)
                self.btn_conn_fpga.config(text="Déconnecter", bg="salmon")
                self.lbl_st_fpga.config(text=f"✅ Reconnecté ({port_name})", fg="green")
                self.log(f"[WATCHDOG] ✅ FPGA reconnecté sur {port_name}", "sys")
                return
            except Exception:
                pass
        # Port toujours absent, on réessaie dans 3 s
        self.lbl_st_fpga.config(text=f"⏳ Attente {port_name}...", fg="orange")
        self.root.after(3000, lambda: self._try_reconnect_fpga(port_name))

    def _force_disconnect_stm32(self):
        """Déconnexion STM32 forcée (port perdu / masqué par VM)."""
        port_name = self.combo_stm32.get()
        try:
            self.stm32_port.close()
        except Exception:
            pass
        self.stm32_port = None
        self.btn_conn_stm32.config(text="Connecter STM32", bg="lightblue")
        self.lbl_st_stm32.config(text="⚠️ Port perdu !", fg="orange")
        self.root.after(3000, lambda: self._try_reconnect_stm32(port_name))

    def _try_reconnect_stm32(self, port_name):
        """Tente de rouvrir le port STM32 s'il est de nouveau disponible."""
        if self.stm32_port and self.stm32_port.is_open:
            return
        ports = [p.device for p in serial.tools.list_ports.comports()]
        if port_name in ports:
            try:
                self.stm32_port = serial.Serial(port_name, 115200, timeout=0.1)
                self.stm32_port.reset_input_buffer()
                self.btn_conn_stm32.config(text="Déconnecter", bg="salmon")
                self.lbl_st_stm32.config(text=f"✅ Reconnecté ({port_name})", fg="green")
                self.log(f"[WATCHDOG] ✅ STM32 reconnecté sur {port_name}", "sys")
                return
            except Exception:
                pass
        self.lbl_st_stm32.config(text=f"⏳ Attente {port_name}...", fg="orange")
        self.root.after(3000, lambda: self._try_reconnect_stm32(port_name))

    # =========================================================
    # GET STATUS STM32 — NEW
    # =========================================================
    def get_status_stm32(self):
        self.force_status_popup_stm32 = True
        self.send_stm32(CMD_GET_STATUS, [])

    def show_status_window_stm32(self, status_byte):
        """
        Décode le status byte Zephyr :
          bit 0 : alarme ON/OFF
          bit 1 : 0 = PCF8563 physique | 1 = horloge virtuelle RAM
        """
        alarm_on    = bool(status_byte & 0x01)
        virtual_rtc = bool(status_byte & 0x02)

        win = tk.Toplevel(self.root)
        win.title("Statut STM32 Zephyr")
        win.geometry("320x240")
        win.configure(bg="#1e1e1e")
        win.resizable(False, False)

        tk.Label(win, text="⚙️  STATUT STM32 — ZEPHYR RTOS",
                 font=("Arial", 12, "bold"), fg="cyan",
                 bg="#1e1e1e").pack(pady=10)

        tk.Label(win, text="🔔 État Alarme :",
                 fg="white", bg="#1e1e1e").pack()
        tk.Label(win,
                 text="ON" if alarm_on else "OFF",
                 fg="#00ff00" if alarm_on else "#ff4444",
                 font=("Arial", 14, "bold"),
                 bg="#1e1e1e").pack()

        tk.Label(win, text="🕐 Source Horloge :",
                 fg="white", bg="#1e1e1e").pack(pady=(10, 0))
        if virtual_rtc:
            tk.Label(win,
                     text="⚠️  RTC VIRTUEL (RAM)\nPCF8563 non branché",
                     fg="#FF9900", font=("Arial", 11, "bold"),
                     bg="#1e1e1e", justify="center").pack()
        else:
            tk.Label(win,
                     text="✅  RTC PHYSIQUE (PCF8563)\nI²C OK",
                     fg="#00ff00", font=("Arial", 11, "bold"),
                     bg="#1e1e1e", justify="center").pack()

        tk.Label(win,
                 text=f"(status raw = 0x{status_byte:02X})",
                 fg="#555555", font=("Arial", 8),
                 bg="#1e1e1e").pack(pady=(6, 0))

        tk.Button(win, text="Fermer", command=win.destroy,
                  bg="#333", fg="white").pack(pady=10)

    # =========================================================
    # EXPORT CSV
    # =========================================================
    def export_csv(self):
        if not self.full_log_data:
            messagebox.showwarning("Aucune donnée",
                                   "Activez l'Auto-Refresh pour collecter des mesures.")
            return
        filepath = filedialog.asksaveasfilename(
            defaultextension=".csv",
            filetypes=[("Fichier CSV Excel", "*.csv")],
            title="Sauvegarder les mesures de latence",
            initialfile="Report_Drift_FPGA_STM32.csv"
        )
        if filepath:
            try:
                with open(filepath, mode='w', newline='') as f:
                    writer = csv.writer(f, delimiter=';')
                    writer.writerow(["Temps Ecoule (s)", "Latence FPGA (ms)",
                                     "Latence STM32 (ms)", "Surcout RTOS (ms)"])
                    for row in self.full_log_data:
                        writer.writerow([str(v).replace('.', ',') for v in row])
                messagebox.showinfo("Succès !", "Export CSV réussi !")
            except Exception as e:
                messagebox.showerror("Erreur", f"Impossible d'enregistrer :\n{e}")

    def reset_drift_graph(self):
        self.drift_history.clear()
        self.full_log_data.clear()
        self.t_start = time.time()
        self.canvas.delete("all")
        self.canvas.create_text(160, 95,
                                text="Synchronisation... Reprise des mesures",
                                fill="yellow", tags="wait")

    def check_and_update_graph(self):
        if self.lat_fpga is not None and self.lat_stm32 is not None:
            delta_ms = self.lat_stm32 - self.lat_fpga
            self.drift_history.append(delta_ms)
            if len(self.drift_history) > 40:
                self.drift_history.pop(0)

            elapsed = round(time.time() - self.t_start, 3)
            self.full_log_data.append([elapsed,
                                       round(self.lat_fpga, 2),
                                       round(self.lat_stm32, 2),
                                       round(delta_ms, 2)])

            self.canvas.delete("all")
            w, h = 320, 190
            max_y = max(max(self.drift_history), 20)
            min_y = min(min(self.drift_history), 0)

            def get_y(val):
                return h - 20 - ((val - min_y) / max(max_y - min_y, 1)) * (h - 40)

            self.canvas.create_line(0, h - 20, w, h - 20, fill="gray", dash=(2, 2))
            self.canvas.create_text(w / 2, h - 8, text="Temps",
                                    fill="gray", font=("Arial", 8))

            points = [(5 + i * (w / 40), get_y(v))
                      for i, v in enumerate(self.drift_history)]
            if len(points) > 1:
                self.canvas.create_line(points, fill="cyan", width=2, smooth=True)

            latest = self.drift_history[-1]
            self.canvas.create_text(160, 15,
                                    text=f"Surcoût Zephyr/I2C actuel: {latest:.1f} ms",
                                    fill="#00FFFF", font=("Arial", 10, "bold"))
            self.canvas.create_text(160, 30,
                                    text=f"(FPGA: {self.lat_fpga:.1f}ms | STM32: {self.lat_stm32:.1f}ms)",
                                    fill="lightgreen", font=("Arial", 8))
            self.lat_fpga = None
            self.lat_stm32 = None

    # =========================================================
    # UTILITAIRES
    # =========================================================
    def log(self, msg, tag="sys"):
        self.txt_log.config(state="normal")
        self.txt_log.insert(tk.END, msg + "\n", tag)
        self.txt_log.see(tk.END)
        self.txt_log.config(state="disabled")

    def clear_logs(self):
        self.txt_log.config(state="normal")
        self.txt_log.delete(1.0, tk.END)
        self.txt_log.config(state="disabled")

    def update_com_ports(self):
        ports = [p.device for p in serial.tools.list_ports.comports()]
        self.combo_fpga['values']  = ports
        self.combo_stm32['values'] = ports
        if len(ports) > 0: self.combo_fpga.current(0)
        if len(ports) > 1: self.combo_stm32.current(1)

    def toggle_fpga(self):
        if self.fpga_port and self.fpga_port.is_open:
            self.fpga_port.close()
            self.fpga_port = None
            self.btn_conn_fpga.config(text="Connecter FPGA", bg="lightgreen")
            self.lbl_st_fpga.config(text="Déconnecté", fg="red")
            self.var_autorefresh.set(False)
            self.log("[SYSTEM] Port FPGA fermé.", "sys")
        else:
            port = self.combo_fpga.get()
            try:
                self.fpga_port = serial.Serial(port, 115200, timeout=0.1)
                self.btn_conn_fpga.config(text="Déconnecter", bg="salmon")
                self.lbl_st_fpga.config(text=f"Connecté ({port})", fg="green")
                self.log(f"[SYSTEM] FPGA connecté sur {port}", "sys")
                self.root.after(200, lambda: self.send_fpga(CMD_GET_STATUS, []))
            except Exception as e:
                messagebox.showerror("Erreur FPGA", f"Impossible d'ouvrir {port}:\n{e}")

    def toggle_stm32(self):
        if self.stm32_port and self.stm32_port.is_open:
            self.stm32_port.close()
            self.stm32_port = None
            self.btn_conn_stm32.config(text="Connecter STM32", bg="lightblue")
            self.lbl_st_stm32.config(text="Déconnecté", fg="red")
            self.log("[SYSTEM] Port STM32 fermé.", "sys")
        else:
            port = self.combo_stm32.get()
            try:
                self.stm32_port = serial.Serial(port, 115200, timeout=0.1)
                self.stm32_port.reset_input_buffer()
                self.btn_conn_stm32.config(text="Déconnecter", bg="salmon")
                self.lbl_st_stm32.config(text=f"Connecté ({port})", fg="green")
                self.log(f"[SYSTEM] STM32 connecté sur {port}", "sys")
            except Exception as e:
                messagebox.showerror("Erreur STM32", f"Impossible d'ouvrir {port}:\n{e}")

    def send_fpga(self, cmd, payload, manual=False):
        if not self.fpga_port or not self.fpga_port.is_open:
            return
        length = len(payload)
        crc    = calculate_crc(cmd, length, payload)
        frame  = [SOF, cmd, length] + payload + [crc]
        if cmd == CMD_GET_STATUS and manual:
            self.force_status_popup = True
        try:
            self.fpga_port.write(bytes(frame))
        except (serial.SerialException, OSError) as e:
            self.log(f"[WATCHDOG] Port FPGA perdu en écriture : {e}", "warn")
            self._force_disconnect_fpga()
            return
        hex_str = " ".join(f"{b:02X}" for b in frame)
        if not (self.var_autorefresh.get() and
                cmd in [CMD_GET_TIME, CMD_GET_STATUS, CMD_GET_ALARM]):
            self.log(f"[FPGA-TX] {hex_str}  -> ({COMMANDS.get(cmd, 'UNKNOWN')})",
                     "fpga_tx")

    def send_stm32(self, cmd, payload):
        if not self.stm32_port or not self.stm32_port.is_open:
            return
        length = len(payload)
        crc    = calculate_crc(cmd, length, payload)
        frame  = [SOF, cmd, length] + payload + [crc]
        try:
            self.stm32_port.write(bytes(frame))
        except (serial.SerialException, OSError) as e:
            self.log(f"[WATCHDOG] Port STM32 perdu en écriture : {e}", "warn")
            self._force_disconnect_stm32()
            return
        hex_str = " ".join(f"{b:02X}" for b in frame)
        if not (self.var_autorefresh.get() and
                cmd in [CMD_GET_TIME, CMD_GET_ALARM]):
            self.log(f"[STM32-TX] {hex_str}  -> ({COMMANDS.get(cmd, 'UNKNOWN')})",
                     "stm32_tx")

    # --- SET ---
    def set_time(self, target):
        try:
            payload = [int(self.ent_sec.get()), int(self.ent_min.get()),
                       int(self.ent_hr.get())]
            if target in ["FPGA",  "BOTH"]: self.send_fpga(CMD_SET_TIME, payload)
            if target in ["STM32", "BOTH"]: self.send_stm32(CMD_SET_TIME, payload)
            if target == "BOTH": self.reset_drift_graph()
        except ValueError:
            pass

    def set_date(self, target):
        try:
            payload = [int(self.ent_day.get()), int(self.ent_month.get()),
                       int(self.ent_year.get())]
            if target in ["FPGA",  "BOTH"]: self.send_fpga(CMD_SET_DATE, payload)
            if target in ["STM32", "BOTH"]: self.send_stm32(CMD_SET_DATE, payload)
            if target == "BOTH": self.reset_drift_graph()
        except ValueError:
            pass

    def set_alarm(self, target):
        if target in ["FPGA", "BOTH"] and self.hw_switch_local:
            if not messagebox.askyesno("⚠️ Conflit Matériel",
                                       "SW15 levé — FPGA ignorera.\nEnvoyer quand même ?"):
                return
        try:
            payload = [int(self.ent_al_sec.get()), int(self.ent_al_min.get()),
                       int(self.ent_al_hr.get())]
            if target in ["FPGA",  "BOTH"]: self.send_fpga(CMD_SET_ALARM, payload)
            if target in ["STM32", "BOTH"]: self.send_stm32(CMD_SET_ALARM, payload)
        except ValueError:
            pass

    def set_all(self, target):
        try:
            payload = [int(self.ent_sec.get()),   int(self.ent_min.get()),
                       int(self.ent_hr.get()),     int(self.ent_day.get()),
                       int(self.ent_month.get()),  int(self.ent_year.get())]
            if target in ["FPGA",  "BOTH"]: self.send_fpga(CMD_SET_ALL, payload)
            if target in ["STM32", "BOTH"]: self.send_stm32(CMD_SET_ALL, payload)
            if target == "BOTH": self.reset_drift_graph()
        except ValueError:
            messagebox.showerror("Erreur", "Vérifiez vos entrées")

    def set_baud_rate(self):
        sel = self.combo_baud.get()
        payload = [0x01] if sel == "115200" else [0x00]
        self.send_fpga(CMD_SET_BAUD, payload)
        self.send_stm32(CMD_SET_BAUD, payload)
        time.sleep(0.1)
        if self.fpga_port  and self.fpga_port.is_open:
            self.fpga_port.baudrate  = int(sel)
        if self.stm32_port and self.stm32_port.is_open:
            self.stm32_port.baudrate = int(sel)
        self.log(f"[SYSTEM] ⚡ Vitesse changée à {sel} bauds.", "sys")

    def sync_pc_time(self):
        now = datetime.datetime.now()
        payload = [now.second, now.minute, now.hour,
                   now.day, now.month, now.year % 100]
        self.send_fpga(CMD_SET_ALL, payload)
        self.send_stm32(CMD_SET_ALL, payload)
        self.log("[SYSTEM] 🕒 Sync PC -> DEUX CARTES envoyée !", "sys")
        self.reset_drift_graph()

    def show_status_window(self, status_byte):
        win = tk.Toplevel(self.root)
        win.title("Statut Nexys A7")
        win.geometry("300x200")
        alarm_on = (status_byte & 0x01) != 0
        tk.Label(win, text="🔍 DÉCODAGE STATUS BYTE",
                 font=("Arial", 12, "bold")).pack(pady=10)
        tk.Label(win, text="🔔 État Alarme :").pack()
        tk.Label(win, text="ON" if alarm_on else "OFF",
                 fg="green" if alarm_on else "red",
                 font=("Arial", 12, "bold")).pack()
        tk.Label(win, text="🎛️ Contrôle (SW15) :").pack(pady=5)
        tk.Label(win,
                 text="LOCAL (Ignorera le PC)" if self.hw_switch_local else "PC (UART distant)",
                 fg="blue", font=("Arial", 12, "bold")).pack()

    # =========================================================
    # AUTO-REFRESH + BOUCLES D'ÉCOUTE
    # =========================================================
    def auto_refresh_task(self):
        if self.var_autorefresh.get():
            if self.fpga_port and self.fpga_port.is_open:
                self.t_last_req_fpga = time.time()
                self.send_fpga(CMD_GET_TIME, [])
                self.send_fpga(CMD_GET_STATUS, [])
            if self.stm32_port and self.stm32_port.is_open:
                self.t_last_req_stm32 = time.time()
                self.send_stm32(CMD_GET_TIME, [])
        self.root.after(500, self.auto_refresh_task)

    def listen_fpga(self):
        if self.fpga_port and self.fpga_port.is_open:
            try:
                if self.fpga_port.in_waiting > 0:
                    self.rx_buf_fpga.extend(
                        self.fpga_port.read(self.fpga_port.in_waiting))
            except (serial.SerialException, OSError) as e:
                # Port masqué par la VM ou débranché
                self.log(f"[WATCHDOG] Port FPGA perdu en lecture : {e}", "warn")
                self._force_disconnect_fpga()
                self.root.after(50, self.listen_fpga)
                return

            while len(self.rx_buf_fpga) >= 4:
                if self.rx_buf_fpga[0] != SOF:
                    self.rx_buf_fpga.pop(0)
                    continue
                expected_len = self.rx_buf_fpga[2]
                total_size   = 4 + expected_len
                if len(self.rx_buf_fpga) < total_size:
                    break

                frame   = self.rx_buf_fpga[:total_size]
                del self.rx_buf_fpga[:total_size]

                hex_str  = " ".join(f"{b:02X}" for b in frame)
                cmd      = frame[1]
                is_spam  = (self.var_autorefresh.get() and
                            cmd in [CMD_GET_TIME, CMD_GET_STATUS, CMD_GET_ALARM])

                if cmd == ACK and not is_spam:
                    self.log(f"[FPGA-RX] {hex_str}  <- (ACK)", "fpga_rx")
                elif cmd == NACK:
                    self.log(f"[FPGA-RX] {hex_str}  <- (NACK: Erreur CRC)", "alert")
                elif cmd == CMD_ALARM_EVT:
                    self.log(f"[FPGA-RX] {hex_str}  <- ⚠️ ALARM EVENT", "alert")
                    play_alarm_sound("FPGA")
                elif cmd == CMD_GET_TIME and len(frame) >= 7:
                    if self.var_autorefresh.get() and self.lat_fpga is None:
                        self.lat_fpga = (time.time() - self.t_last_req_fpga) * 1000
                        self.check_and_update_graph()
                    s, m, h = frame[3], frame[4], frame[5]
                    self.lbl_time_f.config(text=f"{h:02d}:{m:02d}:{s:02d}")
                    if not is_spam:
                        self.log(f"[FPGA-RX] {hex_str}  <- (Heure)", "fpga_rx")
                elif cmd == CMD_GET_DATE and len(frame) >= 7:
                    d, mth, y = frame[3], frame[4], frame[5]
                    self.lbl_date_f.config(text=f"{d:02d}/{mth:02d}/20{y:02d}")
                    self.log(f"[FPGA-RX] {hex_str}  <- (Date)", "fpga_rx")
                elif cmd == CMD_GET_ALARM and len(frame) >= 7:
                    s, m, h = frame[3], frame[4], frame[5]
                    self.lbl_alarm_f.config(
                        text=f"🔔 Alarme: {h:02d}:{m:02d}:{s:02d}")
                    if not is_spam:
                        self.log(f"[FPGA-RX] {hex_str}  <- (Alarme)", "fpga_rx")
                elif cmd == CMD_GET_ALL and len(frame) >= 10:
                    s, m, h, d, mth, y = (frame[3], frame[4], frame[5],
                                          frame[6], frame[7], frame[8])
                    self.lbl_time_f.config(text=f"{h:02d}:{m:02d}:{s:02d}")
                    self.lbl_date_f.config(text=f"{d:02d}/{mth:02d}/20{y:02d}")
                    self.log(f"[FPGA-RX] {hex_str}  <- (ALL)", "fpga_rx")
                elif cmd == CMD_GET_STATUS and len(frame) >= 5:
                    status_byte          = frame[3]
                    self.hw_switch_local = (status_byte & 0x02) != 0
                    if self.force_status_popup:
                        self.show_status_window(status_byte)
                        self.force_status_popup = False
                    if not is_spam:
                        self.log(f"[FPGA-RX] {hex_str}  <- (Status)", "fpga_rx")
                elif cmd == CMD_GET_BAUD and len(frame) >= 5:
                    bd = "115200" if frame[3] == 0x01 else "9600"
                    self.lbl_baud_f.config(text=f"Baud Rate: {bd}")
                    self.log(f"[FPGA-RX] {hex_str}  <- (Baud: {bd})", "fpga_rx")

        self.root.after(50, self.listen_fpga)

    def listen_stm32(self):
        if self.stm32_port and self.stm32_port.is_open:
            try:
                if self.stm32_port.in_waiting > 0:
                    self.rx_buf_stm32.extend(
                        self.stm32_port.read(self.stm32_port.in_waiting))
            except (serial.SerialException, OSError) as e:
                self.log(f"[WATCHDOG] Port STM32 perdu en lecture : {e}", "warn")
                self._force_disconnect_stm32()
                self.root.after(50, self.listen_stm32)
                return

            while len(self.rx_buf_stm32) >= 4:
                if self.rx_buf_stm32[0] != SOF:
                    self.rx_buf_stm32.pop(0)
                    continue
                expected_len = self.rx_buf_stm32[2]
                total_size   = 4 + expected_len
                if len(self.rx_buf_stm32) < total_size:
                    break

                frame   = self.rx_buf_stm32[:total_size]
                del self.rx_buf_stm32[:total_size]

                hex_str = " ".join(f"{b:02X}" for b in frame)
                cmd     = frame[1]
                is_spam = (self.var_autorefresh.get() and
                           cmd in [CMD_GET_TIME, CMD_GET_ALARM])

                if cmd == ACK and not is_spam:
                    self.log(f"[STM32-RX] {hex_str}  <- (ACK)", "stm32_rx")
                elif cmd == NACK:
                    if expected_len == 1:
                        self.log(
                            f"[STM32-RX] {hex_str}  <- (NACK Zephyr n°{frame[3]})",
                            "alert")
                    else:
                        self.log(f"[STM32-RX] {hex_str}  <- (NACK CRC)", "alert")
                elif cmd == CMD_ALARM_EVT:
                    self.log(f"[STM32-RX] {hex_str}  <- ⚠️ ALARM EVENT", "alert")
                    play_alarm_sound("STM32")
                elif cmd == CMD_GET_TIME and len(frame) >= 7:
                    if self.var_autorefresh.get() and self.lat_stm32 is None:
                        self.lat_stm32 = (time.time() - self.t_last_req_stm32) * 1000
                        self.check_and_update_graph()
                    s, m, h = frame[3], frame[4], frame[5]
                    self.lbl_time_s.config(text=f"{h:02d}:{m:02d}:{s:02d}")
                    if not is_spam:
                        self.log(f"[STM32-RX] {hex_str}  <- (Heure)", "stm32_rx")
                elif cmd == CMD_GET_DATE and len(frame) >= 7:
                    d, mth, y = frame[3], frame[4], frame[5]
                    self.lbl_date_s.config(text=f"{d:02d}/{mth:02d}/20{y:02d}")
                    self.log(f"[STM32-RX] {hex_str}  <- (Date)", "stm32_rx")
                elif cmd == CMD_GET_ALARM and len(frame) >= 7:
                    s, m, h = frame[3], frame[4], frame[5]
                    self.lbl_alarm_s.config(
                        text=f"🔔 Alarme: {h:02d}:{m:02d}:{s:02d}")
                    if not is_spam:
                        self.log(f"[STM32-RX] {hex_str}  <- (Alarme)", "stm32_rx")
                elif cmd == CMD_GET_ALL and len(frame) >= 10:
                    s, m, h, d, mth, y = (frame[3], frame[4], frame[5],
                                          frame[6], frame[7], frame[8])
                    self.lbl_time_s.config(text=f"{h:02d}:{m:02d}:{s:02d}")
                    self.lbl_date_s.config(text=f"{d:02d}/{mth:02d}/20{y:02d}")
                    self.log(f"[STM32-RX] {hex_str}  <- (ALL)", "stm32_rx")
                # NEW — décodage CMD_GET_STATUS STM32
                elif cmd == CMD_GET_STATUS and len(frame) >= 5:
                    status_byte = frame[3]
                    alarm_on    = bool(status_byte & 0x01)
                    virtual_rtc = bool(status_byte & 0x02)
                    # Met à jour le petit label RTC mode dans l'afficheur STM32
                    self.lbl_rtc_mode_s.config(
                        text="🕐 RTC Virtuel (RAM)" if virtual_rtc else "✅ PCF8563",
                        fg="#FF9900" if virtual_rtc else "#00AA00"
                    )
                    if self.force_status_popup_stm32:
                        self.show_status_window_stm32(status_byte)
                        self.force_status_popup_stm32 = False
                    if not is_spam:
                        rtc_str = "VIRTUEL" if virtual_rtc else "PCF8563"
                        self.log(
                            f"[STM32-RX] {hex_str}  <- "
                            f"(Status: alarme={'ON' if alarm_on else 'OFF'}, RTC={rtc_str})",
                            "stm32_rx")
                elif cmd == CMD_GET_BAUD and len(frame) >= 5:
                    bd = "115200" if frame[3] == 0x01 else "9600"
                    self.log(f"[STM32-RX] {hex_str}  <- (Baud: {bd})", "stm32_rx")

        self.root.after(50, self.listen_stm32)


if __name__ == "__main__":
    root = tk.Tk()
    app  = RTC_App(root)
    root.mainloop()