// 新平台测试程序代码
// By He Xu and FPGAOL developers
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/26 20:33:20
// Design Name: 
// Module Name: example
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module example(
    input clk,
    input [7:0] sw,
    input rxd,
    input btn,
    output [7:0] led,
    output reg [2:0] an,
    output reg [3:0] d,
    output txd
    );

reg clear =0;
reg state,state_r1,state_r2 = 0;
reg [26:0] cnt = 0;
reg [3:0] dr[7:0];
wire state_redge;
reg btn_prev;  // 用来存储上一次按钮的状态

assign led = sw;  // 当clear为1时，led为0，否则led显示sw的值
assign txd = rxd;


// 检测按钮的上升沿
always @(posedge clk) begin
    btn_prev <= btn;  // 更新上一次按钮的状态
    if (!btn_prev && btn)  // 如果上一次按钮是低，这次是高，表示检测到上升沿
        clear <= 1'b1;  // 设置清零标志
    else
        clear <= 1'b0;  // 清除清零标志
end

always@(posedge clk)
begin
  if (cnt >= 100000000)
    cnt <= 0;
  else
    cnt <= cnt + 1;
end

always@(posedge clk)
begin
    if (cnt[26:19]) state <= 1;
    else state <= 0;
    state_r1 <= state;
    state_r2 <= state_r1;
end

assign state_redge = state_r1 & (~state_r2);

always@(posedge clk)
begin
    if (clear)
    begin
        dr[0] <= 0;
        dr[1] <= 0;
        dr[2] <= 0;
        dr[3] <= 0;
        dr[4] <= 0;
        dr[5] <= 0;
        dr[6] <= 0;
        dr[7] <= 0;
    end
    else if(state_redge)
    begin
        dr[0] <= dr[0]+1;
        dr[1] <= dr[0];
        dr[2] <= dr[1];
        dr[3] <= dr[2];
        dr[4] <= dr[3];
        dr[5] <= dr[4];
        dr[6] <= dr[5];
        dr[7] <= dr[6];
    end
end

always@(posedge clk)
begin
    case(cnt[20:18])
        3'b000: begin an <= 0; d <= dr[0]; end
        3'b001: begin an <= 1; d <= dr[1]; end
        3'b010: begin an <= 2; d <= dr[2]; end
        3'b011: begin an <= 3; d <= dr[3]; end
        3'b100: begin an <= 4; d <= dr[4]; end
        3'b101: begin an <= 5; d <= dr[5]; end
        3'b110: begin an <= 6; d <= dr[6]; end
        3'b111: begin an <= 7; d <= dr[7]; end
    endcase
end

endmodule

