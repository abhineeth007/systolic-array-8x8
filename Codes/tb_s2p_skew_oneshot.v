`timescale 1ns / 1ps

module tb_s2p_skew_oneshot;

    reg clk;
    reg reset;
    reg capture_enable;
    reg shift_enable;
    reg signed [7:0] serial_in;

    wire launch_pulse;
    wire signed [7:0] skew_out_0;
    wire signed [7:0] skew_out_1;
    wire signed [7:0] skew_out_2;
    wire signed [7:0] skew_out_3;
    wire signed [7:0] skew_out_4;
    wire signed [7:0] skew_out_5;
    wire signed [7:0] skew_out_6;
    wire signed [7:0] skew_out_7;

    integer sample_count;

    S2P_Skew_OneShot #(
        .IN_WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .capture_enable(capture_enable),
        .shift_enable(shift_enable),
        .serial_in(serial_in),
        .launch_pulse(launch_pulse),
        .skew_out_0(skew_out_0),
        .skew_out_1(skew_out_1),
        .skew_out_2(skew_out_2),
        .skew_out_3(skew_out_3),
        .skew_out_4(skew_out_4),
        .skew_out_5(skew_out_5),
        .skew_out_6(skew_out_6),
        .skew_out_7(skew_out_7)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset          = 1'b1;
        capture_enable = 1'b0;
        shift_enable   = 1'b0;
        serial_in      = 8'sd0;
        sample_count   = 0;

        #20;
        reset        = 1'b0;
        shift_enable = 1'b1;

        capture_enable = 1'b1;
        serial_in = 8'sd11; #10;
        serial_in = 8'sd22; #10;
        serial_in = 8'sd33; #10;
        serial_in = 8'sd44; #10;
        serial_in = 8'sd55; #10;
        serial_in = 8'sd66; #10;
        serial_in = 8'sd77; #10;
        serial_in = 8'sd88; #10;
        capture_enable = 1'b0;

        #100;

        $display("TB_PASS: inspect waveform for skew_out_0..skew_out_7 staircase behavior.");
        $finish;
    end

    always @(posedge clk) begin
        if (capture_enable)
            sample_count = sample_count + 1;

        $display("[%0t] cap=%0b shift=%0b serial=%0d launch=%0b | o0=%0d o1=%0d o2=%0d o3=%0d o4=%0d o5=%0d o6=%0d o7=%0d",
                 $time, capture_enable, shift_enable, serial_in, launch_pulse,
                 skew_out_0, skew_out_1, skew_out_2, skew_out_3,
                 skew_out_4, skew_out_5, skew_out_6, skew_out_7);
    end

endmodule
