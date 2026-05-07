`timescale 1ns/1ps
`include "Uart_packet.sv"

module uart_tx_te(uart_if.te uart_tx_if);
	//------------------------ PARAMTERS ------------------------//
	int MAX_BUSY_CYCLES = 100;
	int RESET_WINDOW    = 11;
	//------------------ STIMULUS DECLARATIONS ------------------//
	Uart_packet uart_packet_i;
	logic [7:0] expected_data_in;
	//---------------- OUTPUT DATA DECLARATIONS -----------------//
	typedef struct packed{
		logic tx; 
		logic tx_busy;               
	
	} data_out_t;
	
	data_out_t data_out_queue[$];
	
	//------------- EXPECTED DATA ARRAY DECLARATION -------------//
	data_out_t expected_out_queue[$];
	
	//------------------------ TEST INFO ------------------------//
	int config_no      = 0;
	int tests_passed   = 0;
	int tests_failed   = 0;
	int tests_invalid  = 0;
	int total_tests    = 100;
	int reset_cycle    = 20;
	
	//--------------------- RUNNING TESTCASES -------------------//
	string verb;   //configure details printed from test bench
	string tb_state;
	int show_per_test;
	bit pkt_state;
    test_type_e test_config;
	
	initial begin
		if(! $value$plusargs("verbosity=%s", verb)) begin
			verb = "detailed";
		end
		show_per_test = verb_value(verb,tb_state);
		$display("----------------------------------------------------------------------");
		$display("--------------------- UART-TX TESTBENCH (%s) ---------------------",tb_state);
		$display("----------------------------------------------------------------------");	
		
		//deassert the reset signal
		uart_tx_if.rst_n = 0;
		@(negedge uart_tx_if.clk);
		uart_tx_if.rst_n = 1;

		uart_packet_i = new();
		// ------------------------------------ Ensure correct frame structure ------------------------------------//
		reset(uart_packet_i);
		total_tests = 100;
		$display("----------------------- Running %0d tests to ensure correct frame structure ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		
		// ------------------------------------ Ensure correct frame structure while ignoring parity bit ------------------------------------//
		reset(uart_packet_i); 
		total_tests = 100;
		$display("-------------- Running %0d tests to ensure correct frame structure while ignoring parity bit --------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		
		test_config = IGNORE_PARITY_BIT;
		run_tests(uart_packet_i, test_config);
		
		
		
		// ------------------------------------ Ensure that payload is sent in correct bit order ------------------------------------//
		reset(uart_packet_i); 
		total_tests = 350;
		$display("----------------- Running %0d tests to stress test that the payload is sent in correct bit order (LSB first) ----------------",total_tests);
		uart_packet_i.non_palindrome_c.constraint_mode(1);
		test_config = IGNORE_PARITY_BIT;
		run_tests(uart_packet_i, test_config);

		// ------------------------------------ Ensure that parity bit is set correctly ------------------------------------//
		reset(uart_packet_i);
		total_tests = 100;
		$display("----------------------- Running %0d tests to stress test parity bit is set correctly ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		uart_packet_i.force_parity_c.constraint_mode(1);
		
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
	
		// ------------------------------------ Ensure that parity bit is set correctly for odd parity ------------------------------------//
		reset(uart_packet_i);
		total_tests = 100;
		$display("----------------------- Running %0d tests to stress test parity bit is set correctly for odd parity ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		uart_packet_i.force_odd_parity_c.constraint_mode(1);
		
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------------ Ensure that parity bit is set correctly for even parity ------------------------------------//
		reset(uart_packet_i);
		total_tests = 100;
		$display("----------------------- Running %0d tests to stress test parity bit is set correctly for even parity ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		uart_packet_i.force_even_parity_c.constraint_mode(1);
		
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------------ Mixture of different types of payloads and parity settings ------------------------------------//
		reset(uart_packet_i);
		total_tests = 500;
		$display("----------------------- Running %0d tests of random payloads and parity settings ------------------------",total_tests);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		
		// ------------------------------- Test payload = 0xFF corner case with no parity-------------------------------//
		reset(uart_packet_i);
		total_tests = 1;
		$display("----------------------- Running %0d tests of no parity with payload = 0xFF corner case ------------------------",total_tests);
		uart_packet_i.force_all_ones_c.constraint_mode(1);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Test payload = 0xFF corner case with parity-------------------------------//
		reset(uart_packet_i);
		total_tests = 10;
		$display("----------------------- Running %0d tests of parity type with payload = 0xFF corner case ------------------------",total_tests);
		uart_packet_i.force_all_ones_c.constraint_mode(1);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Mixture of different types of parity settings with 0xFF corner case -------------------------------//
		reset(uart_packet_i);
		total_tests = 10;
		$display("----------------------- Running %0d tests of random parity settings with payload = 0xFF corner case ------------------------",total_tests);
		uart_packet_i.force_all_ones_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Test payload = 0x00 corner case with no parity-------------------------------//
		reset(uart_packet_i);
		total_tests = 1;
		$display("----------------------- Running %0d tests of no parity with payload = 0x00 corner case ------------------------",total_tests);
		uart_packet_i.force_all_zeros_c.constraint_mode(1);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Test payload = 0x00 corner case with parity-------------------------------//
		reset(uart_packet_i);
		total_tests = 10;
		$display("----------------------- Running %0d tests of parity type with payload = 0x00 corner case ------------------------",total_tests);
		uart_packet_i.force_all_zeros_c.constraint_mode(1);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Mixture of different types of parity settings with 0x00 corner case -------------------------------//
		reset(uart_packet_i);
		total_tests = 10;
		$display("----------------------- Running %0d tests of random parity settings with payload = 0x00 corner case ------------------------",total_tests);
		uart_packet_i.force_all_zeros_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Ensure data and tx_start are latched correctly -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		
		$display("----------------------- Running %0d tests to ensure data and tx_start are latched correctly ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		
		test_config = DATA_NOISE;
		run_tests(uart_packet_i, test_config);
		
		
		
		// ------------------------------- Ensure data and tx_start are latched correctly for palindromes while ignoring parity -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		
		$display("-------------- Running %0d tests to ensure data and tx_start are latched correctly for palindromes while ignoring parity ----------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		test_config = DATA_NOISE_IGNORE_PARITY;
		run_tests(uart_packet_i, test_config);
		
		
		// ------------------------------- Ensure data and tx_start are latched correctly for all cases ignoring parity -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		
		$display("-------------- Running %0d tests to ensure data and tx_start are latched correctly while ignoring parity ----------------",total_tests);
		test_config = DATA_NOISE_IGNORE_PARITY;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Ensure data and tx_start are latched correctly for all cases -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		
		$display("-------------- Running %0d tests to ensure data and tx_start are latched correctly under different parity and payload settings ----------------",total_tests);
		test_config = DATA_NOISE;
		run_tests(uart_packet_i, test_config);
		
	
		
		// ------------------------------- Assess impact of toggling parity enable mid transmission while ignoring parity bit value -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		$display("--------------- Running %0d tests to assess impact of toggling parity enable mid transmission while ignoring parity bit value ----------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		
		test_config = TOGGLE_PARITY_EN_IGNORE_PARITY;
		run_tests(uart_packet_i, test_config);
		
		
		// ------------------------------- Assess impact of toggling parity enable mid transmission -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		$display("--------------- Running %0d tests to assess impact of toggling parity enable mid transmission ----------------",total_tests);
		test_config = TOGGLE_PARITY_EN;
		run_tests(uart_packet_i, test_config);

		
		// ------------------------------- Assess impact of toggling parity type mid transmission -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		$display("----------------------- Running %0d tests to assess impact of toggling parity type mid transmission ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		uart_packet_i.force_parity_c.constraint_mode(1);
		
		test_config = TOGGLE_PARITY_TYPE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Assess impact of toggling parity type mid transmission for all payloads -------------------------------//
		total_tests = 100;
		reset(uart_packet_i);
		$display("------------- Running %0d tests to assess impact of toggling parity type mid transmission for different payload types -----------------",total_tests);
		uart_packet_i.force_parity_c.constraint_mode(1);
		
		test_config = TOGGLE_PARITY_TYPE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Assess impact of different types of noise together -------------------------------//
		total_tests = 80;
		reset(uart_packet_i);
		$display("------------- Running %0d tests for different types of noise sent -----------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		test_config = ALL_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Assess impact of different types of noise together for different payload types -------------------------------//
		total_tests = 80;
		reset(uart_packet_i);
		$display("------------- Running %0d tests for different types of noise sent for different payload types -----------------",total_tests);
		test_config = ALL_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ------------------------------- Mixture of different types of parity settings with checkerboard corner case -------------------------------//
		reset(uart_packet_i);
		total_tests = 50;
		$display("----------------------- Running %0d tests of random parity settings with checkerboard corner case ------------------------",total_tests);
		uart_packet_i.force_checkerboard_c.constraint_mode(1);
		test_config = NO_NOISE;
		run_tests(uart_packet_i, test_config);
		
		// ----------------------------------- Testing asserting reset mid frame transmission with no parity ----------------------------------//
		reset(uart_packet_i);
		total_tests = 50;
		$display("----------------------- Running %0d tests of setting rst_n to low mid transmission with no parity ------------------------",total_tests);
		uart_packet_i.force_no_parity_c.constraint_mode(1);
		uart_packet_i.palindrome_c.constraint_mode(1);
		test_config = TEST_RESET;
		run_tests(uart_packet_i, test_config);
		
		// ----------------------------------- Testing asserting reset mid frame transmission while ignoring parity ----------------------------------//
		reset(uart_packet_i);
		total_tests = 50;
		$display("----------------------- Running %0d tests of setting rst_n to low mid transmission while ignoring parity bit ------------------------",total_tests);
		uart_packet_i.palindrome_c.constraint_mode(1);
		test_config = TEST_RESET_IGNORE_PARITY;
		run_tests(uart_packet_i, test_config);
		
		// ----------------------------------- Testing asserting reset mid frame for differnt payload types ----------------------------------//
		reset(uart_packet_i);
		total_tests = 50;
		$display("----------------------- Running %0d tests of setting rst_n to low mid transmission while ignoring parity bit ------------------------",total_tests);
		test_config = TEST_RESET;
		run_tests(uart_packet_i, test_config);
		
		#150ns;
		$stop();
	end
	
	
	
	//-----------------------------------------------------------//
	//-------------------- TASKS AND FUNCTIONS ------------------//
	//-----------------------------------------------------------//
	

	//---------------- Generating random stimulus ---------------//
	function automatic bit generate_stimulus(ref Uart_packet uart_packet_i);
		if(uart_packet_i.randomize()) begin
			uart_packet_i.post_randomize();
			if(show_per_test == 0 || show_per_test == 2) uart_packet_i.display();
			return 1;
		end
		else begin
			$display("Randomization failed :(");
			return 0;
		end
		
	endfunction
	
	//----------------------- Driving dut -----------------------//
	task automatic drive_stim(ref Uart_packet pkt);	
		uart_tx_if.data_in = pkt.data_in;
		uart_tx_if.parity_en = pkt.parity_en;
		uart_tx_if.even_parity = pkt.even_parity;
		uart_tx_if.tx_start = 1'b1;
		@(negedge uart_tx_if.clk);
		uart_tx_if.tx_start = 1'b0;
		pkt.uart_cg.sample();
	endtask

	//---------------------- Golden model -----------------------//
	function automatic void golden_model(ref Uart_packet pkt, test_type_e test_type, int reset_cycle);
		data_out_t exp_out;
		bit parity_state;
		bit parity_toggle;
		bit parity_type_toggle;
		bit ignore_parity;
		bit test_reset;
		int cycles_no;
		
		parity_toggle      = ((test_type == TOGGLE_PARITY_EN_IGNORE_PARITY) || (test_type == TOGGLE_PARITY_EN) || (test_type == ALL_NOISE) );
		parity_type_toggle = ((test_type == TOGGLE_PARITY_TYPE) || (test_type == ALL_NOISE) );
		parity_state       = ((parity_toggle)?(!pkt.parity_en):(pkt.parity_en));
		ignore_parity      = (test_type == TOGGLE_PARITY_EN_IGNORE_PARITY) || (test_type == IGNORE_PARITY_BIT) || (test_type == DATA_NOISE_IGNORE_PARITY) ;
		ignore_parity      = ignore_parity || (test_type == TEST_RESET_IGNORE_PARITY);
		test_reset         = (test_type == TEST_RESET) || (test_type == TEST_RESET_IGNORE_PARITY);
		cycles_no          = 0;
		
		if(test_reset && cycles_no == reset_cycle) begin
			exp_out = '{tx:1'b1, tx_busy: 1'b0}; 
		end
		else begin
			exp_out = '{tx:1'b0, tx_busy: 1'b1}; 
		end
		cycles_no++;
		expected_out_queue.push_back(exp_out); //start bit
		
		for(int i = 0;i<uart_tx_if.PAYLOAD_SIZE;i++) begin
			if(test_reset && cycles_no == reset_cycle) begin
				exp_out = '{tx:1'b1,tx_busy: 1'b0}; 
				expected_out_queue.push_back(exp_out);
				cycles_no++;
				break;
			end
			if(test_reset && cycles_no > reset_cycle) begin
				break;
			end
			exp_out = '{tx:pkt.data_in[i],tx_busy: 1'b1}; 
			expected_out_queue.push_back(exp_out);
			cycles_no++;	
		end
		
		if(test_reset && cycles_no == reset_cycle) begin
			exp_out = '{tx:1'b1,tx_busy: 1'b0}; 
			expected_out_queue.push_back(exp_out);
			cycles_no++;
		end else if (parity_state && (!test_reset || (test_reset && cycles_no < reset_cycle))) begin
			if(ignore_parity) begin
				exp_out = '{tx:1'bx,tx_busy: 1'b1}; 
				expected_out_queue.push_back(exp_out);
			end
			else if(pkt.even_parity ^ parity_type_toggle) begin
				exp_out = '{tx:~(^pkt.data_in), tx_busy: 1'b1}; 
				expected_out_queue.push_back(exp_out);
			end
			else begin
				exp_out = '{tx: ^(pkt.data_in),tx_busy: 1'b1}; 
				expected_out_queue.push_back(exp_out);
			end
			cycles_no++;
		end
		
		if(test_reset && cycles_no == reset_cycle) begin
			exp_out = '{tx: 1'b1,tx_busy: 1'b0}; 
			expected_out_queue.push_back(exp_out); //idle
			cycles_no++;
		end else if(!test_reset || cycles_no < reset_cycle) begin
			exp_out = '{tx: 1'b1,tx_busy: 1'b1}; 
			expected_out_queue.push_back(exp_out); //stop bit
			cycles_no++;
		end
		
		if(!test_reset) begin
			exp_out = '{tx:1'b1,tx_busy: 1'b0}; 
			expected_out_queue.push_back(exp_out); //idle		
		end
		
		while(test_reset && cycles_no < (reset_cycle + RESET_WINDOW)) begin
			exp_out = '{tx:1'b1,tx_busy: 1'b0}; 
			expected_out_queue.push_back(exp_out); //idle
			cycles_no ++;
		end
	endfunction
	
	
	//------------------- Collecting output  --------------------//
	task automatic collect_output_data(ref Uart_packet pkt,test_type_e t, int reset_cycle);
		data_out_t data_out;
		int cycles_no;
		int toggle_parity;
		bit test_rst;
		test_rst = (t == TEST_RESET || t == TEST_RESET_IGNORE_PARITY);
		toggle_parity = $urandom_range(7,1);
		cycles_no = 0;
		while(uart_tx_if.tx_busy || (test_rst && (cycles_no < reset_cycle + RESET_WINDOW)) ) begin
			if((t == TEST_RESET || t == TEST_RESET_IGNORE_PARITY) && (cycles_no == reset_cycle)) begin
				uart_tx_if.rst_n = 1'b0;
			end
			if(t == DATA_NOISE || t == ALL_NOISE || (t == DATA_NOISE_IGNORE_PARITY)) begin
				uart_tx_if.data_in = $urandom;
				if(cycles_no < 9) uart_tx_if.tx_start = $urandom;
				else uart_tx_if.tx_start = 0;
			end
			if((t == TOGGLE_PARITY_EN) || (t == TOGGLE_PARITY_EN_IGNORE_PARITY) || (t == ALL_NOISE)) begin
				if(cycles_no == toggle_parity) begin
					uart_tx_if.parity_en = ~uart_tx_if.parity_en;
				end
			end
			if(t == TOGGLE_PARITY_TYPE || (t == ALL_NOISE)) begin
				if(cycles_no == toggle_parity) begin
					uart_tx_if.even_parity = ~uart_tx_if.even_parity;
				end
			end
			@(negedge uart_tx_if.clk);	
			data_out = '{tx:      uart_tx_if.tx,
						 tx_busy: uart_tx_if.tx_busy
						};
			data_out_queue.push_back(data_out);	
			cycles_no++;
			if(cycles_no == MAX_BUSY_CYCLES) begin
				$display("Transmitter is busy for too long, ... stopping collecting outputs");
				break;
			end
		end	
	endtask
	

	//-------------------- Checking results ---------------------//
	task automatic check_results(const ref data_out_t expected_out_queue[$], const ref data_out_t data_out_queue[$]);
		bit queues_match;
		string queue_type;
		queues_match = 1;
		if(expected_out_queue.size() != data_out_queue.size()) begin
			queues_match = 0;
		end else begin
			foreach(expected_out_queue[i]) begin
				if(i >= data_out_queue.size()) begin
					queues_match = 0;
					break;
				end
				if(expected_out_queue[i] != data_out_queue[i])begin
					queues_match = 0;
					break;
				end
			end
		end if(!queues_match) begin
			tests_failed = tests_failed + 1;
			if(show_per_test == 0 || show_per_test == 2) begin
				$error("[FAILED]");
				queue_type = "Expected";
				display_queue(expected_out_queue,queue_type);
				
				queue_type = "Obtained";
				display_queue(data_out_queue,queue_type);
			end			
		end else begin 
			tests_passed = tests_passed + 1;
			if(show_per_test == 0) begin
				$display("[PASSED :)]");
				queue_type = "Expected";
				display_queue(expected_out_queue,queue_type);
				
				queue_type = "Obtained";
				display_queue(data_out_queue,queue_type);
			end
		end 
	endtask

	
	
	//----------------- Print Test bench summary  ---------------//
	task print_summary(input int config_no);
		$display("-------- test bench summary for configuration number: %0d------ ", config_no);
		$display("tests failed: %0d out of %0d ", tests_failed,total_tests);
		$display("invalid tests: %0d out of %0d", tests_invalid,total_tests);
		$display("tests passed: %0d out of %0d", tests_passed,total_tests);
	endtask
	
	//-------------------- Reset test values  -------------------//
	task automatic reset(ref Uart_packet uart_packet_i);
		tests_failed = 0;
		tests_invalid = 0;
		tests_passed = 0;
		expected_out_queue.delete();
		data_out_queue.delete();
		
		uart_packet_i.palindrome_c.constraint_mode(0);
		uart_packet_i.non_palindrome_c.constraint_mode(0);
		uart_packet_i.force_no_parity_c.constraint_mode(0);
		uart_packet_i.force_parity_c.constraint_mode(0);
		uart_packet_i.force_even_parity_c.constraint_mode(0);
		uart_packet_i.force_odd_parity_c.constraint_mode(0);
		uart_packet_i.force_all_ones_c.constraint_mode(0);
		uart_packet_i.force_all_zeros_c.constraint_mode(0);
		uart_packet_i.force_checkerboard_c.constraint_mode(0);
		config_no++;
	endtask
	
	//------------------------ Run tests ------------------------//
	task automatic run_tests(ref Uart_packet uart_packet_i, test_type_e test_config);
		repeat(total_tests) begin
			pkt_state = generate_stimulus(uart_packet_i);
			if(!pkt_state) begin
				$display("Randomization failed... running tests is terminated");
				break;
			end
			if(test_config == TEST_RESET || test_config == TEST_RESET_IGNORE_PARITY) begin
				reset_cycle = $urandom_range(0,10);
			end else begin
				reset_cycle = 20;
			end
			if(show_per_test == 0 || show_per_test == 2) $display("the cycle at which reset is asserted = %0d",reset_cycle);
			golden_model(uart_packet_i,test_config,reset_cycle);
			drive_stim(uart_packet_i);
			collect_output_data(uart_packet_i,test_config,reset_cycle);
			check_results(expected_out_queue, data_out_queue);
			@(negedge uart_tx_if.clk);
			uart_tx_if.rst_n = 1'b1;
			@(negedge uart_tx_if.clk);
			expected_out_queue.delete();
			data_out_queue.delete();
		end
		print_summary(config_no);
	endtask
	//----- Determine level of detail printed in testbench  -----//
	function automatic int verb_value(string verb, ref string tb_state);
		int ans;
		if(verb == "summary") begin
			ans = 1;
			tb_state = "SUMMARY";
		end
		else if(verb == "error") begin
			ans = 2;
			tb_state = "DISPLAYING ERRORS ONLY";
		end
		else if(verb == "detailed") begin
			ans = 0;
			tb_state = "DETAILED";
		end
		else begin
			ans = 0;
			tb_state = "DETAILED";
		end
		return ans;	
	endfunction
	
	//----------------------- Print frame -----------------------//
	task automatic display_queue(const ref data_out_t queue[$], const ref string queue_type);
		$display("%s number of bits in frame = %0d",queue_type, queue.size());
		
		$write ("%s frame data = ",queue_type);
		foreach(queue[i]) begin
			$write("%b",queue[i].tx);
			if(i%4 == 3 && (i < (queue.size() - 1))) $write("_");
		end
		$display();
				
		$write ("%s frame tx busy = ",queue_type);
			foreach(queue[i]) begin
				$write("%b",queue[i].tx_busy);
				if(i%4 == 3 && (i < (queue.size() - 1)) ) $write("_");
			end
		$display();
	endtask
	
endmodule 