
module usb_controller(clk,reset,mode,L,R,U,D,A,B,X,Y,out_cordinate_P,out_operation_P,out_cordinate_S,out_operation_S);
    input clk;
    input reset;
    input mode;
    input L;
    input R;
    input U;
    input D;
    input A;
    input B;
    input X;
    input Y;

    output reg out_cordinate_S;
    output reg out_operation_S;
    output reg [7:0] out_cordinate_P;
    output reg [3:0] out_operation_P;

    // Define states
    reg [3:0] state;
    localparam IDLE        	= 4'b0000,
              TX_START_S  	= 4'b0001,
              TX_START_P  	= 4'b0010,
              MOVE_S      	= 4'b0011,
              MOVE_P     	= 4'b0100,
              Operation_S 	= 4'b0101,
              Operation_P 	= 4'b0110,
              TX_END_S    	= 4'b0111,
              TX_END_P    	= 4'b1000;

    // Define reference coordinates and operations
    reg [3:0] ref_X_S, ref_Y_S;
    reg [3:0] ref_X_P, ref_Y_P;
    reg [3:0] serial;
    reg [3:0] parallel;

    // Bit count variables
    integer bit_count_S = 0;  //used in TX_END_S state

   //loop variable
integer i;

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) 
		begin
            	state <= IDLE;
            	ref_X_S <= 4'b1010; // Binary for 10
            	ref_Y_S <= 4'b1000; // Binary for 8
            	ref_X_P <= 4'b1010; // Binary for 10
            	ref_Y_P <= 4'b1000; // Binary for 8
		out_cordinate_S<=1'b0;
    		out_operation_S<=1'b0;

		out_cordinate_P[3:0]<=ref_Y_P[3:0];
		out_cordinate_P[7:4]<=ref_X_P[3:0];
		out_operation_P<=4'b0;

        	end 
	else 
	begin
            case (state)
                IDLE		:
		begin
                    if (mode)
			begin
			state <= TX_START_S;
			end
                    else 
			begin
			state <= TX_START_P;
			end
		end

                TX_START_S	:
		begin
                    if (L | R | U | D) 
			begin
			state <= MOVE_S;
			end
                    else if (A | B | X | Y) 
			begin
			state <= Operation_S;
			end
                    else if(~((L | R | U | D) ^ (A | B | X | Y))) 
			begin
			ref_X_S <= 4'b1010; // Binary for 10
            		ref_Y_S <= 4'b1000; // Binary for 8
            		ref_X_P <= 4'b1010; // Binary for 10
            		ref_Y_P <= 4'b1000; // Binary for 8
			state <= TX_START_S;
			end
		end

                TX_START_P	:
		begin
                    if (L | R | U | D) 
			begin
			state <= MOVE_P;
			end
                    else if (A | B | X | Y) 
			begin
			out_cordinate_S<=1'b0;
    			out_operation_S<=1'b0;
			state <= Operation_P;
			end
                    else if (~((L | R | U | D) ^ (A | B | X | Y))) 
			begin
			ref_X_S <= 4'b1010; // Binary for 10
            		ref_Y_S <= 4'b1000; // Binary for 8
            		ref_X_P <= 4'b1010; // Binary for 10
            		ref_Y_P <= 4'b1000; // Binary for 8
			state <= TX_START_P;
			end
		end

                MOVE_S		:
		begin
		    if (L & ~R & ~U & ~D) 
			begin
                        ref_X_S <= ref_X_S - 1'b1;
                        state <= TX_END_S;
                    	end 
		    else if (~L & R & ~U & ~D) 
			begin
                        ref_X_S <= ref_X_S + 1'b1;
                        state <= TX_END_S;
                    	end 
		    else if (~L & ~R & U & ~D) 
			begin
                        ref_Y_S <= ref_Y_S + 1'b1;
                        state <= TX_END_S;
                    	end 
		    else if (~L & ~R & ~U & D) 
			begin
                        ref_Y_S <= ref_Y_S - 1'b1;
                        state <= TX_END_S;
                    	end 
		    else 
			begin
			state <= TX_START_S;
			end
		end

                MOVE_P		:
		begin
                    if (L & ~R & ~U & ~D) 
			begin
                        ref_X_P <= ref_X_P - 1'b1;
                        state <= TX_END_P;
                    	end 
		    else if (~L & R & ~U & ~D) 
			begin
                        ref_X_P <= ref_X_P + 1'b1;
                        state <= TX_END_P;
                   	end 
		    else if (~L & ~R & U & ~D) 
			begin
                        ref_Y_P <= ref_Y_P + 1'b1;
                        state <= TX_END_P;
                    	end 
		    else if (~L & ~R & ~U & D) 
			begin
                        ref_Y_P <= ref_Y_P - 1'b1;
                        state <= TX_END_P;
                    	end 
		    else 
			begin
			state <= TX_START_P;
			end
		end
	
                Operation_S		:
		begin
		if (A & ~B & ~X & ~Y) 
			begin
                        serial <= 4'b1001;
                        state <= TX_END_S;
                    	end 
		else if (~A & B & ~X & ~Y) 
			begin
                        serial <= 4'b1011;
                        state <= TX_END_S;
                    	end 
		else if (~A & ~B & X & ~Y) 
			begin
                        serial <= 4'b1101;
                        state <= TX_END_S;
                    	end 
		else if (~A & ~B & ~X & Y) 
			begin
                        serial <= 4'b1111;
                        state <= TX_END_S;
                    	end 
		else 
			begin
			state <= TX_START_S;
			end
		end

                Operation_P		:
		begin
		if (A & ~B & ~X & ~Y) 	
			begin
                        parallel <= 4'b1001;
                        state <= TX_END_P;
                    	end 
		else if (~A & B & ~X & ~Y) 
			begin
                        parallel <= 4'b1011;
                        state <= TX_END_P;
                    	end 
		else if (~A & ~B & X & ~Y) 
			begin
                        parallel <= 4'b1101;
                        state <= TX_END_P;
                    	end 
			else if (~A & ~B & ~X & Y) 
			begin
                        parallel <= 4'b1111;
                        state <= TX_END_P;
                    	end 
		else 
			begin
			state <= TX_START_P;
			end
		end

                TX_END_S		:
		begin
		if (bit_count_S < 8) 
			begin
                        if (bit_count_S < 4) 
				begin
                            	out_cordinate_S <= ref_X_S[3-bit_count_S];
                            	out_operation_S <= serial[3-bit_count_S];
				bit_count_S <= bit_count_S + 1;
                        	end 
			else 
				begin
                            	out_cordinate_S <= ref_Y_S[7-bit_count_S];
				out_operation_S <= 1'b0;
				bit_count_S <= bit_count_S + 1;
                        	end
                    	end 
		else 
			begin
                        bit_count_S <= 0;
                        state <= TX_START_S;
                    	end
		end

                TX_END_P		:
		begin
			for(i=0;i<8;i=i+1)
			begin
				if(i<4)
				begin
					out_cordinate_P[i]<=ref_Y_P[i];
					out_operation_P[i]<=parallel[i];
				end
				else
				begin
					out_cordinate_P[i]<=ref_X_P[i-4];
				end
			end
		end
       	        default:
           	        state <= IDLE;
            endcase
        end
    end
endmodule
