
module top;
  parameter simulation_cycle = 100;
  bit  scan_in = 0;
  logic scan_out ;
   bit [0:3] error_found = 0; 
  bit clk;
  always #(simulation_cycle/2) 
    clk = ~clk;

  calc2_if calc(clk); // CALC interafce
  calc2_test   t1(calc);  // Testbench program
 // calc1_top    calc1(calc.SLAVE);  // Memory device
calc2_top D1(calc.SLAVE.out_data1, calc.SLAVE.out_data2, calc.SLAVE.out_data3, 
calc.SLAVE.out_data4, calc.SLAVE.out_resp1, calc.SLAVE.out_resp2, calc.SLAVE.out_resp3, 
calc.SLAVE.out_resp4, calc.SLAVE.out_tag1, calc.SLAVE.out_tag2, calc.SLAVE.out_tag3, 
calc.SLAVE.out_tag4, scan_out , 0, 0, calc.SLAVE.c_clk, 
calc.SLAVE.req1_cmd_in, calc.SLAVE.req1_data_in,calc.SLAVE.req1_tag_in, 
calc.SLAVE.req2_cmd_in, calc.SLAVE.req2_data_in,calc.SLAVE.req2_tag_in, 
calc.SLAVE.req3_cmd_in, calc.SLAVE.req3_data_in,calc.SLAVE.req3_tag_in, 
calc.SLAVE.req4_cmd_in, calc.SLAVE.req4_data_in,calc.SLAVE.req4_tag_in, calc.SLAVE.reset, scan_in);

endmodule  

