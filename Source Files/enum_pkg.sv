package enum_pkg;

	typedef enum logic [1:0] {
		ODD,
		EVEN,
		NO_PARITY
	}parity_e;
	
	
	typedef enum int {
		NO_NOISE,
		IGNORE_PARITY_BIT,
		DATA_NOISE,
		DATA_NOISE_IGNORE_PARITY,
		TOGGLE_PARITY_EN,
		TOGGLE_PARITY_EN_IGNORE_PARITY,
		TOGGLE_PARITY_TYPE,
		ALL_NOISE,
		TEST_RESET,
		TEST_RESET_IGNORE_PARITY
	}test_type_e;

endpackage 

