onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB/clk
add wave -noupdate /TB/in
add wave -noupdate /TB/control
add wave -noupdate /TB/out
add wave -noupdate /TB/c
add wave -noupdate /TB/z
add wave -noupdate /TB/v
add wave -noupdate /TB/s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {79349 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {79242 ps} {80094 ps}
