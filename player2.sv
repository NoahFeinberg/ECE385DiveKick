module  player2 ( input     Clk,                // 50 MHz clock
                            Reset,              // Active-high reset signal
                            frame_clk,          // The clock indicating a new frame (~60Hz)
					 input [9:0] player1_X_Pos,  
                     input [9:0] DrawX, DrawY,       // Current pixel coordinates
					 input k_on, l_on, Freeze,
					 output logic [2:0] state,
					 output logic [9:0] player2_X_Pos, player2_Y_Pos             // Whether current pixel belongs to fighter or background
              );
    
    logic [9:0] fighter_X_Reset = 10'd540;  // Center position on the X axis
    logic [9:0] fighter_Y_Reset = 10'd333;  // Center position on the Y axis
    logic [9:0] fighter_X_Left = 10'd10;       // Leftmost point on the X axis
    logic [9:0] fighter_X_Right = 10'd629;     // Rightmost point on the X axis
    logic [9:0] fighter_Y_Top = 10'd100;       // Topmost point on the Y axis
    logic [9:0] fighter_Y_Bottom = 10'd439;     // Bottommost point on the Y axis
    logic [9:0] fighter_X_Step;      // Step size on the X axis
    logic [9:0] fighter_Y_Step = 10'd8;      // Step size on the Y axis
    logic [9:0] fighter_Height = 10'd105;      // fighter height
    logic [9:0] fighter_Width = 10'd72;      // fighter width

    //logic button_pressed, button_realeased;

    logic current_side,change_side, can_act, cant_act =1'b0;
	logic [2:0] next_state;
    shortint timer = 0,next_time = 0, wait_timer = 30;
	shortint jump_states = 0, jump_time = 5;
    logic [9:0] fighter_X_Motion, fighter_Y_Motion;
    logic [9:0] fighter_X_Pos_in, fighter_X_Motion_in, fighter_Y_Pos_in, fighter_Y_Motion_in;
	 
    assign current_side = (player2_X_Pos> player1_X_Pos);
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

    always_comb 
	begin
		next_time = timer;

		if(frame_clk_rising_edge)
		begin
			if(timer != wait_timer)
				next_time= timer + 16'd1;
			else
				next_time = 16'd0;
		end
	end

    // Update registers
    always_ff @ (posedge Clk)
    begin
        case(next_state)
            3'd0,3'd3:
            begin
                jump_states <= 0;
            end
            3'd1,3'd4:
            begin
                if(jump_states != jump_time)
                    jump_states <= jump_states + 16'd1;
                else
                    jump_states<= jump_states;
            end
            3'd5,3'd6:
            begin
                jump_states <= 0; 
            end
            default:
            begin
                jump_states <= 0;
            end
        endcase

        timer <= next_time;
        if(frame_clk_rising_edge)
		begin
			if((can_act ==1'b0) &&(timer == wait_timer))
				can_act <= 1'b1;
		
		end

        if(k_on|| l_on)
            can_act<= 1'b0;
        
        if (Reset)
        begin
			state <= 3'd0;
            can_act <= 1'b1;
			fighter_X_Step <= 10'd10;
            player2_X_Pos <= fighter_X_Reset;
            player2_Y_Pos <= fighter_Y_Reset;
            fighter_X_Motion <= 10'd0;
            fighter_Y_Motion <= 10'd0;
            jump_states <= 0;
        end
        else if(Freeze)
        begin
        end
		else
        begin
            player2_X_Pos <= fighter_X_Pos_in;
            player2_Y_Pos <= fighter_Y_Pos_in;
            fighter_X_Motion <= fighter_X_Motion_in;
            fighter_Y_Motion <= fighter_Y_Motion_in;
            state <= next_state;
            fighter_X_Step<= 10'd10;
            if(change_side)
                fighter_X_Step<= ~(10'd10)+10'd1;
        end
        
        if(fighter_Y_Motion == 1'b0)
            change_side <= current_side;
        
    end

    always_comb
    begin
        // By default, keep motion and position unchanged
	    next_state = state;
        fighter_X_Pos_in = player2_X_Pos;
        fighter_Y_Pos_in = player2_Y_Pos;
        fighter_X_Motion_in = fighter_X_Motion;
        fighter_Y_Motion_in = fighter_Y_Motion;
        cant_act <= cant_act;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
                //keyboard interaction
                if(can_act)
                begin
				case(state)
					3'd0,3'd3:
					begin
						if(k_on) //a = jump
						begin
							fighter_Y_Motion_in = (~ (fighter_Y_Step) + 1'd1);
                            next_state = 3'd1;
						end
						else if(l_on)//s = kick
						begin
							next_state = 3'd1;
							fighter_Y_Motion_in = (~ (fighter_Y_Step) + 1'd1);
                            fighter_X_Motion_in = (~ (fighter_X_Step) + 1'd1);
						end
					end
					3'd1,3'd4:
					begin
                        
						if(l_on)//l = kick
						begin
							next_state = 3'd2;
							fighter_X_Motion_in = fighter_X_Step;
							fighter_Y_Motion_in = fighter_Y_Step;
						end
                        else if(fighter_X_Motion != 10'd0)
                        begin
                            if(jump_states != jump_time)
                            begin
                                fighter_Y_Motion_in -=  1'd1;
                            end
                           else
                           begin
                               fighter_Y_Motion_in += 1'd1;
                           end
                        end
					end
                    default:;
				endcase
                end

            //movement
            fighter_X_Pos_in = player2_X_Pos + fighter_X_Motion;
            fighter_Y_Pos_in = player2_Y_Pos + fighter_Y_Motion;

            //floor collisions
            if( (player2_Y_Pos+fighter_Height > fighter_Y_Bottom) && (fighter_Y_Motion != 10'd0)) 
            begin
                fighter_Y_Motion_in = 1'b0;  
				fighter_X_Motion_in = 1'b0;
                next_state = 3'd0;
                fighter_Y_Pos_in  = fighter_Y_Bottom-fighter_Height;
            end
            //cieling colision
            else if ( player2_Y_Pos< fighter_Y_Top)  
            begin
				fighter_Y_Motion_in = fighter_Y_Step;
			end

            //right wall colision
            if((player2_X_Pos + fighter_Width) > fighter_X_Right)
            begin
                fighter_X_Motion_in = 1'b0;
                fighter_X_Pos_in = fighter_X_Right-fighter_Width;
                fighter_Y_Motion_in = fighter_Y_Step;
                next_state = 3'd1;
            end
            //left wall colision
            else if(player2_X_Pos  < fighter_X_Left)
            begin
                fighter_X_Motion_in = 1'b0;
                fighter_X_Pos_in = fighter_X_Left;
                fighter_Y_Motion_in = fighter_Y_Step;
                next_state = 3'd1;
            end
            

            case(next_state)
                3'd0,3'd3:
                    next_state =3'd3;
                3'd1,3'd4:
                    next_state =3'd4;
                3'd2,3'd5:
                    next_state =3'd5;
            endcase
            if(change_side)
            begin
                case(next_state)
                3'd0,3'd3:
                    next_state =3'd0;
                3'd1,3'd4:
                    next_state =3'd1;
                3'd2,3'd5:
                    next_state =3'd2;
            endcase
            end
            
        end
    end
    
endmodule
