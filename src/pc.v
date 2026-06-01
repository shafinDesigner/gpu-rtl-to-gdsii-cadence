`default_nettype none
`timescale 1ns/1ns

module pc (
    clk,
    reset,
    enable,
    core_state,
    decoded_nzp,
    decoded_immediate,
    decoded_nzp_write_enable,
    decoded_pc_mux,
    alu_out,
    current_pc,
    next_pc
);

    parameter DATA_MEM_DATA_BITS  = 8;
    parameter PROGRAM_MEM_ADDR_BITS = 8;

    input  wire clk;
    input  wire reset;
    input  wire enable;

    input  wire [2:0] core_state;
    input  wire [2:0] decoded_nzp;
    input  wire [DATA_MEM_DATA_BITS-1:0] decoded_immediate;
    input  wire decoded_nzp_write_enable;
    input  wire decoded_pc_mux;

    input  wire [DATA_MEM_DATA_BITS-1:0] alu_out;
    input  wire [PROGRAM_MEM_ADDR_BITS-1:0] current_pc;

    output reg  [PROGRAM_MEM_ADDR_BITS-1:0] next_pc;

    localparam EXECUTE = 3'b101;
    localparam UPDATE  = 3'b110;

    reg [2:0] nzp;

    wire branch_taken;
    wire [PROGRAM_MEM_ADDR_BITS-1:0] pc_plus_one;
    wire [PROGRAM_MEM_ADDR_BITS-1:0] branch_target;

    assign branch_taken  = decoded_pc_mux && ((nzp & decoded_nzp) != 3'b000);
    assign pc_plus_one   = current_pc + {{(PROGRAM_MEM_ADDR_BITS-1){1'b0}}, 1'b1};
    assign branch_target = decoded_immediate[PROGRAM_MEM_ADDR_BITS-1:0];

    always @(posedge clk) begin
        if (reset) begin
            nzp     <= 3'b000;
            next_pc <= {PROGRAM_MEM_ADDR_BITS{1'b0}};
        end else if (enable) begin

            if (core_state == EXECUTE) begin
                if (branch_taken)
                    next_pc <= branch_target;
                else
                    next_pc <= pc_plus_one;
            end

            if ((core_state == UPDATE) && decoded_nzp_write_enable) begin
                nzp <= alu_out[2:0];
            end

        end
    end

endmodule

`default_nettype wire