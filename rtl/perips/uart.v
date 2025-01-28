`include "../cpu/cpu_define.v"

module  uart
(
    input   wire            sys_clk        ,
    input   wire            sys_reset      ,
    
    input   wire            uart_rx        ,
    output  reg             uart_tx        ,
    
    input   wire            wr_en_i        ,
    input   wire    [31:0]  wr_addr_i      ,
    input   wire    [31:0]  wr_data_i      ,
    input   wire    [31:0]  rd_addr_i      ,
    output  reg     [31:0]  rd_data_o      
);

// register address parameter
parameter   UART_CTRL = 4'd0, UART_TX_DATA_BUF = 4'd4, UART_RX_DATA_BUF = 4'd8;
parameter   DELAY_CLK = 3'd4;


reg     [31:0]   uart_ctrl; // addr = 0x00
reg     [31:0]   uart_tx_data_buf; // addr = 0x04
reg     [31:0]   uart_rx_data_buf; // addr = 0x08


parameter   BAUD_CNT_MAX = `CLK_FREQ / `UART_BPS;

parameter   IDLE = 4'd0,
            BEGIN= 4'd1,
            RX_BYTE = 4'd2,
            TX_BYTE = 4'd3,
            END  = 4'd4;

wire            uart_rx_tmp;
reg             uart_rx_delay;
reg     [2:0]   uart_rx_state;
reg     [12:0]  rx_baud_cnt;
reg     [3:0]   rx_bit_cnt;
reg     [31:0]  uart_rx_data_buf_tmp;
reg     [31:0]  rd_addr_reg;

reg     [2:0]   uart_tx_state;
reg     [12:0]  tx_baud_cnt;
reg     [4:0]   tx_bit_cnt;
reg             tx_data_ready;

reg     [31:0]  delay_buf;


always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                uart_ctrl <= 32'b0;
                uart_tx_data_buf <= 32'b0;
            end
        else
            begin
                if(wr_en_i == 1'b1)
                    begin
                        case(wr_addr_i[3:0])
                            UART_CTRL:
                                begin
                                    uart_ctrl <= wr_data_i;
                                end
                            UART_TX_DATA_BUF:
                                begin
                                    uart_tx_data_buf <= wr_data_i;
                                end
                        endcase
                    end
                if(uart_tx_state == END && tx_baud_cnt == 13'b1)
                    begin
                        uart_ctrl[1] <= 1'b1; // TI set 1
                    end
                if(uart_rx_state == END && rx_baud_cnt == 13'b1)
                    begin
                        uart_ctrl[0] <= 1'b1; // RI set 1
                    end
                rd_addr_reg <= rd_addr_i;
            end
    end


always@(*)
    begin
        case(rd_addr_reg[3:0])
            UART_CTRL:
                begin
                    rd_data_o <= uart_ctrl;
                end
            UART_TX_DATA_BUF:
                begin
                    rd_data_o <= uart_tx_data_buf;
                end
            UART_RX_DATA_BUF:
                begin
                    rd_data_o <= uart_rx_data_buf;
                end
            default:
                begin
                    rd_data_o <= 32'b0;
                end
        endcase
    end

/* TX */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                tx_data_ready <= 1'b0;
            end
        else if(wr_en_i == 1'b1 && wr_addr_i[3:0] == UART_TX_DATA_BUF)
            begin
                tx_data_ready <= 1'b1;
            end
        else if(uart_tx_state == END && tx_baud_cnt == 1)
            begin
                tx_data_ready <= 1'b0;
            end
        else
            begin
                tx_data_ready <= tx_data_ready;
            end
    end

/* TX baud count */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                tx_baud_cnt = 13'b0;
            end 
        else if(uart_tx_state == IDLE || tx_baud_cnt == BAUD_CNT_MAX - 1)
            begin
                tx_baud_cnt = 13'b0;
            end
        else
            begin
                tx_baud_cnt = tx_baud_cnt + 1;
            end
    end

/* TX send */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                uart_tx_state <= IDLE;
                tx_bit_cnt <= 5'd0;
                uart_tx <= 1'b1;
            end 
        else
            begin
                case(uart_tx_state)
                    IDLE:
                        begin
                            uart_tx <= 1'b1;
                            if(tx_data_ready == 1'b1) begin
                                uart_tx_state <= BEGIN;
                            end
                            else begin
                                uart_tx_state <= uart_tx_state;
                            end
                        end
                    BEGIN:
                        begin
                            uart_tx <= 1'b0;
                            if(tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                uart_tx_state <= TX_BYTE;
                            end
                            else begin
                                uart_tx_state <= uart_tx_state;
                            end
                        end
                    TX_BYTE:
                        begin
                            if(tx_bit_cnt == 5'd7 && tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                tx_bit_cnt <= 5'd0;
                                uart_tx_state <= END;
                            end
                            else if(tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                tx_bit_cnt <= tx_bit_cnt + 1;
                            end
                            else begin
                                uart_tx <= uart_tx_data_buf[tx_bit_cnt];
                            end
                        end
                    END:
                        begin
                            uart_tx <= 1'b1;
                            if(tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                uart_tx_state <= IDLE;
                            end
                            else begin
                                uart_tx_state <= uart_tx_state;
                            end
                        end
                    default:
                        begin
                            uart_tx_state <= IDLE;
                            tx_bit_cnt <= 5'd0;
                            uart_tx  <= 1'b1;
                        end
                endcase
            end
            
    end



/* RX */
integer n;

always@(posedge sys_clk)
    begin
        for(n = DELAY_CLK - 1; n > 0; n = n - 1) begin
            delay_buf[n] <= delay_buf[n - 1];
        end
        delay_buf[0] <= uart_rx;
    end

assign uart_rx_tmp = delay_buf[DELAY_CLK - 1];

always@(posedge sys_clk)
    begin
        uart_rx_delay <= uart_rx_tmp;
    end
    
/* RX baud count */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                rx_baud_cnt <= 13'd0;
            end 
        else if(uart_rx_state == IDLE || rx_baud_cnt == BAUD_CNT_MAX - 1)
            begin
                rx_baud_cnt <= 13'd0;
            end
        else
            begin
                rx_baud_cnt <= rx_baud_cnt + 1;
            end
    end

/* RX receive */
always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                uart_rx_state <= IDLE;
                rx_bit_cnt <= 4'd0;
                uart_rx_data_buf <= 32'd0;
                uart_rx_data_buf_tmp <= 32'd0;
            end 
        else
            begin
                case(uart_rx_state)
                    IDLE:
                        begin
                            if(uart_rx_tmp == 1'b0 && uart_rx_delay == 1'b1) begin
                                uart_rx_state <= BEGIN;
                            end
                            else begin
                                uart_rx_state <= uart_rx_state;
                            end
                        end
                    BEGIN:
                        begin
                            if(rx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                uart_rx_state <= RX_BYTE;
                            end
                            else begin
                                uart_rx_state <= uart_rx_state;
                            end                            
                        end
                    RX_BYTE:
                        begin
                            if(rx_bit_cnt == 4'd7 && rx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                rx_bit_cnt <= 4'd0;
                                uart_rx_state <= END;
                            end
                            else if(rx_baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                                uart_rx_data_buf_tmp <= {24'b0, uart_rx_delay, uart_rx_data_buf_tmp[7:1]};
                            end
                            else if(rx_baud_cnt == BAUD_CNT_MAX - 1) begin
                                rx_bit_cnt <= rx_bit_cnt + 1'b1;
                            end
                            else begin
                                uart_rx_state <= uart_rx_state;
                            end   
                        end
                    END:
                        begin
                            if(rx_baud_cnt == 1) begin
                                uart_rx_state <= IDLE;
                                uart_rx_data_buf <= uart_rx_data_buf_tmp;
                            end
                            else begin
                                uart_rx_state <= uart_rx_state;
                            end   
                        end
                    default:
                        begin
                            uart_rx_state <= IDLE;
                            rx_bit_cnt <= 4'd0;
                        end
                endcase
            end
        end

endmodule
