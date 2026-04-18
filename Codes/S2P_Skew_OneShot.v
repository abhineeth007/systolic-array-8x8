`timescale 1ns / 1ps

module S2P_Skew_OneShot #(
    parameter IN_WIDTH = 8
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    capture_enable,
    input  wire                    shift_enable,
    input  wire signed [IN_WIDTH-1:0] serial_in,

    output reg                     launch_pulse,
    output reg signed [IN_WIDTH-1:0] skew_out_0,
    output reg signed [IN_WIDTH-1:0] skew_out_1,
    output reg signed [IN_WIDTH-1:0] skew_out_2,
    output reg signed [IN_WIDTH-1:0] skew_out_3,
    output reg signed [IN_WIDTH-1:0] skew_out_4,
    output reg signed [IN_WIDTH-1:0] skew_out_5,
    output reg signed [IN_WIDTH-1:0] skew_out_6,
    output reg signed [IN_WIDTH-1:0] skew_out_7
);

    integer i;

    reg [2:0] counter;
    reg signed [IN_WIDTH-1:0] s2p_reg [0:7];

    reg signed [IN_WIDTH-1:0] delay_row1 [0:0];
    reg signed [IN_WIDTH-1:0] delay_row2 [0:1];
    reg signed [IN_WIDTH-1:0] delay_row3 [0:2];
    reg signed [IN_WIDTH-1:0] delay_row4 [0:3];
    reg signed [IN_WIDTH-1:0] delay_row5 [0:4];
    reg signed [IN_WIDTH-1:0] delay_row6 [0:5];
    reg signed [IN_WIDTH-1:0] delay_row7 [0:6];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter      <= 3'd0;
            launch_pulse <= 1'b0;

            skew_out_0 <= {IN_WIDTH{1'b0}};
            skew_out_1 <= {IN_WIDTH{1'b0}};
            skew_out_2 <= {IN_WIDTH{1'b0}};
            skew_out_3 <= {IN_WIDTH{1'b0}};
            skew_out_4 <= {IN_WIDTH{1'b0}};
            skew_out_5 <= {IN_WIDTH{1'b0}};
            skew_out_6 <= {IN_WIDTH{1'b0}};
            skew_out_7 <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 8; i = i + 1) begin
                s2p_reg[i] <= {IN_WIDTH{1'b0}};
            end

            delay_row1[0] <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 2; i = i + 1)
                delay_row2[i] <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 3; i = i + 1)
                delay_row3[i] <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 4; i = i + 1)
                delay_row4[i] <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 5; i = i + 1)
                delay_row5[i] <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 6; i = i + 1)
                delay_row6[i] <= {IN_WIDTH{1'b0}};

            for (i = 0; i < 7; i = i + 1)
                delay_row7[i] <= {IN_WIDTH{1'b0}};
        end else if (shift_enable) begin
            launch_pulse     <= 1'b0;

            if (capture_enable) begin
                s2p_reg[counter] <= serial_in;
            end

            if (capture_enable && (counter == 3'd7)) begin
                launch_pulse <= 1'b1;
                counter      <= 3'd0;

                skew_out_0 <= s2p_reg[0];

                delay_row1[0] <= s2p_reg[1];
                skew_out_1    <= delay_row1[0];

                delay_row2[0] <= s2p_reg[2];
                delay_row2[1] <= delay_row2[0];
                skew_out_2    <= delay_row2[1];

                delay_row3[0] <= s2p_reg[3];
                delay_row3[1] <= delay_row3[0];
                delay_row3[2] <= delay_row3[1];
                skew_out_3    <= delay_row3[2];

                delay_row4[0] <= s2p_reg[4];
                delay_row4[1] <= delay_row4[0];
                delay_row4[2] <= delay_row4[1];
                delay_row4[3] <= delay_row4[2];
                skew_out_4    <= delay_row4[3];

                delay_row5[0] <= s2p_reg[5];
                delay_row5[1] <= delay_row5[0];
                delay_row5[2] <= delay_row5[1];
                delay_row5[3] <= delay_row5[2];
                delay_row5[4] <= delay_row5[3];
                skew_out_5    <= delay_row5[4];

                delay_row6[0] <= s2p_reg[6];
                delay_row6[1] <= delay_row6[0];
                delay_row6[2] <= delay_row6[1];
                delay_row6[3] <= delay_row6[2];
                delay_row6[4] <= delay_row6[3];
                delay_row6[5] <= delay_row6[4];
                skew_out_6    <= delay_row6[5];

                delay_row7[0] <= serial_in;
                delay_row7[1] <= delay_row7[0];
                delay_row7[2] <= delay_row7[1];
                delay_row7[3] <= delay_row7[2];
                delay_row7[4] <= delay_row7[3];
                delay_row7[5] <= delay_row7[4];
                delay_row7[6] <= delay_row7[5];
                skew_out_7    <= delay_row7[6];
            end else begin
                if (capture_enable) begin
                    counter <= counter + 3'd1;
                end

                skew_out_0 <= {IN_WIDTH{1'b0}};

                delay_row1[0] <= {IN_WIDTH{1'b0}};
                skew_out_1    <= delay_row1[0];

                delay_row2[0] <= {IN_WIDTH{1'b0}};
                delay_row2[1] <= delay_row2[0];
                skew_out_2    <= delay_row2[1];

                delay_row3[0] <= {IN_WIDTH{1'b0}};
                delay_row3[1] <= delay_row3[0];
                delay_row3[2] <= delay_row3[1];
                skew_out_3    <= delay_row3[2];

                delay_row4[0] <= {IN_WIDTH{1'b0}};
                delay_row4[1] <= delay_row4[0];
                delay_row4[2] <= delay_row4[1];
                delay_row4[3] <= delay_row4[2];
                skew_out_4    <= delay_row4[3];

                delay_row5[0] <= {IN_WIDTH{1'b0}};
                delay_row5[1] <= delay_row5[0];
                delay_row5[2] <= delay_row5[1];
                delay_row5[3] <= delay_row5[2];
                delay_row5[4] <= delay_row5[3];
                skew_out_5    <= delay_row5[4];

                delay_row6[0] <= {IN_WIDTH{1'b0}};
                delay_row6[1] <= delay_row6[0];
                delay_row6[2] <= delay_row6[1];
                delay_row6[3] <= delay_row6[2];
                delay_row6[4] <= delay_row6[3];
                delay_row6[5] <= delay_row6[4];
                skew_out_6    <= delay_row6[5];

                delay_row7[0] <= {IN_WIDTH{1'b0}};
                delay_row7[1] <= delay_row7[0];
                delay_row7[2] <= delay_row7[1];
                delay_row7[3] <= delay_row7[2];
                delay_row7[4] <= delay_row7[3];
                delay_row7[5] <= delay_row7[4];
                delay_row7[6] <= delay_row7[5];
                skew_out_7    <= delay_row7[6];
            end
        end else begin
            launch_pulse <= 1'b0;
        end
    end

endmodule
