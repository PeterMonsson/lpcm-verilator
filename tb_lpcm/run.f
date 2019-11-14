-Wall -Wno-PINCONNECTEMPTY -Wno-SYNCASYNCNET -Wno-UNUSED --assert --trace -Os -cc
-F lpcm/files.f
top.sv
../dut.v
-F scoreboard/files.f
--exe sim_main.cpp      
--top-module top
