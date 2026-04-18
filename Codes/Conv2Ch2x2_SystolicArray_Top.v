`timescale 1ns / 1ps

module Conv2Ch2x2_SystolicArray_Top #(
    parameter IN_WIDTH       = 8,
    parameter OUT_WIDTH      = 16,
    parameter ADDR_WIDTH     = 5,
    parameter ACTIVE_KERNELS = 2
)(
    input  wire                             clk,
    input  wire                             reset,
    input  wire                             start,

    output wire signed [OUT_WIDTH-1:0]      aligned_out_0,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_1,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_2,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_3,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_4,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_5,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_6,
    output wire signed [OUT_WIDTH-1:0]      aligned_out_7,
    output wire                             aligned_valid,
    output wire                             inference_done,

    output wire [ADDR_WIDTH-1:0]            dbg_read_addr,
    output wire signed [IN_WIDTH-1:0]       dbg_im2col_data,
    output wire                             dbg_im2col_valid,
    output wire                             dbg_launch_pulse
);

    localparam CTRL_IDLE = 2'd0;
    localparam CTRL_LOAD = 2'd1;
    localparam CTRL_RUN  = 2'd2;
    localparam CTRL_WAIT = 2'd3;
    localparam KERNEL_COUNT = (ACTIVE_KERNELS > 8) ? 8 : ACTIVE_KERNELS;

    reg  [1:0] ctrl_state;
    reg  [2:0] load_count;
    reg  [4:0] drain_count;
    reg        im2col_start;
    reg        inference_done_r;

    wire       freeze_weights;
    wire       shift_enable;

    reg signed [IN_WIDTH-1:0] tensor_data;
    reg signed [IN_WIDTH-1:0] weight_stream_0;
    reg signed [IN_WIDTH-1:0] weight_stream_1;
    reg signed [IN_WIDTH-1:0] weight_stream_2;
    reg signed [IN_WIDTH-1:0] weight_stream_3;
    reg signed [IN_WIDTH-1:0] weight_stream_4;
    reg signed [IN_WIDTH-1:0] weight_stream_5;
    reg signed [IN_WIDTH-1:0] weight_stream_6;
    reg signed [IN_WIDTH-1:0] weight_stream_7;

    wire [ADDR_WIDTH-1:0]      read_addr;
    wire                       im2col_valid;
    wire                       im2col_done;
    wire                       launch_pulse;

    wire signed [IN_WIDTH-1:0] skew_out_0;
    wire signed [IN_WIDTH-1:0] skew_out_1;
    wire signed [IN_WIDTH-1:0] skew_out_2;
    wire signed [IN_WIDTH-1:0] skew_out_3;
    wire signed [IN_WIDTH-1:0] skew_out_4;
    wire signed [IN_WIDTH-1:0] skew_out_5;
    wire signed [IN_WIDTH-1:0] skew_out_6;
    wire signed [IN_WIDTH-1:0] skew_out_7;

    wire signed [OUT_WIDTH-1:0] raw_out_0;
    wire signed [OUT_WIDTH-1:0] raw_out_1;
    wire signed [OUT_WIDTH-1:0] raw_out_2;
    wire signed [OUT_WIDTH-1:0] raw_out_3;
    wire signed [OUT_WIDTH-1:0] raw_out_4;
    wire signed [OUT_WIDTH-1:0] raw_out_5;
    wire signed [OUT_WIDTH-1:0] raw_out_6;
    wire signed [OUT_WIDTH-1:0] raw_out_7;

    function signed [IN_WIDTH-1:0] get_kernel_value;
        input integer col;
        input integer idx;
        begin
            get_kernel_value = {IN_WIDTH{1'b0}};
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

    function signed [IN_WIDTH-1:0] get_tensor_value;
        input [ADDR_WIDTH-1:0] addr;
        begin
            case (addr)
                5'd0:  get_tensor_value =  8'sd1;
                5'd1:  get_tensor_value =  8'sd2;
                5'd2:  get_tensor_value =  8'sd3;
                5'd3:  get_tensor_value =  8'sd4;
                5'd4:  get_tensor_value =  8'sd5;
                5'd5:  get_tensor_value =  8'sd6;
                5'd6:  get_tensor_value =  8'sd7;
                5'd7:  get_tensor_value =  8'sd8;
                5'd8:  get_tensor_value =  8'sd9;
                5'd9:  get_tensor_value =  8'sd10;
                5'd10: get_tensor_value =  8'sd11;
                5'd11: get_tensor_value =  8'sd12;
                5'd12: get_tensor_value =  8'sd13;
                5'd13: get_tensor_value =  8'sd14;
                5'd14: get_tensor_value =  8'sd15;
                5'd15: get_tensor_value = -8'sd1;
                5'd16: get_tensor_value = -8'sd2;
                5'd17: get_tensor_value = -8'sd3;
                5'd18: get_tensor_value = -8'sd4;
                5'd19: get_tensor_value = -8'sd5;
                5'd20: get_tensor_value = -8'sd6;
                5'd21: get_tensor_value = -8'sd7;
                5'd22: get_tensor_value = -8'sd8;
                5'd23: get_tensor_value = -8'sd9;
                5'd24: get_tensor_value = -8'sd10;
                5'd25: get_tensor_value = -8'sd11;
                5'd26: get_tensor_value = -8'sd12;
                5'd27: get_tensor_value = -8'sd13;
                5'd28: get_tensor_value = -8'sd14;
                5'd29: get_tensor_value = -8'sd15;
                default: get_tensor_value = {IN_WIDTH{1'b0}};
            endcase
        end
    endfunction

    assign freeze_weights = (ctrl_state != CTRL_LOAD);
    assign shift_enable   = (ctrl_state == CTRL_RUN) || (ctrl_state == CTRL_WAIT);
    assign inference_done = inference_done_r;
    assign dbg_read_addr  = read_addr;
    assign dbg_im2col_data = tensor_data;
    assign dbg_im2col_valid = im2col_valid;
    assign dbg_launch_pulse = launch_pulse;

    always @(*) begin
        tensor_data = get_tensor_value(read_addr);
    end

    always @(*) begin
        weight_stream_0 = (KERNEL_COUNT > 0) ? get_kernel_value(0, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_1 = (KERNEL_COUNT > 1) ? get_kernel_value(1, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_2 = (KERNEL_COUNT > 2) ? get_kernel_value(2, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_3 = (KERNEL_COUNT > 3) ? get_kernel_value(3, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_4 = (KERNEL_COUNT > 4) ? get_kernel_value(4, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_5 = (KERNEL_COUNT > 5) ? get_kernel_value(5, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_6 = (KERNEL_COUNT > 6) ? get_kernel_value(6, 7 - load_count) : {IN_WIDTH{1'b0}};
        weight_stream_7 = (KERNEL_COUNT > 7) ? get_kernel_value(7, 7 - load_count) : {IN_WIDTH{1'b0}};
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ctrl_state      <= CTRL_IDLE;
            load_count      <= 3'd0;
            drain_count     <= 5'd0;
            im2col_start    <= 1'b0;
            inference_done_r <= 1'b0;
        end else begin
            im2col_start     <= 1'b0;
            inference_done_r <= 1'b0;

            case (ctrl_state)
                CTRL_IDLE: begin
                    load_count  <= 3'd0;
                    drain_count <= 5'd0;
                    if (start)
                        ctrl_state <= CTRL_LOAD;
                end

                CTRL_LOAD: begin
                    if (load_count == 3'd7) begin
                        load_count   <= 3'd0;
                        im2col_start <= 1'b1;
                        ctrl_state   <= CTRL_RUN;
                    end else begin
                        load_count <= load_count + 1'b1;
                    end
                end

                CTRL_RUN: begin
                    if (im2col_done) begin
                        drain_count <= 5'd16;
                        ctrl_state  <= CTRL_WAIT;
                    end
                end

                CTRL_WAIT: begin
                    if (drain_count == 5'd0) begin
                        inference_done_r <= 1'b1;
                        ctrl_state       <= CTRL_IDLE;
                    end else begin
                        drain_count <= drain_count - 1'b1;
                    end
                end

                default: begin
                    ctrl_state <= CTRL_IDLE;
                end
            endcase
        end
    end

    im2col_addr_gen #(
        .C(2),
        .IN_H(3),
        .IN_W(5),
        .K(2),
        .STRIDE(1),
        .OUT_H(2),
        .OUT_W(4),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) addr_gen_inst (
        .clk(clk),
        .rst_n(~reset),
        .start(im2col_start),
        .read_addr(read_addr),
        .valid(im2col_valid),
        .done(im2col_done)
    );

    S2P_Skew_OneShot #(
        .IN_WIDTH(IN_WIDTH)
    ) s2p_skew_inst (
        .clk(clk),
        .reset(reset),
        .capture_enable(im2col_valid),
        .shift_enable(shift_enable),
        .serial_in(tensor_data),
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

    Systolic_Array_8x8 #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) systolic_array_inst (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .freeze_weights(freeze_weights),
        .launch_pulse(launch_pulse),
        .weight_in_top_0(weight_stream_0),
        .weight_in_top_1(weight_stream_1),
        .weight_in_top_2(weight_stream_2),
        .weight_in_top_3(weight_stream_3),
        .weight_in_top_4(weight_stream_4),
        .weight_in_top_5(weight_stream_5),
        .weight_in_top_6(weight_stream_6),
        .weight_in_top_7(weight_stream_7),
        .in_0(skew_out_0),
        .in_1(skew_out_1),
        .in_2(skew_out_2),
        .in_3(skew_out_3),
        .in_4(skew_out_4),
        .in_5(skew_out_5),
        .in_6(skew_out_6),
        .in_7(skew_out_7),
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
