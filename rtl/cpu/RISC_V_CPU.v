`include "cpu_define.v"


module  RISC_V_CPU
(
    input   wire            sys_clk  ,
    input   wire            sys_reset,
    input   wire            DataOrReg,
    input   wire    [1:0]   vout_addr,
    input   wire    [10:0]  address  ,
    input   wire    [7:0]   instr_i  ,
    
    output  reg     [7:0]   value_o
);

/* Parameter */

wire    [31:0]  instr, instr_addr, addedPC, pcFlush_MUX_o;
wire    [9:0 ]  ALUfunct_i;
// wire    [11:0]  swIm;
wire    [1:0 ]  pc_type;
wire            rst;

wire    [11:0]  branch_pcIm;
wire    [19:0]  JAL_pcIm;
wire    [11:0]  JALR_pcIm;
wire    [31:0]  pcIm_MUX_o;
wire            PC_Imm_Select;
wire            isBranch;
wire            isJump;
// wire            PC_Branch_Select;

wire    [31:0]  Reg_RS_data_o;
wire    [31:0]  Reg_RT_data_o;

wire    [31:0]  addOffset_data_o;
wire    [31:0]  pcSelect_data_o;
wire            HazardDetect_Hazard_o;

wire    [31:0]  IF_ID_pc_o;
// wire    [11:0]  IF_ID_pcIm_o;
wire    [31:0]  IF_ID_instr_o;
wire            IF_ID_isdiv_o;
// wire    [31:0]  pcIm_Extend_data_o;
// wire    [31:0]  shiftLeft_data_o;
wire    [31:0]  SignExtend_data_o;

wire    [3:0 ]  ALU_control_o;
wire            isMulDiv;
reg             isDivision;
reg             div_operation;
reg             div_flag;
wire            isdiv;
wire            ismul;
reg             MD_select;

wire    [3:0 ]  Control_ALUop_o;
wire            Control_ALUsrc_o;
wire            Control_RegWrite_o;
wire            Control_MemRead_o;
wire            Control_MemWrite_o;
wire            Control_MemToReg_o;
wire    [2:0 ]  Control_immSelect_o;

wire    [3:0 ]  ControlMUX_ALUop_o;
wire            ControlMUX_ALUsrc_o;
wire            ControlMUX_RegWrite_o;
wire            ControlMUX_MemRead_o;
wire            ControlMUX_MemWrite_o;
wire            ControlMUX_MemToReg_o;
wire    [4:0 ]  ControlMUX_RegDst_o;


wire    [31:0]  ID_EX_instr_o;
wire    [31:0]  ID_EX_pc_o;
wire    [31:0]  ID_EX_RD_data0_o;
wire    [31:0]  ID_EX_RD_data1_o;
wire    [31:0]  ID_EX_SignExtended_o;
wire    [4:0 ]  ID_EX_RegDst_o;
wire    [3:0 ]  ID_EX_ALUop_o;
wire            ID_EX_ALUsrc_o;
wire            ID_EX_RegWrite_o;
wire            ID_EX_MemToReg_o;
wire            ID_EX_MemRead_o;
wire            ID_EX_MemWrite_o;
wire    [4:0 ]  ID_EX_RS_addr_o;
wire    [4:0 ]  ID_EX_RT_addr_o;
wire    [31:0]  ID_EX_Offset_o;
wire            ID_EX_isdiv_o;

wire    [1:0 ]  ForwardingUnit_ForwardA_o;
wire    [1:0 ]  ForwardingUnit_ForwardB_o;
wire    [31:0]  ForwardToData1_data_o;
wire    [31:0]  ForwardToData2_data_o;

wire    [31:0]  EX_MEM_ALUResult_o;
wire    [31:0]  EX_MEM_RD_data_o;
wire    [4:0 ]  EX_MEM_RD_addr_o;
wire            EX_MEM_RegWrite_o;
wire            EX_MEM_MemToReg_o;
wire            EX_MEM_MemRead_o;
wire            EX_MEM_MemWrite_o;
wire    [31:0]  EX_MEM_instr_o;
wire    [31:0]  EX_MEM_Offset_o;
wire    [31:0]  EX_MEM_pc_o;
wire            EX_MEM_isjump_o;


wire    [31:0]  ALUsrc_MUX_data_o;
wire    [31:0]  ALU_data_o;
wire            ALU_zero_o;
wire    [31:0]  MALU_data_o;
wire    [31:0]  DALU_data_o;
wire            DALU_div_complete_o;
wire    [31:0]  MD_mux_data_o;
wire    [31:0]  ALU_select_data_o;

wire            branch_estab;

wire    [31:0]  MemToReg_data_o;
wire    [31:0]  MemToReg2_data_o;

wire    [31:0]  MEM_WB_ALUResult_o;
wire    [31:0]  MEM_WB_RD_data_o;
wire    [4:0 ]  MEM_WB_RD_addr_o;
wire            MEM_WB_RegWrite_o;
wire            MEM_WB_MemToReg_o;
wire    [31:0]  MEM_WB_DataMemReadData_o;
wire    [31:0]  MEM_WB_pc_o;
wire            MEM_WB_isjump_o;

wire    [31:0]  Data_Memory_data_o;
wire    [31:0]  reg_o, data_mem_o;

reg             startFlag;
reg             sys_start;
reg     [7:0 ]  counter;

/* Assignment */

// assign  RegEqual = (Reg_RS_data_o == Reg_RT_data_o);
assign  isBranch = (ID_EX_instr_o[6:0] == `INS_TYPE_BRANCH) ? 1'b1 : 1'b0;
assign  isJump = (ID_EX_instr_o[6:0] == `INS_JAL || ID_EX_instr_o[6:0] == `INS_JALR);
assign  PC_Imm_Select = (branch_estab & isBranch) | isJump; // TO flush_i

assign  ALUfunct_i = {ID_EX_instr_o[31:25], ID_EX_instr_o[14:12]}; // funct code

assign  branch_pcIm = {IF_ID_instr_o[31], IF_ID_instr_o[7], IF_ID_instr_o[31:25], IF_ID_instr_o[11:8]} << 1; // B-type imm
assign  JAL_pcIm = {IF_ID_instr_o[31], IF_ID_instr_o[19:12], IF_ID_instr_o[20], IF_ID_instr_o[30:21]} << 1; // JAL imm
assign  JALR_pcIm = IF_ID_instr_o[31:20]; // JALR imm

assign  isMulDiv = (ID_EX_instr_o[6:0] == `INS_TYPE_M) ? 1'b1: 1'b0;
assign  isdiv = ((instr[6:0] == `INS_TYPE_M) && (instr[14:12] == 3'b100 || instr[14:12] == 3'b101 || instr[14:12] == 3'b110 || instr[14:12] == 3'b111))? 1'b1 : 1'b0;
assign  ismul = ((ID_EX_instr_o[6:0] == `INS_TYPE_M) && (ID_EX_instr_o[14:12] == 3'b000 || ID_EX_instr_o[14:12] == 3'b001 || ID_EX_instr_o[14:12] == 3'b010 || ID_EX_instr_o[14:12] == 3'b011))? 1'b1 : 1'b0;

assign  rst = sys_reset;

/* Sequential */

always@(posedge sys_clk or posedge sys_reset)
    if(sys_reset)
        begin
            startFlag <= 1'b0;
            sys_start <= 1'b0;
            counter   <= 8'b0;
        end
    else
         begin
            if(startFlag)
                begin
                    if(instr_i == `INSTR_END && counter > 70)
                        begin
                            startFlag <= 1'b0;
                            sys_start <= 1'b1;
                        end
                    else
                        begin
                            startFlag <= startFlag;
                            sys_start <= sys_start;
                            counter <= counter + 8'b1;
                        end
                end
            else
                begin
                    if(instr_i == `INSTR_START)
                        begin
                            startFlag <= 1'b1;
                            counter <= counter + 8'b1;
                        end
                    else
                        begin
                            startFlag <= startFlag;
                            sys_start <= sys_start;
                        end
                end
        end 
        
        
        
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                isDivision <= 1'b0;
                div_flag <= 1'b1;
            end    
        else if (div_flag && (instr[6:0] == `INS_TYPE_M) && (instr[14:12] == 3'b100 || instr[14:12] == 3'b101 || instr[14:12] == 3'b110 || instr[14:12] == 3'b111))
            begin
                isDivision <= 1'b1;
                div_flag <= 1'b0;
            end
        else if (isDivision)
            begin
                isDivision <= 1'b0;
            end
        else
            begin
                isDivision <= 1'b0;
            end
    end
    
        
    
always@(*)
    begin
        if (DALU_div_complete_o)
            begin
                MD_select <= 1'b1;
                div_flag <= 1'b1;
            end
        else if (ismul)
            begin
                MD_select <= 1'b0;
            end
        else
            begin
                MD_select <= 1'b1;
            end
        
    end
        
/* Combinational */

always@(*)
    begin
        case(vout_addr)
        2'b00: value_o = (DataOrReg) ? reg_o[7:0]     :   data_mem_o[7:0];
        2'b01: value_o = (DataOrReg) ? reg_o[15:8]    :   data_mem_o[15:8];
        2'b10: value_o = (DataOrReg) ? reg_o[23:16]   :   data_mem_o[23:16];
        2'b11: value_o = (DataOrReg) ? reg_o[31:24]   :   data_mem_o[31:24];
        endcase
    end


/* Instance */

mux pc_MUX
(
    .data0_i (pcFlush_MUX_o),
    .data1_i (ID_EX_Offset_o), // branch or Jump
    .select_i(PC_Imm_Select),

    .data_o  (pcSelect_data_o)
);

pc  pc
(
    .sys_clk    (sys_clk),
    .sys_start  (sys_start),
    .pc_i       (pcSelect_data_o),
    .hazardPC_i (HazardDetect_Hazard_o),

    .pc_o       (instr_addr) 
);

adder   add_PC
(
    .data1_i(instr_addr),
    .data2_i(32'd4),

    .data_o (addedPC) // TO IF_ID.pc_i
);

mux pcFlush_MUX
(
    .data0_i (addedPC),
    .data1_i (instr_addr), // PC
    .select_i(isdiv && !DALU_div_complete_o),

    .data_o  (pcFlush_MUX_o)
);

instruction_memory instruction_memory
(
    .sys_clk  (sys_clk),
    .sys_reset(rst),    
    .addr_i   (instr_addr),
    .instr_i  (instr_i),

    .instr_o  (instr) // IF_ID.instr_i
);

pcIm_control pcIm_control
(
    .opcode (IF_ID_instr_o[6:0]),
    
    .pc_type(pc_type)
);

mux3 pcIm_MUX
(
    .data0_i (JAL_pcIm),
    .data1_i (JALR_pcIm), 
    .data2_i (branch_pcIm),
    .select_i(pc_type),

    .data_o  (pcIm_MUX_o)
);

/* SignExtend  PCImmSignExtend
(
    .select_i(pc_type),
    .data_i ({{12{1'b0}}, IF_ID_pcIm_o}),

    .data_o  (pcIm_Extend_data_o)
); */

/* Shift Shift_left
(
    .data_i(pcIm_MUX_o),

    .data_o(shiftLeft_data_o)
); */

adder   add_offset
(
    .data1_i(IF_ID_pc_o),
    .data2_i(pcIm_MUX_o),

    .data_o (addOffset_data_o) 
);

IF_ID   IF_ID
(
    .sys_clk  (sys_clk),
    .sys_start(sys_start),
    .pc_i     (instr_addr),
    .instr_i  (instr),
    .hazard_i (HazardDetect_Hazard_o),
    .flush_i  (PC_Imm_Select),
    .isdiv_i  (isDivision),
/*     .pcIm_i   (pcIm),

    .pcIm_o   (IF_ID_pcIm_o), */
    .pc_o     (IF_ID_pc_o),
    .instr_o  (IF_ID_instr_o),
    .isdiv_o  (IF_ID_isdiv_o)
);

control Control
(
    .op_i       (IF_ID_instr_o[6:0]), // opcode
    .funct3_i   (IF_ID_instr_o[14:12]),
    .funct7_i   (IF_ID_instr_o[31:25]),

    .ALUop_o    (Control_ALUop_o), // ALU  operation
    .ALUsrc_o   (Control_ALUsrc_o), // mux diff input
    .RegWrite_o (Control_RegWrite_o), // enable to write into register
    .MemRead_o  (Control_MemRead_o), // enable to read Memory
    .MemWrite_o (Control_MemWrite_o), // enable to write into Memory
    .MemToReg_o (Control_MemToReg_o), // mux diff input
    .immSelect_o(Control_immSelect_o)
);

controlMUX  ControlMUX
(
    .Hazard_i  (HazardDetect_Hazard_o),

    .ALUop_i   (Control_ALUop_o),
    .ALUsrc_i  (Control_ALUsrc_o),
    .RegWrite_i(Control_RegWrite_o),
    .MemRead_i (Control_MemRead_o),
    .MemWrite_i(Control_MemWrite_o),
    .MemToReg_i(Control_MemToReg_o),
    .RegDst_i  (IF_ID_instr_o[11:7]),

    .ALUop_o   (ControlMUX_ALUop_o),
    .ALUsrc_o  (ControlMUX_ALUsrc_o),
    .RegWrite_o(ControlMUX_RegWrite_o),
    .MemRead_o (ControlMUX_MemRead_o),
    .MemWrite_o(ControlMUX_MemWrite_o),
    .MemToReg_o(ControlMUX_MemToReg_o),
    .RegDst_o  (ControlMUX_RegDst_o)
);


Register    Register_file
(
    .sys_clk   (sys_clk),
    .sys_reset (rst),  
    .op_address(address),
    .RS_addr_i (IF_ID_instr_o[19:15]),
    .RT_addr_i (IF_ID_instr_o[24:20]),
    .RD_addr_i (MEM_WB_RD_addr_o),
    .RD_data_i (MemToReg2_data_o),
    .RegWrite_i(MEM_WB_RegWrite_o),

    .RS_data_o (Reg_RS_data_o),
    .RT_data_o (Reg_RT_data_o),
    .reg_o     (reg_o)
);

SignExtend  SignExtend
(
    .select_i(Control_immSelect_o),
    .data_i (IF_ID_instr_o[31:7]), // L-type & I-type
/*     .data1_i ({IF_ID_instr_o[31:25], IF_ID_instr_o[11:7]}), // S-type & B-type
    .data2_i (IF_ID_instr_o[31:12]), // LUI, AUIPC */

    .data_o  (SignExtend_data_o)
);


ID_EX   ID_EX
(
    .sys_clk        (sys_clk),
    .sys_start      (sys_start),
    
    .flush_i        (PC_Imm_Select),
    .instr_i        (IF_ID_instr_o),
    .pc_i           (IF_ID_pc_o),
    // .pcEX_i         (pcIm_Extend_data_o),
    .RD_data0_i     (Reg_RS_data_o),
    .RD_data1_i     (Reg_RT_data_o),
    .SignExtended_i (SignExtend_data_o),
    .RegDst_i       (ControlMUX_RegDst_o),
    .Offset_i       (addOffset_data_o),

    .ALUop_i        (ControlMUX_ALUop_o),
    .ALUsrc_i       (ControlMUX_ALUsrc_o),
    .RegWrite_i     (ControlMUX_RegWrite_o),
    .MemToReg_i     (ControlMUX_MemToReg_o),
    .MemRead_i      (ControlMUX_MemRead_o),
    .MemWrite_i     (ControlMUX_MemWrite_o),
    .PC_branch_sel_i(PC_Imm_Select),

    .RS_addr_i      (IF_ID_instr_o[19:15]),
    .RT_addr_i      (IF_ID_instr_o[24:20]),
    
    .isdiv_i        (IF_ID_isdiv_o),

    .instr_o        (ID_EX_instr_o),
    .pc_o           (ID_EX_pc_o),
    // .pcEX_o         (),
    .RD_data0_o     (ID_EX_RD_data0_o),
    .RD_data1_o     (ID_EX_RD_data1_o),
    .SignExtended_o (ID_EX_SignExtended_o),
    .RegDst_o       (ID_EX_RegDst_o), 
    .Offset_o       (ID_EX_Offset_o),

    .ALUop_o        (ID_EX_ALUop_o),
    .ALUsrc_o       (ID_EX_ALUsrc_o),
    .RegWrite_o     (ID_EX_RegWrite_o),
    .MemToReg_o     (ID_EX_MemToReg_o),
    .MemRead_o      (ID_EX_MemRead_o),
    .MemWrite_o     (ID_EX_MemWrite_o),
    .PC_branch_sel_o(),

    .RS_addr_o      (ID_EX_RS_addr_o),
    .RT_addr_o      (ID_EX_RT_addr_o),
    
    .isdiv_o        (ID_EX_isdiv_o)
);

hazard_detection hazard_detection
(
    .IF_ID_RS1_i    (IF_ID_instr_o[24:20]),
    .IF_ID_RS2_i    (IF_ID_instr_o[19:15]),
    .ID_EX_RD_i     (ID_EX_instr_o[11:7 ]), // modify
    .ID_EX_MemRead_i(ID_EX_MemRead_o),

    .Hazard_o       (HazardDetect_Hazard_o)
);

forwarding_unit ForwardingUnit
(
    .ID_EX_RS_i       (ID_EX_RS_addr_o),
    .ID_EX_RT_i       (ID_EX_RT_addr_o),
    .EX_MEM_RD_i      (EX_MEM_RD_addr_o),
    .MEM_WB_RD_i      (MEM_WB_RD_addr_o),
    .EX_MEM_RegWrite_i(EX_MEM_RegWrite_o),
    .MEM_WB_RegWrite_i(MEM_WB_RegWrite_o),

    .ForwardA_o       (ForwardingUnit_ForwardA_o),
    .ForwardB_o       (ForwardingUnit_ForwardB_o)
);

forwardingMUX   ForwardToData1
(
    .select_i(ForwardingUnit_ForwardA_o),
    .data_i  (ID_EX_RD_data0_o),
    .EX_MEM_i(EX_MEM_ALUResult_o),
    .MEM_WB_i(MemToReg2_data_o),

    .data_o  (ForwardToData1_data_o)
);

forwardingMUX   ForwardToData2
(
    .select_i(ForwardingUnit_ForwardB_o),
    .data_i  (ID_EX_RD_data1_o),
    .EX_MEM_i(EX_MEM_ALUResult_o),
    .MEM_WB_i(MemToReg2_data_o),

    .data_o  (ForwardToData2_data_o)
);

mux ALUsrc_MUX // behind ForwardToData2
(
    .data0_i (ForwardToData2_data_o),
    .data1_i (ID_EX_SignExtended_o),
    .select_i(ID_EX_ALUsrc_o),

    .data_o  (ALUsrc_MUX_data_o)
);

ALU_control ALU_control
(
    .funct_i   (ALUfunct_i), // {funct7, funct3}
    .ALUop_i   (ID_EX_ALUop_o),

    .ALU_Ctrl_o(ALU_control_o)
);

ALU ALU
(
    .data0_i   (ForwardToData1_data_o),
    .data1_i   (ALUsrc_MUX_data_o),
    .ALU_Ctrl_i(ALU_control_o),

    .data_o    (ALU_data_o),
    .zero_o    (ALU_zero_o)  // for branch
);

MALU MALU
(
    .data0_i   (ForwardToData1_data_o),
    .data1_i   (ALUsrc_MUX_data_o),
    .ALU_Ctrl_i(ALU_control_o),
    .is_M_i    (isMulDiv), // is RV32M instruction

    .data_o    (MALU_data_o)
);

DALU DALU
(
    .sys_clk         (sys_clk),
    .sys_reset       (sys_reset),
    .start           (ID_EX_isdiv_o),
                     
    .dividend_i      (ForwardToData1_data_o),
    .divisor_i       (ALUsrc_MUX_data_o),
    .funct3_i        (ALU_control_o),
                     
    .result_o        (DALU_data_o),
    .div_complete_o  (DALU_div_complete_o)
);

mux MD_mux
(
    .data0_i (MALU_data_o),
    .data1_i (DALU_data_o), 
    .select_i(MD_select),

    .data_o  (MD_mux_data_o)
);

mux ALU_mux
(
    .data0_i (ALU_data_o),
    .data1_i (MD_mux_data_o),
    .select_i(isMulDiv),

    .data_o  (ALU_select_data_o)
);

EX_MEM  EX_MEM
(
    .sys_clk     (sys_clk),
    .sys_start   (sys_start),

    // .flush_i     (PC_Imm_Select),
    .pc_i        (ID_EX_pc_o),
    .ALU_result_i(ALU_select_data_o),
    .RD_data_i   (ForwardToData2_data_o),
    .RD_addr_i   (ID_EX_RegDst_o),
    .RegWrite_i  (ID_EX_RegWrite_o),
    .MemToReg_i  (ID_EX_MemToReg_o),
    .MemRead_i   (ID_EX_MemRead_o),
    .MemWrite_i  (ID_EX_MemWrite_o),
    .instr_i     (ID_EX_instr_o),
    .Offset_i    (ID_EX_Offset_o),
    .isjump_i    (isJump),
    
    .pc_o        (EX_MEM_pc_o),
    .ALU_result_o(EX_MEM_ALUResult_o),
    .RD_data_o   (EX_MEM_RD_data_o),
    .RD_addr_o   (EX_MEM_RD_addr_o),
    .RegWrite_o  (EX_MEM_RegWrite_o),
    .MemToReg_o  (EX_MEM_MemToReg_o),
    .MemRead_o   (EX_MEM_MemRead_o),
    .MemWrite_o  (EX_MEM_MemWrite_o),
    .instr_o     (EX_MEM_instr_o),
    .Offset_o    (EX_MEM_Offset_o),
    .isjump_o    (EX_MEM_isjump_o)
);

branch_control branch_control
(
    .funct3      (ID_EX_instr_o[14:12]),
    .ALU_data    (ALU_select_data_o),
    
    .branch_estab(branch_estab)
);

data_memory data_memory
(
    .sys_clk   (sys_clk),
    .sys_reset (rst),
    .RD_addr_i (address),
    .addr_i    (EX_MEM_ALUResult_o),
    .data_i    (EX_MEM_RD_data_o),
    .funct3_i  (EX_MEM_instr_o[14:12]),
    .MemRead_i (EX_MEM_MemRead_o),
    .MemWrite_i(EX_MEM_MemWrite_o),

    .data_o    (Data_Memory_data_o),
    .data_mem_o(data_mem_o)
);

MEM_WB  MEM_WB
(
    .sys_clk          (sys_clk),
    .sys_start        (sys_start),
    .ALU_result_i     (EX_MEM_ALUResult_o),
    .RD_data_i        (EX_MEM_RD_data_o),
    .RD_addr_i        (EX_MEM_RD_addr_o),
    .RegWrite_i       (EX_MEM_RegWrite_o),
    .MemToReg_i       (EX_MEM_MemToReg_o),
    .DataMemReadData_i(Data_Memory_data_o),
    .pc_i             (EX_MEM_pc_o),
    .isjump_i         (EX_MEM_isjump_o),

    .ALU_result_o     (MEM_WB_ALUResult_o),
    .RD_data_o        (MEM_WB_RD_data_o),
    .RD_addr_o        (MEM_WB_RD_addr_o),
    .RegWrite_o       (MEM_WB_RegWrite_o),
    .MemToReg_o       (MEM_WB_MemToReg_o),
    .DataMemReadData_o(MEM_WB_DataMemReadData_o),
    .pc_o             (MEM_WB_pc_o),
    .isjump_o         (MEM_WB_isjump_o)
);

mux MemToReg_MUX
(
    .data0_i (MEM_WB_ALUResult_o),
    .data1_i (MEM_WB_DataMemReadData_o),
    .select_i(MEM_WB_MemToReg_o),

    .data_o  (MemToReg_data_o)
);

mux MemTOReg2_MUX
(
    .data0_i (MemToReg_data_o),
    .data1_i (MEM_WB_pc_o),
    .select_i(MEM_WB_isjump_o),

    .data_o  (MemToReg2_data_o)
);


endmodule