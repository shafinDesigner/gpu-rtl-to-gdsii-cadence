`default_nettype none
`timescale 1ns/1ns

module controller (
    clk,
    reset,

    consumer_read_valid,
    consumer_read_address,
    consumer_read_ready,
    consumer_read_data,

    consumer_write_valid,
    consumer_write_address,
    consumer_write_data,
    consumer_write_ready,

    mem_read_valid,
    mem_read_address,
    mem_read_ready,
    mem_read_data,

    mem_write_valid,
    mem_write_address,
    mem_write_data,
    mem_write_ready
);

    parameter ADDR_BITS     = 8;
    parameter DATA_BITS     = 16;
    parameter NUM_CONSUMERS = 4;
    parameter NUM_CHANNELS  = 1;
    parameter WRITE_ENABLE  = 1;

    input  wire clk;
    input  wire reset;

    input  wire [NUM_CONSUMERS-1:0] consumer_read_valid;
    input  wire [(NUM_CONSUMERS*ADDR_BITS)-1:0] consumer_read_address;
    output reg  [NUM_CONSUMERS-1:0] consumer_read_ready;
    output reg  [(NUM_CONSUMERS*DATA_BITS)-1:0] consumer_read_data;

    input  wire [NUM_CONSUMERS-1:0] consumer_write_valid;
    input  wire [(NUM_CONSUMERS*ADDR_BITS)-1:0] consumer_write_address;
    input  wire [(NUM_CONSUMERS*DATA_BITS)-1:0] consumer_write_data;
    output reg  [NUM_CONSUMERS-1:0] consumer_write_ready;

    output reg  [NUM_CHANNELS-1:0] mem_read_valid;
    output reg  [(NUM_CHANNELS*ADDR_BITS)-1:0] mem_read_address;
    input  wire [NUM_CHANNELS-1:0] mem_read_ready;
    input  wire [(NUM_CHANNELS*DATA_BITS)-1:0] mem_read_data;

    output reg  [NUM_CHANNELS-1:0] mem_write_valid;
    output reg  [(NUM_CHANNELS*ADDR_BITS)-1:0] mem_write_address;
    output reg  [(NUM_CHANNELS*DATA_BITS)-1:0] mem_write_data;
    input  wire [NUM_CHANNELS-1:0] mem_write_ready;

    localparam IDLE           = 3'b000;
    localparam READ_WAITING   = 3'b010;
    localparam WRITE_WAITING  = 3'b011;
    localparam READ_RELAYING  = 3'b100;
    localparam WRITE_RELAYING = 3'b101;

    localparam CONSUMER_BITS = $clog2(NUM_CONSUMERS);

    reg [(NUM_CHANNELS*3)-1:0] controller_state;
    reg [(NUM_CHANNELS*CONSUMER_BITS)-1:0] current_consumer;
    reg [NUM_CONSUMERS-1:0] channel_serving_consumer;

    integer i;
    integer j;

    reg found_req;
    reg [CONSUMER_BITS-1:0] selected_consumer;

    always @(posedge clk) begin
        if (reset) begin
            mem_read_valid           <= {NUM_CHANNELS{1'b0}};
            mem_read_address         <= {(NUM_CHANNELS*ADDR_BITS){1'b0}};
            mem_write_valid          <= {NUM_CHANNELS{1'b0}};
            mem_write_address        <= {(NUM_CHANNELS*ADDR_BITS){1'b0}};
            mem_write_data           <= {(NUM_CHANNELS*DATA_BITS){1'b0}};

            consumer_read_ready      <= {NUM_CONSUMERS{1'b0}};
            consumer_read_data       <= {(NUM_CONSUMERS*DATA_BITS){1'b0}};
            consumer_write_ready     <= {NUM_CONSUMERS{1'b0}};

            controller_state         <= {(NUM_CHANNELS*3){1'b0}};
            current_consumer         <= {(NUM_CHANNELS*CONSUMER_BITS){1'b0}};
            channel_serving_consumer <= {NUM_CONSUMERS{1'b0}};
        end else begin

            for (i = 0; i < NUM_CHANNELS; i = i + 1) begin

                case (controller_state[i*3 +: 3])

                    IDLE: begin
                        found_req = 1'b0;
                        selected_consumer = {CONSUMER_BITS{1'b0}};

                        for (j = 0; j < NUM_CONSUMERS; j = j + 1) begin
                            if (!found_req && consumer_read_valid[j] && !channel_serving_consumer[j]) begin
                                found_req = 1'b1;
                                selected_consumer = j[CONSUMER_BITS-1:0];

                                channel_serving_consumer[j] <= 1'b1;
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS] <= j[CONSUMER_BITS-1:0];

                                mem_read_valid[i] <= 1'b1;
                                mem_read_address[i*ADDR_BITS +: ADDR_BITS] <=
                                    consumer_read_address[j*ADDR_BITS +: ADDR_BITS];

                                controller_state[i*3 +: 3] <= READ_WAITING;
                            end else if (!found_req && WRITE_ENABLE &&
                                         consumer_write_valid[j] &&
                                         !channel_serving_consumer[j]) begin
                                found_req = 1'b1;
                                selected_consumer = j[CONSUMER_BITS-1:0];

                                channel_serving_consumer[j] <= 1'b1;
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS] <= j[CONSUMER_BITS-1:0];

                                mem_write_valid[i] <= 1'b1;
                                mem_write_address[i*ADDR_BITS +: ADDR_BITS] <=
                                    consumer_write_address[j*ADDR_BITS +: ADDR_BITS];

                                mem_write_data[i*DATA_BITS +: DATA_BITS] <=
                                    consumer_write_data[j*DATA_BITS +: DATA_BITS];

                                controller_state[i*3 +: 3] <= WRITE_WAITING;
                            end
                        end
                    end

                    READ_WAITING: begin
                        if (mem_read_ready[i]) begin
                            mem_read_valid[i] <= 1'b0;

                            consumer_read_ready[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                            ] <= 1'b1;

                            consumer_read_data[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]*DATA_BITS +: DATA_BITS
                            ] <= mem_read_data[i*DATA_BITS +: DATA_BITS];

                            controller_state[i*3 +: 3] <= READ_RELAYING;
                        end
                    end

                    WRITE_WAITING: begin
                        if (mem_write_ready[i]) begin
                            mem_write_valid[i] <= 1'b0;

                            consumer_write_ready[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                            ] <= 1'b1;

                            controller_state[i*3 +: 3] <= WRITE_RELAYING;
                        end
                    end

                    READ_RELAYING: begin
                        if (!consumer_read_valid[
                            current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                        ]) begin
                            channel_serving_consumer[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                            ] <= 1'b0;

                            consumer_read_ready[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                            ] <= 1'b0;

                            controller_state[i*3 +: 3] <= IDLE;
                        end
                    end

                    WRITE_RELAYING: begin
                        if (!consumer_write_valid[
                            current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                        ]) begin
                            channel_serving_consumer[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                            ] <= 1'b0;

                            consumer_write_ready[
                                current_consumer[i*CONSUMER_BITS +: CONSUMER_BITS]
                            ] <= 1'b0;

                            controller_state[i*3 +: 3] <= IDLE;
                        end
                    end

                    default: begin
                        controller_state[i*3 +: 3] <= IDLE;
                    end

                endcase
            end
        end
    end

endmodule

`default_nettype wire