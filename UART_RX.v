// this project creates a UART reciver that recives a byte from the computer and displays
// it on the 7-segment display. the Uart reciever should operate at 115200 Baud rate (amount
// of bits per second), 8 data bits long, no parity 1 stop bit, no flow control

// contains one start bit, one stop bit, and no parity bit. When recieved is complete 
// o_rx_dv will be driven high for one clock cycle 

// Set parameters CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example : 25 MHz Clock, 115200 Baud UART
// (25000000)/(115200) = 217 
// 217/2 = the middle sample of each bit 

module UART_RX
	#(parameter CLKS_PER_BIT = 217)
	(
	input i_Clock,
	input i_RX_Serial,
	output o_RX_DV,
	output [7:0] o_RX_Byte
	);
	
	parameter IDLE			= 3'b000;
	parameter RX_START_BIT	= 3'b001;
	parameter RX_DATA_BIT	= 3'b010;
	parameter RX_STOP_BIT	= 3'b011;
	parameter CLEANUP		= 3'b100;
	
	reg [7:0]	r_Clock_Count = 0; //counting up to 217 
	reg [2:0]	r_Bit_Index   = 0; //indexing 0-7
	reg [7:0]	r_RX_Byte	  = 0; // storing 8 bits of data 
	reg 		r_RX_DV		  = 0; // data valid bit 1 when stop bit recieved 
	reg [2:0]	r_SM_Main     = 0; //// holds 5 different states 
	
	always @(posedge i_Clock)
begin 
	
	case(r_SM_Main)
		IDLE: 
		begin 
			r_RX_DV <= 1'b0;
			r_Clock_Count <= 0;
			r_Bit_Index <= 0;
			
			if (i_RX_Serial == 1'b0) //When i_RX_Serial drops low that means start bit has been detected 
				r_SM_Main <= RX_START_BIT;
			else 
				r_SM_Main <= IDLE;
		end 
		RX_START_BIT:
		begin
			if(r_Clock_Count == (CLKS_PER_BIT-1)/2) // find the middle of the bit and start to recieve
			begin 
				if (i_RX_Serial == 1'b0)
				begin 
					r_Clock_Count <= 0; // set the clock back to 0 so the counter can count upto 217 from middle 
					r_SM_Main <= RX_DATA_BIT; // go to RX_DATA_BIT state to index recieving bits 
				end 
				else 
					r_SM_Main <= IDLE;
			end 
				else 
				begin
					r_Clock_Count <= r_Clock_Count + 1;
					r_SM_Main <= RX_START_BIT;
				end
		end 
		RX_DATA_BIT: 	//start reading i_RX_Serial from middle of bits and index to r_RX_Byte
		begin
			if (r_Clock_Count < (CLKS_PER_BIT-1))
			begin 
				r_Clock_Count <= r_Clock_Count+1;
				r_SM_Main <= RX_DATA_BIT;
			end 
			else 
			begin 
			r_Clock_Count <= 0;
			r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
				if (r_Bit_Index < 7)
				begin 
					r_Bit_Index <= r_Bit_Index+1;
					r_SM_Main <= RX_DATA_BIT;
				end 
				else 
				begin 
					r_Bit_Index <= 0;
					r_SM_Main <= RX_STOP_BIT;
				end
			end
		end 
		RX_STOP_BIT:
		begin
			if(r_Clock_Count < CLKS_PER_BIT-1) //Wait until CLK hits middle of stop bit and then
			begin							   //set DV to 1, reset counter, goto CLEANUP
			r_Clock_Count <= r_Clock_Count +1;
			r_SM_Main <= RX_STOP_BIT;
			end
			else 
			begin
			r_RX_DV <= 1'b1;
			r_Clock_Count <=0;
			r_SM_Main <= CLEANUP;
			end 
		end 
		CLEANUP:
		begin 
			r_SM_Main <= IDLE;
			r_RX_DV <= 1'b0;
		end 
		
		default: 
			r_SM_Main <= IDLE;

	endcase
end 
	
	assign o_RX_DV = r_RX_DV;
	assign o_RX_Byte = r_RX_Byte;
	
endmodule //UART_RX
	
	
