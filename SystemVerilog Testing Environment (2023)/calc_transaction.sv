// Transaction data object class

`ifndef CALC_TRANSACTION_DEFINE
`define CALC_TRANSACTION_DEFINE

class calc_transaction;
    static int top_tx_count = 0; // serial numbers identification
    
    rand bit [3:0] cmd;
    rand bit [31:0] data1;
    rand bit [31:0] data2;
    
    //rand logic [31:0] data1;   // for driving 4-state data during tests
    //rand logic [31:0] data2;   // for driving 4-state data during tests
    
    // - - - - constraints for testing: data value ranges - - - - //
    //
    
    // This block allows multiple tests. See inline comments for details (test cases)
    // v 1.0: line-by-line commenting to indicate tests has been abandoned; please see report document
    // these lines can be commented in and out to tweak data value constraints
  
    //constraint data1_range { data1 inside { [0:100000000] } ; }   
    //constraint data1_range { !(data1 inside { [0:1000000] }) ; } 
    //constraint data1_range { data1 inside { [0:100000] } ; }
    //constraint data1_range { data1 dist { 32'h00000001 := 50, 32'h00000010 := 50, 32'h00000100 := 50, 32'h00001000 := 50, 32'h00010000 := 50, 32'h00100000 := 50} ; }  // test 1.1
    //constraint data1_range { data1 dist { 32'h00000010 := 50, 32'h00001000 := 50} ; } // test 1.1
    //constraint data1_range { data1 dist { 32'h55555555 := 50, 32'haaaaaaaa := 50} ; }
    //constraint data1_range { data1 dist { 32'hf000000f := 50, 32'h0fffffff := 50} ; }  // 2.4.7


    //constraint data2_range { data2 == (32'hffffffff - data1) ; }
    //constraint data2_range { data2 == 32'hf0000000; }  // 2.4.7
    //constraint data2_range { data2 == (32'hffffffff - data1 + 1) ; }
    //constraint data2_range { data2 dist { 32'h00000001 := 50, 32'h00000010 := 50} ; } // test 1.1   
    //constraint data2_range { data2 dist { 32'h00000004 := 50, 32'h00000008 := 50} ; } // test 1.1
    //constraint data2_range { data2 dist { 32'h05555555 := 50, 32'h0aaaaaaa := 50} ; }
    //constraint data2_range { data2 dist { 32'h00000000 := 50, 32'hffffffff := 50} ; }
    //constraint data2_range { data2 [4:0] dist { 5'b00100 := 50, 5'b01000 := 50, 5'b01100 := 50} ; }
    //constraint data2_range { data2 dist { 32'hf5555555 := 50, 32'hfaaaaaaa := 50} ; }
    //constraint data2_range { data2 dist { 0 := 11, 4 := 11, 8 := 11, 12 := 11, 16 := 11, 20 := 1, 24 := 1, 28 := 11, 32 := 11 } ; }
    //constraint data2_range { data2 dist { 0 := 50, 1 := 50 } ; }
    //constraint data2_range { data2 dist { 0 := 25, 1 := 25, 2 := 25, 3 := 25 } ; }
    //
    // - - - - end constraints block - - - - //
    
    // Other class variables
    bit [1:0] tag;
    int id, inst_tx_cnt;

    function new;
    id = top_tx_count++;
    tag = id;
    //$display("New transaction with tag %b", tag);  // display 0 (default) until constructor returns control flow
    endfunction // constructor
    
    // Ref. Spear and Tumbush
  function calc_transaction copy();
    calc_transaction tx = new();
    tx.cmd          = this.cmd;
    tx.data1        = this.data1;
    tx.data2        = this.data2;
    copy = tx;
  endfunction // copy
    
endclass

`endif
