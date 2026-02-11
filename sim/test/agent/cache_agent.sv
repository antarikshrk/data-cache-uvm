//Agent: Layout that contains Driver and Monitor (Both Proxy and Interface)

class cache_agent extends uvm_component;
    //UVM Factory Macro Registration
    `uvm_component_utils(cache_agent)

    //Configuration Objects
    cache_agent_config m_cache_agent_cfg;

    //Component Members
    uvm_analysis_port #(cache_seq_item) ap; //Broadcast to the Scoreboard
    cache_monitor m_cache_mon;
    cache_driver m_cache_drv;
    cache_sequencer m_cache_seqr;
endclass

//Call the Constructor
function cache_agent::new(string name = "cache_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Inside the Constructor of Cache Agent", UVM_LOW);
endfunction

function void cache_agent::build_phase(uvm_phase phase);
    //Only build the agent once it has been configured
    if (!uvm_config_db #(cache_agent_config)::get(this, "", "cache_agent_config", m_cache_agent_cfg)) //Get Configuration Data
        `uvm_fatal("Configuration error, can't get agent config. Have you set it?")
    super.build_phase(phase);

    m_cache_mon = cache_monitor::type_id::create("m_cache_mon", this); //Create a Monitor Object

    //Only create driver and sequencer if the Agent is ACTIVE
    if (m_cache_agent_cfg.active == UVM_ACTIVE) begin
        m_cache_drv = cache_driver::type_id::create("m_cache_drv", this);
        m_cache_seqr = cache_sequencer::type_id::create("m_cache_seqr", this);
    end
endfunction

//Connect Phase: Connect from bottom-up
function void cache_agent::connect_phase(uvm_phase phase);
    ap = m_cache_mon.ap; //Define the Monitor analysis port
    //Only connect the driver and sequencer if ACTIVE
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    if (m_cache_agent_cfg.active == UVM_ACTIVE) begin
        m_cache_drv.seq_item_port.connect(m_cache_seqr.seq_item_export);
    end
endfunction