import cache_pkg::*;

module cache_tb;
    //Clock and Reset signals to simulate 
    reg clk;
    reg rst;
    reg [31:0] address;
    lsu_ops lsu_operator;
    reg mem_enable;
    reg [DATA_WIDTH-1:0] write_data;

    //Outputs to the pipeline
    wire stall;
    wire [DATA_WIDTH-1:0] read_data;

    
    /*The DUT is connected to the Top Level Testbench in the sense the Testbench 
    sends signals to the DUT and the DUT outputs those signals to the log or 
    waveform generator.*/

    //Instiantiate the DUT
    cache_level_top dut(
        .clk(clk),
        .rst(rst),
        .address(address),
        .lsu_operator(lsu_operator),
        .mem_enable(mem_enable),
        .write_data(write_data),
        .stall(stall),
        .read_data(read_data)
    );

    always #5 clk = ~clk; //Period of 10ns (5ns High and 5ns Low = 10ns total)

    initial begin
        clk = 0; //Clk starts out at 0
        rst = 1; //Set Reset High
        address = 0;
        mem_enable = 0;
        lsu_operator = LW;

        //Display a Monitor to watch the Inputs
        $monitor("Time = %0t, Address = 0x%h, Operator = %s, Read Data = 0x%h, Stall = %b", $time, address, lsu_operator, read_data, stall);

        // ═══════════════════════════════════════════════════════════
        // TEST 1: Reset Behavior
        // ═══════════════════════════════════════════════════════════
        $display("TEST 1: Reset Behavior");
        #20; //Wait 20ns
        rst = 0; //Deassert Reset
        #10; //Wait another 10ns

        assert (stall == 1'd0) //Read will be a null value (Don't Care)
            else $error("TEST 1 Failed: stall expected = 0, stall actual = %0d", stall);
        // ═══════════════════════════════════════════════════════════
        // TEST 2: Disable Memory
        // ═══════════════════════════════════════════════════════════
        $display("TEST 2: Disable Memory");
        #20;
        address = 32'h0000_0008; //Choosing an index of 1
        lsu_operator = LW; //Load Word
        mem_enable = 0; //Disable Memory
        #10;

        assert (stall == 1'd0) 
            else $error("TEST 2 Failed: Stall expected = 1, Stall actual = %0d", stall);
        assert (dut.cache_contrl.current == dut.cache_contrl.IDLE)
            else $error("TEST 2 Failed: State Expected = 1, State Actual = %0s", dut.cache_contrl.current);

        // ═══════════════════════════════════════════════════════════
        // TEST 3: Read Miss
        // ═══════════════════════════════════════════════════════════
        $display("TEST 3: Read Miss");
        #20;
        address = 32'h0000_0008; //Choosing an index of 1
        lsu_operator = LW; //Load Word
        mem_enable = 1; //Enable Memory
        #20;

        //Check the State to see if it's in Miss Repair
        assert (dut.cache_contrl.current == dut.cache_contrl.MISS_REPAIR && stall == 1 && dut.mem_req == 1)
            else $error("TEST 3 Failed: State = %0s, Stall = %0d, Memory Reuqest = %0d", dut.cache_contrl.current, stall, dut.mem_req);
        //#40;
        assert (dut.cache_contrl.current == dut.cache_contrl.ACCESS)
            else $error("Test 3 Failed: Expected State = Access, State = %0s", dut.cache_contrl.current);

        // ═══════════════════════════════════════════════════════════
        // TEST 4: Read Hit
        // ═══════════════════════════════════════════════════════════
        $display("TEST 4: Read Hit");
        #20;
        address = 32'h0000_0008; //Choosing an index of 1
        lsu_operator = LW; //Load Word
        mem_enable = 1; //Enable Memory
        #20;

        //Check the Data Cache
        assert (stall == 0 && read_data == 32'hDEAD_0008)
            else $error("TEST 4 Failed: Stall Expected = 0, Stall = %0d, Read Data Expected = 32'hDEAD_0008, Read Data Actual = %0d", stall, read_data);  
        
        // ═══════════════════════════════════════════════════════════
        // TEST 5: Write Miss
        // ═══════════════════════════════════════════════════════════
        $display("TEST 5: Write Miss");
        #20;
        address = 32'h0000_0010; //Choosing an index of 2
        lsu_operator = SW; //Load Word
        mem_enable = 1; //Enable Memory
        write_data = 32'hDEAD_DEAD;
        #20;

        //Check the Data Cache
        assert (dut.cache_contrl.current == dut.cache_contrl.MISS_REPAIR && stall == 1 && dut.mem_req == 1)
            else $error("TEST 5 Failed: State = %0s, Stall = %0d, Memory Reuqest = %0d", dut.cache_contrl.current, stall, dut.mem_req);
        #40;
        assert (dut.cache_contrl.current == dut.cache_contrl.ACCESS)
            else $error("Test 5 Failed: Expected State = Access, State = %0h", dut.cache_contrl.current);
        

        // ═══════════════════════════════════════════════════════════
        // TEST 6: Write Hit
        // ═══════════════════════════════════════════════════════════
        $display("TEST 6: Write Hit");
        #20;
        address = 32'h0000_0010; //Choosing an index of 2
        lsu_operator = SW; //Load Word
        mem_enable = 1; //Enable Memory
        write_data = 32'hDEAD_DEAD;
        #20;

        //Check the Data Cache
        assert (stall == 0 && dut.cache_contrl.cache_data_io == 32'hDEAD_DEAD && dut.write_data_dram == 32'hDEAD_DEAD)
            else $error("TEST 4 Failed: Stall Expected = 0, Stall = %0d, Cache Data Expected = 32'hDEAD_DEAD, Cache Data Actual = %0d, DRAM Data Expected = 32'hDEAD_DEAD, DRAM Data Actual = %0d", stall, dut.cache_contrl.cache_data_io, dut.write_data_dram);  
        
        // ═══════════════════════════════════════════════════════════
        // TEST 7: Tag Replacement
        // ═══════════════════════════════════════════════════════════

        // ═══════════════════════════════════════════════════════════
        // TEST 8: Write-Through Verification
        // ═══════════════════════════════════════════════════════════
        

        $finish;
    end

    initial begin
        $dumpfile("cache_tb.vcd");
        $dumpvars(0, cache_tb);
    end

    /*
    RUNNING THE TESTBENCH:
      cd sim
      iverilog -g2012 -s cache_tb -o cache_sim ../rtl/cache_pkg.sv ../rtl/data_cache.sv ../rtl/cache_controller.sv ../rtl/dummy_DRAM.sv ../rtl/cache_top_lvl.sv cache_tb.sv
      vvp cache_sim
      gtkwave
    */


endmodule