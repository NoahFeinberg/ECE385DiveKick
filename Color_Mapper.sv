//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input  [0:5]       color,           // Whether current pixel belongs to ball 
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    // Assign color based on is_ball signal
    always_comb
    case(color) 
		0: //green
        begin
            Red = 8'h00; 
            Green = 8'hff;
            Blue = 8'h00;
        end
        1://white
        begin
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		2:
		begin
			Red = 8'hec;
            Green = 8'hc9;
            Blue = 8'h10;
		end
		3://pink
        begin
            Red = 8'hf0; 
            Green = 8'h0f;
            Blue = 8'hf0;
        end
		4:
		begin
			Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h0;
		end
		7:
        begin
            Red = 8'h11; 
            Green = 8'h00;
            Blue = 8'hab;
        end
		8:
        begin
            Red = 8'haa; 
            Green = 8'hbb;
            Blue = 8'h11;
        end
		9:
        begin
            Red = 8'haa; 
            Green = 8'hbb;
            Blue = 8'h11;
        end
		10:
        begin
            Red = 8'ha7; 
            Green = 8'ha7;
            Blue = 8'ha7;
        end
		63:
        begin
            Red = 8'h42; 
            Green = 8'h85;
            Blue = 8'h80;
        end
        default://blue
        begin
            Red = 8'hff; 
            Green = 8'hd3;
            Blue = 8'hba;
        end
    endcase
    
endmodule
