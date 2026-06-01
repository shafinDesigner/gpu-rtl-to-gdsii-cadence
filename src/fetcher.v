`default_nettype none
`timescale 1ns/1ns

module fetcher (
    clk,
    reset,
    core_state,
    current_pc,
    mem_read_valid,
    mem_read_address,
    mem_read_ready,
    mem_read_data,
    fetcher_state,
    instruction
);

    parameter PROGRAM_MEM_ADDR_BITS  = 8;
    parameter PROGRAM_MEM_DATA_BITS  = 16;

    input  wire clk;
    input  wire reset;

    input  wire [2:0] core_state;
    input  wire [7:0] current_pc;

    output reg  mem_read_valid;
    output reg  [PROGRAM_MEM_ADDR_BITS-1:0] mem_read_address;
    input  wire mem_read_ready;
    input  wire [PROGRAM_MEM_DATA_BITS-1:0] mem_read_data;

    output reg  [2:0] fetcher_state;
    output reg  [PROGRAM_MEM_DATA_BITS-1:0] instruction;

    localparam IDLE     = 3'b000;
    localparam FETCHING = 3'b001;
    localparam FETCHED  = 3'b010;

    localparam CORE_FETCH  = 3'b001;
    localparam CORE_DECODE = 3'b010;

    always @(posedge clk) begin
        if (reset) begin
            fetcher_state    <= IDLE;
            mem_read_valid   <= 1'b0;
            mem_read_address <= {PROGRAM_MEM_ADDR_BITS{1'b0}};
            instruction      <= {PROGRAM_MEM_DATA_BITS{1'b0}};
        end else begin
            case (fetcher_state)

                IDLE: begin
                    mem_read_valid <= 1'b0;

                    if (core_state == CORE_FETCH) begin
                        fetcher_state    <= FETCHING;
                        mem_read_valid   <= 1'b1;
                        mem_read_address <= current_pc[PROGRAM_MEM_ADDR_BITS-1:0];
                    end
                end

                FETCHING: begin
                    mem_read_valid <= 1'b1;

                    if (mem_read_ready) begin
                        fetcher_state  <= FETCHED;
                        instruction    <= mem_read_data;
                        mem_read_valid <= 1'b0;
                    end
                end

                FETCHED: begin
                    mem_read_valid <= 1'b0;

                    if (core_state == CORE_DECODE) begin
                        fetcher_state <= IDLE;
                    end
                end

                default: begin
                    fetcher_state  <= IDLE;
                    mem_read_valid <= 1'b0;
                end

            endcase
        end
    end

endmodule

`default_nettype wire