`include "cpu_define.v"

module  DALU
(
    input   wire            sys_clk       ,
    input   wire            sys_reset     ,
    input   wire            start         ,
    
    input   wire    [31:0]  dividend_i    ,
    input   wire    [31:0]  divisor_i     ,
    input   wire    [2:0 ]  funct3_i      ,
    
    output  reg     [31:0]  result_o      ,
    output  reg             div_complete_o
);

reg     [31:0]  divisor;
reg     [63:0]  reminder;
reg             dividend_sign, divisor_sign;
reg     [5:0 ]  bit_position;
reg             div_busy;
reg     [2:0 ]  operation;



always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                result_o <= 0;
                div_complete_o <= 0;
                div_busy <= 0;
                divisor <= 0;
                reminder <= 0;
                bit_position <= 0;
                operation <= 0;
            end
        else if(start && !div_busy)
            begin
                // initial
                bit_position <= 31;
                div_busy <= 1'b1;
                div_complete_o <= 0;
                operation <= funct3_i;
                
                dividend_sign <= dividend_i[31];
                divisor_sign  <= divisor_i[31];
                
                if (divisor_i[31] && !funct3_i[0])
                    divisor <= ~(divisor_i) + 1;
                else
                    divisor  <= divisor_i;
                
                if (dividend_i[31] && !funct3_i[0])
                    reminder <= {{32{1'b0}}, (~dividend_i) + 1} << 1;
                else    
                    reminder <= {{32{1'b0}}, dividend_i} << 1;
                
            end
        else if(div_busy) // start division
            begin
                if(bit_position == 6'b111111) // division complete
                    begin
                        reminder[63:32] = reminder[63:32] >> 1;
                        case(operation)
                        4'b0100: // DIV
                            begin
                                if(dividend_sign ^ divisor_sign)
                                    begin
                                        result_o <= ~(reminder[31:0]) + 1;
                                    end
                                else
                                    begin
                                        result_o <= reminder[31:0];
                                    end
                            end
                        4'b0101: // DIVU
                            begin
                                result_o <= reminder[31:0];
                            end
                        4'b0110: // REM
                            begin
                                result_o <= (dividend_sign) ? (~(reminder[63:32]) + 1) : reminder[63:32];
                            end
                        4'b0111: // REMU
                            begin
                                result_o <= reminder[63:32];
                            end
                        default:
                            begin
                                result_o <= 32'b0;
                            end
                        endcase
                    div_busy <= 1'b0;
                    div_complete_o <= 1'b1;
                    end
                else
                    begin
                        if (operation[0]) // unsigned
                            begin
                                if ($unsigned(reminder[63:32]) < $unsigned(divisor))
                                    begin
                                        reminder = reminder << 1;
                                    end
                                else
                                    begin
                                        reminder[63:32] = $unsigned(reminder[63:32]) - $unsigned(divisor);
                                        reminder = (reminder << 1) | 64'b1;
                                    end
                                
                            end
                        else // signed
                            begin
                                if ($signed(reminder[63:32]) < $signed(divisor))
                                    begin
                                        reminder = reminder << 1;
                                    end
                                else
                                    begin
                                        reminder[63:32] = reminder[63:32] - divisor;
                                        reminder = (reminder << 1) | 64'b1;
                                    end                                    
                            end
                        bit_position = bit_position - 1;
                    end
               
            end
        else
            begin
                div_complete_o = 1'b0;
            end
    end


endmodule