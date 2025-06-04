This is a SystemVerilog environment for performing functional verification on an HDL-defined calculator. 
The calculator is a black box (using PRAGMA command) and so the environment is the only interface.

Calculator is a four port in, four port out device. Each input port has command, data, and tag lines
while each output has response, data, and tag lines. The top-level circuit is clocked with
asynchronous reset.

This environment is an iteration on a previous design (for the halfway point in the course),
improving on the functionality and adding standard testing modules like scoreboards and monitors.
