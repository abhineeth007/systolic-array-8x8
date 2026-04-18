`timescale 1ns / 1ps

module tb_im2col_addr_gen;

    reg clk;
    reg rst_n;
    reg start;

    wire [4:0] read_addr;
    wire       valid;
    wire       done;

    integer count;

    im2col_addr_gen #(
        .C(2),
        .IN_H(3),
        .IN_W(5),
        .K(2),
        .STRIDE(1),
        .OUT_H(2),
        .OUT_W(4),
        .ADDR_WIDTH(5)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .read_addr(read_addr),
        .valid(valid),
        .done(done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        count = 0;

        #20;
        rst_n = 1'b1;

        #10;
        start = 1'b1;
        #10;
        start = 1'b0;

        wait(done);
        #20;

        if (count == 64)
            $display("TB_PASS: got all 64 im2col addresses");
        else
            $display("TB_FAIL: expected 64 addresses, got %0d", count);

        $finish;
    end

    always @(posedge clk) begin
        if (valid) begin
            count = count + 1;
            $display("count=%0d addr=%0d", count, read_addr);
        end

        if (done) begin
            $display("im2col generation done");
        end
    end

endmodule
