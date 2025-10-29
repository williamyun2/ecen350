`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module SingleCycleProcTest_v;

   initial
     begin
        $dumpfile("singlecycle.vcd");
        $dumpvars;
     end

   task passTest;
      input [63:0] actualOut, expectedOut;
      input [`STRLEN*8:0] testType;
      inout [7:0] 	  passed;

      if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
      else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
   endtask

   task allPassed;
      input [7:0] passed;
      input [7:0] numTests;

      if(passed == numTests) $display ("All tests passed");
      else $display("Some tests failed: %d of %d passed", passed, numTests);
   endtask

   // Inputs
   reg 		  CLK;
   reg		  Reset;
   reg [63:0] 	  startPC;
   reg [7:0] 	  passed;
   reg [15:0] 	  watchdog;

   // Outputs
   wire [63:0] 	  MemtoRegOut;
   wire [63:0] 	  currentPC;

   // Instantiate the Unit Under Test (UUT)
   SingleCycleProc uut (
		    .CLK(CLK),
		    .reset(Reset),
		    .startpc(startPC),
		    .currentpc(currentPC),
		    .MemtoRegOut(MemtoRegOut)
		    );

   initial begin
      // Initialize Inputs
      Reset = 0;
      startPC = 0;
      passed = 0;

      // Initialize Watchdog timer
      watchdog = 0;

      // Wait for global reset
      #(1 * `ClockPeriod);

      // Program 1
      #1
        Reset = 1; startPC = 0;
      @(posedge CLK);
      @(negedge CLK);
      @(posedge CLK);
      Reset = 0;

      $display("PC     Rd Rn Rm  X9               X10              X11              X12              X13              RW BusW             ALU              Inst");
      while (currentPC < 64'h30)
        begin
	   @(posedge CLK);
	   @(negedge CLK);
           $display("%h %d  %d  %d   %h %h %h %h %h %b  %h %h %h", 
                    currentPC,
                    uut.rd,
                    uut.rn,
                    uut.rm,
                    uut.rf.rf[9], 
                    uut.rf.rf[10], 
                    uut.rf.rf[11], 
                    uut.rf.rf[12], 
                    uut.rf.rf[13], 
                    uut.RegWrite,
                    uut.MemtoRegOut,
                    uut.aluout,
                    uut.instruction);
        end
      passTest(MemtoRegOut, 64'hF, "Results of Program 1", passed);

      allPassed(passed, 1);
      $finish;
   end

   // Initialize the clock to be 0
   initial begin
      CLK = 0;
   end

   // The following is correct if clock starts at LOW level at StartTime //
   always begin
      #`HalfClockPeriod CLK = ~CLK;
      #`HalfClockPeriod CLK = ~CLK;
      watchdog = watchdog +1;
   end

   // Kill the simulation if the watchdog hits 32 cycles to prevent excessive output
   always @*
     if (watchdog == 16'h20)
       begin
          $display("Watchdog Timer Expired - stopping at 32 cycles");
          $finish;
       end

endmodule