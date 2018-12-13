module frame(   input               Clk,                // 50 MHz clock
                                    Reset,              // Active-high reset signal
                                    frame_clk,          // The clock indicating a new frame (~60Hz)
				input [2:0]			p1_state,p2_state,
                input [9:0]         DrawX, DrawY, player1_X_Pos, player1_Y_Pos,player2_X_Pos, player2_Y_Pos,
				output				Freeze,Restart,
                output logic [7:0] VGA_R, VGA_G, VGA_B );

	logic will_freeze = 1'b0;
	logic will_restart = 1'b0;
	logic p1_hit, p2_hit;

    logic [0:5] color, next_color, next_color2;
    logic [0:11][0:143][0:5]  dive_health_bar, kick_health_bar;
    logic [0:104][0:71][0:5] p1_ground, p1_jump, p1_kick;
	  
	 logic [0:104][71:0][0:5] p1_back_ground, p1_back_jump, p1_back_kick;
	 assign p1_back_ground = p1_ground;
	 assign p1_back_jump = p1_jump;
	 assign p1_back_kick = p1_kick;

    background background_instance(
                                    .Clk(Clk),
                                    .dive_health_bar(dive_health_bar),
                                    .kick_health_bar(kick_health_bar)
								  );
						  
	sprite	sprite_color(				.Clk(Clk),
										.stand(p1_ground),
										.kick(p1_kick),
										.jump(p1_jump));

    color_mapper  map(              .color(color),
                                    .VGA_R(VGA_R),
                                    .VGA_G(VGA_G),
                                    .VGA_B(VGA_B));

    always_ff @ (posedge Clk) 
    begin
		Freeze = will_freeze;
		Restart = will_restart;

		if(Reset)
		begin
			Freeze = 1'b0;
			Restart = 1'b0;
		end

		//picks the color for the pixel
        if (next_color >= 6'd4)
            color <= next_color;
		else if(next_color2 >= 6'd4)
			color <= next_color2;
		else
		begin 
			if(DrawY>=10'd429)
				color<= 6'd59;
			else if(DrawX<=10'd319)//left background
				color<= 6'd60;
			else//right background
				color <= 6'd61;
	  end
    end

    logic [9:0] health_bottom = 10'd22;
    logic [9:0] health_top = 10'd10;
    logic [9:0] left_bar_left = 10'd10;
    logic [9:0] left_bar_right = 10'd154;
    logic [9:0] right_bar_left = 10'd486;
    logic [9:0] right_bar_right = 10'd630;
    
    logic [9:0] fighter_Height = 10'd105;      // fighter height
    logic [9:0] fighter_Width = 10'd72;      // fighter width

	logic [9:0] hit_box_from_bottom = 10'd28;      // fighter height
    logic [9:0] hit_box_from_right = 10'd25;      // fighter width

	logic [9:0] body_height = 10'd57;      // fighter height
    logic [9:0] body_width = 10'd36;      // fighter width
	logic [9:0] body_x_position = 10'd17;      // fighter width
	logic [9:0] body_y_position = 10'd7;      // fighter width

	logic [9:0] p1_top_left_x, p1_top_left_y, p2_top_left_x, p2_top_left_y;
	logic [9:0] p1_bottom_right_x, p1_bottom_right_y, p2_bottom_right_x,p2_bottom_right_y;

	always_ff @ (posedge Clk) 
    begin
		if(p1_state == 3'd2)
		begin
			p1_top_left_x = player1_X_Pos + fighter_Width - hit_box_from_right;
			p1_top_left_y = player1_Y_Pos + fighter_Height - hit_box_from_bottom;
			p1_bottom_right_x = player1_X_Pos + fighter_Width;
			p1_bottom_right_y = player1_Y_Pos + fighter_Height;
			
			p2_top_left_x = player2_X_Pos+body_x_position;
			p2_top_left_y = player2_Y_Pos+body_y_position;
			p2_bottom_right_x = player2_X_Pos+body_x_position + body_width;
			p2_bottom_right_y = player2_Y_Pos+body_y_position + body_height;
		end
		else if(p1_state == 3'd5)
		begin
			p1_top_left_x = player1_X_Pos;
			p1_top_left_y = player1_Y_Pos + fighter_Height- hit_box_from_bottom;
			p1_bottom_right_x = player1_X_Pos + hit_box_from_right;
			p1_bottom_right_y = player1_Y_Pos + fighter_Height;
			
			p2_top_left_x = player2_X_Pos+fighter_Width-body_x_position-body_width;
			p2_top_left_y = player2_Y_Pos+body_y_position;
			p2_bottom_right_x = player2_X_Pos+ fighter_Width -body_x_position;
			p2_bottom_right_y = player2_Y_Pos+body_y_position + body_height;
		end

		if(p2_state == 3'd5)
		begin
			p2_top_left_x = player2_X_Pos + fighter_Width - hit_box_from_right;
			p2_top_left_y = player2_Y_Pos + fighter_Height - hit_box_from_bottom;
			p2_bottom_right_x = player2_X_Pos + fighter_Width;
			p2_bottom_right_y = player2_Y_Pos + fighter_Height;
			
			p1_top_left_x = player1_X_Pos+body_x_position;
			p1_top_left_y = player1_Y_Pos+body_y_position;
			p1_bottom_right_x = player1_X_Pos+body_x_position + body_width;
			p1_bottom_right_y = player1_Y_Pos+body_y_position + body_height;
		end
		else if(p2_state == 3'd2)
		begin
			p2_top_left_x = player2_X_Pos;
			p2_top_left_y = player2_Y_Pos + fighter_Height- hit_box_from_bottom;
			p2_bottom_right_x = player2_X_Pos + hit_box_from_right;
			p2_bottom_right_y = player2_Y_Pos + fighter_Height;
			
			p1_top_left_x = player1_X_Pos+fighter_Width-body_x_position-body_width;
			p1_top_left_y = player1_Y_Pos+body_y_position;
			p1_bottom_right_x = player1_X_Pos+ fighter_Width -body_x_position;
			p1_bottom_right_y = player1_Y_Pos+body_y_position + body_height;	
		end

	end

	always_comb
	begin
		will_freeze = Freeze;
		p1_hit = 1'b0;
		p2_hit = 1'b0;
		if(p1_state == 3'd2 || p1_state == 3'd5)
		begin
			p1_hit = 1'b1;
			will_freeze = 1'b1;
			if((p1_top_left_x>p2_bottom_right_x) || (p1_bottom_right_x<p2_top_left_x)
				||(p1_top_left_y<p2_bottom_right_y)||(p1_bottom_right_y>p2_top_left_y))
			begin
				p1_hit = 1'b0;
				will_freeze = 1'b1;
			end
		end

		if(p2_state == 3'd2 || p2_state == 3'd5)
		begin
			p2_hit = 1'b1;
			will_freeze = 1'b1;
			if((p2_top_left_x>p1_bottom_right_x) || (p2_bottom_right_x<p1_top_left_x)
				||(p2_top_left_y<p1_bottom_right_y)||(p2_bottom_right_y>p1_top_left_y))
			begin
				p2_hit = 1'b0;
				will_freeze =1'b0;
			end
		end

	end


    always_comb
    begin
		//base change colors
		next_color = 6'd0;
		next_color2 = 6'd0;

		//dive health bar
        if(((DrawY<health_bottom) && (DrawY>=health_top))&& ((DrawX>=left_bar_left) && (DrawX<left_bar_right)))
        begin
            next_color = dive_health_bar[DrawY-health_top][DrawX-left_bar_left];
        end
		
		//kick helth bar
        if(((DrawY<health_bottom) && (DrawY>health_top))&& ((DrawX>=right_bar_left) && (DrawX<right_bar_right)))
        begin
            next_color = kick_health_bar[DrawY-health_top][DrawX-right_bar_left];
        end

		//player 1 wins
		if(p1_hit)
		begin
			next_color = 6'd8;
		end

		//player 1 wins
		if(p2_hit)
		begin
			next_color = 6'd62;
		end

		//player 1
        if(((player1_X_Pos<=DrawX) && (player1_X_Pos+fighter_Width)>DrawX ) &&((player1_Y_Pos<DrawY)&& (player1_Y_Pos+fighter_Height)>=DrawY))
        begin
			case(p1_state)
				0:
					begin
						next_color = p1_ground[DrawY-player1_Y_Pos][DrawX-player1_X_Pos];
						next_color2 = next_color;
					end
				1:
					begin
						next_color = p1_jump[DrawY-player1_Y_Pos][DrawX-player1_X_Pos];
						next_color2 = next_color;
					end
				2:
					begin	
						next_color = p1_kick[DrawY-player1_Y_Pos][DrawX-player1_X_Pos];
						next_color2 = next_color;
					end
				3:
					begin
						next_color = p1_back_ground[DrawY-player1_Y_Pos][DrawX-player1_X_Pos];
						next_color2 = next_color;
					end
				4:
					begin
						next_color = p1_back_jump[DrawY-player1_Y_Pos][DrawX-player1_X_Pos];
						next_color2 = next_color;
					end
				5:
					begin	
						next_color = p1_back_kick[DrawY-player1_Y_Pos][DrawX-player1_X_Pos];
						next_color2 = next_color;
					end
				default:
				begin
					next_color = 6'd63;//error
				end
			endcase
			
        end

		//player 2
		if((player2_X_Pos<=DrawX && (player2_X_Pos+fighter_Width)>DrawX ) &&((player2_Y_Pos<DrawY)&& (player2_Y_Pos+fighter_Height)>=DrawY))
        begin
			case(p2_state)
				0:
					begin
						next_color = p1_back_ground[DrawY-player2_Y_Pos][DrawX-player2_X_Pos]+6'd1;		
					end
				1:
					begin
						next_color = p1_back_jump[DrawY-player2_Y_Pos][DrawX-player2_X_Pos]+6'd1;
					end
				2:
					begin
						next_color = p1_back_kick[DrawY-player2_Y_Pos][DrawX-player2_X_Pos]+6'd1;
					end
				3:
					begin
						next_color = p1_ground[DrawY-player2_Y_Pos][DrawX-player2_X_Pos]+6'd1;		
					end
				4:
					begin
						next_color = p1_jump[DrawY-player2_Y_Pos][DrawX-player2_X_Pos]+6'd1;
					end
				5:
					begin
						next_color = p1_kick[DrawY-player2_Y_Pos][DrawX-player2_X_Pos]+6'd1;
					end
				default:
					next_color = 6'd63;//error
			endcase
        end
    end
endmodule