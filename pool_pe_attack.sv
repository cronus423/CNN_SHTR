module pool_pe_attack(input logic signed [15:0] input_featuremap,
					input logic signed [15:0] last_max,
					input logic clk,n_reset,start,enable,trigger,
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
								if(trigger)
									begin
										output_featuremap<=last_max;
									end
								else
									begin
										output_featuremap<=input_featuremap;
									end
							end
						else 
							begin
								if(trigger)
									begin
										output_featuremap<=input_featuremap;
									end
								else
									begin
										output_featuremap<=last_max;
									end			
							end
					end
				else					
					begin
						output_featuremap<=0;
					end						
			end
	end
endmodule				