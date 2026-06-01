`default_nettype none
`timescale 1ns/1ns

module decoder (
    clk,
    reset,
    core_state,
    instruction,

    decoded_rd_address,
    decoded_rs_address,
    decoded_rt_address,
    decoded_nzp,
    decoded_immediate,

    decoded_reg_write_enable,
    decoded_mem_read_enable,
    decoded_mem_write_enable,
    decoded_nzp_write_enable,
    decoded_reg_input_mux,
    decoded_alu_arithmetic_mux,
    decoded_alu_output_mux,
    decoded_pc_mux,
    decoded_ret
);

    input  wire       clk;
    input  wire       reset;
    input  wire [2:0] core_state;
    input  wire [15:0] instruction;

    output reg  [3:0] decoded_rd_address;
    output reg  [3:0] decoded_rs_address;
    output reg  [3:0] decoded_rt_address;
    output reg  [2:0] decoded_nzp;
    output reg  [7:0] decoded_immediate;

    output reg        decoded_reg_write_enable;
    output reg        decoded_mem_read_enable;
    output reg        decoded_mem_write_enable;
    output reg        decoded_nzp_write_enable;
    output reg  [1:0] decoded_reg_input_mux;
    output reg  [1:0] decoded_alu_arithmetic_mux;
    output reg        decoded_alu_output_mux;
    output reg        decoded_pc_mux;
    output reg        decoded_ret;

    localparam CORE_DECODE = 3'b010;

    localparam NOP   = 4'b0000;
    localparam BRNZP = 4'b0001;
    localparam CMP   = 4'b0010;
    localparam ADD   = 4'b0011;
    localparam SUB   = 4'b0100;
    localparam MUL   = 4'b0101;
    localparam DIV   = 4'b0110;
    localparam LDR   = 4'b0111;
    localparam STR   = 4'b1000;
    localparam CONST = 4'b1001;
    localparam RET   = 4'b1111;

    always @(posedge clk) begin
        if (reset) begin
            decoded_rd_address         <= 4'b0000;
            decoded_rs_address         <= 4'b0000;
            decoded_rt_address         <= 4'b0000;
            decoded_nzp                <= 3'b000;
            decoded_immediate          <= 8'b00000000;

            decoded_reg_write_enable   <= 1'b0;
            decoded_mem_read_enable    <= 1'b0;
            decoded_mem_write_enable   <= 1'b0;
            decoded_nzp_write_enable   <= 1'b0;
            decoded_reg_input_mux      <= 2'b00;
            decoded_alu_arithmetic_mux <= 2'b00;
            decoded_alu_output_mux     <= 1'b0;
            decoded_pc_mux             <= 1'b0;
            decoded_ret                <= 1'b0;

        end else if (core_state == CORE_DECODE) begin
            decoded_rd_address         <= instruction[11:8];
            decoded_rs_address         <= instruction[7:4];
            decoded_rt_address         <= instruction[3:0];
            decoded_immediate          <= instruction[7:0];
            decoded_nzp                <= instruction[11:9];

            decoded_reg_write_enable   <= 1'b0;
            decoded_mem_read_enable    <= 1'b0;
            decoded_mem_write_enable   <= 1'b0;
            decoded_nzp_write_enable   <= 1'b0;
            decoded_reg_input_mux      <= 2'b00;
            decoded_alu_arithmetic_mux <= 2'b00;
            decoded_alu_output_mux     <= 1'b0;
            decoded_pc_mux             <= 1'b0;
            decoded_ret                <= 1'b0;

            case (instruction[15:12])

                NOP: begin
                    // no operation
                end

                BRNZP: begin
                    decoded_pc_mux <= 1'b1;
                end

                CMP: begin
                    decoded_alu_output_mux   <= 1'b1;
                    decoded_nzp_write_enable <= 1'b1;
                end

                ADD: begin
                    decoded_reg_write_enable   <= 1'b1;
                    decoded_reg_input_mux      <= 2'b00;
                    decoded_alu_arithmetic_mux <= 2'b00;
                end

                SUB: begin
                    decoded_reg_write_enable   <= 1'b1;
                    decoded_reg_input_mux      <= 2'b00;
                    decoded_alu_arithmetic_mux <= 2'b01;
                end

                MUL: begin
                    decoded_reg_write_enable   <= 1'b1;
                    decoded_reg_input_mux      <= 2'b00;
                    decoded_alu_arithmetic_mux <= 2'b10;
                end

                DIV: begin
                    decoded_reg_write_enable   <= 1'b1;
                    decoded_reg_input_mux      <= 2'b00;
                    decoded_alu_arithmetic_mux <= 2'b11;
                end

                LDR: begin
                    decoded_reg_write_enable <= 1'b1;
                    decoded_reg_input_mux    <= 2'b01;
                    decoded_mem_read_enable  <= 1'b1;
                end

                STR: begin
                    decoded_mem_write_enable <= 1'b1;
                end

                CONST: begin
                    decoded_reg_write_enable <= 1'b1;
                    decoded_reg_input_mux    <= 2'b10;
                end

                RET: begin
                    decoded_ret <= 1'b1;
                end

                default: begin
                    // all control signals already defaulted to 0
                end

            endcase
        end
    end

endmodule

`default_nettype wire