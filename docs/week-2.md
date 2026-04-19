# Week 2 – Combinational Logic

## Lecture

- N-bit adder + testbench
- Mux
- ALU
- Encoder
- Decoder
- Verilog functions
- LUT

## Assignment

- Create module to apply quantization and ReLU: `y = relu(quant(x))`
  - Quantization: `q = y/(2^f)`, where `f` is a constant
  - ReLU `z = (y > 0) ? y : 0`
- For each combinational element in `[mux, encoder, decoder, relu]`
  - Consider input of 3 bits
  - Decompose into sum of products
  - Decompose into product of sums 