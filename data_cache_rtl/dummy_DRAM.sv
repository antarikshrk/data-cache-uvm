//"dummy" DRAM
module dummy_dram #(parameter data = 11)(
    input wire clk,
    input wire rst,
    input logic [31:0] mem_address, //Memory Address
    input wire lsu_operator, //Either LW or SW
    input logic mem_req, //Request Memory from the DRAM (Also enable DRAM)
    input logic [data - 1:0] write_data_int, //Write Data to the DRAM
    output logic mem_ready, //Memory Request Accepted
    output logic [data-1:0] dram_data_out //Output DRAM Data

);

localparam memory_length = 1024;    //How many Addresses available in the DRAM
logic [data-1:0] dram_data[0:memory_length-1]; //Fill in DRAM lines with Data

//Create the DRAM Data Array
initial begin
    for (int addr = 0; addr < memory_length; addr++){
        dram_data[addr] = 1'd0;
    }
end

assign mem_ready = mem_req ? 1 : 0; //The Memory is Ready if there is a Memory request
//Changing Memory handshaking to be more realistic later

integer i;
always_ff @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < memory_length; i++){
            dram_data[i] <= 1'd0;
        }
    end else begin
        if (mem_ready) begin //Controlled by the Cache Controller
            case(lsu_operator) //Either LW or SW (LW = 1'd0, SW = 1'd1)
                1'd0: dram_data_out <= dram_data[mem_address[9:0]]; //Reading the Data out of the DRAM
                1'd1: dram_data[mem_address[9:0]] <= write_data_int; //Writing the Data into the DRAM
            endcase
        end      
    end
end
endmodule 