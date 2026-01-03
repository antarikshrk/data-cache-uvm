//Data Cache
module data_cache #(parameter index_count = 256,
parameter data = 11, parameter tag = 20)
(
    input wire clk,
    input wire rst,
    input logic wr_en,
    input logic rd_en,
    input logic [data - 1:0] wr_data,
    input logic [$clog2(index_count) - 1:0] index_sel,
    input logic [tag - 1:0] input_tag,
    input logic [data - 1:0] dram_input,
    input logic mem_ready,

    output wire [data - 1:0] read_data,
    output logic [data - 1:0] write_data,
    output logic hit_miss, //Miss = 1, Hit = 0
    output logic data_req
);

logic hit_miss_int;
logic compared_value; //Comparator output
logic [tag + data:0] cache_data[index_count-1:0]; //Cache Data = {Valid, Tag, Data}
logic [data - 1:0] dram_input_int;
logic [data - 1:0] read_data_reg;


logic [data - 1:0] data_reg;
logic [tag - 1:0] internal_tag;
logic valid;


assign hit_miss = hit_miss_int;
assign data_req = hit_miss_int;

//assign read_data = rd_en && ~hit_miss_int && data; //Read the Data output (Fix)
//assign write_data = wr_en && ~hit_miss_int && data; //Send Data to the DRAM (Fix)

assign dram_input_int = dram_input;
assign read_data = read_data_reg;


//Initializing the Data Array -> Actual Cache Reset
always_ff @(posedge clk or posedge rst) begin
integer index; 
    for (index = 0; index < index_count; index++){
        if (rst) begin
            cache_data[index][tag+data] = 0; //Set the Valid bit to 0, other bits don't matter
        end
    }
end

//Cache Line Select
always_ff @(posedge clk or posedge rst) begin 
    if (rst) begin
        data_reg = 1'd0;
        internal_tag = 1'd0;
        valid = 1'd0;
    end else begin
        case(index_sel):
            data_reg = cache_data[index_sel][data - 1:0];
            internal_tag = cache_data[index_sel][tag + data - 1: data];
            valid = cache_data[index_sel][tag+data];
        endcase 
    end  
end
 
always_comb begin
    //Comparator
    if (input_tag == internal_tag){
        compared_value = 1'b1; //Values Match
    }
    else{
        compared_value = 1'b0; //Values do NOT Match
    }

    hit_miss_int = ~(compared_value & valid);
    //dram_input_int = (data_req & mem_ready) && dram_input;
end

//Need to make a Read/Write-Hit Scenario
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        read_data_reg = 1'd0;
        write_data = 1'd0;
    end else if (~hit_miss_int & wr_en) begin //Write hit, update the Cache
        case(index_sel):
            cache_data[index_sel][tag+data] = 1'b1; //Set Valid Bit
            cache_data[index_sel][tag + data - 1: data] = input_tag; //Set the Tag
            cache_data[index_sel][data - 1:0] = wr_data; //Set Write Data
        endcase
        write_data = wr_data; //Write-Through Cache
    end else if (~hit_miss_int & rd_en) begin //Read Hit, Output the Data Register Value
        case(index_sel):
            read_data_reg = data_reg;
        endcase
    end else begin //Read/Write Hit Miss
        if (data_req & mem_ready){
            case(index_sel):
                cache_data[index_sel][tag+data] = 1'b1; //Update Valid
                cache_data[index_sel][tag + data - 1: data] = input_tag; //Replace the Tag
                cache_data[index_sel][data - 1:0] = dram_input_int; //Provide the DRAM Data
            endcase
    }
    end
end

endmodule