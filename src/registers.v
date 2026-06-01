`default_nettype none
`timescale 1ns/1ns

module registers (
    clk,
    reset,
    enable,
    block_id,
    core_state,
    decoded_rd_address,
    decoded_rs_address,
    decoded_rt_address,
    decoded_reg_write_enable,
    decoded_reg_input_mux,
    decoded_immediate,
    alu_out,
    lsu_out,
    rs,
    rt
);

    parameter THREADS_PER_BLOCK = 4;
    parameter THREAD_ID         = 0;
    parameter DATA_BITS         = 8;

    input  wire clk;
    input  wire reset;
    input  wire enable;

    input  wire [7:0] block_id;
    input  wire [2:0] core_state;

    input  wire [3:0] decoded_rd_address;
    input  wire [3:0] decoded_rs_address;
    input  wire [3:0] decoded_rt_address;

    input  wire decoded_reg_write_enable;
    input  wire [1:0] decoded_reg_input_mux;
    input  wire [DATA_BITS-1:0] decoded_immediate;

    input  wire [DATA_BITS-1:0] alu_out;
    input  wire [DATA_BITS-1:0] lsu_out;

    output reg [7:0] rs;
    output reg [7:0] rt;

    localparam CORE_REQUEST = 3'b011;
    localparam CORE_UPDATE  = 3'b110;

    localparam ARITHMETIC = 2'b00;
    localparam MEMORY     = 2'b01;
    localparam CONSTANT   = 2'b10;

    reg [7:0] regfile [0:15];

    always @(posedge clk) begin
        if (reset) begin
            rs <= 8'b00000000;
            rt <= 8'b00000000;

            regfile[0]  <= 8'b00000000;
            regfile[1]  <= 8'b00000000;
            regfile[2]  <= 8'b00000000;
            regfile[3]  <= 8'b00000000;
            regfile[4]  <= 8'b00000000;
            regfile[5]  <= 8'b00000000;
            regfile[6]  <= 8'b00000000;
            regfile[7]  <= 8'b00000000;
            regfile[8]  <= 8'b00000000;
            regfile[9]  <= 8'b00000000;
            regfile[10] <= 8'b00000000;
            regfile[11] <= 8'b00000000;
            regfile[12] <= 8'b00000000;

            regfile[13] <= 8'b00000000;
            regfile[14] <= THREADS_PER_BLOCK[7:0];
            regfile[15] <= THREAD_ID[7:0];

        end else if (enable) begin

            if (core_state == CORE_REQUEST) begin
                rs <= regfile[decoded_rs_address];
                rt <= regfile[decoded_rt_address];
            end

            if (core_state == CORE_UPDATE) begin
                regfile[13] <= block_id;

                if (decoded_reg_write_enable && (decoded_rd_address < 4'd13)) begin
                    case (decoded_reg_input_mux)

                        ARITHMETIC: begin
                            regfile[decoded_rd_address] <= alu_out;
                        end

                        MEMORY: begin
                            regfile[decoded_rd_address] <= lsu_out;
                        end

                        CONSTANT: begin
                            regfile[decoded_rd_address] <= decoded_immediate;
                        end

                        default: begin
                            regfile[decoded_rd_address] <= regfile[decoded_rd_address];
                        end

                    endcase
                end
            end
        end
    end

endmodule

`default_nettype wire