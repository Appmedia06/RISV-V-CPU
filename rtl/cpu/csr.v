`include "cpu_define.v"

module  csr
(
    input   wire            sys_clk         ,
    input   wire            sys_reset       ,
        
    // by CSR control Read/Write
    input   wire            csr_wr_en_i         ,
    input   wire    [31:0]  csr_wr_addr_i       ,
    input   wire    [31:0]  csr_wr_data_i       ,
    input   wire    [31:0]  csr_rd_addr_i       ,
    output  reg     [31:0]  csr_rd_data_o       ,
    
    // by clint (Core Local Interruptor) Read/Write
    input   wire            clint_wr_en_i         ,
    input   wire    [31:0]  clint_wr_addr_i       ,
    input   wire    [31:0]  clint_wr_data_i       ,
    input   wire    [31:0]  clint_rd_addr_i       ,
    output  reg     [31:0]  clint_rd_data_o       ,
    
    // privilege mode Read/Write
    input   wire            wr_privilege_en_i,
    input   wire    [1:0 ]  wr_privilege_ctrl_i,
    output  wire    [1:0 ]  privilege_o,
    
    // CSR to clint
    output  wire    [31:0]  clint_csr_mtvec,
    output  wire    [31:0]  clint_csr_mepc,
    output  wire    [31:0]  clint_csr_mstatus
);

/*
privilege_mode:
    00: User mode
    01: Supervisor mode
    11: Machine mode
*/
reg     [1:0]   privilege_mode;

/* Control and Status Register */

/*
register name: cycle
size: 64 bit
purpose: The cycle counter tracks the total number of cycles executed since the CPU reset.
*/
reg     [63:0]  cycle;
/*
register name: mtvec
size: 32 bit
purpose: When an exception is entered, PC (Program counter) will enter the address\
         pointed by mtvec and continue running.
*/
reg     [31:0]  mtvec;
/*
register name: mcause
size: 32 bit
purpose: Record the reasons for the exception
*/
reg     [31:0]  mcause;
/*
register name: mepc
size: 32 bit
purpose: The address pointed to by the PC before entering an exception.\ 
Once the exception is handled, the program counter can read that address and continue execution.
*/
reg     [31:0]  mepc;
/*
register name: mie
size: 32 bit
purpose: Determine whether the interrupt is handled.
*/
reg     [31:0]  mie;
/*
register name: mstatus
size: 32 bit
purpose: When an exception occurs, the hardware will update certain fields in the mstatus register.
*/
reg     [31:0]  mstatus;
/*
register name: mscratch
size: 32 bit
purpose: When an exception occurs, determine whether the program was in M-mode\
before the exception by checking the value in the mscratch register.
*/
reg     [31:0]  mscratch;

assign  clint_csr_mtvec   = mtvec;
assign  clint_csr_mepc    = mepc;
assign  clint_csr_mstatus = mstatus;


/* cycle register counter */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                cycle <= 64'b0;
            end
        else 
            begin
                cycle <= cycle + 1'b1;
            end
    end

/* privilege mode */
assign  privilege_o = privilege_mode;

always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                privilege_mode <= `PRIVILEG_MACHINE; // default mechine mode
            end
        else 
            begin
                if (wr_privilege_en_i == 1'b1) begin
                    privilege_mode <= wr_privilege_ctrl_i;
                end
            end
    end
            
/* Write CSR */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                mtvec <= 32'b0;
                mcause <= 32'b0;
                mepc <= 32'b0;
                mie <= 32'b0;
                mstatus <= 32'b0;
                mscratch <= 32'b0;
            end
        else begin
            // Prioritize handling CSR instruction writes
            if (csr_wr_en_i == 1'b1) begin
                case (csr_wr_addr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= csr_wr_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= csr_wr_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= csr_wr_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= csr_wr_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= csr_wr_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= csr_wr_data_i;
                    end
                    default: begin
         
                    end
                endcase
            end
            // clint write
            else if (clint_wr_en_i == 1'b1) begin
                case (clint_wr_addr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= clint_wr_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= clint_wr_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= clint_wr_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= clint_wr_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= clint_wr_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= clint_wr_data_i;
                    end
                    default: begin
         
                    end
                endcase
            end
        end
    end    
            
/* Read CSR */  

/* Read CSR to CSR control */
always@(*)
    begin
        if ((csr_wr_addr_i[11:0] == csr_rd_addr_i[11:0]) && (csr_wr_en_i == 1'b1)) begin
            csr_rd_data_o = csr_wr_data_i;
        end
        else begin
            case (csr_rd_addr_i[11:0])
                `CSR_CYCLE: begin
                    csr_rd_data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    csr_rd_data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    csr_rd_data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    csr_rd_data_o = mcause;
                end
                `CSR_MEPC: begin
                    csr_rd_data_o = mepc;
                end
                `CSR_MIE: begin
                    csr_rd_data_o = mie;
                end
                `CSR_MSTATUS: begin
                    csr_rd_data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    csr_rd_data_o = mscratch;
                end
                default: begin
                    csr_rd_data_o = 32'b0;
                end
            endcase
        end
    end
      
/* Read CSR to clint */      
always@(*)
    begin
        if ((clint_wr_addr_i[11:0] == clint_rd_addr_i[11:0]) && (clint_wr_en_i == 1'b1)) begin
            clint_rd_data_o = clint_wr_data_i;
        end
        else begin
            case (clint_rd_addr_i[11:0])
                `CSR_CYCLE: begin
                    clint_rd_data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    clint_rd_data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    clint_rd_data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    clint_rd_data_o = mcause;
                end
                `CSR_MEPC: begin
                    clint_rd_data_o = mepc;
                end
                `CSR_MIE: begin
                    clint_rd_data_o = mie;
                end
                `CSR_MSTATUS: begin
                    clint_rd_data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    clint_rd_data_o = mscratch;
                end
                default: begin
                    clint_rd_data_o = 32'b0;
                end
            endcase
        end
    end

endmodule