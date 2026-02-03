//Cache Scoreboard: Verify DUT Functionality (Preditor & Evaluation models)
class cache_scoreboard extends uvm_scoreboard;
    //UVM Factory Registration Macro
    `uvm_component_utils(cache_scoreboard);

    cache_seq_item seq_item; //Gets a sequence item from the monitor

    //Define the UVM Analysis port to receieve broadcast from Monitor
    uvm_analysis_imp #(seq_item) scoreboard_port;

    //Call the Constructor
    function cache_scoreboard::new(string name="cache_scoreboard", this);
        super.new(name, this);
    endfunction

    function cache_scoreboard::build_phase(uvm_phase phase);
        super.build_phase(phase);
        scoreboard_port = new("scoreboard_port", this); //Build the Scoreboard port for Agent functionality
    endfunction

    task cache_scoreboard::run_phase(uvm_phase phase);
        super.run_phase(phase);
        //FIGURING OUT FUNCTIONS TO WRITE LATER
    endtask

endclass