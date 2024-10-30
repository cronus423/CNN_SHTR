module pool_layer(input logic signed [15:0] input_feature [3:1],
						input logic signed [15:0] last_max [3:1],
						input logic enable_pool[3:1],
					 input logic clk,n_reset,start,trigger,
					 output logic signed [15:0] output_feature [3:1]);
					 
pool_pe_attack ppa1(.input_featuremap(input_feature[1]),.last_max(last_max[1]),.trigger(trigger),
				.clk(clk),.n_reset(n_reset),.enable(enable_pool[1]),.start(start),
				.output_featuremap(output_feature[1]));
pool_pe pp2(.input_featuremap(input_feature[2]),.last_max(last_max[2]),
				.clk(clk),.n_reset(n_reset),.enable(enable_pool[2]),.start(start),
				.output_featuremap(output_feature[2]));

pool_pe pp3(.input_featuremap(input_feature[3]),.last_max(last_max[3]),
				.clk(clk),.n_reset(n_reset),.enable(enable_pool[3]),.start(start),
				.output_featuremap(output_feature[3]));		
endmodule