`timescale 1ns/1ps
`define PAYLOAD_SIZE 8

module top();
	//------------------------ PARAMTERS ------------------------//
	int CLOCK_PERIOD = 10;
	
	//-------------------- CLOCK GENERATION ---------------------//
	logic clk = 0;
	logic rst_n = 0;
	
	always begin
		#(CLOCK_PERIOD/2) clk = ~clk;
	end
	
	//----------------- INTERFACE INSTANTIATION -----------------//
	uart_if #(.PAYLOAD_SIZE(`PAYLOAD_SIZE)) uart_tx_if(clk);
	
	//-------------------- DUT INSTANTIATION --------------------//
	uart_tx_wrapper dut(uart_tx_if.dut);
	
	//----------------- TESTBENCH INSTANTIATION -----------------//
	uart_tx_te uart_te(uart_tx_if.te);
			   
endmodule

