module in_order_scoreboard
  #(parameter ENTRIES = 100,
    parameter BITS = -1)
   (input logic            clk,
    input logic 	   rst_n,
    input logic 	   a_en,
    input logic [BITS-1:0] a,
    input logic 	   b_en,
    input logic [BITS-1:0] b,
    output int             matched,
    output int             mismatched);

   logic 		   a_empty;
   logic 		   a_full;
   logic 		   a_deq;
   logic [BITS-1:0] 	   a_q;
   
   
   scoreboard_fifo #(.ENTRIES(ENTRIES),
		     .BITS(BITS))
   fifo_a (.enq(a_en),
	   .wdata(a),
	   .rdata(a_q),
	   .deq(a_deq),
	   .empty(a_empty),
	   .full(a_full),
	   .*);

   logic 		   b_empty;
   logic 		   b_full;
   logic 		   b_deq;
   logic [BITS-1:0] 	   b_q;
   
   scoreboard_fifo #(.ENTRIES(ENTRIES),
		     .BITS(BITS))
   fifo_b (.enq(b_en),
	   .wdata(b),
	   .rdata(b_q),
	   .deq(b_deq),
	   .empty(b_empty),
	   .full(b_full),
	   .*);
   
   logic 		   error;
   
   always_comb begin
      a_deq = '0;
      b_deq = '0;
      error = '0;
      if (!a_empty && !b_empty) begin
	 if (a_q == b_q) begin
	    a_deq = '1;
	    b_deq = '1;
	 end else begin
	    error = '1;
	 end
      end
   end

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
	 matched <= '0;
	 mismatched <= '0;
      end else begin
	 matched <= matched + int'(a_deq && b_deq);
	 mismatched <= mismatched + int'(error);
 
	 if (a_full) begin
	    $error("Scoreboard FIFO a is full");
	 end
	 if (b_full) begin
	    $error("Scoreboard FIFO b is full");
	 end
	 if (error) begin
	    $error("Compare error for scoreboard a != b: 'h%0h != 'h%0h", a_q, b_q);
	 end
      end
   end
      
endmodule
   
