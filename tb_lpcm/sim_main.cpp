// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2017 by Wilson Snyder.
//======================================================================

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vtop.h"

// If "verilator --trace" is used, include the tracing class
#if VM_TRACE
# include <verilated_vcd_c.h>
#endif

// Current simulation time (64-bit unsigned)
vluint64_t main_time = 0;
// Called by $time in Verilog
double sc_time_stamp() {
    return main_time;  // Note does conversion to real, to match SystemC
}

int main(int argc, char** argv, char** env) {
    // This is a more complicated example, please also see the simpler examples/hello_world_c.

    // Prevent unused variable warnings
    if (0 && argc && argv && env) {}

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs
    Verilated::debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs
    Verilated::randReset(2);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    Verilated::commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v"
    Vtop* top = new Vtop;  // Or use a const unique_ptr, or the VL_UNIQUE_PTR wrapper

#if VM_TRACE
    // If verilator was invoked with --trace argument,
    // and if at run time passed the +trace argument, turn on tracing
    VerilatedVcdC* tfp = NULL;
    const char* flag = Verilated::commandArgsPlusMatch("trace");
    if (flag && 0==strcmp(flag, "+trace")) {
        Verilated::traceEverOn(true);  // Verilator must compute traced signals
        VL_PRINTF("Enabling waves into obj_dir/vlt_dump.vcd...\n");
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);  // Trace 99 levels of hierarchy
	Verilated::mkdir("obj_dir");
        tfp->open("obj_dir/vlt_dump.vcd");  // Open the dump file //TODO: handle errors here
    }
#endif

    // Set some inputs
    top->rst_n = 0;
    top->clk = 0;

    // Simulate until $finish
    while (!Verilated::gotFinish()) {
        main_time++;  // Time passes...

        // Toggle clocks and such
        top->clk = !top->clk;

	top->rst_n = main_time > 10;  // Control reset by time.

        // Evaluate model
        top->eval();

#if VM_TRACE
        // Dump trace data for this cycle
        if (tfp) tfp->dump(main_time);
#endif

        // Read outputs
        VL_PRINTF("[%" VL_PRI64 "d] clk=%x rst_n=%x\n",
                  main_time, top->clk, top->rst_n);
    }

    // Final model cleanup
    top->final();

    // Close trace if opened
#if VM_TRACE
    if (tfp) { tfp->close(); tfp = NULL; }
#endif

    //  Coverage analysis (since test passed)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    VerilatedCov::write("logs/coverage.dat");
#endif

    // Destroy model
    delete top; top = NULL;

    VL_PRINTF("[%" VL_PRI64 "d] Ending\n",
                  main_time);

    // Fin
    exit(0);
}


// Consider moving this funcion into a separate DPI wrapper

#include <cmath>
#include "Vtop__Dpi.h"

double sine (double rTheta) {
  return sin(rTheta);
}
