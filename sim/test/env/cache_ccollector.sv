//Cache Coverage Collector: Tests for Functional Coverage from the DUT

class cache_ccollector extends uvm_subscriber #(cache_seq_item);
    //UVM Factory Macro
    `uvm_component_utils(cache_ccollector)

    //Instantiate the sequence item object
    cache_seq_item seq_item;

    //UVM Analysis Port
    uvm_analysis_imp #(seq_item) ccollector_port;

    //Add the Covergroup
    covergroup cache_signals;
 
        Reset_cov:coverpoint seq_item.rst; 
        Mem_Enable_cov:coverpoint seq_item.mem_enable; 
        
        //Bins: Categories that group values for coverage tracking
        LSU_cov:coverpoint seq_item.lsu_operator
        {
            bins read = {0};
            bins write = {1};
        }; 

        Index_cov:coverpoint seq_item.address[10:3] //Get the Index 
        {
            bins low_index = {[0:85]};
            bins med_index = {[86:171]};
            bins high_index = {[171:255]};
        };

        Write_cov:coverpoint seq_item.write_data //Split the Write Data
        {
            bins low_wr = {[32'h0000_0001:32'h2AAA_AAAA]};
            bins med_wr = {[32'h2AAA_AAAB:32'h7FFF_FFFF]};
            bins high_wr = {[32'h8000_0000:32'hFFFF_FFFE]};
            bins all_zeros = {32'h0000_0000};
            bins all_ones = {32'hFFFF_FFFF};
        };

        Index_x_WriteData_cov:cross Index_cov, Write_cov, LSU_cov.write
        {
            bins low_zeros = binsof(Index_cov.low_index) && binsof(Write_cov.all_zeros);
            bins med_zeros = binsof(Index_cov.med_index) && binsof(Write_cov.all_zeros);
            bins high_zeros = binsof(Index_cov.high_index) && binsof(Write_cov.all_zeros);

            bins low_ones = binsof(Index_cov.low_index) && binsof(Write_cov.all_ones);
            bins med_ones = binsof(Index_cov.med_index) && binsof(Write_cov.all_ones);
            bins high_ones = binsof(Index_cov.high_index) && binsof(Write_cov.all_ones);

            bins low_low = binsof(Index_cov.low_index) && binsof(Write_cov.low_wr);
            bins med_low = binsof(Index_cov.med_index) && binsof(Write_cov.low_wr);
            bins high_low = binsof(Index_cov.high_index) && binsof(Write_cov.low_wr);

            bins low_med = binsof(Index_cov.low_index) && binsof(Write_cov.med_wr);
            bins med_med = binsof(Index_cov.med_index) && binsof(Write_cov.med_wr);
            bins high_med = binsof(Index_cov.high_index) && binsof(Write_cov.med_wr);

            bins low_high = binsof(Index_cov.low_index) && binsof(Write_cov.high_wr);
            bins med_high = binsof(Index_cov.med_index) && binsof(Write_cov.high_wr);
            bins high_high = binsof(Index_cov.high_index) && binsof(Write_cov.high_wr);
        };

    endgroup
    //Call the Constructor
    function cache_ccollector::new(string name = "cache_ccollector", uvm_component parent);
        super.new(name, parent);
    endfunction

    //UVM Build Phase
    function cache_ccollector::build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    //UVM Run Phase
    task cache_ccollector::run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

    //Write Function
    function void write(cache_seq_item seq_item);
        //Add Write Function later        
    endfunction

endclass