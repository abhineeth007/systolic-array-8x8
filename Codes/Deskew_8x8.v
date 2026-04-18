`timescale 1ns / 1ps

module Deskew_8x8 #(
    parameter OUT_WIDTH = 16
)(
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           enable,
    input  wire                           launch_pulse,

    input  wire signed [OUT_WIDTH-1:0]    raw_out_0,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_1,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_2,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_3,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_4,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_5,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_6,
    input  wire signed [OUT_WIDTH-1:0]    raw_out_7,

    output reg  signed [OUT_WIDTH-1:0]    aligned_out_0,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_1,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_2,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_3,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_4,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_5,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_6,
    output reg  signed [OUT_WIDTH-1:0]    aligned_out_7,
    output wire                           aligned_valid
);

    integer i;
    reg [15:0] valid_pipe;

    reg signed [OUT_WIDTH-1:0] delay_c0 [0:6];
    reg signed [OUT_WIDTH-1:0] delay_c1 [0:5];
    reg signed [OUT_WIDTH-1:0] delay_c2 [0:4];
    reg signed [OUT_WIDTH-1:0] delay_c3 [0:3];
    reg signed [OUT_WIDTH-1:0] delay_c4 [0:2];
    reg signed [OUT_WIDTH-1:0] delay_c5 [0:1];
    reg signed [OUT_WIDTH-1:0] delay_c6 [0:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_pipe <= 16'd0;

            aligned_out_0 <= {OUT_WIDTH{1'b0}};
            aligned_out_1 <= {OUT_WIDTH{1'b0}};
            aligned_out_2 <= {OUT_WIDTH{1'b0}};
            aligned_out_3 <= {OUT_WIDTH{1'b0}};
            aligned_out_4 <= {OUT_WIDTH{1'b0}};
            aligned_out_5 <= {OUT_WIDTH{1'b0}};
            aligned_out_6 <= {OUT_WIDTH{1'b0}};
            aligned_out_7 <= {OUT_WIDTH{1'b0}};

            for (i = 0; i < 7; i = i + 1)
                delay_c0[i] <= {OUT_WIDTH{1'b0}};

            for (i = 0; i < 6; i = i + 1)
                delay_c1[i] <= {OUT_WIDTH{1'b0}};

            for (i = 0; i < 5; i = i + 1)
                delay_c2[i] <= {OUT_WIDTH{1'b0}};

            for (i = 0; i < 4; i = i + 1)
                delay_c3[i] <= {OUT_WIDTH{1'b0}};

            for (i = 0; i < 3; i = i + 1)
                delay_c4[i] <= {OUT_WIDTH{1'b0}};

            for (i = 0; i < 2; i = i + 1)
                delay_c5[i] <= {OUT_WIDTH{1'b0}};

            delay_c6[0] <= {OUT_WIDTH{1'b0}};
        end else if (enable) begin
            valid_pipe <= {valid_pipe[14:0], launch_pulse};

            delay_c0[0] <= raw_out_0;
            for (i = 1; i < 7; i = i + 1)
                delay_c0[i] <= delay_c0[i-1];
            aligned_out_0 <= delay_c0[6];

            delay_c1[0] <= raw_out_1;
            for (i = 1; i < 6; i = i + 1)
                delay_c1[i] <= delay_c1[i-1];
            aligned_out_1 <= delay_c1[5];

            delay_c2[0] <= raw_out_2;
            for (i = 1; i < 5; i = i + 1)
                delay_c2[i] <= delay_c2[i-1];
            aligned_out_2 <= delay_c2[4];

            delay_c3[0] <= raw_out_3;
            for (i = 1; i < 4; i = i + 1)
                delay_c3[i] <= delay_c3[i-1];
            aligned_out_3 <= delay_c3[3];

            delay_c4[0] <= raw_out_4;
            for (i = 1; i < 3; i = i + 1)
                delay_c4[i] <= delay_c4[i-1];
            aligned_out_4 <= delay_c4[2];

            delay_c5[0] <= raw_out_5;
            delay_c5[1] <= delay_c5[0];
            aligned_out_5 <= delay_c5[1];

            delay_c6[0] <= raw_out_6;
            aligned_out_6 <= delay_c6[0];

            aligned_out_7 <= raw_out_7;
        end
    end

    assign aligned_valid = valid_pipe[15];

endmodule
