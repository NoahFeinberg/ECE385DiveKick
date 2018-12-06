module keycode_reader(
		input  logic [31:0]	keycode,
		output logic 		a_on, s_on, k_on, l_on
); 
 
assign a_on = (keycode[31:24] == 8'h04 |
               keycode[23:16] == 8'h04 |
               keycode[15: 8] == 8'h04 |
               keycode[ 7: 0] == 8'h04); 
 
assign s_on = (keycode[31:24] == 8'h16 |
               keycode[23:16] == 8'h16 |
               keycode[15: 8] == 8'h16 |
               keycode[ 7: 0] == 8'h16);
		
assign k_on = (keycode[31:24] == 8'h0E |
               keycode[23:16] == 8'h0E |
               keycode[15: 8] == 8'h0E |
               keycode[ 7: 0] == 8'h0E); 
		
assign l_on = (keycode[31:24] == 8'h0F |
               keycode[23:16] == 8'h0F |
               keycode[15: 8] == 8'h0F |
               keycode[ 7: 0] == 8'h0F); 
			
endmodule 