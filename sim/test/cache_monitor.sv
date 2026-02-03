//Cache Monitor - Gets inputs from the DUT and broadcasts them to scoreboard via analysis port
class cache_monitor extends uvm_monitor #(cache_seq_item);
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_monitor);

    //Instantiate the Virtual Interface and Sequence item
    virtual cache_if vif;
    cache_seq_item seq_item;

    //Define the UVM Analysis port for broadcast
    uvm_analysis_port #(seq_item) monitor_port;

    //Call the Constructor
    function cache_monitor::new(string name = "cache_monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside the Constructor of Cache Monitor", UVM_LOW);
    endfunction

    function cache_monitor::build_phase(uvm_phase phase);
        //Only build if the Virtual Interface has been defined
        (!uvm_config_db #(virtual vif)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Configuration error, failed to get the Virtual Interface. Did you build it?");
        super.build_phase(phase); //Build the Phase
        //Instantiate the monitor port
        monitor_port = new("monitor_port", this);
    endfunction

    function cache_monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task cache_monitor::run_phase(uvm_phase phase);
        super.run_phase(phase);
        //The purpose is to connect the item I/O to the virtual interface
        forever begin
            seq_item = cache_seq_item::type_id::create("seq_item", this); //Create a sequence item to pass to driver

            //Set the Item sent out equal to the vif interface
            @(posedge vif.clk);
                item.rst = vif.rst;
                item.address = vif.address;
                item.lsu_operator = vif.lsu_operator;
                item.mem_enable = vif.mem_enable;
                item.write_data = vif.write_data;

            @(posedge vif.clk); //Wait a clock cycle
                item.stall = vif.stall;
                item.read_data = vif.read_data;
            
            monitor_port.write(seq_item); //Write item to the monitor to be broadcasted
        end
    endtask


endclass