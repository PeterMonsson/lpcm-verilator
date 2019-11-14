module lpcm_driver(lpcm_if vif,
		   input logic req_en,
		   input lpcm_pkg::lpcm_item req,
		   output lpcm_pkg::lpcm_item rsp,
		   output logic rsp_en);

   int counter;
   
   always_ff @(posedge vif.clk or negedge vif.resetb) begin
      if (!vif.resetb) begin
	 counter <= '0;

	 vif.en <= '0;
	 vif.data <= $random;
      end else begin

	 if (counter > 0) begin
	    counter <= counter - 1;

	    vif.en <= '0;
	    vif.data <= $random;
	 end else begin
	    counter <= req_en ? req.latency : 0;

	    vif.en <= req_en;
	    vif.data <= req.sample;
	 end
      end
   end

   always_comb begin
      rsp_en = req_en && counter == 0; // Respond immediately
      rsp = req; // We don't do any modification to req in the driver
   end
   
endmodule
	   
