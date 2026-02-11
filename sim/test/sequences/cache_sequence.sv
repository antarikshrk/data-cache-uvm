//Sequence: Includes base sequence, reset sequence, etc...

//Build the Base Sequence
class base_sequence extends uvm_sequence #(cache_seq_item);
    //UVM Factory Macro Registration
    `uvm_object_utils(base_sequence);

    //Call the Constructor
    function base_sequence::new(string name = "base_sequence");
        build.new(name);
    endfunction
endclass


//