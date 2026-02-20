module AXI-master(
  input clk,
  input reset,
  output reg data[7:0],
  output reg valid,
  output reg last,
  input ready  
);


