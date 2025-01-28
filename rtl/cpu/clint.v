`include "cpu_define.v"

module  clint
(
    input   wire            sys_clk     ,
    input   wire            sys_reset   ,
    
    input   wire    [31:0]  instr_i     ,
    input   wire    [31:0]  pc_i        ,
    
    input   wire            jump_flag_i ,
    input   wire    [31:0]  jump_addr_i ,
    input   wire            div_req_i   ,
    input   wire            div_busy_i  ,
    
    // CSR Read/Write
    output  reg             wr_en_o     ,
    output  reg     [31:0]  wr_addr_o   ,
    output  reg     [31:0]  wr_data_o   , 
    
    // CSR
    input   wire    [31:0]  csr_mtvec   ,
    input   wire    [31:0]  csr_mepc    ,
    input   wire    [31:0]  csr_mstatus ,
    input   wire    [1:0 ]  privilege_i ,
    output  reg             wr_privilege_en_o,
    output  reg     [1:0 ]  wr_privilege_ctrl_o,
    
    input   wire    [7:0 ]  int_flag_i  , // asynchronous interrupt flag
    output  wire            clint_busy_o, // interrupt busy
    output  reg     [31:0]  int_addr_o  , // interrupt entry address
    output  reg             int_assert_o  // interrupt flag
);

/* interrupt status */
parameter   INT_IDLE            =   3'b001;
parameter   INT_SYNC_ASSERT     =   3'b010;
parameter   INT_ASYNC_ASSERT    =   3'b011;
parameter   INT_MRET            =   3'b100;

/* Write control and status register status */
parameter   CSR_IDLE            =   3'b001;
parameter   CSR_MSTATUS         =   3'b010;
parameter   CSR_MEPC            =   3'b011;
parameter   CSR_MSTATUS_MRET    =   3'b100;
parameter   CSR_MCAUSE          =   3'b101;

reg     [2:0 ]      int_state;
reg     [2:0 ]      csr_state;
reg     [31:0]      cause;
reg     [31:0]      ins_addr;
reg     [31:0]      div_ins_addr;

assign  clint_busy_o = ((int_state != INT_IDLE) || (csr_state != CSR_IDLE)) ? 1'b1 : 1'b0;

/* if instr is div, save the PC*/
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                div_ins_addr <= 31'b0;
            end
        else if (instr_i == `INS_DIV || instr_i == `INS_DIVU || instr_i == `INS_REM || instr_i == `INS_REMU)
            begin
                div_ins_addr <= pc_i;
            end
        else
            begin
                div_ins_addr <= div_ins_addr;
            end
    end

/* interrupt arbitration */
always@(*)
    begin
        if(sys_reset)
            begin
                int_state = INT_IDLE;
            end   
        else
            begin
                // asynchronous interrupt
                if (int_flag_i != `INT_NONE && csr_mstatus[3] == 1'b1) begin
                    int_state = INT_ASYNC_ASSERT;
                end
                else if (instr_i == `INS_ECALL || instr_i == `INS_EBREAK) begin
                    // synchronous interrupt
                    if (~div_req_i && ~jump_flag_i) begin
                        int_state = INT_SYNC_ASSERT;
                    end
                    else begin
                        int_state = INT_IDLE;
                    end
                end
                else if (instr_i == `INS_MRET) begin
                    int_state = INT_MRET;
                end
                else begin
                    int_state = INT_IDLE;
                end
            end
    end

/* Write CSR state */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                csr_state <= CSR_IDLE;
                cause <= 32'b0;
                ins_addr <= 32'b0;
            end
        else 
            begin
                case (csr_state)
                    CSR_IDLE: begin
                        // synchronous interrupt
                        if (int_state == INT_SYNC_ASSERT) begin
                            csr_state <= CSR_MEPC;
                            ins_addr <= pc_i;
                            
                            if (instr_i == `INS_ECALL) begin
                                cause <= 32'd11;
                            end
                            else if (instr_i == `INS_EBREAK) begin
                                cause <= 32'd3;
                            end
                            else begin
                                cause <= 32'd10;
                            end
                        end
                        // asynchronous interrupt
                        else if (int_state == INT_ASYNC_ASSERT) begin
                            // Timer int
                            if (int_flag_i & `INT_TIMER) begin
                                cause <= 32'h80000007;
                            end
                            // UART int
                            if (int_flag_i & `INT_UART_REV) begin
                                cause <= 32'h8000000b;
                            end
                            else begin
                                cause <= 32'h8000000a;
                            end
                            
                            csr_state <= CSR_MEPC;
                            
                            if (jump_flag_i == 1'b1) begin
                                ins_addr <= jump_addr_i;
                            end
                            else if (div_req_i == 1'b1 || div_busy_i == 1'b1) begin
                                ins_addr <= div_ins_addr;
                            end
                            else begin
                                ins_addr <= pc_i;
                            end
                        end
                    else if (int_state == INT_MRET) begin
                        csr_state <= CSR_MSTATUS_MRET;
                    end
                    end
                    CSR_MEPC: begin
                        csr_state <= CSR_MSTATUS;
                    end
                    CSR_MSTATUS: begin
                        csr_state <= CSR_MCAUSE;
                    end
                    CSR_MCAUSE: begin
                        csr_state <= CSR_IDLE;
                    end     
                    CSR_MSTATUS_MRET: begin
                        csr_state <= CSR_IDLE;
                    end 
                    default: begin
                        csr_state <= CSR_IDLE;
                    end
                endcase
            end
        end


/* Write CSR */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                wr_en_o <= 1'b0;
                wr_addr_o <= 32'b0;
                wr_data_o <= 32'b0;
                wr_privilege_en_o <= 1'b0;
                wr_privilege_ctrl_o <= `PRIVILEG_MACHINE;
            end
        else
            begin
                case (csr_state)
                    // Set the MEPC register to the current instruction address
                    CSR_MEPC: begin
                        wr_en_o <= 1'b1;
                        wr_addr_o <= {20'h0, `CSR_MEPC};
                        wr_data_o <= ins_addr;
                    end
                    // Set the MCAUSE register as the cause of the interrupt
                    CSR_MCAUSE: begin
                        wr_en_o <= 1'b1;
                        wr_addr_o <= {20'h0, `CSR_MCAUSE};
                        wr_data_o <= cause;
                    end
                    // Turn off global interrupts, change the privilege level to mechine, and store the current privilege level in MPP
                    CSR_MSTATUS: begin
                        wr_privilege_en_o <= 1'b1;
                        wr_privilege_ctrl_o <= `PRIVILEG_MACHINE;
                        wr_en_o <= 1'b1;
                        wr_addr_o <= {20'h0, `CSR_MSTATUS};
                        wr_data_o <= {csr_mstatus[31:13], privilege_i, csr_mstatus[10:4], 1'b0, csr_mstatus[2:0]};
                    end                
                    // Return from interrupt and change the privilege level to MPP
                    CSR_MSTATUS_MRET: begin
                        wr_privilege_en_o <= 1'b1;
                        wr_privilege_ctrl_o <= csr_mstatus[12:11]; // MPP
                        wr_en_o <= 1'b1;
                        wr_addr_o <= {20'h0, `CSR_MSTATUS};
                        wr_data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};                       
                    end
                    default: begin
                        wr_privilege_en_o <= 1'b0;
                        wr_privilege_ctrl_o <= `PRIVILEG_MACHINE;
                        wr_en_o <= 1'b0;
                        wr_addr_o <= 32'b0;
                        wr_data_o <= 32'b0;
                    end
                endcase
            end
    end

/* Send interrupt signal to pipeline */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                int_assert_o <= 1'b0;
                int_addr_o <= 32'b0;
            end
        else 
            begin
                case (csr_state)
                    CSR_MCAUSE: begin
                        int_assert_o <= 1'b1;
                        int_addr_o <= csr_mtvec;
                    end
                    CSR_MSTATUS_MRET: begin
                        int_assert_o <= 1'b1;
                        int_addr_o <= csr_mepc;
                    end
                    default: begin
                        int_assert_o <= 1'b0;
                        int_addr_o <= 32'b0;
                    end
                endcase
            end
    end

endmodule