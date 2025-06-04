// For use in the monitor/scoreboard

`ifndef CALC_RESULT_DEFINE
`define CALC_RESULT_DEFINE

class calc_result;
    bit [1:0] out_resp;
    bit [31:0] out_data;
    bit [1:0] out_tag;
    integer out_port;
    
// Ref. Spear and Tumbush
  function calc_result copy();
    calc_result rs     = new();
    rs.out_resp        = this.out_resp;
    rs.out_data        = this.out_data;
    rs.out_tag         = this.out_tag;
    rs.out_port        = this.out_port;
    copy = rs;
  endfunction: copy
    
endclass

`endif//ndef
