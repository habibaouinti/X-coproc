`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2019 10:06:59
// Design Name: 
// Module Name: dual_port_tcm_ram
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


module dual_port_tcm_ram
#(
    parameter start_address = 32'h0,
    parameter size = 4096
)
(
    input aclk,
    input aresetn,
    
    input  wire [31:0] address_a,
    input  wire        request_a,
    output reg [31:0]  read_data_a,
    output wire        grant_a,
    output reg         valid_a,
    
    input  wire [31:0] address_b,
    input  wire        request_b,
    input  wire        write_enable_b,
    input  wire[3:0]   write_byte_enable_b,
    input  wire[31:0]  write_data_b,
    output reg [31:0]  read_data_b,
    output wire        grant_b,
    output reg         valid_b
);
    localparam address_width = $clog2(size);
    reg [31:0] data[size/4-1:0];
    
    wire        valid_address_a = (address_a >= start_address) && (address_a < start_address + size);
    wire [address_width-3:0] aligned_address_a = address_a[address_width-1:2];
    assign      grant_a = request_a && valid_address_a;
    
    wire        valid_address_b = (address_b >= start_address) && (address_b < start_address + size);
    wire [address_width-3:0] aligned_address_b = address_b[address_width-1:2];
    assign      grant_b = request_b && valid_address_b;
    
    always_ff @(posedge aclk, negedge aresetn)
    begin
    	  if(aresetn == 0)
    		    valid_a <= 0;
    	  else
            valid_a <= grant_a && valid_address_a;
    end
    
    always_ff @(posedge aclk, negedge aresetn)
    begin
    	  if(aresetn == 0)
    		    valid_b <= 0;
    	  else
            valid_b <= grant_b && valid_address_b;
    end
    
    always_ff @(posedge aclk)
    begin
        if(valid_address_a)
            read_data_a <= data[aligned_address_a];
    end
    
    always @(posedge aclk)
    begin
        if(valid_address_b && !write_enable_b)
            read_data_b <= data[aligned_address_b];
        
        if(valid_address_b && write_enable_b)
        begin
            if(write_byte_enable_b[3])
                data[aligned_address_b][31:24] <= write_data_b[31:24];
            if(write_byte_enable_b[2])
                data[aligned_address_b][23:16] <= write_data_b[23:16];
            if(write_byte_enable_b[1])
                data[aligned_address_b][15:8] <= write_data_b[15:8];
            if(write_byte_enable_b[0])
                data[aligned_address_b][7:0] <= write_data_b[7:0];
        end
    end
endmodule
