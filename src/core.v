`default_nettype none
`timescale 1ns/1ns

module core (
    clk,
    reset,
    start,
    done,
    block_id,
    thread_count,

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

    parameter DATA_MEM_ADDR_BITS    = 8;
    parameter DATA_MEM_DATA_BITS    = 8;
    parameter PROGRAM_MEM_ADDR_BITS = 8;
    parameter PROGRAM_MEM_DATA_BITS = 16;
    parameter THREADS_PER_BLOCK     = 4;

    input  wire clk;
    input  wire reset;
    input  wire start;
    output wire done;

    input  wire [7:0] block_id;
    input  wire [$clog2(THREADS_PER_BLOCK):0] thread_count;

    output wire program_mem_read_valid;
    output wire [PROGRAM_MEM_ADDR_BITS-1:0] program_mem_read_address;
    input  wire program_mem_read_ready;
    input  wire [PROGRAM_MEM_DATA_BITS-1:0] program_mem_read_data;

    output wire [THREADS_PER_BLOCK-1:0] data_mem_read_valid;
    output wire [(THREADS_PER_BLOCK*DATA_MEM_ADDR_BITS)-1:0] data_mem_read_address;
    input  wire [THREADS_PER_BLOCK-1:0] data_mem_read_ready;
    input  wire [(THREADS_PER_BLOCK*DATA_MEM_DATA_BITS)-1:0] data_mem_read_data;

    output wire [THREADS_PER_BLOCK-1:0] data_mem_write_valid;
    output wire [(THREADS_PER_BLOCK*DATA_MEM_ADDR_BITS)-1:0] data_mem_write_address;
    output wire [(THREADS_PER_BLOCK*DATA_MEM_DATA_BITS)-1:0] data_mem_write_data;
    input  wire [THREADS_PER_BLOCK-1:0] data_mem_write_ready;

    wire [2:0]  core_state;
    wire [2:0]  fetcher_state;
    wire [15:0] instruction;
    wire [7:0]  current_pc;

    wire [(THREADS_PER_BLOCK*8)-1:0] next_pc;
    wire [(THREADS_PER_BLOCK*8)-1:0] rs;
    wire [(THREADS_PER_BLOCK*8)-1:0] rt;
    wire [(THREADS_PER_BLOCK*2)-1:0] lsu_state;
    wire [(THREADS_PER_BLOCK*8)-1:0] lsu_out;
    wire [(THREADS_PER_BLOCK*8)-1:0] alu_out;

    wire [3:0] decoded_rd_address;
    wire [3:0] decoded_rs_address;
    wire [3:0] decoded_rt_address;
    wire [2:0] decoded_nzp;
    wire [7:0] decoded_immediate;

    wire decoded_reg_write_enable;
    wire decoded_mem_read_enable;
    wire decoded_mem_write_enable;
    wire decoded_nzp_write_enable;
    wire [1:0] decoded_reg_input_mux;
    wire [1:0] decoded_alu_arithmetic_mux;
    wire decoded_alu_output_mux;
    wire decoded_pc_mux;
    wire decoded_ret;

    fetcher #(
        .PROGRAM_MEM_ADDR_BITS(PROGRAM_MEM_ADDR_BITS),
        .PROGRAM_MEM_DATA_BITS(PROGRAM_MEM_DATA_BITS)
    ) fetcher_instance (
        .clk(clk),
        .reset(reset),
        .core_state(core_state),
        .current_pc(current_pc),
        .mem_read_valid(program_mem_read_valid),
        .mem_read_address(program_mem_read_address),
        .mem_read_ready(program_mem_read_ready),
        .mem_read_data(program_mem_read_data),
        .fetcher_state(fetcher_state),
        .instruction(instruction)
    );

    decoder decoder_instance (
        .clk(clk),
        .reset(reset),
        .core_state(core_state),
        .instruction(instruction),
        .decoded_rd_address(decoded_rd_address),
        .decoded_rs_address(decoded_rs_address),
        .decoded_rt_address(decoded_rt_address),
        .decoded_nzp(decoded_nzp),
        .decoded_immediate(decoded_immediate),
        .decoded_reg_write_enable(decoded_reg_write_enable),
        .decoded_mem_read_enable(decoded_mem_read_enable),
        .decoded_mem_write_enable(decoded_mem_write_enable),
        .decoded_nzp_write_enable(decoded_nzp_write_enable),
        .decoded_reg_input_mux(decoded_reg_input_mux),
        .decoded_alu_arithmetic_mux(decoded_alu_arithmetic_mux),
        .decoded_alu_output_mux(decoded_alu_output_mux),
        .decoded_pc_mux(decoded_pc_mux),
        .decoded_ret(decoded_ret)
    );

    scheduler #(
        .THREADS_PER_BLOCK(THREADS_PER_BLOCK)
    ) scheduler_instance (
        .clk(clk),
        .reset(reset),
        .start(start),
        .decoded_mem_read_enable(decoded_mem_read_enable),
        .decoded_mem_write_enable(decoded_mem_write_enable),
        .decoded_ret(decoded_ret),
        .fetcher_state(fetcher_state),
        .lsu_state(lsu_state),
        .current_pc(current_pc),
        .next_pc(next_pc),
        .core_state(core_state),
        .done(done)
    );

    genvar i;
    generate
        for (i = 0; i < THREADS_PER_BLOCK; i = i + 1) begin : threads

            alu alu_instance (
                .clk(clk),
                .reset(reset),
                .enable(i < thread_count),
                .core_state(core_state),
                .decoded_alu_arithmetic_mux(decoded_alu_arithmetic_mux),
                .decoded_alu_output_mux(decoded_alu_output_mux),
                .rs(rs[i*8 +: 8]),
                .rt(rt[i*8 +: 8]),
                .alu_out(alu_out[i*8 +: 8])
            );

            lsu lsu_instance (
                .clk(clk),
                .reset(reset),
                .enable(i < thread_count),
                .core_state(core_state),
                .decoded_mem_read_enable(decoded_mem_read_enable),
                .decoded_mem_write_enable(decoded_mem_write_enable),
                .rs(rs[i*8 +: 8]),
                .rt(rt[i*8 +: 8]),
                .mem_read_valid(data_mem_read_valid[i]),
                .mem_read_address(data_mem_read_address[i*DATA_MEM_ADDR_BITS +: DATA_MEM_ADDR_BITS]),
                .mem_read_ready(data_mem_read_ready[i]),
                .mem_read_data(data_mem_read_data[i*DATA_MEM_DATA_BITS +: DATA_MEM_DATA_BITS]),
                .mem_write_valid(data_mem_write_valid[i]),
                .mem_write_address(data_mem_write_address[i*DATA_MEM_ADDR_BITS +: DATA_MEM_ADDR_BITS]),
                .mem_write_data(data_mem_write_data[i*DATA_MEM_DATA_BITS +: DATA_MEM_DATA_BITS]),
                .mem_write_ready(data_mem_write_ready[i]),
                .lsu_state(lsu_state[i*2 +: 2]),
                .lsu_out(lsu_out[i*8 +: 8])
            );

            registers #(
                .THREADS_PER_BLOCK(THREADS_PER_BLOCK),
                .THREAD_ID(i),
                .DATA_BITS(DATA_MEM_DATA_BITS)
            ) register_instance (
                .clk(clk),
                .reset(reset),
                .enable(i < thread_count),
                .block_id(block_id),
                .core_state(core_state),
                .decoded_rd_address(decoded_rd_address),
                .decoded_rs_address(decoded_rs_address),
                .decoded_rt_address(decoded_rt_address),
                .decoded_reg_write_enable(decoded_reg_write_enable),
                .decoded_reg_input_mux(decoded_reg_input_mux),
                .decoded_immediate(decoded_immediate),
                .alu_out(alu_out[i*8 +: 8]),
                .lsu_out(lsu_out[i*8 +: 8]),
                .rs(rs[i*8 +: 8]),
                .rt(rt[i*8 +: 8])
            );

            pc #(
                .DATA_MEM_DATA_BITS(DATA_MEM_DATA_BITS),
                .PROGRAM_MEM_ADDR_BITS(PROGRAM_MEM_ADDR_BITS)
            ) pc_instance (
                .clk(clk),
                .reset(reset),
                .enable(i < thread_count),
                .core_state(core_state),
                .decoded_nzp(decoded_nzp),
                .decoded_immediate(decoded_immediate),
                .decoded_nzp_write_enable(decoded_nzp_write_enable),
                .decoded_pc_mux(decoded_pc_mux),
                .alu_out(alu_out[i*8 +: 8]),
                .current_pc(current_pc),
                .next_pc(next_pc[i*8 +: 8])
            );

        end
    endgenerate

endmodule

`default_nettype wire