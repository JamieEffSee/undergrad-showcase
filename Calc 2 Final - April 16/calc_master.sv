// Ref. Spear and Tumbush

`ifndef CALC_MASTER_IFC
`define CALC_MASTER_IFC	calc_master_ifc
`include "calc_transaction.sv"

  
class calc_master;

    bit verbose;  // for debug
    
    // define master side ifc and mbx's
    virtual calc_ifc.Master calc_master_ifc;
    mailbox #(calc_transaction) gen2mas, mas2scb;

    // Constructor
    function new(virtual calc_ifc.Master calc_master_ifc, 
                 mailbox #(calc_transaction) gen2mas, mas2scb,
                 bit verbose=0);

      this.gen2mas         = gen2mas;
      this.mas2scb         = mas2scb;    
      this.calc_master_ifc = calc_master_ifc;
      this.verbose         = verbose;
    endfunction
    
    // Main task: retrieve tx's from generator and drive to DUT and scoreboard
    task main();
       calc_transaction tx;

       // - - for debug
       if(verbose)
         $display("@%0d: Starting calc_master", $time);

       forever begin

        // Get a transaction and send it to the DUT
        // wait(mas2scb.num() < 4);                       // wait on mbx.num(): another way to stop sniping tags and overfilling mailboxes
        gen2mas.get(tx);                                  // PARALLEL FUNCTIONALITY BELOW
        // ALLOWS TEST COVERAGE: 1.1, 1.2, etc.
        
        // for debug
        case(tx.cmd)
        
            4'b0001:  // addition
                begin
                  $display("        DRIVING NEW COMMAND: %b (with tag %b; data1 %h; data2 %h; expected %h)", tx.cmd, tx.tag, tx.data1, tx.data2, tx.data1 + tx.data2);
                end
			
            4'b0010:  // subtraction
                begin
		              $display("        DRIVING NEW COMMAND: %b (with tag %b; data1 %h; data2 %h; expected %h)", tx.cmd, tx.tag, tx.data1, tx.data2, tx.data1 - tx.data2);
                end
				
            4'b0101:  // left shift
                begin
                  $display("        DRIVING NEW COMMAND: %b (with tag %b; data1 %h; data2 %h; expected %h)", tx.cmd, tx.tag, tx.data1, tx.data2, tx.data1 << tx.data2[4:0]);
                end
		
            4'b0110:  // right shift
                begin
                  $display("        DRIVING NEW COMMAND: %b (with tag %b; data1 %h; data2 %h; expected %h)", tx.cmd, tx.tag, tx.data1, tx.data2, tx.data1 >> tx.data2[4:0]);
        
                end
           
            default:
                begin
                  $display("@%0d: Note: Idle or illegal command received in calc_master (%b)", $time, tx.cmd);
                  //$finish;
                end
            endcase
        
        
   
        
        // Drive the transaction
        driveTransactionBruteForce(tx);
        
        //repeat(20) @(posedge `CALC_MASTER_IFC.PClk);   // comment in to alter parallel/serial command functionality
        repeat(10) @(posedge `CALC_MASTER_IFC.PClk);
        //repeat(3) @(posedge `CALC_MASTER_IFC.PClk     // 3n delay cycles causes output collisions! see 2.5
        //repeat(2) @(posedge `CALC_MASTER_IFC.PClk);      // any lower than two cycles, and we risk moving faster than the Tx's are being driven
        //repeat(1) @(posedge `CALC_MASTER_IFC.PClk);
        
        
       // - - for debug
       //if(verbose)
       //$display($time, ": In calc_master: tx got and sent");

       end

      // if(verbose)
      //  $display($time, ": Ending calc_master");

    endtask: main
        
  // Sent the calc transaction to all 4 ports of the Calc
 
  task driveTransactionBruteForce(calc_transaction tx);
    
   // tx.data1 = 32'bx;      // used for driving 4-state data
   
	// Drive to DUT Control bus (2 cycles)
     @(posedge `CALC_MASTER_IFC.PClk)
     `CALC_MASTER_IFC.PCmd  <= tx.cmd;   // cmd signal
     `CALC_MASTER_IFC.PData <= tx.data1; // operand1
     `CALC_MASTER_IFC.PTag <= tx.tag;    // ID
     
     @(posedge `CALC_MASTER_IFC.PClk)
     `CALC_MASTER_IFC.PCmd  <= 4'b0000;   // zeroed
     `CALC_MASTER_IFC.PData <= tx.data2;  // operand 2
     `CALC_MASTER_IFC.PTag <= 2'b00;      // zeroed
     
  // Drive Scoreboard
     mas2scb.put(tx);
     
  endtask
  
  //
  //  // TODO: independently-controlled and/or randomized drive protocol
  //
  
  
  // reset protocol
  task reset();
      `CALC_MASTER_IFC.reset <= 1;
      `CALC_MASTER_IFC.PCmd  <= 0;
      `CALC_MASTER_IFC.PData <= 0;
      `CALC_MASTER_IFC.PTag <= 0;
      repeat(7) @(posedge `CALC_MASTER_IFC.PClk);
      
      `CALC_MASTER_IFC.reset <= 0;
      //repeat(7) @(posedge `CALC_MASTER_IFC.PClk);  // unnecessary: lead-in cycles present farther down pipeline
   endtask

endclass

`endif  // ifndef