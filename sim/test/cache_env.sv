//Environment: Layout that contains Cache Agent, Scoreboard, Coverage Collector

class cache_env extends uvm_env;
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_env)

    //Data Members
    bit has_coverage_collector = 1;
    bit has_cache_scoreboard = 1;

    //Configuration Objects
    cache_agent_config m_cache_cfg;
    

endclass: cache_env