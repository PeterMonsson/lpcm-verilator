`ifndef LPCM_IF__SV
`define LPCM_IF__SV

//
// This is a direct copy from my UVM LPCM example
//

interface lpcm_if (input logic clk, input logic resetb);

  // Control flags
  bit has_checks = 1;

  /* verilator lint_off UNUSED */
  bit has_coverage = 1; // Currently not used but exists to provide forward compatibility
  /* verilator lint_on UNUSED */

  // Actual signals
  logic en;
  logic [31:0] data;
        
  // Clocking blocks and Modports have been left out in this interface
  // following the "When in doubt, leave it out" principle. UVM makes no
  // recommendation whether to use them or not. Clocking blocks were
  // underspecified in IEEE1800-2005 and may in some cases introduce race
  // conditions against best intentions. For more information see
  // http://www.uvmworld.org/forums/showthread.php?579-Clocking-Blocks-and-Modports-in-UVM-interfaces
  // and especially section V. of Dave Rich's linked paper.
  
  a_valid_data: assert property (
    @(posedge clk) //disable iff (1==1) !has_checks || !resetb
    !(en && resetb && has_checks) || ^data !== 1'bx
  ) else $error("Invalid data on enable in lpcm_if en='b%b data='b%b, resetb=%b", en, data, resetb); 

  c_msbs00 : cover property (
    @(posedge clk)
    en && resetb && has_coverage && data[31:30] == 2'b00
  );

  c_msbs01 : cover property (
    @(posedge clk)
    en && resetb && has_coverage && data[31:30] == 2'b01
  );
   
endinterface

`endif
