-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Sat Oct 17 09:29:51 2020
-- Host        : DESKTOP-9JB81SB running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               c:/Users/jtalb/Documents/Vivado/ip_repo/AXIS_I2C_Master_1.0/src/s_axis_vip/s_axis_vip_sim_netlist.vhdl
-- Design      : s_axis_vip
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity s_axis_vip_axi4stream_vip_v1_1_7_top is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    aclken : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tstrb : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tid : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tdest : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tstrb : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tid : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tdest : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tuser : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute C_AXI4STREAM_DATA_WIDTH : integer;
  attribute C_AXI4STREAM_DATA_WIDTH of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 8;
  attribute C_AXI4STREAM_DEST_WIDTH : integer;
  attribute C_AXI4STREAM_DEST_WIDTH of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 0;
  attribute C_AXI4STREAM_HAS_ARESETN : integer;
  attribute C_AXI4STREAM_HAS_ARESETN of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 1;
  attribute C_AXI4STREAM_ID_WIDTH : integer;
  attribute C_AXI4STREAM_ID_WIDTH of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 0;
  attribute C_AXI4STREAM_INTERFACE_MODE : integer;
  attribute C_AXI4STREAM_INTERFACE_MODE of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 2;
  attribute C_AXI4STREAM_SIGNAL_SET : string;
  attribute C_AXI4STREAM_SIGNAL_SET of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is "32'b00000000000000000000000000010011";
  attribute C_AXI4STREAM_USER_BITS_PER_BYTE : integer;
  attribute C_AXI4STREAM_USER_BITS_PER_BYTE of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 0;
  attribute C_AXI4STREAM_USER_WIDTH : integer;
  attribute C_AXI4STREAM_USER_WIDTH of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is 0;
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is "yes";
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of s_axis_vip_axi4stream_vip_v1_1_7_top : entity is "axi4stream_vip_v1_1_7_top";
end s_axis_vip_axi4stream_vip_v1_1_7_top;

architecture STRUCTURE of s_axis_vip_axi4stream_vip_v1_1_7_top is
  signal \<const0>\ : STD_LOGIC;
begin
  m_axis_tdata(7) <= \<const0>\;
  m_axis_tdata(6) <= \<const0>\;
  m_axis_tdata(5) <= \<const0>\;
  m_axis_tdata(4) <= \<const0>\;
  m_axis_tdata(3) <= \<const0>\;
  m_axis_tdata(2) <= \<const0>\;
  m_axis_tdata(1) <= \<const0>\;
  m_axis_tdata(0) <= \<const0>\;
  m_axis_tdest(0) <= \<const0>\;
  m_axis_tid(0) <= \<const0>\;
  m_axis_tkeep(0) <= \<const0>\;
  m_axis_tlast <= \<const0>\;
  m_axis_tstrb(0) <= \<const0>\;
  m_axis_tuser(0) <= \<const0>\;
  m_axis_tvalid <= \<const0>\;
  s_axis_tready <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity s_axis_vip is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of s_axis_vip : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of s_axis_vip : entity is "s_axis_vip,axi4stream_vip_v1_1_7_top,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of s_axis_vip : entity is "yes";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of s_axis_vip : entity is "axi4stream_vip_v1_1_7_top,Vivado 2020.1";
end s_axis_vip;

architecture STRUCTURE of s_axis_vip is
  signal NLW_inst_m_axis_tlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_m_axis_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_m_axis_tdata_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_m_axis_tdest_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_m_axis_tid_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_m_axis_tkeep_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_m_axis_tstrb_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_m_axis_tuser_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute C_AXI4STREAM_DATA_WIDTH : integer;
  attribute C_AXI4STREAM_DATA_WIDTH of inst : label is 8;
  attribute C_AXI4STREAM_DEST_WIDTH : integer;
  attribute C_AXI4STREAM_DEST_WIDTH of inst : label is 0;
  attribute C_AXI4STREAM_HAS_ARESETN : integer;
  attribute C_AXI4STREAM_HAS_ARESETN of inst : label is 1;
  attribute C_AXI4STREAM_ID_WIDTH : integer;
  attribute C_AXI4STREAM_ID_WIDTH of inst : label is 0;
  attribute C_AXI4STREAM_INTERFACE_MODE : integer;
  attribute C_AXI4STREAM_INTERFACE_MODE of inst : label is 2;
  attribute C_AXI4STREAM_SIGNAL_SET : string;
  attribute C_AXI4STREAM_SIGNAL_SET of inst : label is "32'b00000000000000000000000000010011";
  attribute C_AXI4STREAM_USER_BITS_PER_BYTE : integer;
  attribute C_AXI4STREAM_USER_BITS_PER_BYTE of inst : label is 0;
  attribute C_AXI4STREAM_USER_WIDTH : integer;
  attribute C_AXI4STREAM_USER_WIDTH of inst : label is 0;
  attribute DowngradeIPIdentifiedWarnings of inst : label is "yes";
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of aclk : signal is "xilinx.com:signal:clock:1.0 CLOCK CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of aclk : signal is "XIL_INTERFACENAME CLOCK, ASSOCIATED_BUSIF M_AXIS:S_AXIS, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of aresetn : signal is "xilinx.com:signal:reset:1.0 RESET RST";
  attribute X_INTERFACE_PARAMETER of aresetn : signal is "XIL_INTERFACENAME RESET, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axis_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS TDATA";
  attribute X_INTERFACE_INFO of s_axis_tlast : signal is "xilinx.com:interface:axis:1.0 S_AXIS TLAST";
  attribute X_INTERFACE_PARAMETER of s_axis_tlast : signal is "XIL_INTERFACENAME S_AXIS, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axis_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS TREADY";
  attribute X_INTERFACE_INFO of s_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS TVALID";
begin
inst: entity work.s_axis_vip_axi4stream_vip_v1_1_7_top
     port map (
      aclk => aclk,
      aclken => '1',
      aresetn => aresetn,
      m_axis_tdata(7 downto 0) => NLW_inst_m_axis_tdata_UNCONNECTED(7 downto 0),
      m_axis_tdest(0) => NLW_inst_m_axis_tdest_UNCONNECTED(0),
      m_axis_tid(0) => NLW_inst_m_axis_tid_UNCONNECTED(0),
      m_axis_tkeep(0) => NLW_inst_m_axis_tkeep_UNCONNECTED(0),
      m_axis_tlast => NLW_inst_m_axis_tlast_UNCONNECTED,
      m_axis_tready => '0',
      m_axis_tstrb(0) => NLW_inst_m_axis_tstrb_UNCONNECTED(0),
      m_axis_tuser(0) => NLW_inst_m_axis_tuser_UNCONNECTED(0),
      m_axis_tvalid => NLW_inst_m_axis_tvalid_UNCONNECTED,
      s_axis_tdata(7 downto 0) => s_axis_tdata(7 downto 0),
      s_axis_tdest(0) => '0',
      s_axis_tid(0) => '0',
      s_axis_tkeep(0) => '0',
      s_axis_tlast => s_axis_tlast(0),
      s_axis_tready => s_axis_tready(0),
      s_axis_tstrb(0) => '0',
      s_axis_tuser(0) => '0',
      s_axis_tvalid => s_axis_tvalid(0)
    );
end STRUCTURE;
