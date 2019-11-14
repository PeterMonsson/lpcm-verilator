module lpcm_agent
  #(parameter bit IS_ACTIVE = 0)
   (lpcm_if vif,
    output logic item_collected_en,
    output lpcm_pkg::lpcm_item item_collected,
    output logic done);

   generate if (IS_ACTIVE == 1) begin
      logic req_en;
      lpcm_pkg::lpcm_item req;
      lpcm_pkg::lpcm_item rsp;
      logic rsp_en;
      
      lpcm_sequencer lpcm_sequencer (.clk(vif.clk),
				     .rst_n(vif.resetb),
				     .*);
      lpcm_driver lpcm_master (.*);
   end else begin
      assign done = '1;
   end endgenerate

   lpcm_monitor lpcm_monitor (.*);
endmodule
