module usb_controller_wpad(PAD_clk,PAD_reset,PAD_mode,PAD_L,PAD_R,PAD_U,PAD_D,PAD_A,PAD_B,PAD_X,PAD_Y,PAD_out_cordinate_P,PAD_out_operation_P,PAD_out_cordinate_S,PAD_out_operation_S);
    	input PAD_clk;
    	input PAD_reset;
    	input PAD_mode;
    	input PAD_L;
    	input PAD_R;
    	input PAD_U;
    	input PAD_D;
    	input PAD_A;
    	input PAD_B;
    	input PAD_X;
    	input PAD_Y;

	output reg PAD_out_cordinate_S;
	output reg PAD_out_operation_S;
	output reg [7:0] PAD_out_cordinate_P;
	output reg [3:0] PAD_out_operation_P;

	wire wire_clk;
    	wire wire_reset;
    	wire wire_mode;
    	wire wire_L;
    	wire wire_R;
    	wire wire_U;
    	wire wire_D;
    	wire wire_A;
    	wire wire_B;
    	wire wire_X;
    	wire wire_Y; 
	
	wire wire_out_cordinate_S;
	wire wire_out_operation_S;
	wire [7:0] wire_out_cordinate_P;
	wire [3:0] wire_out_operation_P;

usb_controller usb_controller_submodule(wire_clk,wire_reset,wire_mode,wire_L,wire_R,wire_U,wire_D,wire_A,wire_B,wire_X,wire_Y,wire_out_cordinate_P,wire_out_operation_P,wire_out_cordinate_S,wire_out_operation_S);

	PADDI pad_clk (.PAD(PAD_clk), .Y(wire_clk));
	PADDI pad_reset (.PAD(PAD_reset), .Y(wire_reset));
	PADDI pad_mode (.PAD(PAD_mode), .Y(wire_mode));
	PADDI pad_L (.PAD(PAD_L), .Y(wire_L));
	PADDI pad_R (.PAD(PAD_R), .Y(wire_R));
	PADDI pad_U (.PAD(PAD_U), .Y(wire_U));
	PADDI pad_D (.PAD(PAD_D), .Y(wire_D));
	PADDI pad_A (.PAD(PAD_A), .Y(wire_A));
	PADDI pad_B (.PAD(PAD_B), .Y(wire_B));
	PADDI pad_X (.PAD(PAD_X), .Y(wire_X));
	PADDI pad_Y (.PAD(PAD_Y), .Y(wire_Y));

	PADDO pad_out_cordinate_S (.PAD(PAD_out_cordinate_S), .A(wire_out_cordinate_S));
	PADDO pad_out_operation_S (.PAD(PAD_out_operation_S), .A(wire_out_operation_S));

	PADDO pad_out_cordinate_P0 (.PAD(PAD_out_cordinate_P[0]), .A(wire_out_cordinate_P[0]));
	PADDO pad_out_cordinate_P1 (.PAD(PAD_out_cordinate_P[1]), .A(wire_out_cordinate_P[1]));
	PADDO pad_out_cordinate_P2 (.PAD(PAD_out_cordinate_P[2]), .A(wire_out_cordinate_P[2]));
	PADDO pad_out_cordinate_P3 (.PAD(PAD_out_cordinate_P[3]), .A(wire_out_cordinate_P[3]));
	PADDO pad_out_cordinate_P4 (.PAD(PAD_out_cordinate_P[4]), .A(wire_out_cordinate_P[4]));
	PADDO pad_out_cordinate_P5 (.PAD(PAD_out_cordinate_P[5]), .A(wire_out_cordinate_P[5]));
	PADDO pad_out_cordinate_P6 (.PAD(PAD_out_cordinate_P[6]), .A(wire_out_cordinate_P[6]));
	PADDO pad_out_cordinate_P7 (.PAD(PAD_out_cordinate_P[7]), .A(wire_out_cordinate_P[7]));

	PADDO pad_out_operation_P0 (.PAD(PAD_out_operation_P[0]), .A(wire_out_operation_P[0]));
	PADDO pad_out_operation_P1 (.PAD(PAD_out_operation_P[1]), .A(wire_out_operation_P[1]));
	PADDO pad_out_operation_P2 (.PAD(PAD_out_operation_P[2]), .A(wire_out_operation_P[2]));
	PADDO pad_out_operation_P3 (.PAD(PAD_out_operation_P[3]), .A(wire_out_operation_P[3]));
endmodule

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
		out_operation_P<=parallel;
		parallel<=4'b0;

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


