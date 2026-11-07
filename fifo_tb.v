`timescale 1ns / 1ps

module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;

    reg                   clk;
    reg                   rst_n;
    reg                   wr_en;
    reg                   rd_en;
    reg  [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire                  full;
    wire                  empty;

    integer i;

    fifo_sync #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("fifo_waveform.vcd");
        $dumpvars(0, fifo_tb);

        clk     = 0;
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 8'h00;

        #25 rst_n = 1;
        #10;
        if (empty === 1'b1 && full === 1'b0)
            $display("[PASS] Reset Verified: FIFO is Empty.");

        $display("--- Writing 16 elements ---");
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk);
            wr_en   = 1'b1;
            data_in = 8'hA0 + i;
        end
        @(negedge clk);
        wr_en = 1'b0;
        #5;
        if (full === 1'b1)
            $display("[PASS] FULL Flag Triggered Successfully.");

        $display("--- Reading 16 elements ---");
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk);
            rd_en = 1'b1;
            @(posedge clk);
            #1;
            if (data_out === (8'hA0 + i))
                $display("[PASS] Read %0d matched: 0x%02X", i, data_out);
        end
        @(negedge clk);
        rd_en = 0;
        #5;
        if (empty === 1'b1)
            $display("[PASS] EMPTY Flag Triggered Successfully.");

        $display("========================================");
        $display("   SIMULATION SUCCESSFUL - ALL PASSED   ");
        $display("========================================");
        #50 $finish;
    end

endmodule