//Cache Package
package cache_pkg;
    //Cache Parameters
    parameter int INDEX_COUNT = 256;
    parameter int DATA_WIDTH = 32;
    parameter int TAG_WIDTH = 20;

    //LSU Operations
    typedef enum logic{
        LW = 1'b0, //LW - Load Word
        SW = 1'b1 //SW - Store Word
    } lsu_ops;

endpackage