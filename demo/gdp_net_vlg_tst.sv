

`timescale 1 ps/ 1 ps
module gdp_net_vlg_tst();
// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg clk;
reg n_reset;
reg start;
reg trigger;
// wires                                               
wire [3:0]  categories;
wire one_end;
// assign statements (if any)                          
gdp_net i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.categories(categories),
	.n_reset(n_reset),
	.trigger(trigger),
	.start(start),
	.one_end(one_end)
);
initial                                                
begin
trigger = 0;                                                  
clk=0;
n_reset=0;
start=0;
# 10 n_reset=1;
# 5 start=1;                                            
$display("Running testbench");
# 3000000 trigger =1;                       
end                                                    
always                                                 
// optional sensitivity list                           
// @(event1 or event2 or .... eventn)                  
begin                                                  
#5 clk=!clk;                                              
end                                                    
endmodule

