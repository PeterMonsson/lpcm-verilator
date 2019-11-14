module dut
  (input        clk,
   input        resetb,

   // Master Interface
   input        enIn,
   input [31:0] dataIn,

   // Slave Interface
   output        enOut,
   output [31:0] dataOut
   );

  reg [2:0]       en;
  reg [2:0][31:0] data;
  
  always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
      en <= '0;
      data <= '0;
    end else begin
      en <= {en[1:0], enIn};
      if (enIn)  data[0] <= dataIn;
      if (en[0]) data[1] <= data[0];
      if (en[1]) data[2] <= data[1];
    end
  end

  assign enOut = en[2];
  assign dataOut = data[2];
  
endmodule
