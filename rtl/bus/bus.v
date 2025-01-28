module  bus
(
    input   wire            sys_clk        ,
    input   wire            sys_reset      ,
    
    input   wire            m_wr_en_i     ,
    input   wire    [31:0]  m_wr_addr_i   ,
    input   wire    [31:0]  m_wr_data_i   ,
    input   wire    [31:0]  m_rd_addr_i   ,
    output  reg     [31:0]  m_rd_data_o   ,
    
    /* UART */
    output  reg             s0_wr_en_o     ,
    output  reg     [31:0]  s0_wr_addr_o   ,
    output  reg     [31:0]  s0_wr_data_o   ,
    output  reg     [31:0]  s0_rd_addr_o   ,
    input   wire    [31:0]  s0_rd_data_i   ,
    
    /* GPIO */
    output  reg             s1_wr_en_o     ,
    output  reg     [31:0]  s1_wr_addr_o   ,
    output  reg     [31:0]  s1_wr_data_o   ,
    output  reg     [31:0]  s1_rd_addr_o   ,
    input   wire    [31:0]  s1_rd_data_i   
    
    /* Timer */
/*     output  reg             s2_wr_en_o     ,
    output  reg     [31:0]  s2_wr_addr_o   ,
    output  reg     [31:0]  s2_wr_data_o   ,
    output  reg     [31:0]  s2_rd_addr_o   ,
    input   wire    [31:0]  s2_rd_data_i    */
);


/* 最高的 byte 決定訪問的外設 */
parameter[3:0]  slave_0 = 4'b0010; /* UART */
parameter[3:0]  slave_1 = 4'b0001; /* GPIO */
// parameter[1:0]  slave_2 = 2'b10; /* Timer */

reg     [31:0]  m_rd_addr_reg_i;


/* master write slave */
always@(*)
    begin
        s0_wr_en_o   = 1'b0;
        s0_wr_addr_o = 32'b0;
        s0_wr_data_o = 32'b0;
        
        s1_wr_en_o   = 1'b0;
        s1_wr_addr_o = 32'b0;
        s1_wr_data_o = 32'b0;

        case (m_wr_addr_i[31:28])
            slave_0: 
                begin
                    s0_wr_en_o   = m_wr_en_i;
                    s0_wr_addr_o = m_wr_addr_i;
                    s0_wr_data_o = m_wr_data_i;
                end
            slave_1: 
                begin
                    s1_wr_en_o   = m_wr_en_i;  
                    s1_wr_addr_o = m_wr_addr_i;
                    s1_wr_data_o = m_wr_data_i;
                end 
            default:
                begin
                    
                end
        endcase
    end
    
always @(posedge sys_clk) 
    begin
        m_rd_addr_reg_i <= m_rd_addr_i;
    end
    

/* master read slave */
always@(*)
    begin
        m_rd_data_o = 32'b0;
        
        case (m_rd_addr_reg_i[31:28])
            slave_0: 
                begin
                    m_rd_data_o = {{4'd0}, s0_rd_data_i[27:0]};
                end
            slave_1: 
                begin
                    m_rd_data_o = {{4'd0}, s0_rd_data_i[27:0]};
                end 
            default:
                begin
                    
                end
        endcase
    end    


/* slave read master */
always@(*)
    begin
        s0_rd_addr_o = 32'b0;
        s1_rd_addr_o = 32'b0;
        
        case (m_rd_addr_reg_i[31:28])
            slave_0: 
                begin
                    s0_rd_addr_o = {{4'd0}, m_rd_addr_i[27:0]};
                end
            slave_1: 
                begin
                    s1_rd_addr_o = {{4'd0}, m_rd_addr_i[27:0]};
                end 
            default:
                begin
                    
                end
        endcase
    end
    
endmodule    