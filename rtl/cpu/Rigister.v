module Register
(
    input   wire                sys_clk   ,
    input   wire                sys_reset ,  
    input   wire    [10:0 ]     op_address,
    input   wire    [4:0 ]      RS_addr_i ,
    input   wire    [4:0 ]      RT_addr_i ,
    input   wire    [4:0 ]      RD_addr_i ,
    input   wire    [31:0]      RD_data_i ,
    input   wire                RegWrite_i,
    
    output  wire    [31:0]      RS_data_o ,
    output  wire    [31:0]      RT_data_o 
);

integer i; // for loop

/* 
    Register File (32x32):
        Def: Store 32 register data
        數據位寬: 32bits
        General Purpose Register: 32
*/
reg     [31:0]      register_file   [0:31];


/* Read */
assign  RS_data_o = register_file[RS_addr_i ];
assign  RT_data_o = register_file[RT_addr_i ];



/* Write */
always@(negedge sys_clk or posedge sys_reset) // nege?
    begin
        if(sys_reset)
            begin
                for(i = 0; i < 32; i = i + 1)
                    register_file[i] <= 0;
            end
        else
            begin
                if(RegWrite_i)
                    begin
                        register_file[RD_addr_i] <= RD_data_i;
                    end
            end
    end

endmodule