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

   // These tasks are used to check if a given test has passed and
   // confirm that all tests passed.
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
   singlecycle uut (
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

      // ***********************************************************
      // This while loop will continue cycling the processor until the
      // PC reaches the final instruction in the first test.  If the
      // program forms an infinite loop, never reaching the end, the
      // watchdog timer will kick in and kill simulation after 64K
      // cycles.
      // ***********************************************************

      while (currentPC < 64'h30)
        begin
	   @(posedge CLK);
	   @(negedge CLK);
           $display("CurrentPC:%h Instruction:%h MemtoRegOut:%h", currentPC, uut.instruction, MemtoRegOut);
        end
      passTest(MemtoRegOut, 64'hF, "Results of Program 1", passed);

      // ***********************************************************
      // Add your new tests here
      // ***********************************************************
      
      // MOVZ Test: Test the MOVZ instruction
      $display("\n=== Starting MOVZ Test ===");
      
      // Run until we complete the LDUR at 0x48, then one more to reach 0x4C
      while (currentPC < 64'h4C)
        begin
	   @(posedge CLK);
	   @(negedge CLK);
           $display("CurrentPC:%h Instruction:%h X9:%h X10:%h MemtoRegOut:%h", 
                    currentPC, uut.instruction, uut.rf.rf[9], uut.rf.rf[10], MemtoRegOut);
        end
      
      // Execute one more cycle to see the branch instruction
      @(posedge CLK);
      @(negedge CLK);
      $display("CurrentPC:%h Instruction:%h X9:%h X10:%h MemtoRegOut:%h", 
               currentPC, uut.instruction, uut.rf.rf[9], uut.rf.rf[10], MemtoRegOut);
      
      $display("\n=== MOVZ Test Results ===");
      // Check that X9 has the correct value after MOVZ instructions
      // Final MOVZ puts 0x1234 in bits [63:48], all else zeros
      passTest(uut.rf.rf[9], 64'h1234000000000000, "MOVZ X9 Construction", passed);
      
      // Check that X10 has the correct value after load from memory
      passTest(uut.rf.rf[10], 64'h1234000000000000, "MOVZ Memory Store/Load", passed);

      // Done
      allPassed(passed, 3);   // 3 tests total
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

   // Kill the simulation if the watchdog hits 64K cycles
   always @*
     if (watchdog == 16'hFFFF)
       begin
          $display("Watchdog Timer Expired.");
          $finish;
       end


endmodule