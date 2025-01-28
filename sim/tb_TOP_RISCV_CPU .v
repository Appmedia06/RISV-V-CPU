`timescale 1ns/10ps


module  tb_TOP_RISCV_CPU();

/* I/O */
reg             sys_clk;
reg             sys_reset;
reg             uart_rx;
wire             uart_tx;
wire     [3:0]   gpio_pins;



always #10 sys_clk = ~sys_clk;


RISC_V_SOC_TOP RISC_V_SOC_TOP
(

    .sys_clk  (sys_clk),
    .sys_reset(sys_reset),

    .uart_rx  (uart_rx), 
    .uart_tx  (uart_tx), 

    .gpio_pins(gpio_pins)          
);

initial
    begin 
        sys_clk = 1'b1;
        
        sys_reset = 1'b0;
        sys_reset = 1'b1;
        #20
        sys_reset = 1'b0;
    end







endmodule