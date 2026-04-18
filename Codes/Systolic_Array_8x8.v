`timescale 1ns / 1ps

module Systolic_Array_8x8 #(
    parameter IN_WIDTH  = 8,
    parameter OUT_WIDTH = 16
)(
    input  wire                             clk,
    input  wire                             reset,
    input  wire                             enable,
    input  wire                             freeze_weights,
    input  wire                             launch_pulse,

    input  wire signed [IN_WIDTH-1:0]       weight_in_top_0,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_1,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_2,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_3,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_4,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_5,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_6,
    input  wire signed [IN_WIDTH-1:0]       weight_in_top_7,

    input  wire signed [IN_WIDTH-1:0]       in_0,
    input  wire signed [IN_WIDTH-1:0]       in_1,
    input  wire signed [IN_WIDTH-1:0]       in_2,
    input  wire signed [IN_WIDTH-1:0]       in_3,
    input  wire signed [IN_WIDTH-1:0]       in_4,
    input  wire signed [IN_WIDTH-1:0]       in_5,
    input  wire signed [IN_WIDTH-1:0]       in_6,
    input  wire signed [IN_WIDTH-1:0]       in_7,

    output wire signed [OUT_WIDTH-1:0]      raw_out_0,
    output wire signed [OUT_WIDTH-1:0]      raw_out_1,
    output wire signed [OUT_WIDTH-1:0]      raw_out_2,
    output wire signed [OUT_WIDTH-1:0]      raw_out_3,
    output wire signed [OUT_WIDTH-1:0]      raw_out_4,
    output wire signed [OUT_WIDTH-1:0]      raw_out_5,
    output wire signed [OUT_WIDTH-1:0]      raw_out_6,
    output wire signed [OUT_WIDTH-1:0]      raw_out_7,

    output wire signed [OUT_WIDTH-1:0]      aligned_out_0,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_1,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_2,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_3,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_4,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_5,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_6,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_7,
    output wire                             aligned_valid
);

    wire signed [IN_WIDTH-1:0]  row_in     [0:7];
    wire signed [IN_WIDTH-1:0]  weight_top [0:7];
    wire signed [IN_WIDTH-1:0]  weight_bus [0:7][0:7];
    wire signed [IN_WIDTH-1:0]  data_bus   [0:7][0:7];
    wire signed [OUT_WIDTH-1:0] psum_bus   [0:7][0:7];

    assign row_in[0] = in_0;
    assign row_in[1] = in_1;
    assign row_in[2] = in_2;
    assign row_in[3] = in_3;
    assign row_in[4] = in_4;
    assign row_in[5] = in_5;
    assign row_in[6] = in_6;
    assign row_in[7] = in_7;

    assign weight_top[0] = weight_in_top_0;
    assign weight_top[1] = weight_in_top_1;
    assign weight_top[2] = weight_in_top_2;
    assign weight_top[3] = weight_in_top_3;
    assign weight_top[4] = weight_in_top_4;
    assign weight_top[5] = weight_in_top_5;
    assign weight_top[6] = weight_in_top_6;
    assign weight_top[7] = weight_in_top_7;

    genvar r, c;
    generate
        for (r = 0; r < 8; r = r + 1) begin : row_gen
            for (c = 0; c < 8; c = c + 1) begin : col_gen
                if ((r == 0) && (c == 0)) begin : pe_top_left
                    Processing_Element #(
                        .IN_WIDTH(IN_WIDTH),
                        .OUT_WIDTH(OUT_WIDTH)
                    ) pe_inst (
                        .clk(clk),
                        .reset(reset),
                        .freeze_weights(freeze_weights),
                        .weight_in(weight_top[c]),
                        .data_in(row_in[r]),
                        .psum_in({OUT_WIDTH{1'b0}}),
                        .weight_out(weight_bus[r][c]),
                        .data_out(data_bus[r][c]),
                        .psum_out(psum_bus[r][c])
                    );
                end else if (r == 0) begin : pe_top_row
                    Processing_Element #(
                        .IN_WIDTH(IN_WIDTH),
                        .OUT_WIDTH(OUT_WIDTH)
                    ) pe_inst (
                        .clk(clk),
                        .reset(reset),
                        .freeze_weights(freeze_weights),
                        .weight_in(weight_top[c]),
                        .data_in(data_bus[r][c-1]),
                        .psum_in({OUT_WIDTH{1'b0}}),
                        .weight_out(weight_bus[r][c]),
                        .data_out(data_bus[r][c]),
                        .psum_out(psum_bus[r][c])
                    );
                end else if (c == 0) begin : pe_left_col
                    Processing_Element #(
                        .IN_WIDTH(IN_WIDTH),
                        .OUT_WIDTH(OUT_WIDTH)
                    ) pe_inst (
                        .clk(clk),
                        .reset(reset),
                        .freeze_weights(freeze_weights),
                        .weight_in(weight_bus[r-1][c]),
                        .data_in(row_in[r]),
                        .psum_in(psum_bus[r-1][c]),
                        .weight_out(weight_bus[r][c]),
                        .data_out(data_bus[r][c]),
                        .psum_out(psum_bus[r][c])
                    );
                end else begin : pe_inner
                    Processing_Element #(
                        .IN_WIDTH(IN_WIDTH),
                        .OUT_WIDTH(OUT_WIDTH)
                    ) pe_inst (
                        .clk(clk),
                        .reset(reset),
                        .freeze_weights(freeze_weights),
                        .weight_in(weight_bus[r-1][c]),
                        .data_in(data_bus[r][c-1]),
                        .psum_in(psum_bus[r-1][c]),
                        .weight_out(weight_bus[r][c]),
                        .data_out(data_bus[r][c]),
                        .psum_out(psum_bus[r][c])
                    );
                end
            end
        end
    endgenerate

    assign raw_out_0 = psum_bus[7][0];
    assign raw_out_1 = psum_bus[7][1];
    assign raw_out_2 = psum_bus[7][2];
    assign raw_out_3 = psum_bus[7][3];
    assign raw_out_4 = psum_bus[7][4];
    assign raw_out_5 = psum_bus[7][5];
    assign raw_out_6 = psum_bus[7][6];
    assign raw_out_7 = psum_bus[7][7];

    Deskew_8x8 #(
        .OUT_WIDTH(OUT_WIDTH)
    ) deskew_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .launch_pulse(launch_pulse),
        .raw_out_0(raw_out_0),
        .raw_out_1(raw_out_1),
        .raw_out_2(raw_out_2),
        .raw_out_3(raw_out_3),
        .raw_out_4(raw_out_4),
        .raw_out_5(raw_out_5),
        .raw_out_6(raw_out_6),
        .raw_out_7(raw_out_7),
        .aligned_out_0(aligned_out_0),
        .aligned_out_1(aligned_out_1),
        .aligned_out_2(aligned_out_2),
        .aligned_out_3(aligned_out_3),
        .aligned_out_4(aligned_out_4),
        .aligned_out_5(aligned_out_5),
        .aligned_out_6(aligned_out_6),
        .aligned_out_7(aligned_out_7),
        .aligned_valid(aligned_valid)
    );

endmodule
