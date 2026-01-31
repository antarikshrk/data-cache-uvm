class cache_agent_config extends uvm_object;
    //UVM Factory Macro Registration
    `uvm_object_utils(cache_agent_config)

    //BFM Virtual Interfaces
    virtual cache_monitor_bfm mon_bfm;
    virtual cache_driver_bfm drv_bfm;

    // Data Members
    uvm_active_passive_enum active = UVM_ACTIVE; //uvm_active_passive_enum tells if active/inactive
endclass


//Call the Constructor
function cache_agent_config::new(string name = "cache_agent_config");
    super.new(name);
endfunction

