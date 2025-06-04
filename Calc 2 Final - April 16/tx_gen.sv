`include "calc_transaction.sv"

class tx_gen;

  // Random transaction
  rand calc_transaction random_tx;

  int tx_cnt = 0;
  int max_tx_cnt;  // N transactions
  
  // event triggers when all transactions have been transmitted
  event ended;

  // Verbosity level, for extra info
  bit verbose;
  
  // Transaction mailbox
  mailbox #(calc_transaction) gen2mas;
    
  // Constructor
  function new(mailbox #(calc_transaction) gen2mas, int max_tx_cnt, bit verbose=0);
    this.gen2mas       = gen2mas;
    this.verbose       = verbose;
    this.max_tx_cnt    = max_tx_cnt;
    random_tx            = new;
  endfunction

  // Main method generates transactions
  task main();
    
    // debug
    if(verbose)
      $display($time, ": Generating %0d transactions", max_tx_cnt);
    
    // generate N transactions
    while(!end_of_test())
      begin
        calc_transaction my_tx;
        
        // Wait & Get a transaction
        my_tx = get_transaction();
        ++tx_cnt;
  
        //if(verbose)
          //my_tx.display("Generator");

        gen2mas.put(my_tx);
      end // while (!end_of_test())
        
    //if(verbose) 
      //$display($time, ": All transactions generated\n");
  
    ->ended;

  endtask


  // Returns TRUE when the test should stop
  virtual function bit end_of_test();
    end_of_test = (tx_cnt >= max_tx_cnt);
  endfunction
    
  // Returns a transaction (associated with transaction member)
  // - - - - Constraints here: command selection - - - - //
  // ALLOWS TEST COVERAGE: cases 1.1, 1.2
  virtual function calc_transaction get_transaction();
    random_tx.inst_tx_cnt = tx_cnt; // set the serial number
    
    // TODO - Wrap in SV_RAND_CHECK properly
    // Maybe not necessary/possible to do so??
    
    //if (!this.random_tx.randomize() with {random_tx.cmd dist{4'b0001 := 10, 4'b0010 := 10, 4'b0101 := 10, 4'b0110 := 10, 4'b1111 := 10};})
    if (!this.random_tx.randomize() with {random_tx.cmd dist{4'b0000 := 0, 4'b0001 := 10, 4'b0010 := 0, 4'b0101 := 0, 4'b0110 := 10};})
    //if (!this.random_tx.randomize() with {random_tx.cmd dist{4'b1111 := 10, 4'b1110 := 10, 4'b1101 := 10, 4'b1100 := 10, 4'b1011 := 10, 4'b1010 := 10, 4'b1001 := 10, 4'b1000 := 10, 4'b0111 := 10, 4'b0100 := 10, 4'b0011 := 10};})
      begin
        $display("Generator: randomize failed");
        $finish;
      end
    
      
      
  
    //if(verbose)
      //$display("generator cmd: %4b", random_tx.cmd");
      
    return random_tx.copy();
  endfunction
    
endclass  // tx_gen