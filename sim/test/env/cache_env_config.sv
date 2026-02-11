//Environment Configure: Actually define the parameters defined

class cache_env_confg extends uvm_object;
    //UVM Factory Registration Macro
    `uvm_object_utils(cache_env_config)

    //Data Members
    bit has_coverage_collector = 1;
    bit has_cache_scoreboard = 1;

    //Configurations for sub_components(Agents)
    cache_agent_config m_cache_agent_cfg;
endclass

//Call the Constructor
function cache_env_config::new(string name = "cache_env_config");
    super.new(name); //Don't need parent for Object
endfunction

