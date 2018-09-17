if [file exists work] {vdel -lib work -all}
vlib work
vmap -c
vmap work work
vcom -work work  D:/git_repos/uart/cocotb/../source/uart_tx.vhd
vsim -onfinish stop -foreign "cocotb_init libfli.dll" work.uart_tx
add wave -recursive /*
