library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    Port (
        CLK     : in  std_logic;
        CE_1ms  : in  std_logic;
        CE_1s   : in  std_logic;
        
        -- Les 8 chiffres pour la Nexys A7
        AD0     : in  std_logic_vector(3 downto 0);
        AD1     : in  std_logic_vector(3 downto 0);
        AD2     : in  std_logic_vector(3 downto 0);
        AD3     : in  std_logic_vector(3 downto 0);
        BD0     : in  std_logic_vector(3 downto 0);
        BD1     : in  std_logic_vector(3 downto 0);
        BD2     : in  std_logic_vector(3 downto 0);
        BD3     : in  std_logic_vector(3 downto 0);

        -- Sorties physiques de la Nexys A7
        AN      : out std_logic_vector(7 downto 0); -- 8 Anodes
        SEG     : out std_logic_vector(6 downto 0); -- 7 Segments
        DP      : out std_logic                     -- Point décimal
    );
end display;

architecture Structural of display is

    -- Signaux internes
    signal sel            : std_logic_vector(3 downto 0);
    signal mux_out        : std_logic_vector(3 downto 0);
    signal seg_out        : std_logic_vector(6 downto 0);
    signal treg_out       : std_logic;
    signal reg8b_out      : std_logic_vector(7 downto 0);
    signal trans4v16_out  : std_logic_vector(15 downto 0);

    signal ana_int, anb_int : std_logic_vector(3 downto 0);

    -- DÉCLARATION DES COMPOSANTS
    component counter_4b_E
        Port ( clk : in std_logic; CE : in std_logic; Q : out std_logic_vector(3 downto 0) );
    end component;
    
    component mux_16x1x4bit
        Port (
            sel : in std_logic_vector(3 downto 0);
            AD0, AD1, AD2, AD3 : in std_logic_vector(3 downto 0);
            BD0, BD1, BD2, BD3 : in std_logic_vector(3 downto 0);
            RD0, RD1, RD2, RD3 : in std_logic_vector(3 downto 0);
            Y   : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component transcoder_7segs
        Port ( A : in std_logic_vector(3 downto 0); O : out std_logic_vector(6 downto 0) );
    end component;
    
    component Tregister_1b
        Port ( clk : in std_logic; T : in std_logic; Q : out std_logic );
    end component;
    
    component register_8b
        Port ( clk : in std_logic; D : in std_logic_vector(7 downto 0); Q : out std_logic_vector(7 downto 0) );
    end component;
    
    component transcoder_4v16
        Port ( A : in std_logic_vector(3 downto 0); O : out std_logic_vector(15 downto 0) );
    end component;
    
    component register_4b
        Port ( clk : in std_logic; D : in std_logic_vector(3 downto 0); Q : out std_logic_vector(3 downto 0) );
    end component;

begin

    -- 1. Compteur de balayage
    U0: counter_4b_E port map ( clk => CLK, CE  => CE_1ms, Q   => sel );
    
    -- 2. Transcodeur pour les anodes
    U1: transcoder_4v16 port map ( A => sel, O => trans4v16_out );
    
    -- 3. Registres des anodes (On ne garde que A et B car 8 afficheurs max)
    U2: register_4b port map ( clk => CLK, D => trans4v16_out(3 downto 0), Q => ana_int );
    U3: register_4b port map ( clk => CLK, D => trans4v16_out(7 downto 4), Q => anb_int );
    
    -- Concaténation pour la sortie physique (8 bits)
    AN <= anb_int & ana_int; 
    
    -- 4. Multiplexeur
    U5: mux_16x1x4bit port map (
        sel => sel,
        AD0 => AD0, AD1 => AD1, AD2 => AD2, AD3 => AD3,
        BD0 => BD0, BD1 => BD1, BD2 => BD2, BD3 => BD3,
        -- On force les RD à "1111" (éteint) car ils ne sont plus utilisés physiquement
        RD0 => "1111", RD1 => "1111", RD2 => "1111", RD3 => "1111",
        Y   => mux_out
    );
    
    -- 5. Transcodeur 7 Segments
    U6: transcoder_7segs port map ( A => mux_out, O => seg_out );
    
    -- 6. Bascule T (Utilisée pour faire clignoter le point décimal DP toutes les secondes)
    U8: Tregister_1b port map ( 
        clk => CLK, 
        T   => CE_1s, 
        Q   => treg_out 
    );

    -- 7. Registre de sortie (8 bits)
    -- On concatène le signal de clignotement (treg_out) avec les 7 segments (seg_out)
    U7: register_8b port map (
        clk => CLK, 
        D   => treg_out & seg_out, 
        Q   => reg8b_out
    );

    -- 8. Assignation finale aux ports de sortie de l'entité
    SEG <= reg8b_out(6 downto 0); -- Les 7 segments (A à G)
    DP  <= reg8b_out(7);          -- Le point décimal clignotant
    
end Structural;