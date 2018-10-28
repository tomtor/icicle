`ifndef BUS_ARBITER
`define BUS_ARBITER

module bus_arbiter (
    /* instruction memory bus */
    input [31:0] instr_address_in,
    input instr_read_in,
    output logic [31:0] instr_read_value_out,
    output logic instr_ready,

    /* data memory bus */
    input [31:0] data_address_in,
    input data_read_in,
    input data_write_in,
    output logic [31:0] data_read_value_out,
    input [3:0] data_write_mask_in,
    input [31:0] data_write_value_in,
    output logic data_ready,

    /* common memory bus */
    output logic [31:0] address_out,
    output logic read_out,
    output logic write_out,
    input [31:0] read_value_in,
    output logic [3:0] write_mask_out,
    output logic [31:0] write_value_out,
    input ready_in
);
    always_comb begin
        if (data_read_in || data_write_in) begin
            address_out = data_address_in;
            read_out = data_read_in;
            write_out = data_write_in;
            instr_read_value_out = 32'bx;
            data_read_value_out = read_value_in;
            write_mask_out = data_write_mask_in;
            write_value_out = data_write_value_in;
            instr_ready = 1'b0;
            data_ready = ready_in;
        end else if (instr_read_in) begin
            address_out = instr_address_in;
            read_out = instr_read_in;
            write_out = 1'b0;
            instr_read_value_out = read_value_in;
            data_read_value_out = 32'bx;
            write_mask_out = 4'b0;
            write_value_out = 32'bx;
            instr_ready = ready_in;
            data_ready = 1'b0;
        end else begin
            address_out = 32'bx;
            read_out = 1'b0;
            write_out = 1'b0;
            instr_read_value_out = 32'bx;
            data_read_value_out = 32'bx;
            write_mask_out = 4'b0;
            write_value_out = 32'bx;
            instr_ready = 1'b0;
            data_ready = 1'b0;
        end
    end
endmodule

`endif
