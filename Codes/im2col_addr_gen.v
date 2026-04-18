`timescale 1ns / 1ps

module im2col_addr_gen #(
    parameter C = 2,
    parameter IN_H = 3,
    parameter IN_W = 5,
    parameter K = 2,
    parameter STRIDE = 1,
    parameter OUT_H = 2,
    parameter OUT_W = 4,
    parameter ADDR_WIDTH = 5
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    output reg  [ADDR_WIDTH-1:0] read_addr,
    output reg                   valid,
    output reg                   done
);

    localparam CW     = (C > 1)     ? $clog2(C)     : 1;
    localparam OH_W   = (OUT_H > 1) ? $clog2(OUT_H) : 1;
    localparam OW_W   = (OUT_W > 1) ? $clog2(OUT_W) : 1;
    localparam K_W    = (K > 1)     ? $clog2(K)     : 1;
    localparam IN_Y_W = $clog2(IN_H + K);
    localparam IN_X_W = $clog2(IN_W + K);

    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam LAST = 2'b10;

    reg [1:0] state, next_state;
    reg [OH_W-1:0] out_y;
    reg [OW_W-1:0] out_x;
    reg [CW-1:0]   c;
    reg [K_W-1:0]  k_y;
    reg [K_W-1:0]  k_x;

    wire [IN_Y_W-1:0] in_y = (STRIDE == 1) ? (out_y + k_y) : ((out_y * STRIDE) + k_y);
    wire [IN_X_W-1:0] in_x = (STRIDE == 1) ? (out_x + k_x) : ((out_x * STRIDE) + k_x);
    wire [ADDR_WIDTH-1:0] calc_addr = in_x + IN_W * (in_y + IN_H * c);

    wire max_reached = (out_y == OUT_H-1) &&
                       (out_x == OUT_W-1) &&
                       (c == C-1) &&
                       (k_y == K-1) &&
                       (k_x == K-1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (start)       next_state = RUN;
            RUN:  if (max_reached) next_state = LAST;
            LAST:                  next_state = IDLE;
            default:               next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_y     <= {OH_W{1'b0}};
            out_x     <= {OW_W{1'b0}};
            c         <= {CW{1'b0}};
            k_y       <= {K_W{1'b0}};
            k_x       <= {K_W{1'b0}};
            read_addr <= {ADDR_WIDTH{1'b0}};
            valid     <= 1'b0;
            done      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    out_y <= {OH_W{1'b0}};
                    out_x <= {OW_W{1'b0}};
                    c     <= {CW{1'b0}};
                    k_y   <= {K_W{1'b0}};
                    k_x   <= {K_W{1'b0}};
                    valid <= 1'b0;
                    done  <= 1'b0;
                end

                RUN: begin
                    read_addr <= calc_addr;
                    valid     <= 1'b1;
                    done      <= 1'b0;

                    if (!max_reached) begin
                        if (k_x == K-1) begin
                            k_x <= {K_W{1'b0}};
                            if (k_y == K-1) begin
                                k_y <= {K_W{1'b0}};
                                if (c == C-1) begin
                                    c <= {CW{1'b0}};
                                    if (out_x == OUT_W-1) begin
                                        out_x <= {OW_W{1'b0}};
                                        if (out_y != OUT_H-1)
                                            out_y <= out_y + 1'b1;
                                    end else begin
                                        out_x <= out_x + 1'b1;
                                    end
                                end else begin
                                    c <= c + 1'b1;
                                end
                            end else begin
                                k_y <= k_y + 1'b1;
                            end
                        end else begin
                            k_x <= k_x + 1'b1;
                        end
                    end
                end

                LAST: begin
                    out_y <= {OH_W{1'b0}};
                    out_x <= {OW_W{1'b0}};
                    c     <= {CW{1'b0}};
                    k_y   <= {K_W{1'b0}};
                    k_x   <= {K_W{1'b0}};
                    valid <= 1'b0;
                    done  <= 1'b1;
                end

                default: begin
                    valid <= 1'b0;
                    done  <= 1'b0;
                end
            endcase
        end
    end

endmodule
