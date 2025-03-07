transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {c:/users/user/fpga soft/quartusii_13.0/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {c:/users/user/fpga soft/quartusii_13.0/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {c:/users/user/fpga soft/quartusii_13.0/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {c:/users/user/fpga soft/quartusii_13.0/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {c:/users/user/fpga soft/quartusii_13.0/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {c:/users/user/fpga soft/quartusii_13.0/quartus/eda/sim_lib/cycloneive_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/bus {C:/Users/user/side project/RISV-V CPU/rtl/bus/bus.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/mux3.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/pcIm_control.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/branch_control.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/controlMUX.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/hazard_detection.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/forwardingMUX.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/forwarding_unit.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/MEM_WB.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/EX_MEM.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/mux.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/SignExtend.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/ID_EX.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/Rigister.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/IF_ID.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/cpu_define.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/top {C:/Users/user/side project/RISV-V CPU/rtl/top/RISC_V_SOC_TOP.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/perips {C:/Users/user/side project/RISV-V CPU/rtl/perips/uart.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/perips {C:/Users/user/side project/RISV-V CPU/rtl/perips/gpio.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/RISCV_CPU.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/MALU.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/DALU.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/data_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/ALU.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/ALU_control.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/control.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/pc.v}
vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/rtl/cpu {C:/Users/user/side project/RISV-V CPU/rtl/cpu/instruction_memory.v}

vlog -vlog01compat -work work +incdir+C:/Users/user/side\ project/RISV-V\ CPU/quartus_prj/../sim {C:/Users/user/side project/RISV-V CPU/quartus_prj/../sim/tb_TOP_RISCV_CPU .v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_TOP_RISCV_CPU

add wave *
view structure
view signals
run -all
