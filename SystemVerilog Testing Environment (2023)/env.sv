// Transactor level test environment
// Ref. Spear and Tumbush

// Gather transactor module classes
`include "calc_master.sv"
`include "calc_ifc.sv"
`include "calc_transaction.sv"
`include "calc_result.sv"
`include "calc_monitor.sv"
`include "calc_sb.sv"
`include "tx_gen.sv"

// helper class
class test_cfg;
  // Test terminates when the trans_cnt is greater than max_trans_cnt
  int trans_cnt = 2500;

  // TODO: centralize final constraints in here; remove from transactors
endclass

class env;

  // Test configuration (helper class)
  test_cfg    tcfg;

  // Transactor instances
  tx_gen       gen;
  calc_master  mst;
  calc_monitor mon;
  calc_sb      scb;

  // mbx's
  mailbox #(calc_transaction) gen2mas, mas2scb;
  mailbox #(calc_result) mon2scb;

virtual calc_ifc arg_ifc;

// Constructor
  function new(virtual calc_ifc arg_ifc);
    this.arg_ifc  = arg_ifc;
    gen2mas   = new();
    mas2scb   = new();
    mon2scb   = new();
    tcfg      = new();

    gen      = new(gen2mas, tcfg.trans_cnt, 1);
    mst      = new(this.arg_ifc, gen2mas, mas2scb, 1);
    mon      = new(this.arg_ifc, mon2scb);
    scb      = new(tcfg.trans_cnt, mas2scb, mon2scb);
  endfunction: new

// TOP LEVEL RUN TASK invoked in test_bench (by way of simulating env_toplevel)
  task run();

    // copy max transactions as defined in generator.
    // we could do this by referencing tcfg.trans_cnt directly but this redundancy is intentional, do not remove --J
    scb.max_tx_cnt = gen.max_tx_cnt;
    
    // initialize transactors
    $display("@%0d: Starting env transactors", $time);
    fork
      scb.main();
      mst.main();
      mon.main();
    join_none
    $display("@%0d: Finished booting env transactors", $time);

    // reset top-level and initialize generator
    mst.reset();
    fork
      gen.main(); // intentional fork to force begin test. DO NOT REMOVE FORK! -- J
    join_none

    // at this point each transactor main() is active, finished, or finishing.
    // continue running test and wait for "ended" events to trigger
    fork
      wait(gen.ended.triggered);
      wait(scb.ended.triggered);
    join

  endtask  // run

endclass  // env
