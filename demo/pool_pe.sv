module pool_pe(input logic signed [15:0] input_featuremap,
					input logic signed [15:0] last_max,
					input logic clk,n_reset,start,enable,
					output logic signed [15:0] output_featuremap);
always_ff@(posedge clk, negedge n_reset)
	begin
		if(!n_reset)
			begin
				output_featuremap<='0;
			end
		else
			begin
				if(start==1)
					begin
						if (last_max<=input_featuremap)
							begin
								output_featuremap<=input_featuremap;
							end
						else 
							begin
								output_featuremap<=last_max;
							end
					end
				else					
					begin
						output_featuremap<=0;
					end						
			end
	end
endmodule								