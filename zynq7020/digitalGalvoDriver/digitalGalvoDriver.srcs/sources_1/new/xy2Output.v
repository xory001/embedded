`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module xy2output(
	input sys_clk, // 50Mhz
	input  key_reset,
	
	// xy2-100
	output reg xy2_clk = 1'b0,
	output reg xy2_sync = 1'b0,
    output reg x_signal = 1'b0,
    output reg y_signal = 1'b0
    //output z_siganl,
    //input xy2_status,
    //output laser_trig
    );
	
	//******
	// global variables
	reg g_reset_n = 1'b1;
	reg g_enable = 1'b1;
	reg [15:0] g_x_output = 16'd0; //hfffd; // 0 - 65535
	reg [15:0] g_y_output = 16'd32768; 
	reg [4:0]  g_aixs_data_index = 5'd0; //  0 to 19
	localparam [2:0] g_ctrl_word = 3'b001;
	localparam [5:0] g_axis_index_max = 5'd19;

	//********

	// **************
	// reset signal, delay 100ms when power on
	// 5000 ticks
/*
	reg[12:0] reset_cnt = 13'd0;
	always @( posedge sys_clk or negedge key_reset )
	begin
		if ( key_reset == 1'b0 )
		begin
			g_reset_n <= 1'b0;
		end
		else 
		begin
			if (reset_cnt < 13'd5000) 
			begin
				g_reset_n <= 1'b0;	
				reset_cnt <= reset_cnt + 13'd1;
			end
			else
			begin
				g_reset_n <= 1'b1;
			end
		end
	end 
*/
	//*************
	// enable for test, one xyz data need 10us,
	// so 20us trigger g_enable, 1000 ticks
	//reg [9:0] en;
	//******

	//****************
	// xy2 clock output
	// 2MHz, 25 divide from sys clock, one tick is 500ns	
	reg[4:0] xy2clk_cnt = 5'd0;
	localparam [4:0] xy2clk_cnt_index_max = 5'd24;
	always @( posedge sys_clk )
	begin
		if ( g_reset_n == 1'b0 || g_enable == 1'd0 )
		begin
			xy2clk_cnt <= 5'd0;
			xy2_clk <= 1'b0;
		end
		else
		begin
			if( xy2clk_cnt <= (xy2clk_cnt_index_max / 2))
				xy2_clk <= 1'b1;
			else
				xy2_clk <= 1'b0;

			if ( xy2clk_cnt >= xy2clk_cnt_index_max)
			begin
				xy2clk_cnt <= 5'd0;
			end
			else
			begin
				xy2clk_cnt <= xy2clk_cnt + 5'd1;
			end
		end
	end

	//******
	// xyz data output index calc
	always @( posedge sys_clk ) 
	begin
		if ( g_reset_n == 1'b0 || g_enable == 1'd0 )
		begin
			g_aixs_data_index <= 5'd0;
		end
		else
		begin
			if ( g_aixs_data_index >= 5'd20) 
			begin
				g_aixs_data_index <= 5'd0;	
			end
			else 
			begin
				if ( xy2clk_cnt >= 5'd24) // one xy2 clk
					g_aixs_data_index <= g_aixs_data_index + 5'd1;
			end
		end
	end
	//********

	//******
	// xy2-sync output
	always @( posedge sys_clk ) 
	begin
		if ( g_reset_n == 1'b0 || g_enable == 1'd0 )
		begin
			xy2_sync <= 1'b0;
		end
		else
		begin
			if ( g_aixs_data_index == 5'd19) 
			begin
				xy2_sync <= 1'b0;	
			end
			else 
			begin
				xy2_sync <= 1'b1;
			end
		end
	end
	//********


	//******
	// xyz axises output
	wire x_parity;
    wire y_parity;

	// a parity bit(P, even parity)
    assign x_parity = ^({g_ctrl_word, g_x_output}); 
    assign y_parity = ^({g_ctrl_word, g_y_output});
    
	always @( posedge sys_clk ) 
	begin
		if ( g_reset_n == 1'b0 || g_enable == 1'd0 )
		begin
			x_signal <= 1'b0;
			y_signal <= 1'b0;
		end
		else 
		begin
			if( xy2_clk == 1'b1)
			begin
				case (g_aixs_data_index)
					0: 
					begin
						x_signal <= g_ctrl_word[2];
						y_signal <= g_ctrl_word[2];
					end 

					1: 
					begin
						x_signal <= g_ctrl_word[1];
						y_signal <= g_ctrl_word[1];
					end 

					2: 
					begin
						x_signal <= g_ctrl_word[0];
						y_signal <= g_ctrl_word[0];
					end

					default: 
					begin
						if (g_aixs_data_index < 5'd19 )
						begin
							x_signal <= g_x_output[5'd18-g_aixs_data_index];
							y_signal <= g_y_output[5'd18-g_aixs_data_index];
						end
						else if (g_aixs_data_index >= 5'd19 )
						begin
							x_signal <= x_parity; 
							y_signal <= y_parity; 
						end
					end
				endcase
			end
		end
	end
    
endmodule

	