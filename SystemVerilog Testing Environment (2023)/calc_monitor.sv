// Ref. Spear and Tumbush

`define CALC_MONITOR_IFC calc_monitor_ifc
`include "calc_result.sv"

class calc_monitor;

  bit verbose;		// DEPRECATED, see v 0.6 notes
  calc_result tx;

  // monitor-side interface and mailbox
  virtual calc_ifc.Monitor calc_monitor_ifc;
  mailbox #(calc_result) mon2scb;
    
  // constructor
  function new(virtual calc_ifc.Monitor calc_monitor_ifc, mailbox #(calc_result) mon2scb, bit verbose=0);
    this.calc_monitor_ifc = calc_monitor_ifc;
    this.verbose = verbose;
    this.mon2scb = mon2scb;
  endfunction

  task main();
   $display("@%0d: Starting calc_monitor", $time);
    
    forever begin
      @(posedge calc_monitor_ifc.PClk)
      
	// check each port, ignoring "idle" responses 
	// and pass transaction to scoreboard
	// TODO: Integrate slave modport and clean this up

	// Delay-drive constraints here have been deprecated - see env.sv (--J)

      if (`CALC_MONITOR_IFC.out_resp1 !== 2'b00) begin
        this.tx = new;
        tx.out_resp = `CALC_MONITOR_IFC.out_resp1;
        tx.out_data = `CALC_MONITOR_IFC.out_data1;
        tx.out_tag = `CALC_MONITOR_IFC.out_tag1;
        tx.out_port = 1;

        mon2scb.put(tx);
      end
      
      if (`CALC_MONITOR_IFC.out_resp2 !== 2'b00) begin
        this.tx = new;
        tx.out_resp = `CALC_MONITOR_IFC.out_resp2;
        tx.out_data = `CALC_MONITOR_IFC.out_data2;
        tx.out_tag = `CALC_MONITOR_IFC.out_tag2;
        tx.out_port = 2;
        
        mon2scb.put(tx);
      end
      
      if (`CALC_MONITOR_IFC.out_resp3 !== 2'b00) begin
        this.tx = new;
        tx.out_resp = `CALC_MONITOR_IFC.out_resp3;
        tx.out_data = `CALC_MONITOR_IFC.out_data3;
        tx.out_tag = `CALC_MONITOR_IFC.out_tag3;
        tx.out_port = 3;
        
        mon2scb.put(tx);
      end
      
      if (`CALC_MONITOR_IFC.out_resp4 !== 2'b00) begin
        this.tx = new;
        tx.out_resp = `CALC_MONITOR_IFC.out_resp4;
        tx.out_data = `CALC_MONITOR_IFC.out_data4;
        tx.out_tag = `CALC_MONITOR_IFC.out_tag4;
        tx.out_port = 4;
        
        // TODO: END slave modport (delete comment block when done)
        
        // Pass the transaction to the scoreboard
        mon2scb.put(tx);
      end

    end // forever
  endtask // main

endclass
