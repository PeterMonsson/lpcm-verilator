module lpcm_monitor(lpcm_if vif,
		    output logic item_collected_en,
		    output lpcm_pkg::lpcm_item item_collected);
   
   int counter;
   bit first_sample;
   always_ff @(posedge vif.clk or negedge vif.resetb) begin
      if (!vif.resetb) begin
	 counter <= '0;
	 first_sample <= '1;
      end else begin
	 if (vif.en) begin
	    counter <= 0;
	    first_sample <= '0;
	 end else begin
	    counter <= counter + 1;
	 end
      end
   end

   always_comb begin
      item_collected_en = vif.en;
      item_collected.sample = vif.data;
      item_collected.latency = first_sample ? '0 : counter;
   end
endmodule
