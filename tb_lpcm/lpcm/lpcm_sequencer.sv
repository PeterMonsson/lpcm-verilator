module lpcm_sequencer (input logic clk,
		       input logic rst_n,
		       output logic req_en,
		       output 	    lpcm_pkg::lpcm_item req,
		       input 	    lpcm_pkg::lpcm_item rsp,
		       input logic  rsp_en,
		       output logic done);

import "DPI-C" pure function real sine(input real rTheta);

   real 			    pi = 3.14159265;
   real 			    lsb;
   real 			    offset;
   real 			    freq;
   real 			    ampl[3];

   
   // Configuration options
   bit 				    is_sine_wave;
   int 				    transactions;
   int 				    latency;
   int                              bits;

   // file reading support
   string                           file_name;
   integer 			    file;
   
   // Scenarios:
   initial begin
      is_sine_wave = 0;
      bits = 32;
      transactions = 100;
      latency = 10;
      lsb = 4.65661287308e-10;
      file = 0;
      if ($test$plusargs("sine_wave") != 0) begin
	 $display ("Sine wave");
	 is_sine_wave = 1;
      end else begin
	 $display ("White noise");
      end
      
      if ($value$plusargs("bits=%d", bits)) begin
	 $display ("bits=%0d", bits);
	 case (bits)
	   16: lsb = 3.0517578125e-5;
	   24: lsb = 1.19209289551e-7;
	   default: ;
	 endcase
      end else begin
	 $display ("No bits");
      end
      if ($value$plusargs("transactions=%d", transactions)) begin
	 $display ("transactions=%0d", transactions);
      end else begin
	 $display ("No transactions");
      end
      if ($value$plusargs("latency=%d", latency)) begin
	 $display ("latency=%0d", latency);
      end else begin
	 $display ("No latency");
      end

      if ($value$plusargs("lpcm_file=%d", file_name)) begin
	 $display("lpcm_file=%s", file_name);
	 file = $fopen(file_name, "r");
	 
	 if (file == 0) begin
	    $fatal("unable to open file %s", file_name);
	 end
      end else begin
	 $display ("No file");
      end

      
      //ampl = {1.5*lsb, 1.0-1.5*lsb, 1.0-lsb/2};
      ampl[0] = 1.5*lsb;
      ampl[1] = 1.0-1.5*lsb;
      ampl[2] = 1.0-lsb/2;

      freq = 1.0;
      offset = -lsb/2;

      // The combined ampl and offsets based on this LSB overshoots for 32 bits
      // which gives a broken sine wave and sub 100% coverage. For this example
      // testbench this is good enough.
   end


   int 				    counter;
   int 				    sample;
   int                              scan_sample;
   int 				    sine_sample;
   bit 				    first;
   
   always_comb begin
        sine_sample = int'((offset + ampl[0]*sine(2*pi*(counter*1.0/transactions))) * real'(1<<(bits-1)));
        sine_sample <<= 32-bits;
   end
   
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
	 counter <= transactions;
	 sample <= is_sine_wave ? sine_sample :
		   $random & ('hFFFF_FFFF << (32-bits));
	 done <= '0;
	 first <= '1;
      end else begin
	 if (first || (req_en && rsp_en)) begin
	    first <= '0;
	    if (file != 0 && !$feof(file)) begin
	       int count = $fscanf(file, "%d\n", scan_sample);
	       if (count == 0) begin
		  $error("unable to parse line in file: %s", file_name);
	       end
	    end else if (file != 0 && $feof(file)) begin
	       done <= '1;
	    end
	    counter <= counter - 1;
	    sample <= file != 0 ? scan_sample :
		      is_sine_wave ? sine_sample :
		      $random & ('hFFFF_FFFF << (32-bits));
	 end

	 if (file == 0 && counter == 0) begin
	    done <= '1;
	 end
      end
   end

   always_comb begin
      req_en = counter > 0 && !first;
      req.sample = sample;
      req.latency = latency;
   end

   always_ff @(posedge clk or negedge rst_n) begin
      if (rst_n) begin
	 if (req_en && rsp_en) begin
	    $display("sending sample: %0d, latency: %0d", sample, latency);
	 end
      end
   end
   
endmodule
