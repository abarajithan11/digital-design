# Week 4 – Practical Circuits

## Lecture 1

- Introduce Assignment 4, to allow students two weeks to try optimizations
  - Demonstration: Neural Network on FPGA processing images from webcam
  - Demonstration: FIR Filter on FPGA on audio
- Trace through waveforms: counter with data loading
- FIR Filter
  - Audio signal, coefficients, processing - basics
  - Naive FIR filter - long combinational path
  - Transposed FIR Filter - shorter path, higher FMAX

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQS_Vj1wYiE4R5rejk78uiATAWcethDAHLuYYF-XUke3trc)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQS_Vj1wYiE4R5rejk78uiATAWcethDAHLuYYF-XUke3trc?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Lecture 2

- Refresher: Setup/hold time
- Activity - draw the waveform of nested counters
- Flow control: ready/valid
- Parallel to Serial Converter
  - State machine
  - Ready/valid, backpressure

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQQCK7wbg_uySYpNPKxr6DMWAU1iKOfSWE05uWOOIb3Ic5Y)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQQCK7wbg_uySYpNPKxr6DMWAU1iKOfSWE05uWOOIb3Ic5Y?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Discussion: FPGA System

- Put UART RX + TX back-to-back on an FPGA
- Write a Python script to send a series of numbers to the FPGA via a serial port, get the numbers back, and display them

## Assignment 4: AXI Stream NN Accelerator System

1. Convert your `dense_relu` layer into an AXI-Stream module
1. Chain multiple dense layers into a dense NN accelerator (AXI stream)
1. Integrate into the UART system, and test with our testbench
1. [Optional] Implement on your FPGA, send MNIST inputs and get outputs
