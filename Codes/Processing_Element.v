`timescale 1ns / 1ps

module Processing_Element #(
    parameter IN_WIDTH  = 8,
    parameter OUT_WIDTH = 16
)(
    input  wire                             clk,
    input  wire                             reset,
    input  wire                             freeze_weights,
    input  wire signed [IN_WIDTH-1:0]       weight_in,
    input  wire signed [IN_WIDTH-1:0]       data_in,
    input  wire signed [OUT_WIDTH-1:0]      psum_in,
    output reg  signed [IN_WIDTH-1:0]       weight_out,
    output reg  signed [IN_WIDTH-1:0]       data_out,
    output reg  signed [OUT_WIDTH-1:0]      psum_out
);

    reg signed [IN_WIDTH-1:0] stationary_weight;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stationary_weight <= {IN_WIDTH{1'b0}};
            weight_out        <= {IN_WIDTH{1'b0}};
            data_out          <= {IN_WIDTH{1'b0}};
            psum_out          <= {OUT_WIDTH{1'b0}};
        end else begin
            if (!freeze_weights) begin
                stationary_weight <= weight_in;
                weight_out        <= weight_in;
                data_out          <= {IN_WIDTH{1'b0}};
                psum_out          <= {OUT_WIDTH{1'b0}};
            end else begin
                weight_out        <= stationary_weight;
                data_out          <= data_in;
                psum_out          <= (data_in * stationary_weight) + psum_in;
            end
        end
    end

endmodule
