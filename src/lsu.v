`default_nettype none
`timescale 1ns/1ns

module lsu (
    clk,
    reset,
    enable,
    core_state,
    decoded_mem_read_enable,
    decoded_mem_write_enable,
    rs,
    rt,
    mem_read_valid,
    mem_read_address,
    mem_read_ready,
    mem_read_data,
    mem_write_valid,
    mem_write_address,
    mem_write_data,
    mem_write_ready,
    lsu_state,
    lsu_out
);

    input  wire       clk;
    input  wire       reset;
    input  wire       enable;
    input  wire [2:0] core_state;

    input  wire       decoded_mem_read_enable;
    input  wire       decoded_mem_write_enable;

    input  wire [7:0] rs;
    input  wire [7:0] rt;

    output reg        mem_read_valid;
    output reg  [7:0] mem_read_address;
    input  wire       mem_read_ready;
    input  wire [7:0] mem_read_data;

    output reg        mem_write_valid;
    output reg  [7:0] mem_write_address;
    output reg  [7:0] mem_write_data;
    input  wire       mem_write_ready;

    output reg  [1:0] lsu_state;
    output reg  [7:0] lsu_out;

    localparam IDLE       = 2'b00;
    localparam REQUESTING = 2'b01;
    localparam WAITING    = 2'b10;
    localparam DONE       = 2'b11;

    localparam CORE_REQUEST = 3'b011;
    localparam CORE_UPDATE  = 3'b110;

    reg is_read_op;
    reg is_write_op;

    always @(posedge clk) begin
        if (reset) begin
            lsu_state         <= IDLE;
            lsu_out           <= 8'b00000000;
            mem_read_valid    <= 1'b0;
            mem_read_address  <= 8'b00000000;
            mem_write_valid   <= 1'b0;
            mem_write_address <= 8'b00000000;
            mem_write_data    <= 8'b00000000;
            is_read_op        <= 1'b0;
            is_write_op       <= 1'b0;
        end else if (enable) begin
            case (lsu_state)

                IDLE: begin
                    mem_read_valid  <= 1'b0;
                    mem_write_valid <= 1'b0;

                    if (core_state == CORE_REQUEST) begin
                        if (decoded_mem_read_enable) begin
                            is_read_op        <= 1'b1;
                            is_write_op       <= 1'b0;
                            lsu_state         <= REQUESTING;
                        end else if (decoded_mem_write_enable) begin
                            is_read_op        <= 1'b0;
                            is_write_op       <= 1'b1;
                            lsu_state         <= REQUESTING;
                        end
                    end
                end

                REQUESTING: begin
                    if (is_read_op) begin
                        mem_read_valid   <= 1'b1;
                        mem_read_address <= rs;
                    end else if (is_write_op) begin
                        mem_write_valid   <= 1'b1;
                        mem_write_address <= rs;
                        mem_write_data    <= rt;
                    end

                    lsu_state <= WAITING;
                end

                WAITING: begin
                    if (is_read_op && mem_read_ready) begin
                        mem_read_valid <= 1'b0;
                        lsu_out        <= mem_read_data;
                        lsu_state      <= DONE;
                    end else if (is_write_op && mem_write_ready) begin
                        mem_write_valid <= 1'b0;
                        lsu_state       <= DONE;
                    end
                end

                DONE: begin
                    mem_read_valid  <= 1'b0;
                    mem_write_valid <= 1'b0;

                    if (core_state == CORE_UPDATE) begin
                        is_read_op  <= 1'b0;
                        is_write_op <= 1'b0;
                        lsu_state   <= IDLE;
                    end
                end

                default: begin
                    lsu_state        <= IDLE;
                    mem_read_valid   <= 1'b0;
                    mem_write_valid  <= 1'b0;
                    is_read_op       <= 1'b0;
                    is_write_op      <= 1'b0;
                end

            endcase
        end
    end

endmodule

`default_nettype wire