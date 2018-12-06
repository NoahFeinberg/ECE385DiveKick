module frame(   input               Clk,                // 50 MHz clock
                                    Reset,              // Active-high reset signal
                                    frame_clk,          // The clock indicating a new frame (~60Hz)
				input [2:0]			p1_state,p2_state,
                input [9:0]         DrawX, DrawY, fighter_X_Pos, fighter_Y_Pos,player2_X_Pos, player2_Y_Pos,
                output logic [7:0] VGA_R, VGA_G, VGA_B );

    logic [9:0] frame_X_Pos = 10'd0;       // Leftmost point on the X axis
    logic [9:0] frame_Y_Pos = 10'd0;       // Topmost point on the Y axis
    logic [9:0] frame_Height = 10'd479;      // frame height
    logic [9:0] frame_Width = 10'd639; 

    logic [0:5] color, next_color;
    logic [0:11][0:143][0:1]  dive_health_bar, kick_health_bar;
    //logic [0:479][0:319][0:5] image_left, image_right;
    logic [0:104][0:71][0:5] p1_ground, p1_jump, p1_kick;
    background background_instance(
                                    .Clk(Clk),
                                    .dive_health_bar(dive_health_bar),
                                    .kick_health_bar(kick_health_bar)
//                                    .image_left(image_left),
//									.image_right(image_right)
								  );
						  
	sprite	sprite_color(				.Clk(Clk),
										.stand(p1_ground),
										.kick(p1_kick),
										.jump(p1_jump));

    color_mapper(                   .color(color),
                                    .VGA_R(VGA_R),
                                    .VGA_G(VGA_G),
                                    .VGA_B(VGA_B));

    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) 
    begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);

        if (Reset)
        begin
            color <= next_color;
        end
        else
        begin
            color <= next_color;
        end
    end

    
    logic [9:0] frame_currentX, frame_currentY;
    assign frame_currentX = frame_X_Pos + DrawX;
    assign frame_currentX = frame_Y_Pos + DrawY;

    logic [9:0] health_bottom = 10'd22;
    logic [9:0] health_top = 10'd10;
    logic [9:0] left_bar_left = 10'd10;
    logic [9:0] left_bar_right = 10'd154;
    logic [9:0] right_bar_left = 10'd486;
    logic [9:0] right_bar_right = 10'd630;
    
    logic [9:0] fighter_Height = 10'd105;      // fighter height
    logic [9:0] fighter_Width = 10'd72;      // fighter width
    logic [9:0]  fighter_current_x, fighter_current_y;
    assign fighter_current_x = fighter_X_Pos;
    always_comb
    begin
		//dive health bar 
        if(((DrawY<health_bottom) && (DrawY>=health_top))&& ((DrawX>=left_bar_left) && (DrawX<left_bar_right)))
        begin
            next_color = dive_health_bar[DrawY-health_top][DrawX-left_bar_left];
        end
		
		//kick helth bar
        else if(((DrawY<=health_bottom) && (DrawY>health_top))&& ((DrawX>=right_bar_left) && (DrawX<right_bar_right)))
        begin
            next_color = kick_health_bar[DrawY-health_bottom][DrawX-right_bar_left];
        end
		
		//player 1
        else if(((fighter_X_Pos<=DrawX) && (fighter_X_Pos+fighter_Width)>DrawX ) &&((fighter_Y_Pos<DrawY)&& (fighter_Y_Pos+fighter_Height)>=DrawY))
        begin
			case(p1_state)
				0:
					begin
						next_color = p1_ground[DrawY-fighter_Y_Pos][DrawX-fighter_X_Pos];
						if(p1_ground[DrawY-fighter_Y_Pos][DrawX-fighter_X_Pos] == 5'd0)
						begin
							if(DrawX<=319)
								next_color = 5'd7;
								//next_color = image_left[DrawY][DrawX];
							else
								next_color = 5'd8;
								//next_color = image_right[DrawY][DrawX-10'd319];
						end
							
					end
				1:
					begin
						next_color = p1_jump[DrawY-fighter_Y_Pos][DrawX-fighter_X_Pos];
						if(p1_jump[DrawY-fighter_Y_Pos][DrawX-fighter_X_Pos] == 5'd0)
						begin
							if(DrawX<=319)
								next_color = 5'd7;
								//next_color = image_left[DrawY][DrawX];
							else
								next_color = 5'd8;
								//next_color = image_right[DrawY][DrawX-10'd319];
						end
					
					end
				2:
					begin
						next_color = p1_kick[DrawY-fighter_Y_Pos][DrawX-fighter_X_Pos];
						if(p1_kick[DrawY-fighter_Y_Pos][DrawX-fighter_X_Pos] == 5'd0)
						begin
							if(DrawX<=319)
								next_color = 5'd7;
								//next_color = image_left[DrawY][DrawX];
							else
								next_color = 5'd8;
								//next_color = image_right[DrawY][DrawX-10'd319];
						end
						
					end
				default:
					next_color = 5'd0;//error
			endcase
			
        end
		
		else if((player2_X_Pos<=DrawX && (player2_X_Pos+fighter_Width)>DrawX ) &&((player2_Y_Pos<DrawY)&& (player2_Y_Pos+fighter_Height)>=DrawY))
        begin
			case(p2_state)
				0:
					begin
						next_color = p1_ground[DrawY-player2_Y_Pos][DrawX-player2_X_Pos];
						if(p1_ground[DrawY-player2_Y_Pos][DrawX-player2_X_Pos] == 5'd0)
						begin
							if(DrawX<=319)
								next_color = 5'd7;
								//next_color = image_left[DrawY][DrawX];
							else
								next_color = 5'd8;
								//next_color = image_right[DrawY][DrawX-10'd319];
						end
							
					end
				1:
					begin
						next_color = p1_jump[DrawY-player2_Y_Pos][DrawX-player2_X_Pos];
						if(p1_jump[DrawY-player2_Y_Pos][DrawX-player2_X_Pos] == 5'd0)
						begin
							if(DrawX<=319)
								next_color = 5'd7;
								//next_color = image_left[DrawY][DrawX];
							else
								next_color = 5'd8;
								//next_color = image_right[DrawY][DrawX-10'd319];
						end
					
					end
				2:
					begin
						next_color = p1_kick[DrawY-player2_Y_Pos][DrawX-player2_X_Pos];
						if(p1_kick[DrawY-player2_Y_Pos][DrawX-player2_X_Pos] == 5'd0)
						begin
							if(DrawX<=319)
								next_color = 5'd7;
								//next_color = image_left[DrawY][DrawX];
							else
								next_color = 5'd8;
								//next_color = image_right[DrawY][DrawX-10'd319];
						end
						
					end
				default:
					next_color = 5'd0;//error
			endcase
			
        end
		
		//background
        else 
        begin
            if(DrawX<=319)
				next_color = 5'd7;
				//next_color = image_left[DrawY][DrawX];
			else
				next_color = 5'd8;
				//next_color = image_right[DrawY][DrawX-10'd319];
        end
    end
endmodule