// Ref. Wile et. al. 
`ifndef CALC_IFC_DEFINE
`define CALC_IFC_DEFINE

`include "config.sv"

interface calc_ifc (input PClk);
    
    // Internal Signals
    
    logic [ENV_CMD_SIZE-1:0] assertCmd // DEPRECATED (v 0.5)
    logic [ENV_CMD_SIZE-1:0]  PCmd;
    logic [ENV_DATA_SIZE-1:0]  PData;
    logic [1:0] PTag;

    //Input for DUT
    logic [ENV_CMD_SIZE-1:0] req1_cmd_in;
    logic [ENV_CMD_SIZE-1:0] req2_cmd_in;
    logic [ENV_CMD_SIZE-1:0] req3_cmd_in;
    logic [ENV_CMD_SIZE-1:0] req4_cmd_in;

    logic [ENV_DATA_SIZE-1:0]  req1_data_in;
    logic [ENV_DATA_SIZE-1:0]  req2_data_in;
    logic [ENV_DATA_SIZE-1:0]  req3_data_in;
    logic [ENV_DATA_SIZE-1:0]  req4_data_in;

    logic [1:0]  req1_tag_in;
    logic [1:0]  req2_tag_in;
    logic [1:0]  req3_tag_in;
    logic [1:0]  req4_tag_in;

    logic reset;

    //Output for DUT
    wire [1:0]  out_resp1;
    wire [1:0]  out_resp2;
    wire [1:0]  out_resp3;
    wire [1:0]  out_resp4;

    wire [ENV_DATA_SIZE-1:0]  out_data1;
    wire [ENV_DATA_SIZE-1:0]  out_data2;
    wire [ENV_DATA_SIZE-1:0]  out_data3;
    wire [ENV_DATA_SIZE-1:0]  out_data4;   
    
    wire [1:0]  out_tag1;
    wire [1:0]  out_tag2;
    wire [1:0]  out_tag3;
    wire [1:0]  out_tag4;

    always @ (posedge PClk) begin
// drive one command to all ports
        req1_cmd_in <= PCmd;
        req2_cmd_in <= PCmd;
        req3_cmd_in <= PCmd;
        req4_cmd_in <= PCmd;
    
        req1_data_in <= PData;
        req2_data_in <= PData;
        req3_data_in <= PData;
        req4_data_in <= PData;

        req1_tag_in <= PTag;
        req2_tag_in <= PTag;
        req3_tag_in <= PTag;
        req4_tag_in <= PTag;
        
    end
    
    
//    always @ (posedge PClk) begin
// // drive command to one(ish) port(s) at a time  //  used for facilitating certain test cases
//
//        req3_cmd_in <= PCmd;
//        req4_cmd_in <= 0;
//        req2_cmd_in <= 0;
//        req1_cmd_in <= 0;
//    
//        req3_data_in <= PData;
//        req4_data_in <= 0;
//        req2_data_in <= 0;
//        req1_data_in <= 0;
//
//        req3_tag_in <= PTag;
//        req4_tag_in <= 0;
//        req2_tag_in <= 0;
//        req1_tag_in <= 0;
//        
//    end

//    always @ (posedge PClk) begin
//    end


// Modports
// one each for the three main DUT/env interfaces
  modport Master(input PClk, output PCmd, PData, PTag, reset);
  
  modport Monitor(      input PClk, out_resp1, out_resp2, out_resp3, out_resp4,
                        out_data1, out_data2, out_data3, out_data4,
                        out_tag1, out_tag2, out_tag3, out_tag4
                        );
  
  modport Slave(        input req1_cmd_in, req2_cmd_in, req3_cmd_in, req4_cmd_in,
                        req1_data_in, req2_data_in, req3_data_in, req4_data_in,
                        req1_tag_in, req2_tag_in, req3_tag_in, req4_tag_in,

                        output out_resp1, out_resp2, out_resp3, out_resp4,
                        out_data1, out_data2, out_data3, out_data4,
                        out_tag1, out_tag2, out_tag3, out_tag4
                        );
  
endinterface

`endif   // ifndef
