`ifndef RV32_MEM
`define RV32_MEM

`include "rv32_branch.sv"

module rv32_mem (
    input clk,

    /* control in */
    input read_en_in,
    input write_en_in,
    input [1:0] branch_op_in,
    input [4:0] rd_in,
    input rd_writeback_in,

    /* data in */
    input [31:0] result_in,
    input [31:0] rs2_value_in,
    input [31:0] branch_pc_in,

    /* control out */
    output read_en_out,
    output branch_taken_out,
    output [4:0] rd_out,
    output rd_writeback_out,

    /* data out */
    output [31:0] result_out,
    output [31:0] read_value_out,
    output [31:0] branch_pc_out
);
    logic [31:0] data_mem [255:0];

    rv32_branch branch (
        /* control in */
        .op_in(branch_op_in),

        /* data in */
        .result_in(result_in),

        /* control out */
        .taken_out(branch_taken_out)
    );

    assign branch_pc_out = branch_pc_in;

    always_ff @(posedge clk) begin
        read_en_out <= read_en_in;
        rd_out <= rd_in;
        rd_writeback_out <= rd_writeback_in;
        result_out <= result_in;

        if (read_en_in)
            read_value_out <= data_mem[result_in[31:2]];

        if (write_en_in)
            data_mem[result_in[31:2]] <= rs2_value_in;
    end
endmodule

`endif
