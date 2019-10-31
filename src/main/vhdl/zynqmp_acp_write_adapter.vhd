-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_write_adapter.vhd
--!     @brief   ZynqMP ACP Write Adapter
--!     @version 0.1.0
--!     @date    2019/10/31
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--! @brief 
-----------------------------------------------------------------------------------
entity  ZYNQMP_ACP_WRITE_ADAPTER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        AXI_ADDR_WIDTH      : --! @brief AXI ADDRRESS WIDTH :
                              integer := 64;
        AXI_DATA_WIDTH      : --! @brief AXI DATA WIDTH :
                              integer := 128;
        AXI_ID_WIDTH        : --! @brief AXI ID WIDTH :
                              integer := 6;
        WDATA_QUEUE_SIZE    : --! @brief WRITE DATA QUEUE SIZE :
                              integer range 4 to 16 := 16;
        MAX_BURST_LENGTH    : --! @brief ACP MAX BURST LENGTH :
                              integer := 4
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock / Reset Signals.
    -------------------------------------------------------------------------------
        ACLK                : in  std_logic;
        ARESETn             : in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_AWID            : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_AWADDR          : in  std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_AWLEN           : in  std_logic_vector(7 downto 0);
        AXI_AWSIZE          : in  std_logic_vector(2 downto 0);
        AXI_AWBURST         : in  std_logic_vector(1 downto 0);
        AXI_AWLOCK          : in  std_logic_vector(0 downto 0);
        AXI_AWCACHE         : in  std_logic_vector(3 downto 0);
        AXI_AWPROT          : in  std_logic_vector(2 downto 0);
        AXI_AWQOS           : in  std_logic_vector(3 downto 0);
        AXI_AWREGION        : in  std_logic_vector(3 downto 0);
        AXI_AWVALID         : in  std_logic;
        AXI_AWREADY         : out std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_WDATA           : in  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        AXI_WSTRB           : in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        AXI_WLAST           : in  std_logic;
        AXI_WVALID          : in  std_logic;
        AXI_WREADY          : out std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        AXI_BID             : out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_BRESP           : out std_logic_vector(1 downto 0);
        AXI_BVALID          : out std_logic;
        AXI_BREADY          : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP Write Address Channel Signals.
    -------------------------------------------------------------------------------
        ACP_AWID            : out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        ACP_AWADDR          : out std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        ACP_AWLEN           : out std_logic_vector(7 downto 0);
        ACP_AWSIZE          : out std_logic_vector(2 downto 0);
        ACP_AWBURST         : out std_logic_vector(1 downto 0);
        ACP_AWLOCK          : out std_logic_vector(0 downto 0);
        ACP_AWCACHE         : out std_logic_vector(3 downto 0);
        ACP_AWPROT          : out std_logic_vector(2 downto 0);
        ACP_AWQOS           : out std_logic_vector(3 downto 0);
        ACP_AWREGION        : out std_logic_vector(3 downto 0);
        ACP_AWVALID         : out std_logic;
        ACP_AWREADY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP Write Data Channel Signals.
    -------------------------------------------------------------------------------
        ACP_WDATA           : out std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        ACP_WSTRB           : out std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        ACP_WLAST           : out std_logic;
        ACP_WVALID          : out std_logic;
        ACP_WREADY          : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP Write Response Channel Signals.
    -------------------------------------------------------------------------------
        ACP_BID             : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        ACP_BRESP           : in  std_logic_vector(1 downto 0);
        ACP_BVALID          : in  std_logic;
        ACP_BREADY          : out std_logic
    );
end  ZYNQMP_ACP_WRITE_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PipeWork;
use     PipeWork.Components.QUEUE_RECEIVER;
use     PipeWork.Components.QUEUE_REGISTER;
use     PipeWork.Components.REDUCER;
use     PipeWork.Components.SDPRAM;
architecture RTL of ZYNQMP_ACP_WRITE_ADAPTER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    reset         :  std_logic;
    constant  clear         :  std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE    is (IDLE_STATE, WAIT_STATE, ADDR_STATE, DATA_STATE);
    signal    curr_state    :  STATE_TYPE;
    signal    xfer_id       :  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal    xfer_start    :  boolean;
    signal    xfer_last     :  boolean;
    signal    remain_len    :  integer range 0 to MAX_BURST_LENGTH-1;
    signal    byte_pos      :  unsigned( 3 downto 0);
    signal    word_pos      :  unsigned(11 downto 4);
    signal    page_num      :  unsigned(AXI_ADDR_WIDTH-1 downto 12);
    signal    resp_ready    :  boolean;
    constant  WSTRB_ALL_1   :  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    burst_len     :  unsigned(7 downto 0);
    signal    ao_valid      :  std_logic;
    signal    ao_ready      :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    wi_data       :  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
    signal    wi_strb       :  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
    signal    wi_last       :  std_logic;
    signal    wi_valid      :  std_logic;
    signal    wi_ready      :  std_logic;
    signal    wi_full_burst :  boolean;
    signal    wi_none_burst :  boolean;
    signal    wi_next_valid :  boolean;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    wo_last       :  std_logic;
    signal    wo_valid      :  std_logic;
    signal    wo_ready      :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  wq_enable     :  std_logic := '1';
    signal    wq_busy       :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component ZYNQMP_ACP_RESPONSE_QUEUE 
        generic (
            AXI_ID_WIDTH    :  integer := 6;
            QUEUE_SIZE      :  integer := 1
        );
        port(
            CLK             : in  std_logic;
            RST             : in  std_logic;
            CLR             : in  std_logic;
            I_ID            : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            I_LAST          : in  boolean;
            I_VALID         : in  boolean;
            I_READY         : out boolean;
            Q_ID            : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            Q_LAST          : out boolean;
            Q_VALID         : out boolean;
            Q_READY         : in  boolean
        );
    end component;
begin
    reset <= '0' when (ARESETN = '1') else '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset)
        variable u_word_pos : unsigned(word_pos'high+1 downto word_pos'low);
    begin
        if (reset = '1') then
                curr_state <= IDLE_STATE;
                xfer_id    <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                byte_pos   <= (others => '0');
                remain_len <= 1;
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                curr_state <= IDLE_STATE;
                xfer_id    <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                byte_pos   <= (others => '0');
                remain_len <= 1;
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (AXI_AWVALID = '1') then
                            curr_state <= WAIT_STATE;
                            xfer_id    <= AXI_AWID;
                            page_num   <= unsigned(AXI_AWADDR(page_num'range));
                            word_pos   <= unsigned(AXI_AWADDR(word_pos'range));
                            byte_pos   <= unsigned(AXI_AWADDR(byte_pos'range));
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when WAIT_STATE =>
                        if (resp_ready = TRUE and wi_valid = '1') then
                            curr_state <= ADDR_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when ADDR_STATE =>
                        if (xfer_start) then
                            byte_pos   <= (others => '0');
                            if    (wi_full_burst) then
                                remain_len <= MAX_BURST_LENGTH-1;
                                word_pos   <= word_pos + MAX_BURST_LENGTH;
                            else
                                remain_len <= 1;
                                word_pos   <= word_pos + 1;
                            end if;
                            if    (wi_full_burst) then
                                curr_state <= DATA_STATE;
                            elsif (wi_last = '1') then
                                curr_state <= IDLE_STATE;
                            elsif (wi_next_valid) then
                                curr_state <= ADDR_STATE;
                            else
                                curr_state <= WAIT_STATE;
                            end if;
                        else
                                curr_state <= ADDR_STATE;
                        end if;
                    when DATA_STATE =>
                        if (wo_valid = '1' and wo_ready = '1') then
                            if    (remain_len > 1) then
                                curr_state <= DATA_STATE;
                            elsif (wi_last = '1') then
                                curr_state <= IDLE_STATE;
                            elsif (wi_next_valid) then
                                curr_state <= ADDR_STATE;
                            else
                                curr_state <= WAIT_STATE;
                            end if;
                            remain_len <= remain_len - 1;
                        else
                            curr_state <= DATA_STATE;
                        end if;
                    when others =>
                            curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    AXI_AWREADY <= '1' when (curr_state = IDLE_STATE) else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset) begin
        if (reset = '1') then
                ACP_AWSIZE   <= (others => '0');
                ACP_AWBURST  <= (others => '0');
                ACP_AWLOCK   <= (others => '0');
                ACP_AWCACHE  <= (others => '0');
                ACP_AWPROT   <= (others => '0');
                ACP_AWQOS    <= (others => '0');
                ACP_AWREGION <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                ACP_AWSIZE   <= (others => '0');
                ACP_AWBURST  <= (others => '0');
                ACP_AWLOCK   <= (others => '0');
                ACP_AWCACHE  <= (others => '0');
                ACP_AWPROT   <= (others => '0');
                ACP_AWQOS    <= (others => '0');
                ACP_AWREGION <= (others => '0');
            elsif (curr_state = IDLE_STATE and AXI_AWVALID = '1') then
                ACP_AWSIZE   <= AXI_AWSIZE   ;
                ACP_AWBURST  <= AXI_AWBURST  ;
                ACP_AWLOCK   <= AXI_AWLOCK   ;
                ACP_AWCACHE  <= AXI_AWCACHE  ;
                ACP_AWPROT   <= AXI_AWPROT   ;
                ACP_AWQOS    <= AXI_AWQOS    ;
                ACP_AWREGION <= AXI_AWREGION ;
            end if;
        end if;
    end process;
    ACP_AWID    <= xfer_id;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    xfer_start <= (curr_state = ADDR_STATE and ao_ready = '1' and wo_ready = '1') and
                  (wi_full_burst or wi_none_burst);
    ao_valid   <= '1' when (xfer_start) else '0';
    wo_valid   <= '1' when (xfer_start) or
                           (curr_state = DATA_STATE and wi_valid = '1') else '0';
    wo_last    <= '1' when (curr_state = ADDR_STATE and wi_none_burst) or
                           (curr_state = DATA_STATE and remain_len = 1) else '0';
    wi_ready   <= '1' when (xfer_start) or
                           (curr_state = DATA_STATE and wo_ready = '1') else '0';
    burst_len  <= (others => '0') when (wi_none_burst) else 
                  to_unsigned(MAX_BURST_LENGTH-1, burst_len'length);
    -------------------------------------------------------------------------------
    -- Address 
    -------------------------------------------------------------------------------
    AQ: block
        constant  QUEUE_SIZE    :  integer := 2;
        constant  WADDR_LO      :  integer := 0;
        constant  WADDR_HI      :  integer := WADDR_LO  + 12 - 1;
        constant  WLEN_LO       :  integer := WADDR_HI  +  1;
        constant  WLEN_HI       :  integer := WLEN_LO   +  8 - 1;
        constant  WORD_BITS     :  integer := WLEN_HI   - WADDR_LO + 1;
        signal    i_word        :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    q_word        :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    q_valid       :  std_logic_vector(QUEUE_SIZE  downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        i_word(WLEN_HI  downto WLEN_LO ) <= std_logic_vector(burst_len);
        i_word(WADDR_HI downto WADDR_LO) <= std_logic_vector(word_pos ) &
                                            std_logic_vector(byte_pos );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        QUEUE: QUEUE_REGISTER                    -- 
            generic map (                        -- 
                QUEUE_SIZE  => QUEUE_SIZE      , -- 
                DATA_BITS   => WORD_BITS         -- 
            )                                    -- 
            port map (                           -- 
                CLK         => ACLK            , -- In  :
                RST         => reset           , -- In  :
                CLR         => clear           , -- In  :
                I_DATA      => i_word          , -- In  :
                I_VAL       => ao_valid        , -- In  :
                I_RDY       => ao_ready        , -- Out :
                Q_DATA      => q_word          , -- Out :
                Q_VAL       => q_valid         , -- Out :
                Q_RDY       => ACP_AWREADY       -- In  :
            );                                   -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ACP_AWVALID <= q_valid(0);
        ACP_AWADDR  <= std_logic_vector(page_num) & q_word(WADDR_HI downto WADDR_LO);
        ACP_AWLEN   <= q_word(WLEN_HI downto WLEN_LO);
    end block;
    -------------------------------------------------------------------------------
    -- Write Data Block
    -------------------------------------------------------------------------------
    W: block
        constant  IPORT_QUEUE   :  boolean := TRUE;
        constant  OPORT_QUEUE   :  boolean := TRUE;
        constant  WDATA_LO      :  integer := 0;
        constant  WDATA_HI      :  integer := WDATA_LO  + AXI_DATA_WIDTH   - 1;
        constant  WSTRB_LO      :  integer := WDATA_HI  + 1;
        constant  WSTRB_HI      :  integer := WSTRB_LO  + AXI_DATA_WIDTH/8 - 1;
        constant  WLAST_POS     :  integer := WSTRB_HI  + 1;
        constant  WORD_BITS     :  integer := WLAST_POS - WDATA_LO         + 1;
        signal    ip_valid      :  std_logic;
        signal    ip_ready      :  std_logic;
        signal    ip_data       :  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        signal    ip_strb       :  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        signal    ip_last       :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        IPORT: if (IPORT_QUEUE = TRUE) generate
            signal    i_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_word    :  std_logic_vector(WORD_BITS-1 downto 0);
        begin 
            QUEUE: QUEUE_RECEIVER                -- 
                generic map (                    -- 
                    QUEUE_SIZE  => 2           , -- 
                    DATA_BITS   => WORD_BITS     -- 
                )                                -- 
                port map (                       -- 
                    CLK         => ACLK        , -- In  :
                    RST         => reset       , -- In  :
                    CLR         => clear       , -- In  :
                    I_ENABLE    => '1'         , -- In  :
                    I_DATA      => i_word      , -- In  :
                    I_VAL       => AXI_WVALID  , -- In  :
                    I_RDY       => AXI_WREADY  , -- Out :
                    O_DATA      => q_word      , -- Out :
                    O_VAL       => ip_valid    , -- Out :
                    O_RDY       => ip_ready      -- In  :
                );
            i_word(WDATA_HI downto WDATA_LO) <= AXI_WDATA;
            i_word(WSTRB_HI downto WSTRB_LO) <= AXI_WSTRB;
            i_word(WLAST_POS               ) <= AXI_WLAST;
            ip_data  <= q_word(WDATA_HI downto WDATA_LO);
            ip_strb  <= q_word(WSTRB_HI downto WSTRB_LO);
            ip_last  <= q_word(WLAST_POS);
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        IPORT_BUF: if (IPORT_QUEUE = FALSE) generate
            ip_data  <= AXI_WDATA;
            ip_strb  <= AXI_WSTRB;
            ip_last  <= AXI_WLAST;
            ip_valid <= AXI_WVALID;
            AXI_WREADY <= ip_ready;
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        STRB: block
            signal    i_word   :  std_logic_vector(1 downto 0);
            constant  q_full   :  std_logic_vector(  MAX_BURST_LENGTH-1 downto 0) := (others => '1');
            signal    q_word   :  std_logic_vector(2*MAX_BURST_LENGTH-1 downto 0);
            signal    q_valid  :  std_logic_vector(  MAX_BURST_LENGTH   downto 0);
            constant  q_shift  :  std_logic_vector(0 downto 0) := "1";
        begin
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            QUEUE: REDUCER                          -- 
               generic map (                        -- 
                   WORD_BITS   => 2               , -- 
                   STRB_BITS   => 1               , -- 
                   I_WIDTH     => 1               , -- 
                   O_WIDTH     => MAX_BURST_LENGTH, -- 
                   QUEUE_SIZE  => WDATA_QUEUE_SIZE, -- 
                   VALID_MIN   => 0               , -- 
                   VALID_MAX   => MAX_BURST_LENGTH, -- 
                   O_VAL_SIZE  => 1               , --
                   O_SHIFT_MIN => q_shift'low     , --
                   O_SHIFT_MAX => q_shift'high    , --
                   I_JUSTIFIED => 1               , -- 
                   FLUSH_ENABLE=> 0                 -- 
               )                                    -- 
               port map (                           -- 
                   CLK         => ACLK            , -- In  :
                   RST         => reset           , -- In  :
                   CLR         => clear           , -- In  :
                   BUSY        => wq_busy         , -- Out :
                   VALID       => q_valid         , -- Out :
                   I_ENABLE    => wq_enable       , -- In  :
                   I_DATA      => i_word          , -- In  :
                   I_STRB      => "1"             , -- In  :
                   I_DONE      => ip_last         , -- In  :
                   I_VAL       => ip_valid        , -- In  :
                   I_RDY       => ip_ready        , -- Out :
                   O_DATA      => q_word          , -- Out :
                   O_STRB      => open            , -- Out :
                   O_DONE      => open            , -- Out :
                   O_VAL       => wi_valid        , -- Out :
                   O_RDY       => wi_ready        , -- In  :
                   O_SHIFT     => q_shift           -- In  :
               );                                   --
            i_word(0) <= '1' when (ip_strb = WSTRB_ALL_1) else '0';
            i_word(1) <= ip_last;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            process (q_word, q_valid, word_pos, byte_pos)
                variable full_burst :  boolean;
                variable none_burst :  boolean;
            begin
                if (word_pos(5 downto 4) = "00" and byte_pos = "0000") then
                    full_burst := TRUE;
                    none_burst := FALSE;
                    for i in 0 to MAX_BURST_LENGTH-1 loop
                        if (q_valid(i) = '0') or  (q_word(2*i) = '0') then
                            full_burst := full_burst and FALSE;
                        end if;
                        if (q_valid(i) = '1') and (q_word(2*i) = '0') then
                            none_burst := none_burst or  TRUE;
                        end if;
                    end loop;
                else
                    full_burst := FALSE;
                    none_burst := (q_valid(0) = '1');
                end if;
                wi_last       <= q_word(1);
                wi_full_burst <= full_burst;
                wi_none_burst <= none_burst;
                xfer_last     <= (full_burst and q_word(2*(MAX_BURST_LENGTH-1)+1) = '1') or
                                 (none_burst and q_word(                       1) = '1');
                wi_next_valid <= (q_valid(1) = '1');
            end process;
        end block;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        BUF: block
            signal    we        :  std_logic_vector(0 downto 0);
            signal    waddr     :  std_logic_vector(3 downto 0);
            signal    raddr     :  std_logic_vector(3 downto 0);
            signal    raddr_q   :  std_logic_vector(3 downto 0);
        begin
            we    <= (others => '1') when (ip_valid = '1' and ip_ready = '1') else (others => '0');
            raddr <= std_logic_vector(to_01(unsigned(raddr_q)) + 1) when (wi_valid = '1' and wi_ready = '1') else raddr_q;
            process(ACLK, reset) begin
                if (reset = '1') then
                        raddr_q <= (others => '0');
                        waddr   <= (others => '0');
                elsif (ACLK'event and ACLK = '1') then
                    if (clear = '1') then
                        raddr_q <= (others => '0');
                        waddr   <= (others => '0');
                    else
                        raddr_q <= raddr;
                        if (ip_valid = '1' and ip_ready = '1') then
                            waddr <= std_logic_vector(unsigned(waddr) + 1);
                        end if;
                    end if;
                end if;
            end process;
            DATA: SDPRAM                 -- 
                generic map(             -- 
                    DEPTH  =>  11      , -- 2**11 = 2048bit(16*128bit)
                    RWIDTH =>  7       , -- 2**7  = 128bit
                    WWIDTH =>  7       , -- 2**7  = 128bit
                    WEBIT  =>  0       , -- 
                    ID     =>  0         -- 
                )                        -- 
                port map (               -- 
                    WCLK    => ACLK    , -- In  :
                    WE      => we      , -- In  :
                    WADDR   => waddr   , -- In  :
                    WDATA   => ip_data , -- In  :
                    RCLK    => ACLK    , -- In  :
                    RADDR   => raddr   , -- In  :
                    RDATA   => wi_data   -- Out :
                );
            STRB: SDPRAM                 -- 
                generic map(             -- 
                    DEPTH  =>  8       , -- 2**8  = 256bit(16*128/8bit)
                    RWIDTH =>  4       , -- 2**4  = 128/8=16
                    WWIDTH =>  4       , -- 2**4  = 128/8=16
                    WEBIT  =>  0       , -- 
                    ID     =>  0         -- 
                )                        -- 
                port map (               -- 
                    WCLK    => ACLK    , -- In  :
                    WE      => we      , -- In  :
                    WADDR   => waddr   , -- In  :
                    WDATA   => ip_strb , -- In  :
                    RCLK    => ACLK    , -- In  :
                    RADDR   => raddr   , -- In  :
                    RDATA   => wi_strb   -- Out :
                );
        end block;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        OPORT: block
            signal    i_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_valid   :  std_logic_vector(2 downto 0);
        begin 
            QUEUE: QUEUE_REGISTER                -- 
                generic map (                    -- 
                    QUEUE_SIZE  => 2           , -- 
                    DATA_BITS   => WORD_BITS     -- 
                )                                -- 
                port map (                       -- 
                    CLK         => ACLK        , -- In  :
                    RST         => reset       , -- In  :
                    CLR         => clear       , -- In  :
                    I_DATA      => i_word      , -- In  :
                    I_VAL       => wo_valid    , -- In  :
                    I_RDY       => wo_ready    , -- Out :
                    Q_DATA      => q_word      , -- Out :
                    Q_VAL       => q_valid     , -- Out :
                    Q_RDY       => ACP_WREADY    -- In  :
                );
            i_word(WDATA_HI downto WDATA_LO) <= wi_data;
            i_word(WSTRB_HI downto WSTRB_LO) <= wi_strb;
            i_word(WLAST_POS               ) <= wo_last;
            ACP_WVALID <= q_valid(0);
            ACP_WDATA  <= q_word(WDATA_HI downto WDATA_LO);
            ACP_WSTRB  <= q_word(WSTRB_HI downto WSTRB_LO);
            ACP_WLAST  <= q_word(WLAST_POS               );
        end block;
    end block;
    -------------------------------------------------------------------------------
    -- Write Response Block
    -------------------------------------------------------------------------------
    B: block
        signal    q_last        :  boolean;
        signal    q_valid       :  boolean;
        signal    q_ready       :  boolean;
        signal    state         :  std_logic_vector(1 downto 0);
        constant  IDLE_STATE    :  std_logic_vector(1 downto 0) := "00";
        constant  IN_STATE      :  std_logic_vector(1 downto 0) := "01";
        constant  OUT_STATE     :  std_logic_vector(1 downto 0) := "10";
    begin
        ---------------------------------------------------------------------------
        -- Write Response Request Queue
        ---------------------------------------------------------------------------
        QUEUE: ZYNQMP_ACP_RESPONSE_QUEUE           -- 
            generic map (                          -- 
                AXI_ID_WIDTH    => AXI_ID_WIDTH  , -- 
                QUEUE_SIZE      => 1               -- 
            )                                      -- 
            port map (                             -- 
                CLK             => ACLK          , -- In  :
                RST             => reset         , -- In  :
                CLR             => clear         , -- In  :
                I_ID            => xfer_id       , -- In  :
                I_LAST          => xfer_last     , -- In  :
                I_VALID         => xfer_start    , -- In  :
                I_READY         => resp_ready    , -- Out :
                Q_ID            => open          , -- Out :
                Q_LAST          => q_last        , -- Out :
                Q_VALID         => q_valid       , -- Out :
                Q_READY         => q_ready         -- In  :
            );                                     -- 
        ---------------------------------------------------------------------------
        -- Output Signals
        ---------------------------------------------------------------------------
        ACP_BREADY <= state(0); -- '1' when (state = IN_STATE ) else '0';
        AXI_BVALID <= state(1); -- '1' when (state = OUT_STATE) else '0';
        q_ready    <= (state = IN_STATE and ACP_BVALID = '1');
        ---------------------------------------------------------------------------
        -- Finite State Machine
        ---------------------------------------------------------------------------
        FSM: process(ACLK, reset) begin
            if (reset = '1') then
                    state     <= IDLE_STATE;
                    AXI_BRESP <= (others => '0');
                    AXI_BID   <= (others => '0');
            elsif (ACLK'event and ACLK = '1') then
                if (clear = '1') then
                    state     <= IDLE_STATE;
                    AXI_BRESP <= (others => '0');
                    AXI_BID   <= (others => '0');
                else
                    case state is
                        when IDLE_STATE =>
                            if (q_valid) then
                                state <= IN_STATE;
                            else
                                state <= IDLE_STATE;
                            end if;
                        when IN_STATE =>
                            if    (ACP_BVALID = '1' and q_last = TRUE ) then
                                state <= OUT_STATE;
                            elsif (ACP_BVALID = '1' and q_last = FALSE) then
                                state <= IDLE_STATE;
                            else
                                state <= IN_STATE;
                            end if;
                            AXI_BRESP <= ACP_BRESP;
                            AXI_BID   <= ACP_BID;
                        when OUT_STATE =>
                            if (AXI_BREADY = '1') then
                                state <= IDLE_STATE;
                            else
                                state <= OUT_STATE;
                            end if;
                        when others => 
                                state <= IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
    end block;
end RTL;
