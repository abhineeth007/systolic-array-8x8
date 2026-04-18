`timescale 1ns / 1ps

module tb_conv2ch2x2_systolic_array;

    parameter CLK_PERIOD = 10;

    reg clk;
    reg reset;
    reg start;

    wire signed [15:0] aligned_out_0;
    wire signed [15:0] aligned_out_1;
    wire signed [15:0] aligned_out_2;
    wire signed [15:0] aligned_out_3;
    wire signed [15:0] aligned_out_4;
    wire signed [15:0] aligned_out_5;
    wire signed [15:0] aligned_out_6;
    wire signed [15:0] aligned_out_7;
    wire               aligned_valid;
    wire               inference_done;
    wire [4:0]         dbg_read_addr;
    wire signed [7:0]  dbg_im2col_data;
    wire               dbg_im2col_valid;
    wire               dbg_launch_pulse;

    integer patch_count;
    integer addr_count;
    integer exp_out_y;
    integer exp_out_x;
    integer exp_c;
    integer exp_ky;
    integer exp_kx;
    reg signed [15:0] expected_k0 [0:7];
    reg signed [15:0] expected_k1 [0:7];

    function signed [7:0] get_kernel_value;
        input integer col;
        input integer idx;
        begin
            get_kernel_value = 8'sd0;
            case (col)
                0: begin
                    case (idx)
                        0: get_kernel_value =  8'sd1;
                        1: get_kernel_value =  8'sd0;
                        2: get_kernel_value =  8'sd0;
                        3: get_kernel_value = -8'sd1;
                        4: get_kernel_value =  8'sd1;
                        5: get_kernel_value =  8'sd1;
                        6: get_kernel_value =  8'sd0;
                        7: get_kernel_value =  8'sd0;
                    endcase
                end
                1: begin
                    case (idx)
                        0: get_kernel_value =  8'sd0;
                        1: get_kernel_value =  8'sd1;
                        2: get_kernel_value =  8'sd1;
                        3: get_kernel_value =  8'sd0;
                        4: get_kernel_value = -8'sd1;
                        5: get_kernel_value =  8'sd0;
                        6: get_kernel_value =  8'sd0;
                        7: get_kernel_value =  8'sd1;
                    endcase
                end
            endcase
        end
    endfunction

    function signed [7:0] get_tensor_value;
        input integer addr;
        begin
            case (addr)
                0:  get_tensor_value =  8'sd1;
                1:  get_tensor_value =  8'sd2;
                2:  get_tensor_value =  8'sd3;
                3:  get_tensor_value =  8'sd4;
                4:  get_tensor_value =  8'sd5;
                5:  get_tensor_value =  8'sd6;
                6:  get_tensor_value =  8'sd7;
                7:  get_tensor_value =  8'sd8;
                8:  get_tensor_value =  8'sd9;
                9:  get_tensor_value =  8'sd10;
                10: get_tensor_value =  8'sd11;
                11: get_tensor_value =  8'sd12;
                12: get_tensor_value =  8'sd13;
                13: get_tensor_value =  8'sd14;
                14: get_tensor_value =  8'sd15;
                15: get_tensor_value = -8'sd1;
                16: get_tensor_value = -8'sd2;
                17: get_tensor_value = -8'sd3;
                18: get_tensor_value = -8'sd4;
                19: get_tensor_value = -8'sd5;
                20: get_tensor_value = -8'sd6;
                21: get_tensor_value = -8'sd7;
                22: get_tensor_value = -8'sd8;
                23: get_tensor_value = -8'sd9;
                24: get_tensor_value = -8'sd10;
                25: get_tensor_value = -8'sd11;
                26: get_tensor_value = -8'sd12;
                27: get_tensor_value = -8'sd13;
                28: get_tensor_value = -8'sd14;
                29: get_tensor_value = -8'sd15;
                default: get_tensor_value = 8'sd0;
            endcase
        end
    endfunction

    function integer expected_addr;
        input integer out_y;
        input integer out_x;
        input integer c;
        input integer k_y;
        input integer k_x;
        begin
            expected_addr = (out_x + k_x) + 5 * ((out_y + k_y) + 3 * c);
        end
    endfunction

    Conv2Ch2x2_SystolicArray_Top #(
        .ACTIVE_KERNELS(2)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .aligned_out_0(aligned_out_0),
        .aligned_out_1(aligned_out_1),
        .aligned_out_2(aligned_out_2),
        .aligned_out_3(aligned_out_3),
        .aligned_out_4(aligned_out_4),
        .aligned_out_5(aligned_out_5),
        .aligned_out_6(aligned_out_6),
        .aligned_out_7(aligned_out_7),
        .aligned_valid(aligned_valid),
        .inference_done(inference_done),
        .dbg_read_addr(dbg_read_addr),
        .dbg_im2col_data(dbg_im2col_data),
        .dbg_im2col_valid(dbg_im2col_valid),
        .dbg_launch_pulse(dbg_launch_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        expected_k0[0] = -16'sd9;
        expected_k0[1] = -16'sd11;
        expected_k0[2] = -16'sd13;
        expected_k0[3] = -16'sd15;
        expected_k0[4] = -16'sd19;
        expected_k0[5] = -16'sd21;
        expected_k0[6] = -16'sd23;
        expected_k0[7] = -16'sd25;

        expected_k1[0] = 16'sd2;
        expected_k1[1] = 16'sd4;
        expected_k1[2] = 16'sd6;
        expected_k1[3] = 16'sd8;
        expected_k1[4] = 16'sd12;
        expected_k1[5] = 16'sd14;
        expected_k1[6] = 16'sd16;
        expected_k1[7] = 16'sd18;
    end

    initial begin
        reset      = 1'b1;
        start      = 1'b0;
        patch_count = 0;
        addr_count  = 0;
        exp_out_y   = 0;
        exp_out_x   = 0;
        exp_c       = 0;
        exp_ky      = 0;
        exp_kx      = 0;

        #(3 * CLK_PERIOD);
        reset = 1'b0;

        #(2 * CLK_PERIOD);
        start = 1'b1;
        #(CLK_PERIOD);
        start = 1'b0;

        wait(inference_done);
        #(5 * CLK_PERIOD);

        if (addr_count != 64) begin
            $display("TB_FAIL: expected 64 im2col reads, got %0d", addr_count);
            $stop;
        end

        if (patch_count != 8) begin
            $display("TB_FAIL: expected 8 aligned output vectors, got %0d", patch_count);
            $stop;
        end

        $display("TB_PASS: all aligned systolic-array outputs matched the expected convolution results.");
        $finish;
    end

    always @(posedge clk) begin
        if (dbg_im2col_valid) begin
            $display("[%0t] im2col addr=%0d data=%0d", $time, dbg_read_addr, dbg_im2col_data);
            if (dbg_read_addr !== expected_addr(exp_out_y, exp_out_x, exp_c, exp_ky, exp_kx)) begin
                $display("TB_FAIL: im2col address mismatch at read %0d", addr_count);
                $stop;
            end
            if (dbg_im2col_data !== get_tensor_value(expected_addr(exp_out_y, exp_out_x, exp_c, exp_ky, exp_kx))) begin
                $display("TB_FAIL: im2col data mismatch at read %0d", addr_count);
                $stop;
            end
            addr_count = addr_count + 1;

            if (exp_kx == 1) begin
                exp_kx = 0;
                if (exp_ky == 1) begin
                    exp_ky = 0;
                    if (exp_c == 1) begin
                        exp_c = 0;
                        if (exp_out_x == 3) begin
                            exp_out_x = 0;
                            if (exp_out_y == 1)
                                exp_out_y = 0;
                            else
                                exp_out_y = exp_out_y + 1;
                        end else begin
                            exp_out_x = exp_out_x + 1;
                        end
                    end else begin
                        exp_c = exp_c + 1;
                    end
                end else begin
                    exp_ky = exp_ky + 1;
                end
            end else begin
                exp_kx = exp_kx + 1;
            end
        end

        if (!reset && (dut.ctrl_state == 2'd1)) begin
            $display("[%0t] weight load cycle=%0d col0=%0d col1=%0d col2=%0d col3=%0d col4=%0d col5=%0d col6=%0d col7=%0d",
                     $time,
                     dut.load_count,
                     dut.weight_stream_0,
                     dut.weight_stream_1,
                     dut.weight_stream_2,
                     dut.weight_stream_3,
                     dut.weight_stream_4,
                     dut.weight_stream_5,
                     dut.weight_stream_6,
                     dut.weight_stream_7);

            if (dut.weight_stream_0 !== get_kernel_value(0, 7 - dut.load_count)) begin
                $display("TB_FAIL: kernel 0 load order mismatch at cycle %0d", dut.load_count);
                $stop;
            end
            if (dut.weight_stream_1 !== get_kernel_value(1, 7 - dut.load_count)) begin
                $display("TB_FAIL: kernel 1 load order mismatch at cycle %0d", dut.load_count);
                $stop;
            end
            if ((dut.weight_stream_2 !== 8'sd0) || (dut.weight_stream_3 !== 8'sd0) ||
                (dut.weight_stream_4 !== 8'sd0) || (dut.weight_stream_5 !== 8'sd0) ||
                (dut.weight_stream_6 !== 8'sd0) || (dut.weight_stream_7 !== 8'sd0)) begin
                $display("TB_FAIL: unused kernel load streams must remain zero.");
                $stop;
            end
        end

        if (dbg_launch_pulse) begin
            $display("[%0t] launch_pulse asserted for an 8-sample im2col patch", $time);
        end

        if (aligned_valid) begin
            $display("[%0t] patch=%0d out0=%0d out1=%0d out2=%0d out3=%0d out4=%0d out5=%0d out6=%0d out7=%0d",
                     $time,
                     patch_count,
                     aligned_out_0,
                     aligned_out_1,
                     aligned_out_2,
                     aligned_out_3,
                     aligned_out_4,
                     aligned_out_5,
                     aligned_out_6,
                     aligned_out_7);

            if (aligned_out_0 !== expected_k0[patch_count]) begin
                $display("TB_FAIL: kernel 0 mismatch at patch %0d", patch_count);
                $stop;
            end
            if (aligned_out_1 !== expected_k1[patch_count]) begin
                $display("TB_FAIL: kernel 1 mismatch at patch %0d", patch_count);
                $stop;
            end
            if ((aligned_out_2 !== 16'sd0) || (aligned_out_3 !== 16'sd0) ||
                (aligned_out_4 !== 16'sd0) || (aligned_out_5 !== 16'sd0) ||
                (aligned_out_6 !== 16'sd0) || (aligned_out_7 !== 16'sd0)) begin
                $display("TB_FAIL: unused kernel columns were expected to stay at zero.");
                $stop;
            end

            patch_count = patch_count + 1;
        end
    end

endmodule
