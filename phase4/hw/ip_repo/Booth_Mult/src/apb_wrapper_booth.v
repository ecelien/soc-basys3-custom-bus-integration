module apb_booth_multiplier_wrapper #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // Global Signals
    input                     S_PCLK,
    input                     S_PRESETN,

    // APB4 Interface
    input      [ADDR_WIDTH-1:0] S_PADDR,
    input                     S_PSEL,
    input                     S_PENABLE,
    input                     S_PWRITE,
    input      [DATA_WIDTH-1:0] S_PWDATA,
    output reg                S_PREADY,
    output reg [DATA_WIDTH-1:0] S_PRDATA,
    output                    S_PSLVERR
);

    // --- Address Map ---
    localparam ADDR_OPERAND_A = 8'h00; // Multiplier A (16-bit)
    localparam ADDR_OPERAND_B = 8'h04; // Multiplicand B (16-bit)
    localparam ADDR_PRODUCT   = 8'h08; // Result (32-bit) - Read Only

    // --- Internal Registers ---
    reg [15:0] reg_a;
    reg [15:0] reg_b;
    wire [31:0] multiplier_out;

    // --- Error and Ready Logic ---
    assign S_PSLVERR = 1'b0; // Simple implementation, no slave errors

    // --- Instantiate VHDL Booth Multiplier ---
    // Mapping: 16x16 -> 32 bit output
    mult_booth_array #(
        .word_size_a(16),
        .word_size_b(16),
        .sync_in_out(1),     // Keep it synchronous for clean timing
        .use_pipelining(1)   // High performance mode
    ) booth_inst (
        .clk_i(S_PCLK),
        .rst_i(~S_PRESETN),  // VHDL module uses active-high reset
        .ce_i(1'b1),         // Always enabled
        .a_i(reg_a),
        .b_i(reg_b),
        .p_o(multiplier_out)
    );

    // --- APB Read/Write Logic ---
    always @(posedge S_PCLK or negedge S_PRESETN) begin
        if (!S_PRESETN) begin
            reg_a    <= 16'h0;
            reg_b    <= 16'h0;
            S_PREADY <= 1'b0;
            S_PRDATA <= 32'h0;
        end else begin
            
            S_PREADY <= S_PSEL & S_PENABLE;

            if (S_PSEL && S_PWRITE && S_PENABLE) begin
                // Write Access
                case (S_PADDR)
                    ADDR_OPERAND_A: reg_a <= S_PWDATA[15:0];
                    ADDR_OPERAND_B: reg_b <= S_PWDATA[15:0];
                    default: ; // Ignore writes to read-only or invalid regs
                endcase
            end 
            else if (S_PSEL && !S_PWRITE) begin
                // Read Access
                case (S_PADDR)
                    ADDR_OPERAND_A: S_PRDATA <= {16'h0, reg_a};
                    ADDR_OPERAND_B: S_PRDATA <= {16'h0, reg_b};
                    ADDR_PRODUCT:   S_PRDATA <= multiplier_out;
                    default:        S_PRDATA <= 32'hDEADBEEF;
                endcase
            end
        end
    end

endmodule
