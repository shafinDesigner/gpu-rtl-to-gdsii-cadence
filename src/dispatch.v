`default_nettype none
`timescale 1ns/1ns

module dispatch (
    clk,
    reset,
    start,
    thread_count,
    core_done,
    core_start,
    core_reset,
    core_block_id,
    core_thread_count,
    done
);

    parameter NUM_CORES = 2;
    parameter THREADS_PER_BLOCK = 4;

    input  wire clk;
    input  wire reset;
    input  wire start;

    input  wire [7:0] thread_count;

    input  wire [NUM_CORES-1:0] core_done;
    output reg  [NUM_CORES-1:0] core_start;
    output reg  [NUM_CORES-1:0] core_reset;
    output reg  [(NUM_CORES*8)-1:0] core_block_id;
    output reg  [(NUM_CORES*($clog2(THREADS_PER_BLOCK)+1))-1:0] core_thread_count;

    output reg done;

    localparam THREAD_COUNT_BITS = $clog2(THREADS_PER_BLOCK) + 1;

    wire [7:0] total_blocks;
    assign total_blocks = thread_count[1:0] ? 
                          ((thread_count >> 2) + 8'd1) : 
                          (thread_count >> 2);

    reg [7:0] blocks_dispatched;
    reg [7:0] blocks_done;
    reg start_execution;

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            done              <= 1'b0;
            blocks_dispatched <= 8'b00000000;
            blocks_done       <= 8'b00000000;
            start_execution   <= 1'b0;

            core_start <= {NUM_CORES{1'b0}};
            core_reset <= {NUM_CORES{1'b1}};

            for (i = 0; i < NUM_CORES; i = i + 1) begin
                core_block_id[i*8 +: 8] <= 8'b00000000;
                core_thread_count[i*THREAD_COUNT_BITS +: THREAD_COUNT_BITS]
                    <= THREADS_PER_BLOCK[THREAD_COUNT_BITS-1:0];
            end

        end else if (start) begin

            if (!start_execution) begin
                start_execution <= 1'b1;
                core_reset      <= {NUM_CORES{1'b1}};
                done            <= 1'b0;
            end

            if (blocks_done == total_blocks) begin
                done <= 1'b1;
            end

            for (i = 0; i < NUM_CORES; i = i + 1) begin
                if (core_reset[i]) begin
                    core_reset[i] <= 1'b0;

                    if (blocks_dispatched < total_blocks) begin
                        core_start[i] <= 1'b1;
                        core_block_id[i*8 +: 8] <= blocks_dispatched;

                        if (blocks_dispatched == (total_blocks - 8'd1)) begin
                            core_thread_count[i*THREAD_COUNT_BITS +: THREAD_COUNT_BITS]
                                <= thread_count[THREAD_COUNT_BITS-1:0];
                        end else begin
                            core_thread_count[i*THREAD_COUNT_BITS +: THREAD_COUNT_BITS]
                                <= THREADS_PER_BLOCK[THREAD_COUNT_BITS-1:0];
                        end

                        blocks_dispatched <= blocks_dispatched + 8'd1;
                    end
                end

                if (core_start[i] && core_done[i]) begin
                    core_reset[i] <= 1'b1;
                    core_start[i] <= 1'b0;
                    blocks_done   <= blocks_done + 8'd1;
                end
            end
        end
    end

endmodule

`default_nettype wire