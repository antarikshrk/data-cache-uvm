//Cache Driver - Both the Proxy and BFM Interface
class cache_driver extends uvm_driver #(cache_seq_item);
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_driver);

    //Instantiate BFM
    virtual cache_driver_bfm drv_bfm;

    //Instantiate Virtual Interface
    virtual cache_if vif;
    cache_seq_item seq_item;

    //Call the Constructor
    function cache_driver::new(string name = "cache_driver", uvm_component parent);
        super.new(name, parent)
    endfunction

    function cache_driver::build_phase(uvm_phase phase);
        //Only build the driver if the Virtual Interface has been configured
        if (!uvm_config_db #(virtual vif):: get(this, "", "vif", vif)) 
            `uvm_fatal(get_type_name(), "Configuration error, can't get virtual interface. Have you set it?");
        super.build_phase(phase);
    endfunction

    function cache_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task cache_driver::run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item = cache_seq_item::type_id::create("seq_item", this); //Create a sequence item to pass to driver
            seq_item_port.get(seq_item); //Get from the Sequencer
            drive(seq_item); //Drive is a task that connects the Virtual Interface to the Object
            seq_item_port.item_done(); //Mark end of Transaction
        end
    endtask

    task drive(cache_seq_item item);
        @(posedge vif.clk); 
        //Set the Virtual Inteface equal to the Item ports
        vif.rst = item.rst;
        vif.address = item.address;
        vif.lsu_operator = item.lsu_operator;
        vif.mem_enable = item.mem_enable;
        vif.write_data = item.write_data;
    endtask

endclass