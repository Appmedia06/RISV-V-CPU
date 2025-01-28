`include "../cpu/cpu_define.v"

module RISC_V_SOC_TOP(

    input   wire                        sys_clk             ,
    input   wire                        sys_reset           ,
    
    input   wire                        uart_rx             , 
    output  wire                        uart_tx             , 
    
    output  wire    [3:0]               gpio_pins                     
);

wire            m_wr_en;
wire    [31:0]  m_wr_addr;
wire    [31:0]  m_wr_data;
wire    [31:0]  m_rd_addr;
wire    [31:0]  m_rd_data;

wire            s0_wr_en  ;
wire    [31:0]  s0_wr_addr;
wire    [31:0]  s0_wr_data;
wire    [31:0]  s0_rd_addr;
wire    [31:0]  s0_rd_data;

wire            s1_wr_en;
wire    [31:0]  s1_wr_addr;
wire    [31:0]  s1_wr_data;
wire    [31:0]  s1_rd_addr;
wire    [31:0]  s1_rd_data;

wire            s2_wr_en;
wire    [31:0]  s2_wr_addr;
wire    [31:0]  s2_wr_data;
wire    [31:0]  s2_rd_addr;
wire    [31:0]  s2_rd_data;

wire            timer_int_flag;
wire    [7:0 ]  int_flag;

assign  int_flag = {7'b0, timer_int_flag}; // can be extended


RISCV_CPU  RISCV_CPU
(
    .sys_clk     (sys_clk),
    .sys_reset   (sys_reset),

    .m_wr_en_o   (m_wr_en  ),
    .m_wr_addr_o (m_wr_addr),
    .m_wr_data_o (m_wr_data),
    .m_rd_addr_o (m_rd_addr),
    .m_rd_data_i (m_rd_data),
    
    .int_flag_i  (int_flag)
);

bus  bus
(
    .sys_clk     (sys_clk),
    .sys_reset   (sys_reset),

    .m_wr_en_i   (m_wr_en  ),
    .m_wr_addr_i (m_wr_addr),
    .m_wr_data_i (m_wr_data),
    .m_rd_addr_i (m_rd_addr),
    .m_rd_data_o (m_rd_data),

    .s0_wr_en_o  (s0_wr_en),
    .s0_wr_addr_o(s0_wr_addr),
    .s0_wr_data_o(s0_wr_data),
    .s0_rd_addr_o(s0_rd_addr),
    .s0_rd_data_i(s0_rd_data),

    .s1_wr_en_o  (s1_wr_en  ),
    .s1_wr_addr_o(s1_wr_addr),
    .s1_wr_data_o(s1_wr_data),
    .s1_rd_addr_o(s1_rd_addr),
    .s1_rd_data_i(s1_rd_data) 
);

uart    uart
(
    .sys_clk  (sys_clk),
    .sys_reset(sys_reset),

    .uart_rx  (uart_rx),
    .uart_tx  (uart_tx),

    .wr_en_i  (s0_wr_en  ),
    .wr_addr_i(s0_wr_addr),
    .wr_data_i(s0_wr_data),
    .rd_addr_i(s0_rd_addr),
    .rd_data_o(s0_rd_data)
);

gpio    gpio
(
    .sys_clk  (sys_clk),
    .sys_reset(sys_reset),

    .wr_en_i  (s1_wr_en),
    .wr_addr_i(s1_wr_addr),
    .wr_data_i(s1_wr_data),
    .rd_addr_i(s1_rd_addr),
    .rd_data_o(s1_rd_data),

    .gpio_pins(gpio_pins)
);

timer   timer
(
    .sys_clk         (sys_clk),
    .sys_reset       (sys_reset),

    .wr_en_i         (s2_wr_en),
    .wr_addr_i       (s2_wr_addr),
    .wr_data_i       (s2_wr_data),
    .rd_addr_i       (s2_rd_addr),
    .rd_data_o       (s2_rd_data),

    .timer_int_flag_o(timer_int_flag)
);


endmodule