`default_nettype none
`timescale 1ns/1ns

module alu (
    clk,
    reset,
    enable,
    core_state,
    decoded_alu_arithmetic_mux,
    decoded_alu_output_mux,
    rs,
    rt,
    alu_out
);

    input  wire       clk;
    input  wire       reset;
    input  wire       enable;
    input  wire [2:0] core_state;
    input  wire [1:0] decoded_alu_arithmetic_mux;
    input  wire       decoded_alu_output_mux;
    input  wire [7:0] rs;
    input  wire [7:0] rt;
    output reg  [7:0] alu_out;

    localparam ADD     = 2'b00;
    localparam SUB     = 2'b01;
    localparam MUL     = 2'b10;
    localparam DIV     = 2'b11;
    localparam EXECUTE = 3'b101;

    always @(posedge clk) begin
        if (reset) begin
            alu_out <= 8'b0;
        end else if (enable && (core_state == EXECUTE)) begin
            if (decoded_alu_output_mux) begin
                alu_out <= {5'b0, (rs > rt), (rs == rt), (rs < rt)};
            end else begin
                case (decoded_alu_arithmetic_mux)
                    ADD: alu_out <= rs + rt;
                    SUB: alu_out <= rs - rt;
                    MUL: alu_out <= rs * rt;
                    DIV: alu_out <= rs / rt;
                    default: alu_out <= alu_out;
                endcase
            end
        end
    end

endmodule

`default_nettype wire