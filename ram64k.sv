`ifndef RAM
`define RAM

module ram (
    input clk,
    input reset,

    /* memory bus */
    input [31:0] address_in,
    input sel_in,
    output logic [31:0] read_value_out,
    input [3:0] write_mask_in,
    input [31:0] write_value_in,
    output logic ready_out
);

    logic [31:0] read_value;
    logic ready;

    SB_SPRAM256KA ram_low( // bits[15:0]
	.DATAOUT(read_value[15:0]),
	.ADDRESS(address_in[15:2]),
	.DATAIN({write_value_in[15:8], write_value_in[7:0]}),
	.MASKWREN({write_mask_in[1], write_mask_in[1], write_mask_in[0], write_mask_in[0]}),
	.WREN(write_mask_in[0] | write_mask_in[1]),

	.CHIPSELECT(sel_in & !reset),
	.CLOCK(clk),

	.STANDBY(1'b0),
	.SLEEP(1'b0),
	.POWEROFF(1'b1)
    );

    SB_SPRAM256KA ram_high( // bits[31:16]
	.DATAOUT(read_value[31:16]),
	.ADDRESS(address_in[15:2]),
	.DATAIN({write_value_in[31:24], write_value_in[23:16]}),
	.MASKWREN({write_mask_in[3], write_mask_in[3], write_mask_in[2], write_mask_in[2]}),
	.WREN(write_mask_in[2] | write_mask_in[3]),

	.CHIPSELECT(sel_in & !reset),
	.CLOCK(clk),

	.STANDBY(1'b0),
	.SLEEP(1'b0),
	.POWEROFF(1'b1)
    );


    assign read_value_out = sel_in ? read_value : 0;
    assign ready_out = sel_in ? ready : 0;

    always_ff @(posedge clk) begin

        if (sel_in && !reset) begin
            ready <= !ready;

        end else begin
            ready <= 0;
        end
    end
endmodule

`endif
