import enum_pkg::*;
class Uart_packet;

	rand logic data_palindrome; //decide if type of data is palindrom or non-palindrome
	rand logic [7:0] data_in;
	
	rand parity_e parity_type;
	rand logic parity_en;
	rand logic even_parity;

	//----------- CONSTRAINTS  -----------//
	
	constraint parity_c{
		parity_type dist {
			NO_PARITY := 34,
			EVEN := 33,
			ODD := 33
		};
	}
	
	constraint palindrome_c {
        data_in[7] == data_in[0]; 
        data_in[6] == data_in[1]; 
        data_in[5] == data_in[2]; 
        data_in[4] == data_in[3]; 
    }
    
    constraint non_palindrome_c {
        !((data_in[7] == data_in[0]) &&
          (data_in[6] == data_in[1]) &&
          (data_in[5] == data_in[2]) && 
          (data_in[4] == data_in[3]));
    }
	constraint force_all_ones_c { 
		data_in == 8'hFF; 
	}
	constraint force_all_zeros_c { 
		data_in == 8'h00; 
	}
	
	constraint force_checkerboard_c { 
		(data_in == 8'hAA) || (data_in == 8'h55); 
	}
	
	constraint force_no_parity_c { 
		parity_type == NO_PARITY; 
	}
	constraint force_parity_c { 
		parity_type != NO_PARITY; 
	}
	constraint force_even_parity_c { 
		parity_type == EVEN; 
	}
	constraint force_odd_parity_c { 
		parity_type == ODD; 
	}

	function void post_randomize();
		if(parity_type == NO_PARITY) begin
			parity_en = 0;
		end
		else if(parity_type == EVEN) begin
			parity_en = 1;
			even_parity = 1;
		end
		else begin
			parity_en = 1;
			even_parity = 0;
		end
	endfunction 
	//----------- COVER GROUPS  ----------//
	covergroup uart_cg;
		cp_parity: coverpoint parity_type{
			bins no_parity = {NO_PARITY};
			bins even_parity = {EVEN};
			bins odd_parity = {ODD};
		}
		
		cp_data_auto: coverpoint data_in{
			option.auto_bin_max = 256;
		}
		
		cp_data: coverpoint data_in{
			bins all_zeros = {'h00};
			bins all_ones = {'hFF};
			bins checkerboard = {'h55, 'hAA};
			
			bins low_range  = {[8'h01:8'h7E]};
			bins high_range = {[8'h7F:8'hFE]};
			
			bins data_even_parity = {[0:255]} with (^item == 0);
			bins data_odd_parity = {[0:255]} with (^item == 1);
		}
		
		cross_parity_data: cross cp_parity, cp_data{
			option.cross_auto_bin_max = 0; // disable automatic creation of all other bins to improve performance 
			bins even_parity_data_no_parity   = binsof(cp_parity.no_parity)   && binsof(cp_data.data_even_parity);
			bins even_parity_data_even_parity = binsof(cp_parity.even_parity) && binsof(cp_data.data_even_parity);
			bins even_parity_data_odd_parity  = binsof(cp_parity.odd_parity)  && binsof(cp_data.data_even_parity);
			
			bins odd_parity_data_no_parity    = binsof(cp_parity.no_parity)   && binsof(cp_data.data_odd_parity);
			bins odd_parity_data_even_parity  = binsof(cp_parity.even_parity) && binsof(cp_data.data_odd_parity);
			bins odd_parity_data_odd_parity   = binsof(cp_parity.odd_parity)  && binsof(cp_data.data_odd_parity);
		}
		
		
	endgroup
	
	//-------- FUNCTIONS & TASKS  --------//
	function new();
		uart_cg = new();
	endfunction
	
	function void display();
		$display("Sending >>> data_in = %8b, parity mode = %s",data_in,parity_type.name() );
	endfunction 
endclass

