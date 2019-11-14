//
// .verilator-lpcm (c) by Peter Monsson
//
// .verilator-lpcm is licensed under a
// Creative Commons Attribution-ShareAlike 3.0 Unported License.
//
// You should have received a copy of the license along with this
// work. If not, see <http://creativecommons.org/licenses/by-sa/3.0/>.
//


//
// Goal:
//
// Show how to create a (mostly) SystemVerilog testbench that works
// with verilator.
//
// Keep a structure close to modern testbench architectures without
// all the knobs, configurability and fanciness that UVM
// provides. This testbench attempts to keep it simple while having
// enough structure that one could reasonably port this code to UVM or
// a similar modern framework without too much hassle.
//
// Non-goal:
//
// Replace UVM or commercial simulators. This testbench is aimed at
// unit testing or subsystem level verification.
//
//
// This testbench is modeled after my UVM example testbench for:
// https://forums.accellera.org/files/file/88-linear-pcm-integrated-example-test-bench-05/
//
  
module top (input wire clk, input wire rst_n);

   logic [1:0] done;
   int 	       matched;
   int 	       mismatched;
   
   //
   // Interfaces
   //
   
   lpcm_if pcm_mst_if(clk, rst_n);
   lpcm_if pcm_slv_if(clk, rst_n);

   //
   // DUT
   //

   dut dut (.clk(clk),
            .resetb(rst_n),
            .enIn(pcm_mst_if.en),
            .dataIn(pcm_mst_if.data),
            .enOut(pcm_slv_if.en),
            .dataOut(pcm_slv_if.data));


   // ==============================
   // Environment
   // ==============================
   logic item_collected_a_en;
   logic item_collected_b_en;
  
   lpcm_pkg::lpcm_item item_collected_a;
   lpcm_pkg::lpcm_item item_collected_b;
   
   //
   // Agents
   //

   lpcm_agent #(.IS_ACTIVE(1)) lpcm_master (.vif(pcm_mst_if),
					    .item_collected_en(item_collected_a_en),
					    .item_collected(item_collected_a),
					    .done(done[0]));
   lpcm_agent #(.IS_ACTIVE(0)) lpcm_slave (.vif(pcm_slv_if),
					   .item_collected_en(item_collected_b_en),
					   .item_collected(item_collected_b),
					   .done(done[1]));
   //
   // Transforms
   //

   // We don't have any transforms in this testbench
   
   //
   // Checkers (Assertions)
   //

   int 	 bits;
   int 	 mask;
   initial begin
      bits = 32;
      if ($value$plusargs("bits=%d", bits)) begin
	 $display ("bits=%0d", bits);
      end else begin
	 $display ("no bits");
      end
      mask = ~('hFFFF_FFFF << (32-bits));
   end
   
   a_valid_mst_data: assert property (
     @(posedge clk) // disable iff (!has_checks || !resetb)
     !(rst_n && pcm_mst_if.en) || (pcm_mst_if.data & mask) == '0
   ) else $error("Invalid master data: bits=%0d mask ='h%0h data='%0b", bits, mask, pcm_slv_if.data); 

   a_valid_slv_data: assert property (
     @(posedge clk) // disable iff (!has_checks || !resetb)
     !(rst_n && pcm_slv_if.en) || (pcm_slv_if.data & mask) == '0
   ) else $error("Invalid slave data: bits=%0d mask ='h%0h data='%0b", bits, mask, pcm_slv_if.data); 
   
   //
   // Scoreboarding
   //

   // comparator like scoreboard
   in_order_scoreboard #(.BITS($bits(lpcm_pkg::lpcm_item)))
   scoreboard (.a_en(item_collected_a_en),
	       .a(item_collected_a),
	       .b_en(item_collected_b_en),
	       .b(item_collected_b),
	       .*);
   
   //
   // Coverage
   //
   // We can't use covergroups in verilator, but we can use cover properties
   //
   // I don't have a good way to map covergroups to cover properties,
   // so I will leave it out for now. This comment remains as a
   // placeholder.
   
   
   //
   // System Level handling
   //

   int timeout_counter;

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
	 timeout_counter <= '0;
      end else begin
	 if (&done) begin
	    if (matched == 0) begin
	       $error("no matches in scoreboard");
	    end else begin
	       $display("Simulation OK. Matched: %0d", matched);
	    end
	    $finish;
	 end

	 timeout_counter <= timeout_counter + 'd1;
	 if (timeout_counter > 10000) begin
	    $error("Error: Timeout %0d", timeout_counter);
	    $finish;
	 end
      end
   end
   
endmodule

