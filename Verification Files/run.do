if { [info exists 1] } {
    set v_arg $1
} else {
    set v_arg "detailed"
}

vlib work 
vlog enum_pkg.sv Uart_packet.sv uart_if.sv uart_tx.v uart_tx_te.sv top.sv   
vlog -cover bcefst +covercells uart_tx.v
vsim -voptargs=+acc work.top +verbosity=$v_arg -cover
coverage save -onexit cov.ucdb

add wave -r *
run -all 
coverage exclude -code b -du uart_tx -line 33 -allfalse
coverage report -details -output cov_report.txt



