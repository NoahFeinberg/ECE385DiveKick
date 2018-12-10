module  player2 ( input     Clk,                // 50 MHz clock
                            Reset,              // Active-high reset signal
                            frame_clk,          // The clock indicating a new frame (~60Hz)
					 input [9:0] player1_X_Pos, player1_Y_Pos,  
                input [9:0] DrawX, DrawY,       // Current pixel coordinates
					 input k_on, l_on, Freeze,
					 output logic [2:0] state,
					 output logic [9:0] player2_X_Pos, player2_Y_Pos             // Whether current pixel belongs to fighter or background
              );
    
    logic [9:0] fighter_X_Reset = 10'd549;  // Center position on the X axis
    logic [9:0] fighter_Y_Reset = 10'd333;  // Center position on the Y axis
    logic [9:0] fighter_X_Left = 10'd10;       // Leftmost point on the X axis
    logic [9:0] fighter_X_Right = 10'd629;     // Rightmost point on the X axis
    logic [9:0] fighter_Y_Top = 10'd100;       // Topmost point on the Y axis
    logic [9:0] fighter_Y_Bottom = 10'd439;     // Bottommost point on the Y axis
    logic [9:0] fighter_X_Step = ~(10'd5)+10'd1;      // Step size on the X axis
    logic [9:0] fighter_Y_Step = 10'd4;      // Step size on the Y axis
    logic [9:0] fighter_Height = 10'd105;      // fighter height
    logic [9:0] fighter_Width = 10'd72;      // fighter width
    
	logic [2:0] next_state = 3'd0;
	
    logic current_side, change_side;
    logic [9:0] fighter_X_Motion, fighter_Y_Motion;
    logic [9:0] fighter_X_Pos_in, fighter_X_Motion_in, fighter_Y_Pos_in, fighter_Y_Motion_in;
	 
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
				state <= 3'd0;
				change_side<= 1'b0;
				fighter_X_Step<= ~(10'd5)+10'd1;
            player2_X_Pos <= fighter_X_Reset;
            player2_Y_Pos <= fighter_Y_Reset;
            fighter_X_Motion <= 10'd0;
            fighter_Y_Motion <= 10'd0;
        end
        else if(Freeze)
        begin
        end
        else if(current_side)
        begin
				state <= next_state;
				change_side<= current_side;
				fighter_X_Step<= ~(10'd5)+10'd1;
            player2_X_Pos <= fighter_X_Pos_in;
            player2_Y_Pos <= fighter_Y_Pos_in;
            fighter_X_Motion <= fighter_X_Motion_in;
            fighter_Y_Motion <= fighter_Y_Motion_in;
        end
		  else
        begin
				state <= next_state+3'd3; 
				change_side<= current_side;
				fighter_X_Step <= 10'd5;
            player2_X_Pos <= fighter_X_Pos_in;
            player2_Y_Pos <= fighter_Y_Pos_in;
            fighter_X_Motion <= fighter_X_Motion_in;
            fighter_Y_Motion <= fighter_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
		  next_state = state;
		  current_side = change_side; 
        fighter_X_Pos_in = player2_X_Pos;
        fighter_Y_Pos_in = player2_Y_Pos;
        fighter_X_Motion_in = fighter_X_Motion;
        fighter_Y_Motion_in = fighter_Y_Motion;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
                //keyboard interaction
				case(state)
					0,3:
					begin
						if(k_on) //k = jump
						begin
							if (fighter_Y_Motion == 10'd0)
							begin
								next_state = 3'd1;
								fighter_Y_Motion_in = (~ (fighter_Y_Step) + 1'd1);
							end
						end
						else if(l_on)//l = kick
						begin
							if (fighter_Y_Motion == 10'd0)
							begin
								// next_state = 3'd1;
								// fighter_Y_Motion_in = (~ (fighter_Y_Step) + 1'd1);
                                // fighter_X_Motion_in = (~ (fighter_X_Step) + 1'd1);
							end
						end
						current_side = (player2_X_Pos>= player1_X_Pos);
					end
					1,4:
					begin
						if(l_on)//l = kick
						begin
							next_state = 3'd2;
							fighter_X_Motion_in = fighter_X_Step;
							fighter_Y_Motion_in = fighter_Y_Step;
						end
                        else
                        begin
                            if(fighter_X_Motion != 10'd0)
                            begin
                            end
                        end
					end
				endcase
				
            //movement
            fighter_X_Pos_in = player2_X_Pos + fighter_X_Motion;
            fighter_Y_Pos_in = player2_Y_Pos + fighter_Y_Motion;
            //floor collisions
            if( (player2_Y_Pos+fighter_Height > fighter_Y_Bottom) && (fighter_Y_Motion != 10'd0)) 
			begin
                fighter_Y_Motion_in = 1'b0;  
				fighter_X_Motion_in = 1'b0;
                next_state = 4'd0;
                fighter_Y_Pos_in  = fighter_Y_Bottom-fighter_Height;
			end

            //cieling colision
            else if ( player2_Y_Pos< fighter_Y_Top)  
            begin
				fighter_Y_Motion_in = fighter_Y_Step;
			end

            //right wall colision
			if( player2_X_Pos + fighter_Width > fighter_X_Right )  
            begin
                fighter_X_Motion_in = 1'b0;
                fighter_X_Pos_in = fighter_X_Right-fighter_Width;
            end

            //left wall colision
			else if( player2_X_Pos < fighter_X_Left )  
            begin
                fighter_X_Motion_in = 1'b0;
                fighter_X_Pos_in = fighter_X_Left;
            end
        end
    end
    
endmodule
