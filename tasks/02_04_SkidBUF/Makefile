all: AXI-stream, skidbuff

AXI-stream:
	iverilog -o ./simulation/files/AXI-stream_dsn -I ./code ./testbenches/AXI-stream_tb.v ./code/AXI-stream.v
	vvp ./simulation/files/AXI-stream_dsn
	mv ./AXI-strem_simulation.vcd ./simulation/files

skidbuff:
	iverilog -o ./simulation/files/skidbuff_dsn -I ./code ./testbenches/skidbuff_tb.v ./code/skidbuff.v
	vvp ./simulation/files/skidbuff_dsn
	mv ./skidbuff_simulation.vcd ./simulation/files

clean:
	rm -rf ./simulation/files/*
