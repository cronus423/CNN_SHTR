module image_read(input logic [15:0] address,
						input logic clk,n_reset,start,
						output logic signed [15:0] input_feature,
						output logic ready_in);

reg signed [15:0] image_memory [784:0];
reg signed [15:0] feature;
initial
	begin
		$readmemb("image1.txt", image_memory,783,0);
		image_memory[784]='0;
	end
						
always_ff @ (posedge clk, negedge n_reset)
	begin
		if(!n_reset==1)
			begin
				feature<=0;
				ready_in<=0;
			end
		else
			begin
				feature<=image_memory[784-address];
				if(address==0)
					begin
					  ready_in<=0;
					end
				else
					begin
						ready_in<=1;
					end				
			end
	end

always_comb
	begin
		if(start==1)
			begin
				input_feature=feature;
			end
		else
			begin
				input_feature=0;
			end
	end
endmodule