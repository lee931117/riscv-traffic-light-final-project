module top (
    input clk,
    input reset,
    input [3:0] sw,
    input [3:0] btn,
    output reg [3:0] led,
    output [7:0] seg,
    output [3:0] an
);

    wire resetn = ~reset;

    // 目前先關閉七段顯示器
    assign seg = 8'b1111_1111;
    assign an  = 4'b1111;

    // ========== PicoRV32 memory interface ==========
    wire        mem_valid;
    wire        mem_instr;
    reg         mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata;

    wire trap;

    // ========== PicoRV32 unused / optional ports ==========
    wire        mem_la_read;
    wire        mem_la_write;
    wire [31:0] mem_la_addr;
    wire [31:0] mem_la_wdata;
    wire [3:0]  mem_la_wstrb;

    wire        pcpi_valid;
    wire [31:0] pcpi_insn;
    wire [31:0] pcpi_rs1;
    wire [31:0] pcpi_rs2;
    reg         pcpi_wr;
    reg  [31:0] pcpi_rd;
    reg         pcpi_wait;
    reg         pcpi_ready;

    reg  [31:0] irq;
    wire [31:0] eoi;

    wire        trace_valid;
    wire [35:0] trace_data;

    initial begin
        pcpi_wr = 1'b0;
        pcpi_rd = 32'b0;
        pcpi_wait = 1'b0;
        pcpi_ready = 1'b0;
        irq = 32'b0;
    end

    // ========== Instruction / Data Memory ==========
    reg [31:0] memory [0:1023];

    initial begin
        $readmemh("firmware.mem", memory);
    end

    // ========== PicoRV32 CPU ==========
    picorv32 #(
        .PROGADDR_RESET(32'h0000_0000),
        .STACKADDR(32'h0000_0400),
        .ENABLE_COUNTERS(0),
        .ENABLE_COUNTERS64(0),
        .COMPRESSED_ISA(0),
        .ENABLE_MUL(0),
        .ENABLE_DIV(0),
        .ENABLE_IRQ(0)
    ) cpu (
        .clk(clk),
        .resetn(resetn),
        .trap(trap),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        .mem_la_read(mem_la_read),
        .mem_la_write(mem_la_write),
        .mem_la_addr(mem_la_addr),
        .mem_la_wdata(mem_la_wdata),
        .mem_la_wstrb(mem_la_wstrb),

        .pcpi_valid(pcpi_valid),
        .pcpi_insn(pcpi_insn),
        .pcpi_rs1(pcpi_rs1),
        .pcpi_rs2(pcpi_rs2),
        .pcpi_wr(pcpi_wr),
        .pcpi_rd(pcpi_rd),
        .pcpi_wait(pcpi_wait),
        .pcpi_ready(pcpi_ready),

        .irq(irq),
        .eoi(eoi),

        .trace_valid(trace_valid),
        .trace_data(trace_data)
    );

    // ========== Memory-mapped I/O ==========
    // 0x00000000 ~ 0x00000FFF：RAM / instruction memory
    // 0x10000000：LED register
    always @(posedge clk) begin
        mem_ready <= 1'b0;

        if (!resetn) begin
            led <= 4'b0000;
            mem_rdata <= 32'b0;
        end else begin
            if (mem_valid && !mem_ready) begin
                mem_ready <= 1'b1;

                if (mem_addr < 32'h0000_1000) begin
                    mem_rdata <= memory[mem_addr[11:2]];

                    if (mem_wstrb[0]) memory[mem_addr[11:2]][7:0]   <= mem_wdata[7:0];
                    if (mem_wstrb[1]) memory[mem_addr[11:2]][15:8]  <= mem_wdata[15:8];
                    if (mem_wstrb[2]) memory[mem_addr[11:2]][23:16] <= mem_wdata[23:16];
                    if (mem_wstrb[3]) memory[mem_addr[11:2]][31:24] <= mem_wdata[31:24];
                end else if (mem_addr == 32'h1000_0000) begin
                    mem_rdata <= {28'b0, led};

                    if (mem_wstrb != 4'b0000) begin
                        led <= mem_wdata[3:0];
                    end
                end else begin
                    mem_rdata <= 32'h0000_0000;
                end
            end
        end
    end

endmodule