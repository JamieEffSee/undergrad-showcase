//`default_nettype none  // NO lol don't ever do this

// Ref. In-lecture Labs

`include "env.sv"

program automatic test_bench(calc_ifc top_ifc);

// Top level environment
env the_best_env;

initial begin
  // Instantiate the top level and fire the test
  the_best_env = new(top_ifc);
  the_best_env.run();

  $finish; // top level finish: all testing successful
end 

endprogram