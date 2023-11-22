module Binary_To_7Segment 
	(input i_Clk,
	input [3:0] i_Binary_Num,
	output o_Segment_A,
	output o_Segment_B,
	output o_Segment_C,
	output o_Segment_D,
	output o_Segment_E,
	output o_Segment_F,
	output o_Segment_G);

 reg [6:0] r_Hex_Encoding = 7'h00;
 
 // Purpose: Creates a case statement for all possible input binary numbers.
 // Drives r_Hex_Encoding appropriately for each input combination. 
 
 always @ (posedge i_Clk)
	begin 
		case (i_Binary_Num)
			4'b0000 : 
				r_Hex_Encoding <= 7'h7E; //7 bit wide hexidecimal number 7E=111 1110 representing number 0
			4'b0001 :
				r_Hex_Encoding <= 7'h30; // 011 0000 number 1 
			4'b0010 :
				r_Hex_Encoding <= 7'h6D; // 110 1101 number 2
			4'b0011 :
				r_Hex_Encoding <= 7'h79; //111 1001 number 3
			4'b0100 :
				r_Hex_Encoding <= 7'h33; //111 1001 number 4
			4'b0101 :
				r_Hex_Encoding <= 7'h5B; //111 1001 number 5
			4'b0110 :
				r_Hex_Encoding <= 7'h5F; //111 1001 number 6
			4'b0111 :
				r_Hex_Encoding <= 7'h70; //111 1001 number 7
			4'b1000 :
				r_Hex_Encoding <= 7'h7F; //111 1001 number 8
			4'b1001 :
				r_Hex_Encoding <= 7'h7B; //111 1001 number 9
			4'b1010 :
				r_Hex_Encoding <= 7'h77; //111 1001 number A
			4'b1011 :
				r_Hex_Encoding <= 7'h1F; //111 1001 number B
			4'b1100 :
				r_Hex_Encoding <= 7'h4E; //111 1001 number C
			4'b1101 :
				r_Hex_Encoding <= 7'h3D; //111 1001 number D
			4'b1110 :
				r_Hex_Encoding <= 7'h4F; //111 1001 number E
			4'b1111 :
				r_Hex_Encoding <= 7'h47; //111 1001 number F
		endcase 
	end //always @ (posedge i_Clk)

//r_Hex_Encoding[7] is unused 
// assinging the bits to the right segments in this case abcdefg is the order so a is MSB of 6th bit 
assign o_Segment_A = r_Hex_Encoding[6];
assign o_Segment_B = r_Hex_Encoding[5];
assign o_Segment_C = r_Hex_Encoding[4];
assign o_Segment_D = r_Hex_Encoding[3];
assign o_Segment_E = r_Hex_Encoding[2];
assign o_Segment_F = r_Hex_Encoding[1];
assign o_Segment_G = r_Hex_Encoding[0];	

endmodule // Binary_To_7Segment		
				