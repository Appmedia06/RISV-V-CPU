`include "cpu_define.v"

module  csr_control
(
    input   wire            sys_clk      ,
    input   wire            sys_reset    ,
    
    input   wire    [31:0]  instr_i      ,
    input   wire    [31:0]  csr_rd_data_i,
    input   wire    [31:0]  RS_data_i    ,
                                         
    output  reg             csr_wr_en_o  ,
    output  reg     [31:0]  csr_wr_addr_o,
    output  reg     [31:0]  csr_wr_data_o,
    output  reg     [31:0]  csr_rd_addr_o
);

wire     [11:0]  csr_addr;
wire     [4:0 ]  csr_zimm;

assign  csr_addr = instr_i[31:20];
assign  csr_zimm = instr_i[19:15];

always@(*)
    begin
        if (instr_i[6:0] == `INS_TYPE_CSR) begin
          case (instr_i[14:12])  
            `INS_CSRRW: begin
                csr_wr_en_o = 1'b1;
                csr_wr_addr_o = {20'b0, csr_addr};
                csr_wr_data_o = RS_data_i;
                csr_rd_addr_o = {20'b0, csr_addr};
            end
            `INS_CSRRS: begin
                csr_wr_en_o = 1'b1;
                csr_wr_addr_o = {20'b0, csr_addr};
                csr_wr_data_o = csr_rd_data_i | RS_data_i;
                csr_rd_addr_o = {20'b0, csr_addr};
            end
            `INS_CSRRC: begin
                csr_wr_en_o = 1'b1;
                csr_wr_addr_o = {20'b0, csr_addr};
                csr_wr_data_o = csr_rd_data_i & ~(RS_data_i);
                csr_rd_addr_o = {20'b0, csr_addr};
            end
            `INS_CSRRWI: begin
                csr_wr_en_o = 1'b1;
                csr_wr_addr_o = {20'b0, csr_addr};
                csr_wr_data_o = {27'b0, csr_zimm};
                csr_rd_addr_o = {20'b0, csr_addr};
            end
            `INS_CSRRSI: begin
                csr_wr_en_o = 1'b1;
                csr_wr_addr_o = {20'b0, csr_addr};
                csr_wr_data_o = csr_rd_data_i | csr_zimm;
                csr_rd_addr_o = {20'b0, csr_addr};
            end
            `INS_CSRRCI: begin
                csr_wr_en_o = 1'b1;
                csr_wr_addr_o = {20'b0, csr_addr};
                csr_wr_data_o = csr_rd_data_i & ~(csr_zimm);
                csr_rd_addr_o = {20'b0, csr_addr};
            end
            default: begin
                csr_wr_en_o = 1'b0;
                csr_wr_addr_o = 32'b0;
                csr_wr_data_o = 32'b0;
                csr_rd_addr_o = 32'b0;
            end
            endcase
        end
        else begin
            csr_wr_en_o = 1'b0;
            csr_wr_addr_o = 32'b0;
            csr_wr_data_o = 32'b0;
            csr_rd_addr_o = 32'b0;
        end
    end

endmodule