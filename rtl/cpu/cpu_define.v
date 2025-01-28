// Clock Cycle
`define CYCLE_TIME  20 // freq=50M(Hz)


// Instruction Memory bit width
`define IM_ADDR   31:0
`define IM_INST_I 7 :0
`define IM_INST_O 31:0

// Memory bit width
`define INSTR_MEM_BW 31:0
`define DATA_MEM_BW  7:0

// Memory size
// `define INSTR_MEM_NUM 4096
// `define DATA_MEM_NUM  4096

`define INSTR_MEM_NUM 256
`define DATA_MEM_NUM  128

// Instruction symbol
`define INSTR_START 8'b1111_1110
`define INSTR_END   8'b1111_1111

// Instruction memory address
`define INSTR_MEM_ADDR_MAX 5'b11111


// R-type and M-type instruction (opcode)
`define INS_TYPE_R_M 7'b011_0011
// R-type {funct7, funct3}
`define INS_ADD     10'b00_0000_0000
`define INS_SUB     10'b01_0000_0000
`define INS_SLL     10'b00_0000_0001  
`define INS_SLT     10'b00_0000_0010  
`define INS_SLTU    10'b00_0000_0011  
`define INS_XOR     10'b00_0000_0100  
`define INS_SRL     10'b00_0000_0101  
`define INS_SRA     10'b01_0000_0101  
`define INS_OR      10'b00_0000_0110
`define INS_AND     10'b00_0000_0111

// ALU operation
`define ALU_ADD      4'b0000
`define ALU_SUB      4'b0001
`define ALU_SLL      4'b0010
`define ALU_SLT      4'b0011
`define ALU_SLTU     4'b0100
`define ALU_XOR      4'b0101
`define ALU_SRL      4'b0110
`define ALU_SRA      4'b0111
`define ALU_OR       4'b1000
`define ALU_AND      4'b1010
`define ALU_LUI      4'b1011  

// M-type {funct7, funct3}
`define INS_MUL     10'b00_0000_1000  
`define INS_MULH    10'b00_0000_1001  
`define INS_MULHSU  10'b00_0000_1010  
`define INS_MULHU   10'b00_0000_1011  
`define INS_DIV     10'b00_0000_1100  
`define INS_DIVU    10'b00_0000_1101  
`define INS_REM     10'b00_0000_1110  
`define INS_REMU    10'b00_0000_1111  

`define INS_TYPE_M  7'b011_0011

`define MALU_MUL    4'b0000
`define MALU_MULH   4'b0001
`define MALU_MULHSU 4'b0010
`define MALU_MULHU  4'b0011
`define MALU_DIV    4'b0100
`define MALU_DIVU   4'b0101
`define MALU_REM    4'b0110
`define MALU_REMU   4'b0111
  

// I-type (opcode)
`define INS_TYPE_I  7'b001_0011
// funct3
`define INS_ADDI         3'b000
`define INS_SLTI         3'b010
`define INS_SLTIU        3'b011
`define INS_XORI         3'b100
`define INS_ORI          3'b110
`define INS_ANDI         3'b111
`define INS_SLLI         3'b001
`define INS_SRLI_SRAI    3'b101

// U-type (opcode)
`define INS_LUI         7'b011_0111  
`define INS_AUIPC       7'b001_0111  

// Unconditional jump instruction (opcode)
`define INS_JAL         7'b110_1111  // 立即数+pc
`define INS_JALR        7'b110_0111  // 立即数+寄存器+pc

// Branch instruction (opcode)
`define INS_TYPE_BRANCH         7'b110_0011
// funct3
`define INS_BEQ         3'b000  // 相等跳转
`define INS_BNE         3'b001  // 不等跳转
`define INS_BLT         3'b100  // 小于跳转
`define INS_BGE         3'b101  // 大于跳转
`define INS_BLTU        3'b110  // 小于跳转（无符号数）
`define INS_BGEU        3'b111  // 大于跳转（无符号数）

// Memory Access SAVE (opcode)
`define INS_TYPE_SAVE        7'b010_0011 
// funct3
`define INS_SB          3'b000  // 存8位
`define INS_SH          3'b001  // 存16位
`define INS_SW          3'b010  // 存32位

// Memory Access LOAD (opcode)
`define INS_TYPE_LOAD        7'b000_0011 
// funct3
`define INS_LB          3'b000  // 取8位
`define INS_LH          3'b001  // 取16位
`define INS_LW          3'b010  // 取32位
`define INS_LBU         3'b100  // 取8位，无符号拓展
`define INS_LHU         3'b101  // 取16位，无符号拓展


// CSR register instruction (opcode)
`define INS_TYPE_CSR         7'b1110011
// funct3
`define INS_CSRRW       3'b001
`define INS_CSRRS       3'b010
`define INS_CSRRC       3'b011
`define INS_CSRRWI      3'b101
`define INS_CSRRSI      3'b110
`define INS_CSRRCI      3'b111

`define INS_ECALL  32'h0000_0073
`define INS_EBREAK 32'h0010_0073
`define INS_MRET   32'h3020_0073
`define INS_NOP    32'h0000_0013  // 空操作指令，NOP: ADDI x0,x0,0

// Asynchronous interrupt
`define INT_NONE      8'b0000_0000
`define INT_TIMER     8'b0000_0001
`define INT_UART_REV  8'b0000_0010


// privilege mode
`define PRIVILEG_USER        2'b00
`define PRIVILEG_SUPERVISOR  2'b01
`define PRIVILEG_MACHINE     2'b11


`define CLK_FREQ   'd50_000_000
`define UART_BPS   'd9600


/* Control and Status Register (CSR) address */
`define CSR_CYCLE    12'hc00
`define CSR_CYCLEH   12'hc80
`define CSR_MTVEC    12'h305
`define CSR_MCAUSE   12'h342
`define CSR_MEPC     12'h341
`define CSR_MIE      12'h304
`define CSR_MSTATUS  12'h300
`define CSR_MSCRATCH 12'h340

/* privilege mode */
`define PRIVILEG_USER        2'b00
`define PRIVILEG_SUPERVISOR  2'b01
`define PRIVILEG_MACHINE     2'b11