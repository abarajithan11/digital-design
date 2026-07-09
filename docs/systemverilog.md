# SystemVerilog Basics

SystemVerilog describes both hardware (digital circuits) and testbenches (software code to test them). 
Some constructs synthesize into hardware; others exist only for simulation. 

:::{admonition} Keywords & Features of SystemVerilog Avoided in this Course

`reg`, `wire`, `assign`, `always`, packed arrays

SystemVerilog is a strict superset of old Verilog, which dates to 1984. 
Therefore is one of the most complex languages ever, with a lot of historical baggage and countless footguns, that have been since superseded by newer features that allow us to write clean code. 
To avoid wasting our limited time debating those, we will avoid the above. 
However, this page explains various details for the sake of completeness.
:::

### Signals and Vectors

A **vector** is an ordered group of bits treated as one value, such as `logic [7:0]`, an 8-bit vector numbered from 7 down to 0. 
Most built-in integral types are essentially convenient names for fixed-width vectors:

| Type | Vector equivalent | States |
|---|---|---|
| `byte` | `bit signed [7:0]` | 2-state |
| `shortint` | `bit signed [15:0]` | 2-state |
| `int` | `bit signed [31:0]` | 2-state |
| `longint` | `bit signed [63:0]` | 2-state |
| `integer` | `logic signed [31:0]` | 4-state |
| `time` | `logic [63:0]` | 4-state |

Explicit packed vectors are usually clearer for RTL because their hardware width is visible in the declaration.

### Literals, Widths, and Casts

An integer literal can specify its width and radix:

```systemverilog
8'b1010_0011  // 8-bit binary
12'hA5F       // 12-bit hexadecimal
6'd42         // 6-bit decimal
4'o7          // 4-bit octal
```

The general form is `width'radix value`, where the radix is `b`, `o`, `d`, or `h`. Add `s` for a signed literal: `8'shFE`. 
Four-state literals may contain `x` (unknown) and `z` (high impedance). 
The literals `'0`, `'1`, `'x`, and `'z` fill the destination width:

```systemverilog
mask = '1;  // all 32 bits are 1
```

Widths and signedness affect arithmetic, comparisons, and extension. 
Prefer sized literals and make conversions explicit:

```systemverilog
logic signed [7:0] a;
logic signed [8:0] sum;

sum   = 9'(a) + 9'sd1;  // size cast
count = $clog2(N)'(N);  // expression sized to the counter width
value = $signed(a) + $signed(sum);  // interpret the bit pattern as signed
```

`$bits(value)` returns a type or expression's width. 
A cast changes how an expression is interpreted; it does not add hardware by itself.

### Concatenation, Replication, and Slices

```systemverilog
word     = {upper_byte, lower_byte}; // concatenate
extended = {{8{value[7]}}, value};   // replicate the sign bit
```

A fixed slice uses `[msb:lsb]`. An indexed part-select chooses a fixed number of
bits from a variable starting point:

```systemverilog
byte0 = word[7:0];
byteN = word[start +: 8];  // start, start+1, ..., start+7
byteN = word[start -: 8];  // start, start-1, ..., start-7
```

### Logical, Bitwise, and Reduction Operators

Logical operators treat each operand as true or false and produce one bit. 
If a vector is all zeros, it is false, else it is true.
Bitwise operators act independently on every bit. 
Reduction operators combine all bits of one vector into one bit:

```systemverilog
valid = ready && enable; // logical AND, equivalent to: (ready != 0) AND enable != 0)
masked = data & mask;    // bitwise AND, equivalent to: for (i=0;i<N;i++) masked[i] = data[i] AND mask[i]
all_set = &data;         // reduction AND: 1 if every bit is 1
any_set = |data;         // reduction OR: 1 if any bit is 1
parity  = ^data;         // reduction XOR
```

For OR and NOT, the logical forms are `||` and `!`, while the bitwise forms are `|` and `~`. 

## Datatypes

Old Verilog mainly used `wire` and `reg`, both four-state types:

- A `wire` is driven continuously, for example by `assign` or a module output.
- A signal assigned inside an `always` block must be declared `reg`.

Despite its name, `reg` does **not** mean a hardware register. 
The statements in the `always` block determine the hardware. 
This old Verilog describes a combinational multiplexer, but `y` must still be a `reg`:

```systemverilog
reg y; // named reg, but becomes combinational
always @(*) begin
  if (sel) y = b;
  else     y = a;
end
```

SystemVerilog introduced `logic`, a four-state type (`0`, `1`, `x`, `z`) that works for most single-driver RTL signals. 
Use `logic` by default.
Use an explicit net type such as `wire` for continuous or multiple drivers. 
`tri` behaves like `wire`, but emphasizes that tri-state or multiple drivers are expected.

### Four-State Logic

`logic` can represent `x` when a value is unknown and `z` when a net is not driven. 
These values help simulation expose missing resets, conflicting drivers, and incomplete assignments.

- `==` and `!=` can produce `x` when an operand contains `x` or `z`.
- `===` and `!==` compare all four states and always produce `0` or `1`.

Use `==` for normal RTL comparisons. 
Use `===` mainly in testbenches when checking explicitly for `x` or `z`; careless use can hide an unknown-value bug.

### Two-State Logic

Often we use `bit` in testbenches, in the place of `logic`.
It represents two-state logic, either `0` or `1`.

SystemVerilog silently creates a one-bit wire for some undeclared names. 
Prevent misspellings from becoming implicit wires by placing this before the modules in a source file:

```systemverilog
`default_nettype none
```

## Packed and Unpacked Arrays

Dimensions **before** the name are packed; dimensions **after** the name are
unpacked:

```systemverilog
logic [7:0] byte_value;       // one packed 8-bit value
logic [3:0][7:0] word;        // one packed 32-bit value: four bytes
logic [7:0] memory [0:255];   // 256 unpacked elements, each 8 bits
```

A packed array is one contiguous integral value so it supports arithmetic, bitwise operations, and slicing. 
An unpacked array is a collection of separate elements, useful for memories and lists. 
A packed array is easier to deal with when assigning to flat arrays.
An unpacked array is easier to read in simulation waveforms.
For `memory`, `memory[3]` selects an 8-bit element and `memory[3][0]` selects one bit within it.

## `typedef`, `enum`, and `struct`

`typedef` gives a type a reusable name. 
An `enum` gives meaningful names to encoded values, which is especially useful for states and opcodes:

```systemverilog
typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
state_t state, next_state;
```

A `struct` groups related fields:

```systemverilog
typedef struct packed {
  logic       valid;
  logic [7:0] data;
} packet_t;
```

A `packed struct` is one contiguous vector and can pass through a port or be assigned as a whole. 
An unpacked struct is a collection of separate members.

## Modules, Parameters, and Instantiation

A module's ports are its hardware interface. 
`parameter` values let each instance select a configuration; 
`localparam` defines a constant that cannot be overridden during instantiation:

```systemverilog
module counter #(
  parameter  WIDTH = 8,
  localparam MAX   = 2**WIDTH - 1
) (
  input  logic             clk,
  output logic [WIDTH-1:0] count
);
  // ...
endmodule
```

Port directions describe signal flow:

- `input` is read by the module and driven from outside.
- `output` is driven by the module and read outside.
- `inout` permits both directions and should be reserved for genuine bidirectional or tri-state connections.

Override parameters and connect ports by name:

```systemverilog
counter #(.WIDTH(16)) u_counter (
  .clk   (clk),
  .count (count)
);
```

If the signal and port have the same name, `.clk` abbreviates `.clk(clk)`.
`.*` connects all matching names; it is convenient in small examples, but explicit connections are clearer when interfaces become large.

A hierarchical name accesses an object through its instance path:

```systemverilog
assert (dut.state == IDLE);
```

This is useful in testbenches for observing internal state. 
Synthesizable modules should communicate through ports rather than reach into another module's hierarchy.

## Combinational and Sequential Circuits

Use these specialized procedural blocks to state the intended hardware:

- `always_comb` describes combinational logic and creates its sensitivity list automatically. 
  Assign every output on every path to avoid an unintended latch.
- `always_ff @(posedge clk ...)` describes flip-flops. Include reset behavior in the event control and body when needed.
- `always_latch` describes an intentional level-sensitive latch. 
  Most designs avoid latches unless they are required.

Never drive a signal from multiple always blocks / module ports, unless you are doing something advanced, with tri-state logic, and you know what you're doing.

```systemverilog
always_comb begin
  next_count = count;
  if (enable) next_count = count + 1'b1;
end

always_ff @(posedge clk or negedge rstn) begin
  if (!rstn) count <= '0;
  else       count <= next_count;
end
```

Including reset in the event control creates an asynchronous reset: the flip-flops reset without waiting for a clock edge.
This is common for ASIC designs.
A synchronous reset is tested only at the clock edge, preferred for FPGA designs.
Choose the reset style required by the target technology and project convention.

```systemverilog
// Asynchronous active-low reset
always_ff @(posedge clk or negedge rstn)
  if (!rstn) q <= '0;
  else       q <= d;

// Synchronous active-high reset
always_ff @(posedge clk)
  if (rst) q <= '0;
  else     q <= d;
```

Use blocking assignment `=` for combinational logic (`always_comb`) and nonblocking assignment `<=` for clocked sequential logic (`always_ff`). 
A nonblocking assignment updates after the current simulation region, so every flip-flop observes the old values from that clock edge.

### Continuous Assignment and `always_comb`

Both forms below describe combinational hardware:

```systemverilog
assign y = sel ? b : a;  // drives a net continuously

always_comb begin        // procedural logic; useful for multiple statements
  if (sel) y = b;
  else     y = a;
end
```

`assign` can be used for simple expressions and net connections. 
Use `always_comb` when the calculation needs control flow or intermediate values. 
Do not drive the same signal from both.
In this class we will avoid `assign`, and only use `always_comb`.

### Last Assignment Wins

Inside an always block (`always_comb`, `always_ff`), the **last assignment wins**.
This property enables us to describe circuits in a readable way.

```systemverilog
logic [N-1:0]    code;
logic [2**N-1:0] onehot;
logic [W-1:0]    vector [N-1:0];
logic [W+$clog2(N)-1:0] sum;

always_comb begin // This generates a decoder
  onehot       = '0;
  onehot[code] = 1'b1;
end

always_comb begin // This generates a circuit that sums N numbers combinationally
  sum = '0;
  for (int i=0; i<N i++) sum += vector[i];
end
```


### `case`, `unique`, and `priority`

A `case` statement selects among alternatives:

```systemverilog
always_comb begin
  y = '0;                 // default prevents a latch
  unique case (opcode)
    ADD: y = a + b;
    SUB: y = a - b;
    XOR: y = a ^ b;
    default: ;            // retain the default value
  endcase
end
```

`unique case` states that at most one item should match and that every expected value is covered. 
`priority case` states that the first matching item wins and that a match is expected. 
Simulators can warn when these promises are broken, and synthesis may optimize using them. 
Always write safe defaults. 
Do not use these keywords merely to silence incomplete logic.

## Functions and Tasks

A function returns a value and cannot consume simulation time.
It is a good way to package reusable combinational logic:

```systemverilog
function automatic logic [7:0] min_value(
  input logic [7:0] a, b
);
  return (a < b) ? a : b;
endfunction
```

A task may have multiple input/output arguments and may consume time using `#`, `@`, or `wait`, making tasks useful for testbench operations such as sending a
UART packet. 
Time-consuming tasks are not synthesizable.

## Generate Blocks

Generate constructs create hardware during elaboration. 
Their conditions and loop bounds must be constant:

```systemverilog
if (USE_PIPELINE) begin : g_pipe
  pipeline_stage u_stage (.*);
end else begin : g_bypass
  always_comb out = in;
end

for (genvar i = 0; i < WIDTH; i++) begin : g_bit
  bit_cell u_cell (.a(a[i]), .y(y[i]));
end
```

A generate `if` selects hardware from a parameter or constant. 
A generate `for` replicates hardware. 
Name each block to produce readable hierarchical names in the netlist and simulation.
The outer `generate...endgenerate` keywords are optional in SystemVerilog.

Do not confuse a procedural loop with a generate loop:

```systemverilog
always_comb
  for (int i = 0; i < WIDTH; i++)
    parity[i] = a[i] ^ b[i];       // repeated behavior in one process

for (genvar i = 0; i < WIDTH; i++) begin : g_cell
  bit_cell u_cell (.a(a[i]), .y(y[i])); // replicated instances/hierarchy
end
```

Both can synthesize to parallel hardware. 
A procedural loop repeats statements inside a process. 
A generate loop creates separate scopes and instances during elaboration.

## Simulation Time and Events

Set the simulation time unit and precision at the top of the file:

```systemverilog
`timescale 1ns/1ps
```

`#10` waits ten time units, `#1ps` uses an explicit unit, and an event control waits for an event:

```systemverilog
#10;
@(posedge clk);
@(data);          // wait for data to change
```

Delays are normally testbench-only. 
Edge event controls are also used by synthesizable `always_ff` blocks. 
`` `timescale`` is file-scoped, so place it in each source file that uses simulation delays.

## `initial`, `fork`, and `join`

An `initial` block starts at simulation time 0 and runs once.
It is commonly used for testbench stimulus. 
A testbench often has multiple initial blocks. 
They all start at the same time and run in parallel from the simulation perspective.
Use blocking assignment `=` inside `initial` so each statement takes effect in sequence:

```systemverilog
initial forever #5 clk = ~clk; // Toggle clock every 5 units indefinitely.

initial begin
  rstn = 0;
  repeat (2) @(posedge clk);
  rstn = 1;
end
```

Do not depend on `initial` for portable ASIC RTL.
FPGA initialization support is tool and device-specific.

Statements inside `begin...end` run sequentially. 
Statements directly inside `fork...join` run concurrently:

```systemverilog
fork
  send_request();
  check_response();
join
```

- `join` waits for every child process.
- `join_any` waits until any one child finishes; the others keep running.
- `join_none` returns immediately; all children keep running.

## Assertions

An immediate assertion checks an expression when execution reaches it:

```systemverilog
assert (actual == expected)
  else $error("actual=%h expected=%h", actual, expected);
```

Assertions make failures visible where they occur. 
Use `$fatal` to crash when simulation cannot continue meaningfully and `$error` when later checks are still useful.
Concurrent assertions can check behavior across clock cycles, but are beyond this basic introduction.

## System Tasks

System tasks and functions begin with `$` and are primarily simulation utilities:

```systemverilog
$display("data=%h time=%0t", data, $time); // print now with newline
$write("data=%h ", data);                  // print without newline
$strobe("q=%h", q);                        // print at end of this time step
$monitor("a=%b y=%b", a, y);               // print when an argument changes
```

Useful control and reporting tasks include `$finish`, `$stop`, `$fatal`, `$error`, `$warning`, and `$info`. 
Common format specifiers are `%b`, `%d`, `%h`, `%s`, and `%0t`. 
These tasks do not describe hardware and are not synthesizable.

## Other Testbench Features

Random stimulus explores cases that directed tests may miss:

```systemverilog
data = 8'($urandom);
delay = $urandom_range(1, 20);
assert (std::randomize(data) with { data inside {[1:100]}; });
```

Queue is a dynamic array that grows and shrinks during simulation:

```systemverilog
logic [7:0] expected [$];
expected.push_back(data);
data = expected.pop_front();
```

Queues, dynamic arrays, classes, constrained randomization, and file I/O are testbench features and are not synthesizable. 
Common file operations are `$fopen`, `$fscanf`, `$fwrite`, and `$fclose`.

```systemverilog
int f, y, status;  // f is a file handle

initial begin
  f = $fopen("out.txt", "w");
  if (f == 0) $error("Could not open file");
  $fwrite(f, "Hello, SystemVerilog!\n y = %d", y); // Writing to a file
  $fclose(f);
end

initial begin
  f = $fopen("in.txt", "r");
  if (f == 0) $error("Could not open file");
  status = $fscanf(f, "%d", y);  // Reading from a file into a variable
  $display("y = %0d", y);
  $fclose(f);
end
```

## Main Sources

- [IEEE Std 1800-2023: SystemVerilog Language Reference Manual](https://standards.ieee.org/ieee/1800/7743/)
- Stuart Sutherland, *RTL Modeling with SystemVerilog for Simulation and
  Synthesis*
- Stuart Sutherland, Simon Davidmann, and Peter Flake, *SystemVerilog for
  Design*, 2nd ed.
- Stuart Sutherland, Don Mills, and Chris Spear, *Synthesizing SystemVerilog:
  Busting the Myth that SystemVerilog is only for Verification*
- Chris Spear, *SystemVerilog for Verification*, 2nd ed.
- [*SystemVerilog for RTL Modeling, Simulation, and Verification: Modules, Controls, and Interfaces*](https://systemverilog.dev)
