This is a SystemVerilog environment for performing functional verification on an HDL-defined calculator. 
The DUT is defined as a black box (using PRAGMA command) and so the environment is the only feasible 
interface for interacting with it.

The calculator is a four-port in, four-port out device. Each input port has command, data, and tag lines
while each output has response, data, and tag lines. The top-level circuit is clocked and has an
asynchronous reset.

This environment is an iteration on a previous design (created for the halfway point in the course),
improving on its functionality and adding industry-standard testing modules like scoreboards and monitors.
