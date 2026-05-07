module uart_tx_wrapper(uart_if.dut uart_tx_if);

	uart_tx dut(.clk(uart_tx_if.clk),
				.rst_n(uart_tx_if.rst_n),
				.tx_start(uart_tx_if.tx_start),
				.data_in(uart_tx_if.data_in),
				.parity_en(uart_tx_if.parity_en),     
				.even_parity(uart_tx_if.even_parity),   
				.tx(uart_tx_if.tx),
				.tx_busy(uart_tx_if.tx_busy)
			   );
endmodule

