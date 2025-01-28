`include "../cpu/cpu_define.v"

module  timer
(
    input   wire            sys_clk         ,
    input   wire            sys_reset       ,
                                            
    input   wire            wr_en_i         ,
    input   wire    [31:0]  wr_addr_i       ,
    input   wire    [31:0]  wr_data_i       ,
    input   wire    [31:0]  rd_addr_i       ,
    output  reg     [31:0]  rd_data_o       ,
    
    output  wire            timer_int_flag_o
);

parameter   TIMER_CTRL = 4'd0, TIMER_COUNT = 4'd4, TIMER_EVALUE = 4'd8;

// [0]: timer enable
// [1]: timer int enable
// [2]: timer int pending, software write 0 to clear it
// addr offset: 0x00
reg     [31:0]  timer_ctrl;

// timer current count, read only
// addr offset: 0x04
reg     [31:0]  timer_count;

// timer expired value
// addr offset: 0x08
reg     [31:0]  timer_evalue;

assign timer_int_flag_o = ((timer_ctrl[2] == 1'b1) && (timer_ctrl[1] == 1'b1)) ? 1'b1 : 1'b0;

reg     [31:0]  rd_addr_reg;

always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                timer_ctrl <= 32'b0;
                timer_evalue <= 32'b0;
            end
        else
            begin
                if (wr_en_i == 1'b1) begin
                    case (wr_addr_i[3:0])
                        TIMER_CTRL: begin
                            // software only can set timer_ctrl[2] to 0
                            timer_ctrl <= {wr_data_i[31:3], (timer_ctrl[2] & wr_data_i[2]), wr_data_i[1:0]};
                        end
                        TIMER_EVALUE: begin
                            timer_evalue <= wr_data_i;
                        end
                    endcase
                end
                
                if (timer_ctrl[0] == 1'b1 && timer_count >= timer_evalue) begin
                    timer_ctrl[0] <= 1'b0;
                    timer_ctrl[2] <= 1'b1;
                end
                rd_addr_reg <= rd_addr_i;
            end
    end

always@(*)
    begin
        case(rd_addr_reg[3:0])
            TIMER_CTRL:  
                begin
                    rd_data_o <= timer_ctrl;
                end
            TIMER_COUNT:  
                begin
                    rd_data_o <= timer_count;
                end
            TIMER_EVALUE:
                begin
                    rd_data_o <= timer_evalue;
                end
            default:    
                begin
                    rd_data_o <= 32'b0;
                end
        endcase
    end

// timer count
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                timer_count <= 32'b0;
            end
        else
            begin
              if (timer_ctrl[0] != 1'b1 || timer_count >= timer_evalue) begin
                timer_count <= 32'b0;
              end
              else begin
                timer_count = timer_count + 1'b1;
              end
            end
    end
    
endmodule
