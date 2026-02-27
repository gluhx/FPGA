all: AXI-master, skidbuff

AXI-master:
	iverilog -o ./simulation/files/AXI_master_dsn -I ./code ./testbenches/AXI_master_tb.v ./code/AXI_master.v
	vvp ./simulation/files/AXI_master_dsn
	mv ./AXI_master_simulation.vcd ./simulation/files

skidbuff:
	iverilog -o ./simulation/files/skidbuff_dsn -I ./code ./testbenches/skidbuff_tb.v ./code/skidbuff.v
	vvp ./simulation/files/skidbuff_dsn
	mv ./skidbuff_simulation.vcd ./simulation/files

clean:
	rm -rf ./simulation/files/*
