//Cache Controller
import cache_pkg::*;

module cache_controller #(
    parameter index_count,
    parameter data, 
    parameter tag
)(
    //Pipeline Inputs
    input wire clk,
    input wire rst,
    input wire [31:0] address, //Address Input
    input lsu_ops lsu_operator, //Either LW or SW
    input wire mem_enable, //Enable Memory (Cache + DRAM) 
    input wire [tag+data:0] write_data, //Write Data 

    //DRAM inputs
    input logic mem_ready, //Memory is Ready from the DRAM
    input logic [data-1:0] dram_data_input, //Memory from the DRAM

    //Cache Inputs
    input logic [tag - 1:0] cache_tag, //Input from the Cache Tag
    input logic cache_valid, //Valid signal from the Cache
    input logic [data-1:0] cache_data_io, //Data from the Cache

    //Cache Outputs
    output logic cache_enable, //Enable the Cache
    output logic [tag + data:0] write_index, //Write Data to the Cache {valid, tag, data}
    output logic [$clog2(index_count) - 1:0] index_sel, //Index Select

    //DRAM Outputs
    output logic mem_req, //Request Data from the DRAM
    output logic [data-1:0] write_data_int, //Output data to the dummy DRAM


    //Pipeline Outputs
    output wire stall, //Stall the Pipeline
    output wire [data-1:0] read_data //Read the Data
);

//Instantiate the Data Cache
data_cache #(
    .index_count(index_count),
    .data(data),
    .tag(tag)
) dcache(
    .clk(clk),
    .rst(rst),

    .cache_enable(cache_enable),
    .write_index(write_index),
    .index_sel(index_sel),
    .rd_wr_sel(lsu_operator),
    .read_data(read_data),
    .cache_tag(cache_tag),
    .cache_valid(cache_valid),
    .write_data_int(write_data_int),
    .cache_data_io(cache_data_io)
);

logic hit_miss; //Hit = 1, Miss = 0
logic compare;
logic [31:0] mem_address;
logic stall_reg;
logic [tag-1:0] input_tag; //Derived from the Address
logic mem_req_reg;
logic [7:0] index;

assign input_tag = address[tag + data - 1:data];
assign stall = stall_reg;
assign mem_address = address;
//assign dram_data_input_reg = dram_data_input;
assign mem_req = mem_req_reg;
assign index = address[10:3];
assign index_sel = index;
assign compare = (input_tag == cache_tag) ? 1 : 0; //Compare the Input and Cache Tag
assign hit_miss = compare && cache_valid;

typedef enum logic [1:0]{
    IDLE = 2'b00, //Go here when RESET
    ACCESS = 2'b01, //When Memory is enabled go here
    MISS_REPAIR = 2'b10 //hit_miss = 0
} state_t;
state_t current, next;

//State Transition
always_ff @(posedge clk) begin 
    if (rst) begin
        current <= IDLE;
    end else begin
        current <= next;
    end
end

//Begin Sequential Logic
always_ff @(posedge clk) begin
    if (rst) begin
        stall_reg <= 1'd0;  
        mem_req_reg <= 1'd0;
    end else begin
        case(current)
            IDLE: begin
                stall_reg <= 1'd0;
                mem_req_reg <= 1'd0;
            end
            ACCESS: begin 
                stall_reg <= 1'd0;
                mem_req_reg <= 1'd0;
                cache_enable <= 1'b1; //Enable the Cache
                if (hit_miss == 1'b1) begin //If it's a hit
                    if (lsu_operator == SW) begin //If it's a write ONLY
                        write_data_int <= write_data;
                        mem_req_reg <= 1'b1; //Request Memory
                        // if (mem_ready == 1'b1) begin //If handshaking enabled
                        //     write_data_int <= cache_data_io; //Send the Data to the DRAM
                        // end
                        write_data_int <= cache_data_io; //Send the Data to the DRAM
                    end
                end 
            end
            MISS_REPAIR: begin 
                mem_req_reg <= 1'b1;
                stall_reg <= 1'd1; //Assert Stall
                cache_enable <= 1'd1;
                if (mem_req_reg & mem_ready == 1'b1) begin
                    write_index[tag + data] <= 1'b1; //Set to Valid
                    write_index[tag + data - 1:data] <= input_tag; //Update the Tag
                    write_index[data-1:0] <= dram_data_input; //Update the Data
                    cache_enable <= 1'd0; //Turn off Cache Enable
                    mem_req_reg <= 1'b0; //Turn off Memory Request
                end
            end
        endcase
    end
end

always_comb begin
    next = current;
    case(current)
        IDLE: begin
            if (mem_enable) begin //If the Memory is Enabled, it is an Access
                next = ACCESS;
            end else begin
                next = IDLE; //Else it is at Idle
            end
        end
        ACCESS: begin
            if (!mem_enable) begin
                next = IDLE; //Go back to IDLE if memory isn't enabled
            end else begin
                if (hit_miss == 1'b1) begin //If it's a Hit
                    next = ACCESS;
                end else if (hit_miss == 1'b0) begin //If it's a Miss
                    next = MISS_REPAIR;
                end
            end
        end
        MISS_REPAIR: begin 
            if (!mem_enable) begin
                next = IDLE; //Go back to IDLE if memory isn't enabled
            end else begin
                if (mem_ready == 1'b1) begin //If Handshaking enabled, there is a Miss
                    next = MISS_REPAIR;
                end else if (mem_ready == 1'b0) begin //once Handshaking is disabled, go back to Access and try again
                    next = ACCESS;
                end
            end
        end
    endcase
    
end
endmodule