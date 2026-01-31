//Test: Base of the Testbench

class cache_test extends uvm_test;
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_test) 

    //environment class
    cache_env m_env; //components include scoreboard, coverage collector, monitor, and driver

    //Sequence Objects
    rst_sequence rst_seq;
    /*Adding Later once Built:
     test_sequence1 test_seq1;
     test_sequence2 test_seq2;
     test_sequence3 test_seq3;
     test_sequence4 test_seq4;
     test_sequence5 test_seq5;*/


    //Configuration objects
    cache_env_config m_env_cfg; //Top-level config
    cache_agent_config m_cache_cfg; //Cache agent config
endclass: cache_test

//Call the constructor
function cache_test::new(string name = "cache_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Inside constructor of Test Class", UVM_LOW); //Important Info: Set inside Test Class
endfunction

//Build Phase: Build the env, create the env configuration
//The goal is to build and create your classes and sub-configurations
function void cache_test::build_phase(uvm_phase phase);
    super.build_phase(phase); //Build the Phase (Must always include)
    m_env_cfg = cache_env_config::type_id::create("m_env_cfg"); //Create the top-level environment config object
    m_cache_cfg = cache_agent_config::type_id::create("m_cache_cfg"); //Create the cache agent config object
    
    //Apply the "settings"
    m_cache_cfg.active = UVM_ACTIVE; //Agent is Active
    m_env_cfg.m_cache_agent_cfg = m_cache_cfg; //Set the Agent within the environment to cache agent
    m_env_cfg.has_coverage_collector = 1; //Has functional coverage (Coverage Collector)
    m_env_cfg.has_cache_scoreboard = 1; //Has Scoreboard

    //Define the BFM Interface (Driver & Monitor) to connect to DUT
    if (!uvm_config_db #(virtual cache_monitor_bfm)::get(this, "", "cache_mon_bfm", m_cache_cfg.mon_bfm))
        `uvm_fatal("NO_VIF", "Cache Monitor BFM Interface not found")
    
    if (!uvm_config_db #(virtual cache_driver_bfm)::get(this, "", "cache_drv_bfm", m_cache_cfg.drv_bfm))
        `uvm_fatal("NO_VIF", "Cache Driver BFM Interface not found")

    //Configure and create the environment
    uvm_config_db #(cache_env_config)::set(this, "*", "cache_env_config", m_env_cfg); //Anyone can access cache env config (Agents, Scoreboard, Coverage collector)    
    m_env = cache_env::type_id::create("m_env", this);
endfunction

//Run Phase: Create the Sequence Objects
task cache_test::run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this); //Start a "counter" for Phase to begin
        rst_seq = rst_sequence::type_id::create("rst_seq");
        rst_seq.start(m_env.m_agent.m_sequencer);
        #10ns;
        //Adding additional sequences later
    phase.drop_objection(this); //Reset the "counter" for Phase to end 

endtask