//Cache Sequence Item - Generate the Objects for the Sequencer to pass to Driver

class cache_seq_item extends uvm_sequence_item;
    //UVM Factory Registration Macro
    `uvm_object_utils(cache_seq_item);

    //Data Members
    rand bit rst;
    rand logic [31:0] address;
    rand bit lsu_operator;
    rand bit mem_enable;
    rand logic [31:0] write_data;

    logic stall;
    logic [31:0] read_data;

    //Define the Constraints
    constraint wd_constr {write_data inside {[32'h0000_0001, 32'hFFFF_FFFF]};}
    
    //Call the Constructor: Just use new because it's defined
    function new(string name = "cache_seq_item");
        super.new(name);
    endfunction

endclass

