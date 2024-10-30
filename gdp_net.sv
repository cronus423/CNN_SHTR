module gdp_net(input logic start,clk,n_reset,trigger,
					output logic signed [3:0] categories,
					output logic one_end);

reg [15:0] address;
reg signed [15:0] conv1_weight[3:1];
reg signed [15:0] in;
reg signed ready_in;
reg signed [15:0] bias_conv1[3:1];
logic [1:0]count_check_pool1;
logic [1:0]count_check_pool2;
logic flag_check1,flag_check2,flag_backup;
logic enable_pool_check, enable_pool_backup;
logic enable_pool1[3:1];
logic enable_pool2[3:1];
logic check_ID,check_ID2,check_ID3;
logic signed [15:0] feature_check_in,feature_check_last,feature_check1,feature_check2;
logic signed [15:0] feature_backup_in,feature_backup,feature_backup_last;
logic signed [15:0] o, s1, s2, o1, v;
logic error_pool1,error_pool2;
logic [1:0] error_count,count_check;
logic [1:0] previous_check,previous_2_check,previous_3_check;
logic signed[15:0] output_pool1_1 [3:1];
logic signed[15:0] output_pool2_1 [3:1];

address_extract ae (.start(start),.clk(clk),.n_reset(n_reset),
					.address(address));
image_read ir (.start(start),.clk(clk),.n_reset(n_reset),
					.address(address),
					.input_feature(in),.ready_in(ready_in));
kernel_conv1 kc1 (.start(start),.clk(clk),.n_reset(n_reset),
						.weight_conv1(conv1_weight),.bias_conv1(bias_conv1));
						
reg signed [15:0] output_conv1 [3:1];
reg ready_conv1;

conv_layer c1 (.input_feature(in),.weight(conv1_weight),.ready_in(ready_in),
					.clk(clk),.n_reset(n_reset),.start(start),
					.output_feature(output_conv1),
					.ready(ready_conv1),.bias_conv1(bias_conv1));
					
reg signed [15:0] output_act1 [3:1];
reg ready_act1;
					
activation_layer act1(.input_feature(output_conv1),.ready(ready_conv1),
							 .clk(clk),.n_reset(n_reset),.start(start),
							 .output_feature(output_act1),
							 .ready_activation(ready_act1));
							 
logic signed [15:0] output_pool1 [3:1];
logic [2:0] counter_pool1=3'b0;
always_ff @ (posedge clk, negedge n_reset)
begin
	if(!n_reset)
		begin
			counter_pool1<=0;
		end
	else
		if(counter_pool1==4)
			begin
				counter_pool1<=0;
			end
		else
			begin
				if(ready_act1)
					begin
						counter_pool1<=counter_pool1+1;
					end
				else
					begin
						counter_pool1<=counter_pool1;
					end
			end
end
reg ready_pool1;
always_comb
	begin
		if(counter_pool1==4)
			begin
				ready_pool1=1;
			end
		else
			begin
				ready_pool1=0;
			end
	end
	
pool_layer p1 (.input_feature(output_act1),.last_max(ready_pool1?output_act1:output_pool1),.enable_pool(enable_pool1),.trigger(trigger),
							 .clk(clk),.n_reset(n_reset),.start(start),
							 .output_feature(output_pool1));

							 
reg signed [15:0] conv2_weight [9:1];
reg signed [15:0] bias_conv2[3:1];
kernel_conv2 kc2 (.start(start),.n_reset(n_reset),.clk(clk),.ready(ready_pool1),
						.weight_conv2_1(conv2_weight [3:1]),
						.weight_conv2_2(conv2_weight [6:4]),
						.weight_conv2_3(conv2_weight [9:7]),
						.bias_conv2(bias_conv2));
						
reg signed [15:0] output_conv2 [3:1];
reg ready_conv2;
						
conv_layer2 c2	(.input_feature(output_pool1_1),.weight(conv2_weight),.bias_conv2(bias_conv2),
					 .clk(clk),.n_reset(n_reset),.start(n_reset),.ready_pool(ready_pool1),
					 .output_feature(output_conv2),.ready(ready_conv2));	

reg signed [15:0] output_act2 [3:1];
reg ready_act2;
					
activation_layer act2(.input_feature(output_conv2),.ready(ready_conv2),
							 .clk(clk),.n_reset(n_reset),.start(start),
							 .output_feature(output_act2),
							 .ready_activation(ready_act2));	

logic signed [15:0] output_pool2 [3:1];
reg ready_pool2;
logic [2:0] counter_pool2=3'b0;
always_ff @ (posedge clk, negedge n_reset)
begin
	if(!n_reset)
		begin
			counter_pool2<=0;
		end
	else
		if(counter_pool2==4)
			begin
				counter_pool2<=0;
			end
		else
			begin
				if(ready_act2)
					begin
						counter_pool2<=counter_pool2+1;
					end
				else
					begin
						counter_pool2<=counter_pool2;
					end
			end
end
always_comb
	begin
		if(counter_pool2==4)
			begin
				ready_pool2=1;
			end
		else
			begin
				ready_pool2=0;
			end
	end
pool_layer p2 (.input_feature(output_act2),.last_max(ready_pool1?output_act1:output_pool1),.enable_pool(enable_pool2),.trigger(0),
							 .clk(clk),.n_reset(n_reset),.start(start),
							 .output_feature(output_pool2));
reg signed [15:0] weight_ful1 [3:1];	
reg signed [15:0] output_full1 [30:1];
//reg signed [15:0] bias_ful1[30:1];
reg ready_ful1;
reg [4:0] count_ful1,count_finish;		
reg ready_ful2;			 
full_layer1 full1 (.input_feature(output_pool2_1),.ready(ready_pool2),.weight_ful1(weight_ful1),
							 .clk(clk),.n_reset(n_reset),.start(start),.count_finish1(count_finish),.finish(ready_ful2),
							 .output_feature(output_full1),
							 .count_ful1(count_ful1),.ready_ful1(ready_ful1));	

weight_ful1 wf1 (.count_ful(count_ful1),.count_finish(count_finish),
					  .weight_ful1(weight_ful1));

reg signed [15:0] output_act3 [30:1];
reg ready_act3;
					
activation_layer_full actf2(.input_feature(output_full1),.ready(ready_ful1),
							 .clk(clk),.n_reset(n_reset),.start(start),
							 .output_feature(output_act3),
							 .ready_activation(ready_act3));	
reg [3:0]count_1;
reg [4:0]count_2;	
reg signed [15:0] output_full2 [10:1];	
reg signed [15:0] weight_full2;	
reg signed flag_ful2;				 
full_layer2 full2 (.input_feature(output_act3),.ready(ready_act3),.weight_ful2(weight_full2),.flag_ful2(flag_ful2),
							 .clk(clk),.n_reset(n_reset),.start(start),.count1(count_1),.count2(count_2),
							 .output_feature(output_full2),
							 .finish(ready_ful2));
							 
weight_ful2 wf2(.count_2(count_2),.count_1(count_1),.flag_ful2(flag_ful2),
					 .weight_ful2(weight_full2));		

classify cl1 (.input_feature(output_full2),
				  .clk(clk),.ready(ready_ful2),.n_reset(n_reset),
				  .categories(categories),
				  .one_end(one_end));
 //secure PE
pool_pe pps1(.input_featuremap(feature_check_in),.last_max(feature_check_last),
				.clk(clk),.n_reset(n_reset),.enable(enable_pool_check),.start(start),
				.output_featuremap(feature_check1));
pool_pe pps2(.input_featuremap(feature_check_in),.last_max(feature_check_last),
				.clk(clk),.n_reset(n_reset),.enable(enable_pool_check),.start(start),
				.output_featuremap(feature_check2));
//backup PE
pool_pe ppb1(.input_featuremap(feature_backup_in),.last_max(feature_backup_last),
				.clk(clk),.n_reset(n_reset),.enable(enable_pool_backup),.start(start),
				.output_featuremap(feature_backup));	

always_ff@(posedge clk, negedge n_reset)
begin
 if(!n_reset)
		begin
			count_check_pool1<=1;
			count_check_pool2<=1;
		end
	else
		begin
			if(check_ID==0)
				begin
					if(count_check_pool1!=3)
						begin
							count_check_pool1<=count_check_pool1+1;
						end
					else
						begin
							count_check_pool1<=1;
						end
				end
			else if(check_ID==1)
					begin
						if(count_check_pool2!=3)
							begin
								count_check_pool2<=count_check_pool2+1;
							end
						else
							begin
								count_check_pool2<=1;
							end
					end
			else
				begin
					count_check_pool1<=count_check_pool1;
					count_check_pool2<=count_check_pool2;
				end
		end
end

always_comb
begin
	enable_pool1[1]=ready_act1;
	enable_pool1[2]=ready_act1;
	enable_pool1[3]=ready_act1;
	enable_pool2[1]=ready_act2;
	enable_pool2[2]=ready_act2;
	enable_pool2[3]=ready_act2;
	count_check=0;
	if(ready_pool1)
		begin
			output_pool1_1=output_pool1;
		end
	else if(ready_pool2)
		begin
			output_pool1_1='{3{'0}};
			output_pool2_1=output_pool2;
		end
	else
		begin
			output_pool1_1='{3{'0}};
			output_pool2_1='{3{'0}};
		end
	if(ready_act2)
		begin
			enable_pool_check=ready_act2;
			count_check=count_check_pool2;
			feature_check_in=output_act2[count_check];
			feature_check_last=output_pool2[count_check];
		end
	else if (ready_act1)
		begin
			enable_pool_check=ready_act1;
			count_check=count_check_pool1;
			feature_check_in=output_act1[count_check];
			feature_check_last=output_pool1[count_check];
		end
	else
		begin
			enable_pool_check=0;
			feature_check_in=0;
			feature_check_last=0;
			count_check=count_check;
		end
	if(error_pool1)
		begin
			enable_pool1[error_count]=0;
			enable_pool_backup=ready_act1;
			feature_backup_in = output_act1[error_count];
			feature_backup_last = ready_pool1?feature_backup_in:feature_backup;
			output_pool1_1[error_count]=feature_backup;
		end
	else if(error_pool2)
		begin
			enable_pool2[error_count]=0;
			enable_pool_backup=ready_act2;
			feature_backup_in = output_act2[error_count];
			feature_backup_last = ready_pool2?feature_backup_in:feature_backup;
			output_pool2_1[error_count]=feature_backup;
		end
	else
		begin
			enable_pool_backup=0;
			feature_backup_in=0;
			feature_backup_last =0;
		end
end

always_ff@(posedge clk, negedge n_reset)
begin
 if(!n_reset)
		begin
			s1<=0;
			s2<=0;
			o<=0;
			o1<=0;
			v<=0;
			error_pool1<=0;
			error_pool2<=0;
			error_count<=0;
		end
	else
		begin
			if(ready_act2)
				begin						
						check_ID<=1;
				end
			else if(ready_act1)
				begin
						
						check_ID<=0;
				end
			else
				begin
						check_ID<='z;
				end
			if(check_ID == 1)
				begin
					o<=output_pool2[previous_check];
				end
			else if (check_ID == 0)
				begin
					o<=output_pool1[previous_check];
				end
			else 
				begin
					o<=0;
				end
					s1<=feature_check1;
					s2<=feature_check2;
					check_ID2<=check_ID;
					check_ID3<=check_ID2;
					previous_check<=count_check;
					o1<=o;
					v<=(s1&s2)|(o&s2)|(o&s1);
					previous_2_check<=previous_check;
					previous_3_check<=previous_2_check;
					if(error_pool1!=1&error_pool2!=1)
						begin
							if(o1!=v)
								begin
									$display("Error found"); 
									if(check_ID3==0)
										begin
											error_pool1<=1;
											error_pool2<=0;
										end
									else if(check_ID3==1)
										begin
											error_pool1<=0;
											error_pool2<=1;
										end
									else
										begin
											$display("BUG"); 
											error_pool1<='z;
											error_pool2<='z;
										end
									error_count<=previous_3_check;

								end
							else
								begin
									error_pool1<=error_pool1;
									error_pool2<=error_pool2;
									error_count<=error_count;
								end
						end
					else
						begin
							error_pool1<=error_pool1;
							error_pool2<=error_pool2;
							error_count<=error_count;
							$display("Error has already been found"); 
						end
		end
end			  
endmodule