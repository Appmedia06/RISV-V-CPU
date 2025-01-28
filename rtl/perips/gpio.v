`include "../cpu/cpu_define.v"

module  gpio
(
    input   wire            sys_clk        ,
    input   wire            sys_reset      ,
    
    input   wire            wr_en_i        ,
    input   wire    [31:0]  wr_addr_i      ,
    input   wire    [31:0]  wr_data_i      ,
    input   wire    [31:0]  rd_addr_i      ,
    output  reg     [31:0]  rd_data_o      ,
    
    output  wire    [3:0]   gpio_pins
);

parameter   GPIO_CTRL = 4'd0, GPIO_DATA = 4'd4;

reg     [31:0]  gpio_ctrl;
reg     [31:0]  gpio_data;

reg     [31:0]  rd_addr_reg;

assign gpio_pins = ~gpio_data[3:0];

always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                gpio_data <= 32'b0;
            end
        else
            begin
                if (wr_en_i) 
                    begin
                        case(wr_addr_i[3:0])
                            GPIO_CTRL:  begin
                                gpio_ctrl <= wr_data_i;
                            end
                            GPIO_DATA:  begin
                                gpio_data <= wr_data_i;
                            end
                        endcase
                    end
                rd_addr_reg <= rd_addr_i;
            end
    end
            
always@(*)
    begin
        case(rd_addr_reg[3:0])
            GPIO_CTRL:  
                begin
                    rd_data_o <= gpio_ctrl;
                end
            GPIO_DATA:  
                begin
                    rd_data_o <= gpio_data;
                end
            default:    
                begin
                    rd_data_o <= 32'b0;
                end
        endcase
    end

endmodule







    
