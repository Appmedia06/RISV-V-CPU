`timescale 1ns/10ps


module  tb_SL_RISC_V_CPU();

/* I/O */
reg             sys_clk;
reg             sys_reset;

reg             DataOrReg;
reg     [1:0]   vout_addr;
reg     [10:0]   address;
reg     [7:0]   instr_i;

wire    [7:0]   value_o;

/* testbench */
reg     [7:0]   instr_store[0: (64*4 + 1)];
reg     [7:0]   golden [0:72];

/* testbench parameter */
integer         j, k; // for loop
integer         counter; // instruction counter
integer         stall, flush, idx;
integer         error_num; 
integer         outfile;


always #10 sys_clk = ~sys_clk;


RISC_V_CPU  RISC_V_CPU
(
    .sys_clk  (sys_clk),
    .sys_reset(sys_reset),
    .DataOrReg(DataOrReg),
    .vout_addr(vout_addr),
    .address  (address),
    .instr_i  (instr_i),

    .value_o  (value_o)
);


initial
    begin
        counter = 0;
        stall = 0;
        flush = 0;
        idx = 0;
        error_num = 0;
        
        DataOrReg = 1;
        address = 5'b00101;
        vout_addr = 2'b11;
        instr_i = 0;
        
        for(j = 0; j < (64*4 + 1); j = j + 1)
            instr_store[j] = 0;
        
        /* I-type */
/*         $readmemb("C:/Users/user/side project/RISV-V CPU/data/I_type/I_type_instr.txt", instr_store);
        $readmemh("C:/Users/user/side project/RISV-V CPU/data/I_type/I_type_ans.dat", golden); */
        
        /* R-type */
/*         $readmemb("C:/Users/user/side project/RISV-V CPU/data/R_type/R_type_instr.txt", instr_store);
        $readmemh("C:/Users/user/side project/RISV-V CPU/data/R_type/R_type_ans.dat", golden); */
        
        /* SL_type */
        $readmemb("C:/Users/user/side project/RISV-V CPU/data/S_L_type/SL_type_instr.txt", instr_store);
        $readmemh("C:/Users/user/side project/RISV-V CPU/data/S_L_type/SL_type_ans.dat", golden);
        
        outfile = $fopen("C:/Users/user/side project/RISV-V CPU/data/Foutput.txt") | 1;
        
        sys_clk = 1'b1;
        
        sys_reset = 1'b0;
        sys_reset = 1'b1;
        #20
        sys_reset = 1'b0;
    end


always@(posedge sys_clk)
    begin
        if(counter <= 256) // change
            begin
                #5
                instr_i = instr_store[counter];
            end
        else
            instr_i = 8'd0;
    end

initial
    begin
        k = 0;
        for(k = 0; k < 72; k = k + 1)
            $display("golden[%d] = %h", k, golden[k]);
        
        $display("--------------------------- [ Simulation Starts !!! ] ---------------------------");
        #(20*250);
        for(k = 0; k < 52; k = k + 1) // change
            begin
                if((k % 4 == 0) && (k != 0))
                    begin
                        address = address + 5'd1;
                        $display(" ");
                    end
                    
                @(posedge sys_clk);
                vout_addr = vout_addr - 2'd1;
                
                if(value_o !== golden[k])
                    begin
                        error_num = error_num + 1;
                        $display("pattern%d is wrong:output %h != expected %h", k, value_o, golden[k]);
                    end
                else
                    begin
                        $display("pattern%d is correct:output %h == expected %h", k, value_o, golden[k]);
                    end
            end
            
        $display(" ");
        $display("Data Memery");
        $display(" ");
        
        DataOrReg = 0;    
        address = 11'h400;
        for(k = 52; k < 72; k = k + 1) // change
            begin
                if((k % 4 == 0) && (k != 52))
                    begin
                        address = address + 11'd4;
                        $display(" ");
                    end
                @(posedge sys_clk);
                vout_addr = vout_addr - 2'd1;
                
                if(value_o !== golden[k])
                    begin
                        error_num = error_num + 1;
                        $display("pattern%d is wrong:output %h != expected %h", k, value_o, golden[k]);
                    end
                else
                    begin
                        $display("pattern%d is correct:output %h == expected %h", k, value_o, golden[k]);
                    end
            end
            #(20*2);
     $display("--------------------------- Simulation Stops !!---------------------------");
     if (error_num) 
        begin 
            $display("============================================================================");
            $display("             ▄▄▄▄▄▄▄ "); 
            $display("         ▄▀▀▀       ▀▄"); 
            $display("       ▄▀            ▀▄ 		ERROR FOUND!!"); 
            $display("      ▄▀          ▄▀▀▄▀▄"); 
            $display("    ▄▀          ▄▀  ██▄▀▄"); 
            $display("   ▄▀  ▄▀▀▀▄    █   ▀▀ █▀▄ 	There are"); 
            $display("   █  █▄▄   █   ▀▄     ▐ █  %d errors in total.", error_num); 
            $display("  ▐▌  █▀▀  ▄▀     ▀▄▄▄▄▀  █ "); 
            $display("  ▐▌  █   ▄▀              █"); 
            $display("  ▐▌   ▀▀▀                ▐▌"); 
            $display("  ▐▌               ▄      ▐▌ "); 
            $display("  ▐▌         ▄     █      ▐▌ "); 
            $display("   █         ▀█▄  ▄█      ▐▌ "); 
            $display("   ▐▌          ▀▀▀▀       ▐▌ "); 
            $display("    █                     █ "); 
            $display("    ▐▌▀▄                 ▐▌"); 
            $display("     █  ▀                ▀ "); 
            $display("============================================================================");
        end
     else 
        begin 
            $display("        ,@@@@@@@@@@,,@@@@@@@&  .#&@@@&&.,@@@@@@@@@@,      &@@@@@@&*   ,@@@&     .#&@@@&&.  *&@@@@&(  ,@@@@@@@&  &@@@@@,     ,@@,");
            $display("            ,@@,    ,@@,      ,@@/   ./.    ,@@,          &@&   ,&@# .&@&@@(   .@@/   ./. #@&.  .,/  ,@@,       &@&  *&@&.  ,@@,");
            $display("            ,@@,    ,@@&&&&&. .&@@/,        ,@@,          &@&   ,&@# &@& /@@,  .&@@/,     (@@&&(*.   ,@@&&&&&.  &@&    &@#  ,@@,");
            $display("            ,@@,    ,@@&&&&&. .&@@/,        ,@@,          &@&   ,&@# &@& /@@,  .&@@/,     (@@&&(*.   ,@@&&&&&.  &@&    &@#  ,@@,");
            $display("            ,@@,    ,@@/,,,,    ./#&@@@(    ,@@,          &@@@@@@&* /@@,  #@&.   ./#&@@@(   *(&&@@&. ,@@/,,,,   &@&    &@#  .&&.");
            $display("            ,@@,    ,@@,      ./,   .&@#    ,@@,          &@&      ,@@@@@@@@@& ./.   .&@# /*.   /@@. ,@@,       &@&  *&@&.   ,, ");
            $display("            ,@@,    ,@@@@@@@& .#&@@@@&/     ,@@,          &@&     .&@#     ,@@/.#&@@@@&/   /&&@@@@.  ,@@@@@@@&  &@@@@@.     ,@@,");
            $display(",*************,,*/(((((//,,*(#&&&&&&&&&&&&&&&#(*,,,****************************************************,*/(((((((((/((((////****/((##&&&&&&");
            $display(",*************,,//((((((//,,*(&&&&&&&&&&&&&&&&&##/*****************************************************,,*/(///(//////****//((##&&&&&&&&&&&");
            $display(",************,,*/(((((((//***/#&&&&&&&&&&&&&&&&&&&#(/***************************************************,*//////////*//((#&&&&&&&&&&&&&&&&&");
            $display(",***********,,*////////////***/##&&&&&&&&&&&&&&&&&&&##(*,***********************************************,,*////////(###&&&&&&&&&&&&&&&&&&&&");
            $display(",**********,,,*/*******//////**/(#&&&&&&&&&&&&&&&&&&&&&#(/**********************************************,,,***/(##&&&&&&&&&&&&&&&&&&&&&&&&&");
            $display(",*********,,,,*************///***/(#&&&&&&&&&&&&&&&&&&&&&&#(/***********************************,****,****/((#&&&&&&&&&&&&&&&&&&&&&&&&&&&&#");
            $display(",*********,,,***************//****/(##&&&&&&&&&&&&&&&&&&&&&&##//**************//////////////////////((#####&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(");
            $display(",********,,,,***********************/(#&&&&&&&&&&&&&&&&&&&&&&&##################&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##(/");
            $display(",*******,..,***********************,,*/##&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&###((//");
            $display(",*******,.,,***********************,,,,*(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##(//**//");
            $display(",******,.,,,************************,,,,*/(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(//*******");
            $display(",*****,,,,,********,***,,,,,,,,,,,,*,,,,,,*/(######&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##(/**********");
            $display(",*****,..,*******,,,,,,,,,,,,,,,,,,,,,,*,,,,*///((#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&###(/************");
            $display(",*****,,,*******,,,,,*,,,,,,,,,,,,,,,,,****,,,*/(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#######(//**************");
            $display(",****,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**,,,/(&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#((//******************");
            $display(",***,..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..,,,,,,,*(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(/*******************");
            $display(",**,,.,,,,,,,,,,,,,,,,,,,,,,,,,,.......,,,,,,/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#####&&&&&&&&&&&&&&&&#(/******************");
            $display(",**,..,,,,,,,,,,,,,,,,,,,,,,,,,......,,,*,,,*(#&&&&&&&&##(((/(##&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##(((/*/((#&&&&&&&&&&&&&&#(/*****************");
            $display(",*,..,,,,,,,,,,,,,,,,,,,,,,,,,,,.....,,**,,*/#&&&&&&&##((((*,**/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&##((##/,,,*(#&&&&&&&&&&&&&&#(*****************");
            $display(".*,.,,,**,,,,,,,,,,,,,,,,,,,,,,,,,,*****,,,/(&&&&&&&&#(//(#/,..*/#&&&&&&&&&&&&&&&&&&&&&&&&&&&#(//(#/,..,/(#&&&&&&&&&&&&&&#/*****///////////");
            $display(".,..,,,,,,,,,,,,,,,,,,,,,,,,,,*,,*******,,,(#&&&&&&&&#(*,,,....,/#&&&&&&&&&&&&&&&&&&&&&&&&&&&#(*,,,....,/(#&&&&&&&&&&&&&&#(*,**////////////");
            $display(".,..,,,,,,,,,...........,,,,,,*,********,,*(#&&&&&&&&&#(/*,,...,/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(/*,,..,*/##&&&&&&&&&&&&&&&#(***////////////");
            $display(" ..,,,,,,.................,,,**********,,*(#&&&&&&&&&&&&&&&&&&#&&&&&&&&#((///((#&&&&&&&&&&&&&&&&&&&&&#&&&&&&&&&&&&&&&&&&&&&#/**////////////");
            $display(".,,,,,,,,.................,,***********,,/(####&&&&&&&&&&&&&&&&&&&&&&&&#(/*,,,*(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(/*////////////");
            $display(".,***,,,,,,..............,,,**********,..,***//((##&&&&&&&&&&&&&&&&&&&&&&&##((##&&&&&&&&&&&&&&&&&&&&&&&&&##(((((((((###&&&&&#/**///////////");
            $display(".*****,,,,,,,,,,,,,,,,,,,*************,..,*******/(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##///*//////((#&&&&&#(**///////////");
            $display(".****************/******/***////*****,.,*///////**/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(////////////(#&&&&&#/**//////////");
            $display(".***********************/////*******,..,*//////////(#&&&&&&&&&&&&&&&&&&&&##########&&&&&&&&&&&&&&&&&&&&#(///////////*/(#&&&&&#(***/////////");
            $display(".************************///********,..,*//////////#&&&&&&&&&&&&&&&&&&#(//*****///(((##&&&&&&&&&&&&&&&&#(///////////**/##&&&&##/***////////");
            $display(".***********************************,.,,***///////(#&&&&&&&&&&&&&&&&#(/*,,,*//((((////(#&&&&&&&&&&&&&&&#((////////////(#&&&&&&#(*********//");
            $display(",***********,,,*,,*,,**************,,,*//******//(#&&&&&&&&&&&&&&&&&#(*,,*/(((#####(((((#&&&&&&&&&&&&&&&##///////////(#&&&&&&&&#(***///////");
            $display(",*************,,**,,,************,,,,,/(##((((####&&&&&&&&&&&&&&&&&&&(/**/(((#((((#((//(#&&&&&&&&&&&&&&&&&#(((((((((##&&&&&&&&&&#/**///////");
            $display(",******************************,,,,,,,*(#&#&&&&&&&&&&&&&&&&&&&&&&&&&&#(**/((#(#(((#((//(#&&&&&&&&&&&&&&&&&&&&&&&#&#&&&&&&&&&&&&&#(**///////");
            $display(",*************,**************,****,,,,,/(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(/*/((((#((((///(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&(/*///////");
            $display(",*************************************,*/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##(////////////(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#/**/////*");
            $display(",******////****///////////////////////***/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&####(((((((###&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(********");
            $display(".,*,****///////////////////////////////***/#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(/*******");
            $display(".,,,,*****//////////////////////////*******(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&##(*******");
            $display(".,,,,,,***********/////////////////********/(#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&(*******");
            $display("=========================================");
            $finish;
        end
    $finish;            
    end


always@(posedge sys_clk)
    begin
        if(counter == 400) // change
            $finish;
        else
            counter = counter + 1;
    end

endmodule