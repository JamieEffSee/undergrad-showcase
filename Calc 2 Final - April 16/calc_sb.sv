//Ref. Wile et al.
//Ref. Spear and Tumbush

`include "calc_transaction.sv"
`include "calc_result.sv"

class calc_sb;

  // - - - - CLASS VARIABLES - - - - //
 
  typedef enum {CORRECT, INCORRECT} calc_result_check;
 
  // Debug and flow control
  bit verbose;  // (DEPRECATED: see v0.6 notes)
  event ended;
  
  int max_tx_cnt;  // Max # of transactions
  int match; // Number of good matches (DEPRECATED: see v0.6 notes)

  // Transactions coming in
  mailbox #(calc_transaction) mas2scb;
  mailbox #(calc_result) mon2scb;   

  // Result of comparison
  calc_result_check res_check;
  
  // transaction and result objects
  calc_transaction mas_tx;
  calc_result mon_tx;
  
  // Structure for checking tx vs rx
  bit [31:0] expected_data_array[3:0];
  bit [31:0] exp_val;
  calc_transaction request_array[3:0];
  
  // - - - - COVERGROUPS - - - - //
  
  // Input request: command and operands
  covergroup cg_input;  
    request_cmd: coverpoint mas_tx.cmd 
    {
      bins a = {4'b0001}; // add
      bins b = {4'b0010}; // subtract
      bins c = {4'b0101}; // SHL
      bins d = {4'b0110}; // SHR
    }
    request_data: coverpoint mas_tx.data1;
    request_data2: coverpoint mas_tx.data2;
  endgroup
    
  // Output result: response/result and correctitude  
  covergroup cg_output;
    output_resp: coverpoint mon_tx.out_resp
    {
      bins a = {2'b01}; // good
      bins b = {2'b10}; // bad
    }
    output_data: coverpoint mon_tx.out_data;
    output_match: coverpoint res_check;
    endgroup

  // Constructor
  function new(int max_tx_cnt, mailbox #(calc_transaction) mas2scb, mailbox #(calc_result) mon2scb, bit verbose=0);
    this.max_tx_cnt = max_tx_cnt;
    this.mon2scb       = mon2scb;
    this.mas2scb       = mas2scb;
    this.verbose       = verbose;
    
    // instantiate covergroups
    cg_input = new();
    cg_output = new();
  endfunction
  

  // Main daemon pulls transactions from master and monitor
  task main();
    fork
        forever begin   //  input fork
		// declare an input and perform sampling (BEFORE data handling)
            mas2scb.get(mas_tx);
            request_array[mas_tx.tag] = mas_tx;
            cg_input.sample();
            
		// "Command" case for generating expected values:
		// check the operation, perform it, and
		// save the exp_val
            case(mas_tx.cmd)
              
            //4'b0000:  // no operation
            //    begin
            //        exp_val = mas_tx.data1;
            //        expected_data_array[mas_tx.tag] = exp_val;
            //    end 
        
            4'b0001:  // addition
                begin
                    exp_val = mas_tx.data1 + mas_tx.data2;
                    expected_data_array[mas_tx.tag] = exp_val;
                end
			
            4'b0010:  // subtraction
                begin
                    exp_val = mas_tx.data1 - mas_tx.data2;
                    expected_data_array[mas_tx.tag] = exp_val;				
                end
				
            4'b0101:  // left shift
                begin
                    exp_val = mas_tx.data1 << mas_tx.data2[4:0];
                    expected_data_array[mas_tx.tag] = exp_val;
                end
		
            4'b0110:  // right shift
                begin
                    exp_val = mas_tx.data1 >> mas_tx.data2[4:0];
                    expected_data_array[mas_tx.tag] = exp_val;
                end
           
            default:
                begin
                  $display("@%0d: Note: Scoreboard input fork just received idle or illegal master transaction in mas_tx", $time);
                  //$finish;
                end
            endcase
        end       // input fork
        
        forever begin     //  output fork

            mon2scb.get(mon_tx);            
            // logic assumes the result is correct and checks otherwise
            res_check = CORRECT;
            
            exp_val = expected_data_array[mon_tx.out_tag];
            
            if (mon_tx.out_resp === 2'b00) begin
              $display("@%0d: Note: Scoreboard output fork just received an idle state from mon_tx (port %0d) with resp %2b", $time, mon_tx.out_port, mon_tx.out_resp);
              //$finish;
            end
         
         
           if (mon_tx.out_data !== exp_val) begin
                $display("@%0d: On port #%0d ERROR: Cmd: %4b, Data1: %h, Data2: %h, TxTag: %2b, ResultTag: %2b - monitor data (%h) does not match expected value (%h) with resp %b",
                    $time, mon_tx.out_port, request_array[mon_tx.out_tag].cmd, request_array[mon_tx.out_tag].data1, request_array[mon_tx.out_tag].data2, request_array[mon_tx.out_tag].tag, mon_tx.out_tag, mon_tx.out_data, exp_val, mon_tx.out_resp);
                
                res_check = INCORRECT;
           end
           
         else begin
           $display("@%0d: On port #%0d SUCCESS: Good match for monitor (%h) = expected (%h); resp is %b; tag is %b", $time, mon_tx.out_port, mon_tx.out_data, exp_val, mon_tx.out_resp, mon_tx.out_tag);
         end
            
            //Perform covergroup sampling (AFTER data handling)
            cg_output.sample();
            
            // Determine if the end of test has been reached
            if(--max_tx_cnt<1)
              ->ended;      // sends .triggered() signal up the pipeline
            
        end // output branch of fork
    join_none  //  end fork
    
  endtask   // main

endclass