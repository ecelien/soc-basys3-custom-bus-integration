//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: MedianFilter_tb
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

module apb_wrapper_median_filter #(
parameter BUS_WIDTH = 32
) (
    // Global Signals
    input                     S_CLK,
    input                     S_RSTN, 

    // APB4 Interface
    input                      S_PSEL,
    input                      S_PENABLE,
    input      [31:0]          S_PADDR,
    input                      S_PWRITE,
    input      [BUS_WIDTH-1:0] S_PWDATA,
    output reg                 S_PREADY,
    output reg                 S_PSLVERR,
    output reg [BUS_WIDTH-1:0] S_PRDATA
);

    // --- Address Map Definition ---
    localparam ADDR_INPUT_DATA  = 8'h00;
    localparam ADDR_SORTED_DATA = 8'h04;
    localparam ADDR_MEDIAN_VAL  = 8'h08;

    // --- Internal Registers ---
    reg [BUS_WIDTH-1:0]  input_data_reg;
    wire [BUS_WIDTH-1:0] sorted_bus_wire;
    wire [3:0]            median_val_wire;

    // --- APB Control Signals ---
    wire apb_active = S_PSEL && S_PENABLE;
    wire [7:0] addr = S_PADDR[7:0];

    // --- Median Filter Instance ---
    MedianFilter #(
        .NUM_VALS(8),
        .SIZE(4)
    ) MF_0 (
        .clk(S_CLK),
        .input_data(input_data_reg),     
        .output_data(sorted_bus_wire),
        .mid(median_val_wire)
    );

    always @(posedge S_CLK or negedge S_RSTN) begin
        if (!S_RSTN) begin
            input_data_reg <= 32'h0;
            S_PREADY       <= 1'b0;
            S_PSLVERR      <= 1'b0;
            S_PRDATA       <= 32'h0;
        end else begin
            
            S_PREADY  <= S_PSEL & S_PENABLE; 
            S_PSLVERR <= 1'b0;

            if (S_PSEL && !S_PENABLE) begin
                // Setup Phase: Prepare for data
            end else if (apb_active) begin
                // Access Phase
                if (S_PWRITE) begin
                    if (addr == ADDR_INPUT_DATA) input_data_reg <= S_PWDATA;
                    else S_PSLVERR <= 1'b1; // Write to RO address
                end else begin
                    case (addr)
                        ADDR_INPUT_DATA:  S_PRDATA <= input_data_reg;
                        ADDR_SORTED_DATA: S_PRDATA <= sorted_bus_wire;
                        ADDR_MEDIAN_VAL:  S_PRDATA <= {28'h0, median_val_wire};
                        default:          S_PSLVERR <= 1'b1;
                    endcase
                end
            end
        end
    end

endmodule
