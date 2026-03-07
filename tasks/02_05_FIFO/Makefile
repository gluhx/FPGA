all: FIFO

FIFO:
	iverilog -o ./simulation/files/FIFO_dsn -I ./code ./testbenches/FIFO_tb.v ./code/FIFO.v ./code/read_agent.v ./code/write_agent.v
	vvp ./simulation/files/FIFO_dsn
	mv ./FIFO_simulation.vcd ./simulation/files

clean:
	rm -rf ./simulation/files/*
