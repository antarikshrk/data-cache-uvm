//Environment: Layout that contains Cache Agent, Scoreboard, Coverage Collector

class cache_env extends uvm_env;
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_env)

    //Configuration Objects
    cache_env_config m_env_cfg;
    cache_agent m_cache_agent;
    cache_scoreboard m_scoreboard;
    cache_ccollector m_ccollector;
endclass: cache_env

//Call the Constructor
function cache_env::new(string name = "cache_env", uvm_component parent);
    super.new(name, parent); //Call within constructor to properly initialize
    `uvm_info(get_type_name(), "Inside the Environment constructor", UVM_LOW);
endfunction


function void cache_env::build_phase(uvm_phase phase);
    //Only build if the Environment has been configured
    if (!uvm_config_db #(cache_env_config)::get(this, "", "cache_env_config", m_env_cfg)) //GET THE CONFIG DATA
        `uvm_fatal("Configuration error, can't get environment config. Have you set it?")
    super.build_phase(phase); //Build the Phase

    //Pass the Agent Config to the Agent & Insert code to configure and create the agent when cache_env_cfg is defined
    uvm_config_db #(cache_agent_config)::set(this, "m_cache_agent*", "cache_agent_config", m_env_cfg.m_cache_agent_cfg); //Only Cache agent can access cache agent config    
    m_cache_agent = cache_agent::type_id::create("m_cache_agent", this); //Create the Configuration Object

    //Only generate objects if the Environment has it configured
    if (m_env_cfg.has_cache_scoreboard) begin
        m_scoreboard = cache_scoreboard::type_id::create("m_scoreboard", this); //Create a Scoreboard if configured
    end
    if (m_env_cfg.has_coverage_collector) begin
        m_ccollector = cache_ccollector::type_id::create("m_ccollector", this); //Create a Coverage Collector if configured
    end
endfunction

//Connect Phase: Connecting everything from bottom-top
function void cache_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase); //Call this to build the phase
    //Add monitor connections to scoreboard and coverage collector when defined!
endfunction

task cache_env::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask



