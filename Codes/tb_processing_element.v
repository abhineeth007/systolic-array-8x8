`timescale 1ns / 1ps

module tb_processing_element;

    reg clk;
    reg reset;
    reg freeze_weights;
    reg signed [7:0]  weight_in;
    reg signed [7:0]  data_in;
    reg signed [15:0] psum_in;

    wire signed [7:0]  weight_out;
    wire signed [7:0]  data_out;
    wire signed [15:0] psum_out;

    Processing_Element #(
        .IN_WIDTH(8),
        .OUT_WIDTH(16)
    ) dut (
        .clk(clk),
        .reset(reset),
        .freeze_weights(freeze_weights),
        .weight_in(weight_in),
        .data_in(data_in),
        .psum_in(psum_in),
        .weight_out(weight_out),
        .data_out(data_out),
        .psum_out(psum_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset          = 1'b1;
        freeze_weights = 1'b0;
        weight_in      = 8'sd0;
        data_in        = 8'sd0;
        psum_in        = 16'sd0;

        #20;
        reset = 1'b0;

        weight_in = 8'sd3;
        #10;

        freeze_weights = 1'b1;
        data_in        = 8'sd4;
        psum_in        = 16'sd2;
        #10;

        if (psum_out !== 16'sd14) begin
            $display("TB_FAIL: expected psum_out = 14, got %0d", psum_out);
            $stop;
        end

        data_in = -8'sd2;
        psum_in = 16'sd5;
        #10;

        if (psum_out !== -16'sd1) begin
            $display("TB_FAIL: expected psum_out = -1, got %0d", psum_out);
            $stop;
        end

        $display("TB_PASS: Processing_Element MAC behavior is correct.");
        $finish;
    end

    always @(posedge clk) begin
        $display("[%0t] freeze=%0b weight_in=%0d data_in=%0d psum_in=%0d | weight_out=%0d data_out=%0d psum_out=%0d",
                 $time, freeze_weights, weight_in, data_in, psum_in, weight_out, data_out, psum_out);
    end

endmodule
