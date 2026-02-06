//`timescale 1ns / 1ps

module apb_wrapper_rsa#
(
    parameter BUS_WIDTH = 32,
    parameter ADDR_OFFSET= 'h00000000
)
(
    // Global Signals
    input S_CLK,
    input S_RST,
    
    // Interface to APB bridge
    input S_PSEL,
    input S_PENABLE,
    input [31:0] S_PADDR,
    input S_PWRITE,
    input [31:0] S_PWDATA,
    output reg  S_PREADY,
    output reg  S_PSLVERR,
    output reg [31:0] S_PRDATA
);
 
    // IDK much about this, but if it works thats great.
    wire apb_write;
    wire apb_read;
    wire [7:0] addr_index;
    assign apb_write = S_PSEL & S_PENABLE & S_PWRITE;
    assign apb_read = S_PSEL & S_PENABLE & ~S_PWRITE;
    assign addr_index = S_PADDR[7:0];
    
    // Global Signals
    wire reset;
    assign reset = !S_RST; // Since APB reset is !reset.
    
    wire clk;
    assign clk = S_CLK;
    
    // Input registers. 
    // The seperation of reg and the wire here is redundant for where they are directly connected, but helped me logically organize things in my head.
    reg [127:0] indata_reg;
    wire [127:0] indata;
    assign indata = indata_reg;
    
    reg [127:0] inExp_reg;
    wire [127:0] inExp;
    assign inExp = inExp_reg;
    
    reg [127:0] inMod_reg;
    wire [127:0] inMod;
    assign inMod = inMod_reg;
    
    reg [31:0] ds_reg;
    wire [31:0] ds; // LSB is the one read by RSA.
    assign ds = ds_reg;
    
    // Output registers
    // Im just going to make everything a register so I know what to expect.
    // It is likely best to just have these be wires to the RSA outputs, and read from those wires.
    reg [127:0] cypher_reg;
    wire [127:0] cypher; // Connected to RSA
    
    reg [31:0] ready_reg;
    wire [31:0] ready; // 0th bit is connected to RSA, 31 MSB's go to 0.
    assign ready[31:1] = 31'h0;
    
    // Instantiate the RSA IP
    RSACypher #(.KEYSIZE(128)) RSA (.indata(indata),.inExp(inExp),.inMod(inMod),.cypher(cypher),.clk(clk),.ds(ds[0]),.reset(reset),.ready(ready[0]));
    
    // Register Read/Write
    always@(posedge S_CLK)
    begin
        if (!S_RST) 
        begin
            // APB Signals
            S_PREADY  <= 1'b0;
            S_PSLVERR <= 1'b0;
            S_PRDATA  <= 32'h0;
            
            // Reset Input Registers
            indata_reg <= 128'h0;
            inExp_reg <= 128'h0;
            inMod_reg <= 128'h0;
            ds_reg <= 32'h0;
            
            // Reset Output Registers
            // RSA is reset by the reset signal directly.
            cypher_reg <= 128'h0;
            ready_reg <= 32'h0;
            
        end else
        begin
            // Update Output Registers
            ready_reg <= ready;
            cypher_reg <= cypher;
            
            // Stall signal
            S_PREADY  <= 1'b0;
      
            // Error Signal
            S_PSLVERR <= 1'b0;
            
            if (apb_write) 
            begin
                // Set ready high
                S_PREADY <= 1'b1;
                case (addr_index)
                    // Write indata
                    8'h00: indata_reg[31:0]         <= S_PWDATA;
                    8'h04: indata_reg[63:32]        <= S_PWDATA;
                    8'h08: indata_reg[95:64]        <= S_PWDATA;
                    8'h0C: indata_reg[127:96]       <= S_PWDATA;
                    
                    // Write inExp
                    8'h10: inExp_reg[31:0]          <= S_PWDATA;
                    8'h14: inExp_reg[63:32]         <= S_PWDATA;
                    8'h18: inExp_reg[95:64]         <= S_PWDATA;
                    8'h1C: inExp_reg[127:96]        <= S_PWDATA;
                    
                    // Write inMod
                    8'h20: inMod_reg[31:0]          <= S_PWDATA;
                    8'h24: inMod_reg[63:32]         <= S_PWDATA;
                    8'h28: inMod_reg[95:64]         <= S_PWDATA;
                    8'h2C: inMod_reg[127:96]        <= S_PWDATA;
                    
                    // Write ds
                    8'h30: ds_reg                   <= S_PWDATA;
                endcase
            end
            else if (apb_read) 
            begin
                S_PREADY <= 1'b1;
                case (addr_index)
                    // Read indata
                    8'h00: S_PRDATA                 <= indata_reg[31:0];
                    8'h04: S_PRDATA                 <= indata_reg[63:32];
                    8'h08: S_PRDATA                 <= indata_reg[95:64];
                    8'h0C: S_PRDATA                 <= indata_reg[127:96];
                    
                    // Read inExp
                    8'h10: S_PRDATA                 <= inExp_reg[31:0];
                    8'h14: S_PRDATA                 <= inExp_reg[63:32];
                    8'h18: S_PRDATA                 <= inExp_reg[95:64];
                    8'h1C: S_PRDATA                 <= inExp_reg[127:96];
                    
                    // Read inMod
                    8'h20: S_PRDATA                 <= inMod_reg[31:0];
                    8'h24: S_PRDATA                 <= inMod_reg[63:32];
                    8'h28: S_PRDATA                 <= inMod_reg[95:64];
                    8'h2C: S_PRDATA                 <= inMod_reg[127:96];
                    
                    // Read ds
                    8'h30: S_PRDATA                 <= ds_reg;
                    
                    // Read ready
                    8'h34: S_PRDATA                 <= ready_reg;
                    
                    // Read cypher
                    8'h38: S_PRDATA                 <= cypher_reg[31:0];
                    8'h3C: S_PRDATA                 <= cypher_reg[63:32];
                    8'h40: S_PRDATA                 <= cypher_reg[95:64];
                    8'h44: S_PRDATA                 <= cypher_reg[127:96];
                endcase
            end else S_PRDATA  <= 0;
        end
    end
endmodule
