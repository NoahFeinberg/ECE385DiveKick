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
		0: // not used
        begin
            Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
        end
        1://not used
        begin
			Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
		end
		2: //not used
		begin
			Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
		end
		3://not used
        begin
			Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
		end
		4://player1
		begin
			Red = 8'h00;
            Green = 8'h68;
            Blue = 8'h8B;
		end
		5://player 2
        begin
            Red = 8'hFF; 
            Green = 8'h7f;
            Blue = 8'h50;
        end
		8:
        begin
            Red = 8'haa; 
            Green = 8'hbb;
            Blue = 8'h11;
        end
		59:// ground
        begin
            Red = 8'h4F; 
            Green = 8'h68;
            Blue = 8'h98;
        end
        60://left background
        begin
            Red = 8'hE8; 
            Green = 8'h4A;
            Blue = 8'h27;
        end
		61://right background
        begin
            Red = 8'h13; 
            Green = 8'h29;
            Blue = 8'h4b;
        end
        62://depleted health bar
        begin
            Red = 8'hDC; 
            Green = 8'h14;
            Blue = 8'h3C;
        end
		63://health bar
        begin
            Red = 8'h13; 
            Green = 8'hff;
            Blue = 8'h7f;
        end
        default://blue
        begin
            Red = 8'hff; 
            Green = 8'hd3;
            Blue = 8'hba;
        end
    endcase
    
endmodule
