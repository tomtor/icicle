.DEFAULT_GOAL = all

QUIET    = -q
PLL      = pll.sv
SRC      = $(sort $(wildcard *.sv) $(PLL))
TOP      = top
SV       = $(TOP).sv
YS       = $(ARCH).ys
YS_ICE40 = `yosys-config --datdir/$(ARCH)/cells_sim.v`
BLIF     = $(TOP).blif
JSON     = $(TOP).json
ASC_SYN  = $(TOP)_syn.asc
ASC      = $(TOP).asc
BIN      = $(TOP).bin
SVF      = $(TOP).svf
TIME_RPT = $(TOP).rpt
STAT     = $(TOP).stat
#BOARD   ?= ice40hx8k-b-evn
BOARD    ?= ecp5-evn
#TARGET   = riscv64-unknown-elf
#TARGET   = /opt/riscv32imc/bin/riscv32-unknown-elf
TARGET   = /opt/riscv32i/bin/riscv32-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
LD       = $(TARGET)-gcc
LDFLAGS  = $(CFLAGS) -Wl,-Tprogmem.lds
CC       = $(TARGET)-gcc
CFLAGS   = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 -DTIME -DCORE_HZ=$(FREQ_PLL)000000ll -Os -ffreestanding -nostartfiles -g
OBJCOPY  = $(TARGET)-objcopy

include boards/$(BOARD).mk
include arch/$(ARCH).mk

.PHONY: all clean syntax time stat flash

all: $(BIN)

clean:
	$(RM) $(BLIF) $(JSON) $(ASC_SYN) $(ASC) $(BIN) $(SVF) $(PLL) $(TIME_RPT) $(STAT) \
	       	progmem_syn.hex progmem.hex progmem.bin progmem.o \
	       	start.o start.s progmem progmem.lds defines.sv \
	       	start-flash64.s start-ram64.s datafile_syn.hex \
		dhrystone.o dhrystone_main.o stdlib.o

datafile_syn.hex:
	#icebram -g 32 16384 > $@
	icebram -g 32 2048 > $@

progmem.bin: progmem
	$(OBJCOPY) -O binary $< $@

progmem.hex: progmem.bin
	xxd -p -c 4 < $< > $@

progmem: progmem.o start.o progmem.lds dhrystone.o dhrystone_main.o stdlib.o
	#$(LD) $(LDFLAGS) -o $@ progmem.o start.o -lm
	$(LD) $(LDFLAGS) -o $@ dhrystone.o dhrystone_main.o stdlib.o start.o

$(BLIF) $(JSON): $(YS) $(SRC) progmem_syn.hex progmem.hex defines.sv datafile_syn.hex
# $(BLIF) $(JSON): $(YS) $(SRC) defines.sv datafile_syn.hex
	yosys $(QUIET) $<

syntax: $(SRC) progmem_syn.hex defines.sv
	iverilog -D$(shell echo $(ARCH) | tr 'a-z' 'A-Z') -Wall -t null -g2012 $(YS_ICE40) $(SV)

defines.sv: boards/$(BOARD)-defines.sv
	cp boards/$(BOARD)-defines.sv defines.sv

start-flash64.s: start-flash.s
	cp $< $@

start-ram64.s: start-ram.s
	cp $< $@

start.s: start-$(PROGMEM).s
	cp $< $@

progmem.lds: progmem-$(PROGMEM).lds
	cp $< $@

time: $(TIME_RPT)
	cat $<

stat: $(STAT)
	cat $<

# Flash to BlackIce-II board
dfu-flash: $(BIN) $(TIME_RPT)
	dfu-util -d 0483:df11 --alt 0 --dfuse-address 0x0801F000 -D $(BIN)
