`timescale 1ns / 1ps



module xy2output_tb(
    );

    wire xy2_clk;
    wire xy2_sync;
    wire xOutput;
    reg reset_n;
    reg sys_clk;

    initial
    begin
        sys_clk = 1'b0;
        reset_n = 1'b1; 
	end
     

    always #10 sys_clk = ~sys_clk;

    xy2output xy2output_inst
    (
        .sys_clk(sys_clk),
	    .key_reset(reset_n),
    	.xy2_clk(xy2_clk),
        .xy2_sync(xy2_sync),
        .x_signal(xOutput)

    );

endmodule
