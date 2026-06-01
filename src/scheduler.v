`default_nettype none
`timescale 1ns/1ns

module scheduler (
    clk,
    reset,
    start,

    decoded_mem_read_enable,
    decoded_mem_write_enable,
    decoded_ret,

    fetcher_state,
    lsu_state,

    current_pc,
    next_pc,

    core_state,
    done
);

    parameter THREADS_PER_BLOCK = 4;

    input  wire clk;
    input  wire reset;
    input  wire start;

    input  wire decoded_mem_read_enable;
    input  wire decoded_mem_write_enable;
    input  wire decoded_ret;

    input  wire [2:0] fetcher_state;
    input  wire [(THREADS_PER_BLOCK*2)-1:0] lsu_state;

    output reg  [7:0] current_pc;
    input  wire [(THREADS_PER_BLOCK*8)-1:0] next_pc;

    output reg  [2:0] core_state;
    output reg        done;

    localparam IDLE    = 3'b000;
    localparam FETCH   = 3'b001;
    localparam DECODE  = 3'b010;
    localparam REQUEST = 3'b011;
    localparam WAIT    = 3'b100;
    localparam EXECUTE = 3'b101;
    localparam UPDATE  = 3'b110;
    localparam DONE    = 3'b111;

    localparam FETCHED    = 3'b010;
    localparam REQUESTING = 2'b01;
    localparam LSU_WAITING = 2'b10;

    integer i;
    reg any_lsu_waiting;

    always @(*) begin
        any_lsu_waiting = 1'b0;

        for (i = 0; i < THREADS_PER_BLOCK; i = i + 1) begin
            if ((lsu_state[i*2 +: 2] == REQUESTING) ||
                (lsu_state[i*2 +: 2] == LSU_WAITING)) begin
                any_lsu_waiting = 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            current_pc <= 8'b00000000;
            core_state <= IDLE;
            done       <= 1'b0;
        end else begin
            case (core_state)

                IDLE: begin
                    done <= 1'b0;

                    if (start) begin
                        core_state <= FETCH;
                    end
                end

                FETCH: begin
                    if (fetcher_state == FETCHED) begin
                        core_state <= DECODE;
                    end
                end

                DECODE: begin
                    core_state <= REQUEST;
                end

                REQUEST: begin
                    core_state <= WAIT;
                end

                WAIT: begin
                    if (!any_lsu_waiting) begin
                        core_state <= EXECUTE;
                    end
                end

                EXECUTE: begin
                    core_state <= UPDATE;
                end

                UPDATE: begin
                    if (decoded_ret) begin
                        done       <= 1'b1;
                        core_state <= DONE;
                    end else begin
                        current_pc <= next_pc[(THREADS_PER_BLOCK-1)*8 +: 8];
                        core_state <= FETCH;
                    end
                end

                DONE: begin
                    core_state <= DONE;
                end

                default: begin
                    core_state <= IDLE;
                    done       <= 1'b0;
                end

            endcase
        end
    end

endmodule

`default_nettype wire