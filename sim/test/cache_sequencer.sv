//Cache Sequencer: Connects to the Driver to pass sequence items
class cache_sequencer extends uvm_sequencer#(cache_seq_item);
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_sequencer);
endclass

//Call the Constructor
function cache_sequencer::new(name="cache_sequencer", uvm_component parent = null);
    super.new(name, parent);
endfunction


