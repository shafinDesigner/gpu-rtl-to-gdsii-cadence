`default_nettype none
`timescale 1ns/1ns

module gpu (
    clk,
    reset,
    start,
    done,

    device_control_write_enable,
    device_control_data,

    program_mem_read_valid,
    program_mem_read_address,
    program_mem_read_ready,
    program_mem_read_data,

    data_mem_read_valid,
    data_mem_read_address,
    data_mem_read_ready,
    data_mem_read_data,
    data_mem_write_valid,
    data_mem_write_address,
    data_mem_write_data,
    data_mem_write_ready
);

    parameter DATA_MEM_ADDR_BITS       = 8;
    parameter DATA_MEM_DATA_BITS       = 8;
    parameter DATA_MEM_NUM_CHANNELS    = 4;
    parameter PROGRAM_MEM_ADDR_BITS    = 8;
    parameter PROGRAM_MEM_DATA_BITS    = 16;
    parameter PROGRAM_MEM_NUM_CHANNELS = 1;
    parameter NUM_CORES                = 2;
    parameter THREADS_PER_BLOCK        = 4;

    localparam NUM_LSUS        = NUM_CORES * THREADS_PER_BLOCK;
    localparam NUM_FETCHERS    = NUM_CORES;
    localparam THREAD_CNT_BITS = $clog2(THREADS_PER_BLOCK) + 1;

    input  wire clk;
    input  wire reset;
    input  wire start;
    output wire done;

    input  wire       device_control_write_enable;
    input  wire [7:0] device_control_data;

    output wire [PROGRAM_MEM_NUM_CHANNELS-1:0] program_mem_read_valid;
    output wire [(PROGRAM_MEM_NUM_CHANNELS*PROGRAM_MEM_ADDR_BITS)-1:0] program_mem_read_address;
    input  wire [PROGRAM_MEM_NUM_CHANNELS-1:0] program_mem_read_ready;
    input  wire [(PROGRAM_MEM_NUM_CHANNELS*PROGRAM_MEM_DATA_BITS)-1:0] program_mem_read_data;

    output wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_read_valid;
    output wire [(DATA_MEM_NUM_CHANNELS*DATA_MEM_ADDR_BITS)-1:0] data_mem_read_address;
    input  wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_read_ready;
    input  wire [(DATA_MEM_NUM_CHANNELS*DATA_MEM_DATA_BITS)-1:0] data_mem_read_data;

    output wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_write_valid;
    output wire [(DATA_MEM_NUM_CHANNELS*DATA_MEM_ADDR_BITS)-1:0] data_mem_write_address;
    output wire [(DATA_MEM_NUM_CHANNELS*DATA_MEM_DATA_BITS)-1:0] data_mem_write_data;
    input  wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_write_ready;

    wire [7:0] thread_count;

    wire [NUM_CORES-1:0] core_start;
    wire [NUM_CORES-1:0] core_reset;
    wire [NUM_CORES-1:0] core_done;
    wire [(NUM_CORES*8)-1:0] core_block_id;
    wire [(NUM_CORES*THREAD_CNT_BITS)-1:0] core_thread_count;

    wire [NUM_LSUS-1:0] lsu_read_valid;
    wire [(NUM_LSUS*DATA_MEM_ADDR_BITS)-1:0] lsu_read_address;
    wire [NUM_LSUS-1:0] lsu_read_ready;
    wire [(NUM_LSUS*DATA_MEM_DATA_BITS)-1:0] lsu_read_data;

    wire [NUM_LSUS-1:0] lsu_write_valid;
    wire [(NUM_LSUS*DATA_MEM_ADDR_BITS)-1:0] lsu_write_address;
    wire [(NUM_LSUS*DATA_MEM_DATA_BITS)-1:0] lsu_write_data;
    wire [NUM_LSUS-1:0] lsu_write_ready;

    wire [NUM_FETCHERS-1:0] fetcher_read_valid;
    wire [(NUM_FETCHERS*PROGRAM_MEM_ADDR_BITS)-1:0] fetcher_read_address;
    wire [NUM_FETCHERS-1:0] fetcher_read_ready;
    wire [(NUM_FETCHERS*PROGRAM_MEM_DATA_BITS)-1:0] fetcher_read_data;

    wire [NUM_FETCHERS-1:0] unused_prog_write_ready;
    wire [(NUM_FETCHERS*PROGRAM_MEM_DATA_BITS)-1:0] unused_prog_write_data;

    assign unused_prog_write_data = {(NUM_FETCHERS*PROGRAM_MEM_DATA_BITS){1'b0}};

    dcr dcr_instance (
        .clk(clk),
        .reset(reset),
        .device_control_write_enable(device_control_write_enable),
        .device_control_data(device_control_data),
        .thread_count(thread_count)
    );

    dispatch #(
        .NUM_CORES(NUM_CORES),
        .THREADS_PER_BLOCK(THREADS_PER_BLOCK)
    ) dispatch_instance (
        .clk(clk),
        .reset(reset),
        .start(start),
        .thread_count(thread_count),
        .core_done(core_done),
        .core_start(core_start),
        .core_reset(core_reset),
        .core_block_id(core_block_id),
        .core_thread_count(core_thread_count),
        .done(done)
    );

    controller #(
        .ADDR_BITS(DATA_MEM_ADDR_BITS),
        .DATA_BITS(DATA_MEM_DATA_BITS),
        .NUM_CONSUMERS(NUM_LSUS),
        .NUM_CHANNELS(DATA_MEM_NUM_CHANNELS),
        .WRITE_ENABLE(1)
    ) data_memory_controller (
        .clk(clk),
        .reset(reset),

        .consumer_read_valid(lsu_read_valid),
        .consumer_read_address(lsu_read_address),
        .consumer_read_ready(lsu_read_ready),
        .consumer_read_data(lsu_read_data),

        .consumer_write_valid(lsu_write_valid),
        .consumer_write_address(lsu_write_address),
        .consumer_write_data(lsu_write_data),
        .consumer_write_ready(lsu_write_ready),

        .mem_read_valid(data_mem_read_valid),
        .mem_read_address(data_mem_read_address),
        .mem_read_ready(data_mem_read_ready),
        .mem_read_data(data_mem_read_data),

        .mem_write_valid(data_mem_write_valid),
        .mem_write_address(data_mem_write_address),
        .mem_write_data(data_mem_write_data),
        .mem_write_ready(data_mem_write_ready)
    );

    controller #(
        .ADDR_BITS(PROGRAM_MEM_ADDR_BITS),
        .DATA_BITS(PROGRAM_MEM_DATA_BITS),
        .NUM_CONSUMERS(NUM_FETCHERS),
        .NUM_CHANNELS(PROGRAM_MEM_NUM_CHANNELS),
        .WRITE_ENABLE(0)
    ) program_memory_controller (
        .clk(clk),
        .reset(reset),

        .consumer_read_valid(fetcher_read_valid),
        .consumer_read_address(fetcher_read_address),
        .consumer_read_ready(fetcher_read_ready),
        .consumer_read_data(fetcher_read_data),

        .consumer_write_valid({NUM_FETCHERS{1'b0}}),
        .consumer_write_address({(NUM_FETCHERS*PROGRAM_MEM_ADDR_BITS){1'b0}}),
        .consumer_write_data(unused_prog_write_data),
        .consumer_write_ready(unused_prog_write_ready),

        .mem_read_valid(program_mem_read_valid),
        .mem_read_address(program_mem_read_address),
        .mem_read_ready(program_mem_read_ready),
        .mem_read_data(program_mem_read_data),

        .mem_write_valid(),
        .mem_write_address(),
        .mem_write_data(),
        .mem_write_ready({PROGRAM_MEM_NUM_CHANNELS{1'b0}})
    );

    genvar i;
    generate
        for (i = 0; i < NUM_CORES; i = i + 1) begin : cores

            core #(
                .DATA_MEM_ADDR_BITS(DATA_MEM_ADDR_BITS),
                .DATA_MEM_DATA_BITS(DATA_MEM_DATA_BITS),
                .PROGRAM_MEM_ADDR_BITS(PROGRAM_MEM_ADDR_BITS),
                .PROGRAM_MEM_DATA_BITS(PROGRAM_MEM_DATA_BITS),
                .THREADS_PER_BLOCK(THREADS_PER_BLOCK)
            ) core_instance (
                .clk(clk),
                .reset(core_reset[i]),
                .start(core_start[i]),
                .done(core_done[i]),

                .block_id(core_block_id[i*8 +: 8]),
                .thread_count(core_thread_count[i*THREAD_CNT_BITS +: THREAD_CNT_BITS]),

                .program_mem_read_valid(fetcher_read_valid[i]),
                .program_mem_read_address(fetcher_read_address[i*PROGRAM_MEM_ADDR_BITS +: PROGRAM_MEM_ADDR_BITS]),
                .program_mem_read_ready(fetcher_read_ready[i]),
                .program_mem_read_data(fetcher_read_data[i*PROGRAM_MEM_DATA_BITS +: PROGRAM_MEM_DATA_BITS]),

                .data_mem_read_valid(lsu_read_valid[i*THREADS_PER_BLOCK +: THREADS_PER_BLOCK]),
                .data_mem_read_address(lsu_read_address[i*THREADS_PER_BLOCK*DATA_MEM_ADDR_BITS +: THREADS_PER_BLOCK*DATA_MEM_ADDR_BITS]),
                .data_mem_read_ready(lsu_read_ready[i*THREADS_PER_BLOCK +: THREADS_PER_BLOCK]),
                .data_mem_read_data(lsu_read_data[i*THREADS_PER_BLOCK*DATA_MEM_DATA_BITS +: THREADS_PER_BLOCK*DATA_MEM_DATA_BITS]),

                .data_mem_write_valid(lsu_write_valid[i*THREADS_PER_BLOCK +: THREADS_PER_BLOCK]),
                .data_mem_write_address(lsu_write_address[i*THREADS_PER_BLOCK*DATA_MEM_ADDR_BITS +: THREADS_PER_BLOCK*DATA_MEM_ADDR_BITS]),
                .data_mem_write_data(lsu_write_data[i*THREADS_PER_BLOCK*DATA_MEM_DATA_BITS +: THREADS_PER_BLOCK*DATA_MEM_DATA_BITS]),
                .data_mem_write_ready(lsu_write_ready[i*THREADS_PER_BLOCK +: THREADS_PER_BLOCK])
            );

        end
    endgenerate

endmodule

`default_nettype wire