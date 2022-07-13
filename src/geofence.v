//==================================
//Project: IC Design Contest_2021
//Designer: William
//Date: 2022/07/07
//Version: 2.0
//==================================
module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output reg valid;
output reg is_inside;
// FSM
reg [2:0] state;
reg [2:0] n_state;
parameter IDLE   = 3'b000;
parameter INPUT  = 3'b001;
parameter SORT   = 3'b010; // Implement by bubble sort
parameter VECTOR = 3'b011;
parameter AREA   = 3'b100;
parameter OUTPUT = 3'b101;
// Input stage
reg [3:0] read_cnt;
reg [9:0] X_reg [0:5];
reg [9:0] Y_reg [0:5];
reg [10:0] R_reg [0:5];
reg signed [10:0] vec_X [0:4];
reg signed [10:0] vec_Y [0:4];
// Sorting
reg sort_switch;
//
wire [22:0] len_1_temp;
wire [22:0] len_2_temp;
wire [22:0] len_3_temp;
wire [22:0] len_4_temp;
wire [22:0] len_5_temp;
reg [22:0] sqrt_temp;
wire [11:0] sqrt;
wire [22:0] side_1; 
wire [22:0] side_2;
wire [22:0] side_3;
wire [22:0] side_4;
reg signed [21:0] X_mul;
reg signed [21:0] Y_mul;
reg [12:0] side_temp [0:8];
// Area
reg [11:0] s_0;
reg [11:0] s_1;
reg [19:0] area_fence;
reg [19:0] area_r;
reg area_switch;
wire area_flag;

integer i;

reg [5:0] round;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    round <= 0;
  end
  else if (state == INPUT && read_cnt == 0) begin
    round <= round + 1;
  end
  else begin
    round <= round;
  end
end


// FSM_current state
always @(posedge clk or posedge reset) begin
	if (reset) begin
		state <= INPUT;
	end
	else begin
		state <= n_state;
	end
end

// FSM_next state
always @(*) begin
	case(state)
         IDLE: begin
         	n_state = INPUT;
         end
         INPUT:begin
         	if(read_cnt == 5) n_state = SORT;
         	else n_state = state;
         end
         SORT: begin
         	if(read_cnt == 5) n_state = VECTOR;
         	else n_state = state;
         end
         VECTOR: begin
             if(read_cnt == 8) n_state = AREA;
             else n_state = state;
         end
         AREA: begin
             if(read_cnt == 11) n_state = OUTPUT;
             else n_state = state;
         end
         OUTPUT: begin
             if(read_cnt == 1) n_state = INPUT;
             else n_state = state;
         end
         default: begin
         	n_state = state;
         end
	endcase
end

// Read counter
always @(posedge clk or posedge reset) begin
	if (reset) begin
		read_cnt <= 0;
	end
	else begin
		case(state)
             IDLE: begin
                 read_cnt <= 0;
             end
             INPUT: begin
             	if(read_cnt == 5) read_cnt <= 0;
             	else read_cnt <= read_cnt + 1;
             end
             SORT: begin
             	if(read_cnt == 5) read_cnt <= 0;
             	else read_cnt <= read_cnt + 1;
             end
             VECTOR: begin
                 if(read_cnt == 8) read_cnt <= 0;
                 else read_cnt <= read_cnt + 1;
             end
             AREA: begin
                 if(read_cnt == 11) read_cnt <= read_cnt <= 0;
                 else if(area_switch) read_cnt <= read_cnt + 1;
                 else read_cnt <= read_cnt;
             end
             OUTPUT: begin
                 if(read_cnt == 1) read_cnt <= 0;
                 else read_cnt <= read_cnt + 1;
             end
             default: begin
             	read_cnt <= read_cnt;
             end
		endcase
	end
end

// Register file of X coordinate 
always @(posedge clk or posedge reset) begin
	if (reset) begin
		for(i = 0; i < 6; i = i + 1) begin
			X_reg[i] <= 0;
		end
        // Vector of X
		for(i = 0; i < 5; i = i + 1) begin
			vec_X[i] <= 0;
		end
	end
	else begin
		case(state)
             INPUT: begin
             	X_reg[read_cnt] <= X;
             	if(read_cnt > 0) begin
             		vec_X[read_cnt - 1] <= X - X_reg[0];
             	end
             	else begin
             		for(i = 0; i < 5; i = i + 1) begin
			            vec_X[i] <= vec_X[i];
		            end
             	end  
             end
             SORT: begin
             	if(!sort_switch) begin
             	    for(i = 0; i < 6; i = i + 2) begin
             	        if( (vec_X[i] * vec_Y[i + 1] - vec_X[i + 1] * vec_Y[i]) > 0) begin
             		        vec_X[i] <= vec_X[i + 1];
             		        vec_X[i + 1] <= vec_X[i];
             		        // Sorting register file
             		        X_reg[i + 1] <= X_reg[i + 2];
             			    X_reg[i + 2] <= X_reg[i + 1];
             		    end
             		    else begin
             		        vec_X[i] <= vec_X[i];
             		        vec_X[i + 1] <= vec_X[i + 1];
             		        //
             		    	X_reg[i + 1] <= X_reg[i + 1];
             		    	X_reg[i + 2] <= X_reg[i + 2];
             		    end
             		end
             	end
             	else begin
             		for(i = 1; i < 6; i = i + 2) begin
             			if( (vec_X[i] * vec_Y[i + 1] - vec_X[i + 1] * vec_Y[i]) > 0) begin
             				vec_X[i] <= vec_X[i + 1];
             				vec_X[i + 1] <= vec_X[i];
             				//
             				X_reg[i + 1] <= X_reg[i + 2];
             			    X_reg[i + 2] <= X_reg[i + 1];
             			end
             			else begin
             			    vec_X[i] <= vec_X[i];
             			    vec_X[i + 1] <= vec_X[i + 1];
             				X_reg[i + 1] <= X_reg[i + 1];
             			    X_reg[i + 2] <= X_reg[i + 2];
             			end
             		end
             	end
             end
             default: begin
             	for(i = 0; i < 5; i = i + 1) begin
			        X_reg[i] <= X_reg[i];
		        end
		        for(i = 0; i < 5; i = i + 1) begin
			        vec_X[i] <= vec_X[i];
		        end
             end
		endcase
	end
end

// Register file of Y coordinate 
always @(posedge clk or posedge reset) begin
	if (reset) begin
		for(i = 0; i < 6; i = i + 1) begin
			Y_reg[i] <= 0;
		end
        // Vector of Y
		for(i = 0; i < 5; i = i + 1) begin
			vec_Y[i] <= 0;
		end
	end
	else begin
		case(state)
             INPUT: begin
             	Y_reg[read_cnt] <= Y;
             	if(read_cnt > 0) begin
             		vec_Y[read_cnt - 1] <= Y - Y_reg[0];
             	end
             	else begin
             		for(i = 0; i < 5; i = i + 1) begin
			            vec_Y[i] <= vec_Y[i];
		            end
             	end   
             end
             SORT: begin
             	if(!sort_switch) begin
             	    for(i = 0; i < 6; i = i + 2) begin
             	        if( (vec_X[i] * vec_Y[i + 1] - vec_X[i + 1] * vec_Y[i]) > 0) begin
             	            vec_Y[i] <= vec_Y[i + 1];
             	            vec_Y[i + 1] <= vec_Y[i];
             		        // Sorting register file
             		        Y_reg[i + 1] <= Y_reg[i + 2];
             			    Y_reg[i + 2] <= Y_reg[i + 1];
             		    end
             		    else begin
             		        vec_Y[i] <= vec_Y[i];
             		        vec_Y[i + 1] <= vec_Y[i + 1];
             		        //
             		    	Y_reg[i + 1] <= Y_reg[i + 1];
             		    	Y_reg[i + 2] <= Y_reg[i + 2];
             		    end
             		end
             	end
             	else begin
             		for(i = 1; i < 6; i = i + 2) begin
             			if( (vec_X[i] * vec_Y[i + 1] - vec_X[i + 1] * vec_Y[i]) > 0) begin
             			    vec_Y[i] <= vec_Y[i + 1];
             			    vec_Y[i + 1] <= vec_Y[i];
             			    //
             				Y_reg[i + 1] <= Y_reg[i + 2];
             			    Y_reg[i + 2] <= Y_reg[i + 1];
             			end
             			else begin
             			    vec_Y[i] <= vec_Y[i];
             			    vec_Y[i + 1] <= vec_Y[i + 1];
             			    //
             				Y_reg[i + 1] <= Y_reg[i + 1];
             			    Y_reg[i + 2] <= Y_reg[i + 2];
             			end
             		end
             	end
             end
             default: begin
             	for(i = 0; i < 6; i = i + 1) begin
			        Y_reg[i] <= Y_reg[i];
		        end
		        for(i = 0; i < 5; i = i + 1) begin
			        vec_Y[i] <= vec_Y[i];
		        end
             end
		endcase
	end
end

// Register file of distance 
always @(posedge clk or posedge reset) begin
	if (reset) begin
		for(i = 0; i < 6; i = i + 1) begin
			R_reg[i] <= 0;
		end
	end
	else begin
		case(state)
             INPUT: begin
             	R_reg[read_cnt] <= R;
             end
             SORT: begin
             	if(!sort_switch) begin
             	    for(i = 0; i < 6; i = i + 2) begin
             	        if( (vec_X[i] * vec_Y[i + 1] - vec_X[i + 1] * vec_Y[i]) > 0) begin
             		        R_reg[i + 1] <= R_reg[i + 2];
             			    R_reg[i + 2] <= R_reg[i + 1];
             		    end
             		    else begin
             		    	R_reg[i + 1] <= R_reg[i + 1];
             		    	R_reg[i + 2] <= R_reg[i + 2];
             		    end
             		end
             	end
             	else begin
             		for(i = 1; i < 6; i = i + 2) begin
             			if( (vec_X[i] * vec_Y[i + 1] - vec_X[i + 1] * vec_Y[i]) > 0) begin
             				R_reg[i + 1] <= R_reg[i + 2];
             			    R_reg[i + 2] <= R_reg[i + 1];
             			end
             			else begin
             				R_reg[i + 1] <= R_reg[i + 1];
             			    R_reg[i + 2] <= R_reg[i + 2];
             			end
             		end
             	end
             end
             default: begin
             	for(i = 0; i < 6; i = i + 1) begin
			        R_reg[i] <= R_reg[i];
		        end
             end
		endcase
	end
end

// Switch signal of sorting
always @(posedge clk or posedge reset) begin
	if (reset) begin
		sort_switch <= 0;
	end
	else begin
		case(state)
             SORT: begin
             	sort_switch <= ~sort_switch;
             end
             default: begin
             	sort_switch <= 0;
             end
		endcase
	end
end

// Get ready for signed multiplication
always @(posedge clk or posedge reset) begin
    if (reset) begin
        X_mul <= 0;
        Y_mul <= 0;
    end
    else begin
        case(state)
             SORT: begin
                 if(read_cnt == 5) begin // ready for the first operation in Area
                     X_mul <= vec_X[0];
                     Y_mul <= vec_Y[0];
                 end
                 else begin
                     X_mul <= X_mul;
                     Y_mul <= Y_mul;
                 end
             end
             VECTOR: begin
                 case(read_cnt)
                      0: begin
                          X_mul <= X_reg[2] - X_reg[1];
                          Y_mul <= Y_reg[2] - Y_reg[1];
                      end
                      1: begin
                          X_mul <= vec_X[1];
                          Y_mul <= vec_Y[1];
                      end
                      2: begin
                          X_mul <= X_reg[3] - X_reg[2];
                          Y_mul <= Y_reg[3] - Y_reg[2];
                      end
                      3: begin
                          X_mul <= vec_X[2];
                          Y_mul <= vec_Y[2];
                      end
                      4: begin
                          X_mul <= X_reg[4] - X_reg[3];
                          Y_mul <= Y_reg[4] - Y_reg[3];
                      end
                      5: begin
                          X_mul <= vec_X[3];
                          Y_mul <= vec_Y[3];
                      end
                      6: begin
                          X_mul <= X_reg[5] - X_reg[4];
                          Y_mul <= Y_reg[5] - Y_reg[4];
                      end
                      7: begin
                          X_mul <= vec_X[4];
                          Y_mul <= vec_Y[4];
                      end
                      default: begin
                          X_mul <= X_mul;
                          Y_mul <= Y_mul;
                      end
                 endcase
             end
        endcase
    end
end

// Vector length
assign len_1_temp = (state == VECTOR && read_cnt == 0) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign len_2_temp = (state == VECTOR && read_cnt == 2) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign len_3_temp = (state == VECTOR && read_cnt == 4) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign len_4_temp = (state == VECTOR && read_cnt == 6) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign len_5_temp = (state == VECTOR && read_cnt == 8) ? X_mul * X_mul + Y_mul * Y_mul : 0;
// Side of the hex
assign side_1 = (state == VECTOR && read_cnt == 1) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign side_2 = (state == VECTOR && read_cnt == 3) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign side_3 = (state == VECTOR && read_cnt == 5) ? X_mul * X_mul + Y_mul * Y_mul : 0;
assign side_4 = (state == VECTOR && read_cnt == 7) ? X_mul * X_mul + Y_mul * Y_mul : 0;

always @(*) begin
  case(state)
         VECTOR: begin
             case(read_cnt)
                  0: sqrt_temp = len_1_temp;
                  1: sqrt_temp = side_1;
                  2: sqrt_temp = len_2_temp;
                  3: sqrt_temp = side_2;
                  4: sqrt_temp = len_3_temp;
                  5: sqrt_temp = side_3;
                  6: sqrt_temp = len_4_temp;
                  7: sqrt_temp = side_4;
                  8: sqrt_temp = len_5_temp;
                  default: sqrt_temp = 0;
             endcase
         end
         AREA: begin
             case(read_cnt)
                  0: begin
                      if(!area_switch) sqrt_temp = ((side_temp[0] + side_temp[1] + side_temp[2]) >> 1) * (((side_temp[0] + side_temp[1] + side_temp[2]) >> 1) - side_temp[0]);
                      else sqrt_temp = (((side_temp[0] + side_temp[1] + side_temp[2]) >> 1) - side_temp[1]) * (((side_temp[0] + side_temp[1] + side_temp[2]) >> 1) - side_temp[2]);
                  end
                  1: begin
                      if(!area_switch) sqrt_temp = ((side_temp[2] + side_temp[3] + side_temp[4]) >> 1) * (((side_temp[2] + side_temp[3] + side_temp[4]) >> 1) - side_temp[2]);
                      else sqrt_temp = (((side_temp[2] + side_temp[3] + side_temp[4] + 1) >> 1) - side_temp[3]) * (((side_temp[2] + side_temp[3] + side_temp[4] + 1) >> 1) - side_temp[4]);
                  end
                  2: begin
                      if(!area_switch) sqrt_temp = ((side_temp[4] + side_temp[5] + side_temp[6]) >> 1) * (((side_temp[4] + side_temp[5] + side_temp[6]) >> 1) - side_temp[4]);
                      else sqrt_temp = (((side_temp[4] + side_temp[5] + side_temp[6]) >> 1) - side_temp[5]) * (((side_temp[4] + side_temp[5] + side_temp[6]) >> 1) - side_temp[6]);
                  end
                  3: begin
                      if(!area_switch) sqrt_temp = ((side_temp[6] + side_temp[7] + side_temp[8]) >> 1) * (((side_temp[6] + side_temp[7] + side_temp[8]) >> 1) - side_temp[6]);
                      else sqrt_temp = (((side_temp[6] + side_temp[7] + side_temp[8]) >> 1) - side_temp[7]) * (((side_temp[6] + side_temp[7] + side_temp[8]) >> 1) - side_temp[8]);
                  end
                  4: begin
                      if(!area_switch) sqrt_temp = ((side_temp[0] + R_reg[0] + R_reg[1]) >> 1) * (((side_temp[0] + R_reg[0] + R_reg[1]) >> 1) - side_temp[0]);
                      else sqrt_temp = (((side_temp[0] + R_reg[0] + R_reg[1]) >> 1) - R_reg[0]) * (((side_temp[0] + R_reg[0] + R_reg[1]) >> 1) - R_reg[1]);
                  end
                  5: begin
                      if(!area_switch) sqrt_temp = ((side_temp[1] + R_reg[1] + R_reg[2]) >> 1) * (((side_temp[1] + R_reg[1] + R_reg[2]) >> 1) - side_temp[1]);
                      else sqrt_temp = (((side_temp[1] + R_reg[1] + R_reg[2]) >> 1) - R_reg[1]) * (((side_temp[1] + R_reg[1] + R_reg[2]) >> 1) - R_reg[2]);
                  end
                  6: begin
                      if(!area_switch) sqrt_temp = ((side_temp[3] + R_reg[2] + R_reg[3]) >> 1) * (((side_temp[3] + R_reg[2] + R_reg[3]) >> 1) - side_temp[3]);
                      else sqrt_temp = (((side_temp[3] + R_reg[2] + R_reg[3]) >> 1) - R_reg[2]) * (((side_temp[3] + R_reg[2] + R_reg[3]) >> 1) - R_reg[3]);
                  end
                  7: begin
                      if(!area_switch) sqrt_temp = ((side_temp[5] + R_reg[3] + R_reg[4]) >> 1) * (((side_temp[5] + R_reg[3] + R_reg[4]) >> 1) - side_temp[5]);
                      else sqrt_temp = (((side_temp[5] + R_reg[3] + R_reg[4]) >> 1) - R_reg[3]) * (((side_temp[5] + R_reg[3] + R_reg[4]) >> 1) - R_reg[4]);
                  end
                  8: begin
                      if(!area_switch) sqrt_temp = ((side_temp[7] + R_reg[4] + R_reg[5]) >> 1) * (((side_temp[7] + R_reg[4] + R_reg[5]) >> 1) - side_temp[7]);
                      else sqrt_temp = (((side_temp[7] + R_reg[4] + R_reg[5]) >> 1) - R_reg[4]) * (((side_temp[7] + R_reg[4] + R_reg[5]) >> 1) - R_reg[5]);
                  end
                  9: begin
                      if(!area_switch) sqrt_temp = ((side_temp[8] + R_reg[5] + R_reg[0]) >> 1) * (((side_temp[8] + R_reg[5] + R_reg[0]) >> 1) - side_temp[8]);
                      else sqrt_temp = (((side_temp[8] + R_reg[5] + R_reg[0]) >> 1) - R_reg[5]) * (((side_temp[8] + R_reg[5] + R_reg[0]) >> 1) - R_reg[0]);
                  end
                  default: sqrt_temp = 0;
             endcase
         end
         default: sqrt_temp = 0;
  endcase
end


// DesignWare square root IP(combinational) provided by Synopsys 
DW_sqrt #(23,0) s0(.a(sqrt_temp << 2), .root(sqrt));

// Calculate each side of triangle
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for(i = 0; i < 9; i = i + 1) begin
            side_temp[i] <= 0;
        end
    end
    else begin
        case(state)
             VECTOR: begin
                 for(i = 0; i < 9; i = i + 1) begin
                     side_temp[read_cnt] <= (sqrt + 1) >> 1;
                 end
             end
             default: begin
                 for(i = 0; i < 9; i = i + 1) begin
                     side_temp[i] <= side_temp[i];
                 end
             end
        endcase
    end
end

// Square root of formula selection
always @(posedge clk or posedge reset) begin
    if (reset) begin
        area_switch <= 0;
    end
    else if(state == AREA) begin
        area_switch <= ~area_switch;
    end
    else begin
        area_switch <= 0;
    end
end

// Area calculation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        s_0 <= 0;
        s_1 <= 0;
    end
    else begin
        case(state)
             AREA: begin
                 if(!area_switch) begin
                     s_0 <= (sqrt + 1) >> 1;
                     s_1 <= s_1;
                 end
                 else begin
                     s_0 <= s_0;
                     s_1 <= (sqrt + 1) >> 1;
                 end
             end
             default: begin
                 s_0 <= s_0;
                 s_1 <= s_1;
             end
        endcase
    end
end

// Total area
always @(posedge clk or posedge reset) begin
    if (reset) begin
        area_fence <= 0;
        area_r <= 0;
    end
    else begin
        case(state)
             INPUT: begin
                 area_fence <= 0;
                 area_r <= 0;
             end
             AREA: begin
                 if(area_flag && !area_switch && read_cnt < 5) begin
                     area_fence <= area_fence + s_0 * s_1;
                     area_r <= area_r;
                 end
                 else if(read_cnt > 4 && !area_switch) begin
                     area_fence <= area_fence;
                     area_r <= area_r + s_0 * s_1;
                 end
                 else begin
                     area_fence <= area_fence;
                     area_r <= area_r;
                 end
             end
             default: begin
                 area_fence <= area_fence;
                 area_r <= area_r;
             end
        endcase
    end
end

assign area_flag = (state == AREA && read_cnt > 0) ? 1 : 0;;

// Output valid
always @(posedge clk or posedge reset) begin
    if (reset) begin
        valid <= 0;
    end
    else begin
        case(state)
             IDLE: begin
               valid <= valid;
             end
             /*INPUT: begin
               if(read_cnt == 0) valid <= 0;
               else valid <= valid;
             end*/
             OUTPUT: begin
               valid <= 1; 
             end
             default: begin
               valid <= 0;
             end
        endcase
    end
end

// is inside
always @(posedge clk or posedge reset) begin
    if (reset) begin
        is_inside <= 0;
    end
    else begin
        case(state)
             OUTPUT: begin
                 if(area_fence > area_r) is_inside <= 1;
                 else is_inside <= 0;
             end
             default: begin
                 is_inside <= is_inside;
             end
        endcase
    end
end


endmodule
