// ============================================================================
//  gowin_blackboxes.sv - vendor primitive declarations for the slang frontend.
//
//  yosys' built-in frontend takes an undeclared module and quietly makes it a
//  blackbox; slang is a real elaborator and demands a declaration. yosys ships
//  one in +/gowin/cells_sim.v, but that file's BSRAM/DSP `specify` blocks are
//  not standard-conforming and slang rejects them, so the primitives the course
//  actually instantiates are declared here instead.
//
//  Ports and parameter defaults are copied verbatim from
//  <yosys-datdir>/gowin/cells_sim.v - keep them in sync with the installed
//  yosys, since nextpnr and gowin_pack read the parameters off these cells.
//
//  Passed to read_slang as a library file (-v), so it is elaborated only when
//  something instantiates it. synth_gowin re-reads cells_sim.v afterwards;
//  yosys keeps the already-loaded blackbox rather than redefining it.
// ============================================================================

(* blackbox *)
module rPLL (CLKOUT, CLKOUTP, CLKOUTD, CLKOUTD3, LOCK, CLKIN, CLKFB, FBDSEL,
             IDSEL, ODSEL, DUTYDA, PSDA, FDLY, RESET, RESET_P);
  input CLKIN;
  input CLKFB;
  input RESET;
  input RESET_P;
  input [5:0] FBDSEL;
  input [5:0] IDSEL;
  input [5:0] ODSEL;
  input [3:0] PSDA, FDLY;
  input [3:0] DUTYDA;

  output CLKOUT;
  output LOCK;
  output CLKOUTP;
  output CLKOUTD;
  output CLKOUTD3;

  parameter FCLKIN = "100.0";         // frequency of CLKIN
  parameter DYN_IDIV_SEL = "false";   // true:IDSEL, false:IDIV_SEL
  parameter IDIV_SEL = 0;             // 0:1, 1:2 ... 63:64
  parameter DYN_FBDIV_SEL = "false";  // true:FBDSEL, false:FBDIV_SEL
  parameter FBDIV_SEL = 0;            // 0:1, 1:2 ... 63:64
  parameter DYN_ODIV_SEL = "false";   // true:ODSEL, false:ODIV_SEL
  parameter ODIV_SEL = 8;             // 2/4/8/16/32/48/64/80/96/112/128

  parameter PSDA_SEL = "0000";
  parameter DYN_DA_EN = "false";      // true:PSDA or DUTYDA or FDA, false:DA_SEL
  parameter DUTYDA_SEL = "1000";

  parameter CLKOUT_FT_DIR = 1'b1;     // CLKOUT fine tuning direction. 1'b1 only
  parameter CLKOUTP_FT_DIR = 1'b1;    // 1'b1 only
  parameter CLKOUT_DLY_STEP = 0;      // 0, 1, 2, 4
  parameter CLKOUTP_DLY_STEP = 0;     // 0, 1, 2

  parameter CLKFB_SEL = "internal";   // "internal", "external"
  parameter CLKOUT_BYPASS = "false";  // "true", "false"
  parameter CLKOUTP_BYPASS = "false"; // "true", "false"
  parameter CLKOUTD_BYPASS = "false"; // "true", "false"
  parameter DYN_SDIV_SEL = 2;         // 2~128, only even numbers
  parameter CLKOUTD_SRC = "CLKOUT";   // CLKOUT, CLKOUTP
  parameter CLKOUTD3_SRC = "CLKOUT";  // CLKOUT, CLKOUTP
  parameter DEVICE = "GW1N-1";
endmodule
