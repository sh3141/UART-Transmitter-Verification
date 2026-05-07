interface uart_if#(int PAYLOAD_SIZE)(input logic clk);

	logic 					  rst_n;
	logic        			  tx_start;
    logic [PAYLOAD_SIZE-1:0]  data_in;
    logic        			  parity_en;
    logic        			  even_parity; 
    logic        			  tx;
    logic        			  tx_busy;
	
	modport te(input clk, tx, tx_busy,
			   output rst_n, tx_start, data_in, parity_en,even_parity);
	
	modport dut(input clk, rst_n, tx_start, data_in, parity_en,even_parity,
			    output tx, tx_busy);


endinterface 

