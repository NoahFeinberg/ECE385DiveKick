module  player2 ( input     Clk,                // 50 MHz clock
                            Reset,              // Active-high reset signal
                            frame_clk,          // The clock indicating a new frame (~60Hz)
					 input [9:0] player1_X_Pos, player1_Y_Pos,  
                input [9:0] DrawX, DrawY,       // Current pixel coordinates
					 input k_on, l_on,
					 output logic [2:0] state,
					 output logic [9:0] player2_X_Pos, player2_Y_Pos             // Whether current pixel belongs to fighter or background
              );
    
    parameter [9:0] fighter_X_Reset = 10'd549;  // Center position on the X axis
    parameter [9:0] fighter_Y_Reset = 10'd333;  // Center position on the Y axis
    parameter [9:0] fighter_X_Left = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] fighter_X_Right = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] fighter_Y_Top = 10'd119;       // Topmost point on the Y axis
    parameter [9:0] fighter_Y_Bottom = 10'd439;     // Bottommost point on the Y axis
    parameter [9:0] fighter_X_Step = ~(10'd5);      // Step size on the X axis
    parameter [9:0] fighter_Y_Step = 10'd4;      // Step size on the Y axis
    parameter [9:0] fighter_Height = 10'd105;      // fighter height
    parameter [9:0] fighter_Width = 10'd72;      // fighter width
    
	logic [2:0] next_state;
	
    logic change_side;
    logic [9:0] fighter_X_Motion, fighter_Y_Motion;
    logic [9:0] fighter_X_Pos_in, fighter_X_Motion_in, fighter_Y_Pos_in, fighter_Y_Motion_in;

    assign change_side = (player2_X_Pos>= player1_X_Pos);     
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
            player2_X_Pos <= fighter_X_Reset;
            player2_Y_Pos <= fighter_Y_Reset;
            fighter_X_Motion <= 10'd0;
            fighter_Y_Motion <= 10'd0;
        end
        else
        begin
			state <= next_state; 
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
        fighter_X_Pos_in = player2_X_Pos;
        fighter_Y_Pos_in = player2_Y_Pos;
        fighter_X_Motion_in = fighter_X_Motion;
        fighter_Y_Motion_in = fighter_Y_Motion;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
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
                    if(fighter_Y_Motion != 10'd0)
                    begin
						 next_state = 3'd2;
					    fighter_X_Motion_in = fighter_X_Step;
					    fighter_Y_Motion_in = fighter_Y_Step;
                    end

				end
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. player2_Y_Pos - fighter_Size <= fighter_Y_Min 
            // If player2_Y_Pos is 0, then player2_Y_Pos - fighter_Size will not be -4, but rather a large positive number.
            if( (player2_Y_Pos+fighter_Height >= fighter_Y_Bottom) && (fighter_Y_Motion != 10'd0))  // fighter is at the bottom edge, BOUNCE!
			begin
                fighter_Y_Motion_in = 1'b0;  
				fighter_X_Motion_in = 1'b0;
			end
            else if ( player2_Y_Pos<= fighter_Y_Top)  // fighter is at the top edge, BOUNCE!
            begin
				fighter_Y_Motion_in = fighter_Y_Step;
			end
			else if( player2_X_Pos + fighter_Width >= fighter_X_Right )  // fighter is at the bottom edge, BOUNCE!
                fighter_X_Motion_in = 1'b0;
				

            fighter_X_Pos_in = player2_X_Pos + fighter_X_Motion;
            fighter_Y_Pos_in = player2_Y_Pos + fighter_Y_Motion;
			if(player2_Y_Pos+fighter_Height >=fighter_Y_Bottom)
			begin
				fighter_Y_Pos_in = (fighter_Y_Bottom-1'b1)-fighter_Height;
				next_state = 4'd0;
			end
			if(player2_X_Pos + fighter_Width >= fighter_X_Right)
			begin
				fighter_X_Pos_in = (fighter_X_Right-1'b1)-fighter_Width;

			end
        end
    end
    
endmodule
