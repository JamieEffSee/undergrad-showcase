// Top level test environment
// Ref. In-lecture labs

module env_toplevel;

	parameter master_clock_wavelength = 100;   // ns

	bit clk;

	always #(master_clock_wavelength/2) 	// 1/2*(master_clock_wavelength) up/down; repeat
		clk = ~clk;

	calc_ifc	my_calc_ifc(clk);			// top-level interface
	test_bench	t1(my_calc_ifc);  		// testbench instantiation --> Kickstarts environment
  
	calc2_top	m1  
			(
        // Clock and reset
        .c_clk(clk),
        .reset(my_calc_ifc.reset),

			  // Input ports
			  // cmd_in
        .req1_cmd_in(my_calc_ifc.req1_cmd_in),
        .req2_cmd_in(my_calc_ifc.req2_cmd_in),
        .req3_cmd_in(my_calc_ifc.req3_cmd_in),
        .req4_cmd_in(my_calc_ifc.req4_cmd_in),
                    
			  // data_in
        .req1_data_in(my_calc_ifc.req1_data_in),
        .req2_data_in(my_calc_ifc.req2_data_in),
        .req3_data_in(my_calc_ifc.req3_data_in),
        .req4_data_in(my_calc_ifc.req4_data_in),
                    
			  // tag_in
        .req1_tag_in(my_calc_ifc.req1_tag_in),
        .req2_tag_in(my_calc_ifc.req2_tag_in),
        .req3_tag_in(my_calc_ifc.req3_tag_in),
        .req4_tag_in(my_calc_ifc.req4_tag_in),
                    
			  // Output ports
			  // out_resp
        .out_resp1(my_calc_ifc.out_resp1),
        .out_resp2(my_calc_ifc.out_resp2),
        .out_resp3(my_calc_ifc.out_resp3),
        .out_resp4(my_calc_ifc.out_resp4),
                    
			  // out_data
        .out_data1(my_calc_ifc.out_data1),
        .out_data2(my_calc_ifc.out_data2),
        .out_data3(my_calc_ifc.out_data3),
        .out_data4(my_calc_ifc.out_data4),

			  // out_tag
        .out_tag1(my_calc_ifc.out_tag1),
        .out_tag2(my_calc_ifc.out_tag2),
        .out_tag3(my_calc_ifc.out_tag3),
        .out_tag4(my_calc_ifc.out_tag4)
        );

endmodule
