onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB/n1
add wave -noupdate /TB/n2
add wave -noupdate /TB/of
add wave -noupdate /TB/uf
add wave -noupdate /TB/nan
add wave -noupdate /TB/inf
add wave -noupdate /TB/result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {111 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {99 ns} {167 ns}
