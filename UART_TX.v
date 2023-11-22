module UART_TX
	#(parameter CLKS_PER_BIT = 217)
	(input i_Clock,
	input i_TX_DV,
	input [7:0] i_TX_Byte,
	output reg o_TX_Active,
	output reg o_TX_Serial,
	output reg o_TX_Done);
	
	parameter IDLE 	= 2'b00;
	parameter TX_START_BIT	= 2'b01;
	parameter TX_DATA_BIT = 2'b10;
	parameter TX_STOP_BIT = 2'b11;
	
	reg [2:0] r_SM_Main = 0;
	reg [7:0] r_Clock_Count = 0;
	reg [2:0] r_Bit_Index = 0;
	reg [7:0] r_TX_Data = 0;
	reg r_TX_Done = 0;
	reg r_TX_Active = 0;
	
	//Purpose: control TX State machine 
	always @(posedge i_Clock)
	begin 
		case(r_SM_Main)
			IDLE:
			begin 
				o_TX_Serial <= 1'b1; // drive line high for idle 
				r_TX_Done <= 1'b0;
				r_Clock_Count <= 0;
				r_Bit_Index <= 0;
			
				if (i_TX_DV == 1'b1) //wait for data valid pulse to start transmitting more data 
				begin
					r_TX_Active <= 1'b1; //set TX_Active to show data stream is present 
					r_SM_Main <= TX_START_BIT; //go to start bit state 
					r_TX_Data <= i_TX_Byte; //transfer transmission data input to register 
				end
				else
				r_SM_Main <= IDLE;
			end
			TX_START_BIT:
			begin
				o_TX_Serial <= 1'b0; //output a 0 for the start bit of TX
				if(r_Clock_Count < CLKS_PER_BIT -1) //wait for clk to get to 217 before start TX_Serial 
				begin
					r_Clock_Count <= r_Clock_Count +1; //incre to 217 
					r_SM_Main <= TX_START_BIT;
				end
				else 
				begin 
					r_Clock_Count <=0; //reset clk and jump to data bit state 
					r_SM_Main <= TX_DATA_BIT;
				end 
			end 
			TX_DATA_BIT: 
			begin 
				o_TX_Serial <= r_TX_Data[r_Bit_Index]; // transfer TX_Data to Serial data with index
				if (r_Clock_Count < CLKS_PER_BIT -1) // wait until 217-1 to write more serial data 
				begin 
					r_Clock_Count <= r_Clock_Count +1;
					r_SM_Main <= TX_DATA_BIT;
				end 
				else 
				begin
					r_Clock_Count <= 0; //when clk hits 217-1 restart counter 
					if (r_Bit_Index < 7) // if less than 7 increment 
					begin
						r_Bit_Index <= r_Bit_Index +1;
						r_SM_Main <= TX_DATA_BIT;
					end 
					else 
					begin //if index is 7 then set the index back to 0 and jump to stop bit 
						r_Bit_Index <= 0;
						r_SM_Main <= TX_STOP_BIT;
					end 
				end 
			end 
			TX_STOP_BIT:
			begin 
				o_TX_Serial<=1'b1; //set the serial line back to high for an idled state 
				if (r_Clock_Count < CLKS_PER_BIT-1)
				begin 
					r_Clock_Count <= r_Clock_Count +1;
					r_SM_Main <= TX_STOP_BIT;
				end 
				else 
				begin 
				r_TX_Done <= 1'b1;
				r_Clock_Count <= 0;
				r_SM_Main <=IDLE;
				r_TX_Active <= 1'b0;
				end 
			end 
			
			default: 
			r_SM_Main <= IDLE;
		endcase 
	end 
endmodule //UART_TX