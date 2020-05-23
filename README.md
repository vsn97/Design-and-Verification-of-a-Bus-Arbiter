# Design-and-Verification-of-a-Bus-Arbiter
Design and verification of a 4-way round robin bus arbiter

A 4-way round robin memory bus arbiter along with formal verification assertions are designed in System Verilog and model checked using the Enhanced Bounded Model Checker(EBMC) tool. The instructions to run the code are given below:

1. Clone the repo.
2. Redirect to the cloned folder and run the following command in a terminal/command prompt:

In a Linux system : ./ebmc rr_bus_arbiter.sv --top rr_bus_arbiter --reset reset==1 --bound 10 --trace

In a Windows system : ebmc rr_bus_arbiter.sv --top rr_bus_arbiter --reset reset==1 --bound 10 --trace


Note: Every assertion is commented. To run the assertion, uncomment the assertions in the bottom of the '.sv' file.

Code References: http://www.asic-world.com/examples/verilog/arbiter.html
