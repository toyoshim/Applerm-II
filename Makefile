APP	= lpc1114app
CC	= arm-linux-gnueabi-gcc
AS	= arm-none-eabi-gcc -c
LD	= arm-none-eabi-ld
OBJCOPY	= arm-none-eabi-objcopy
LDSCRIPT= lpc1114.ld
LPC21ISP= lpc21isp
SERIAL	= /dev/ttyUSB0
#SERIAL	= /dev/ttyACM0
SPEED	= 115200
#SPEED	= 9600
CLOCK	= 12000
ROM	= applebasic
//ROM	= apple2o
ROMOBJ	= $(ROM).o
ROMFLAG	= -I binary -O elf32-littlearm -B arm --rename-section .data=.rodata
FRAMEPTR= -fomit-frame-pointer
#FRAMEPTR= -DUSE_FRAMEPOINTER
OBJS	= vectors.o reset.o 6502.o apple2.o uart.o $(ROMOBJ)

$(APP).bin: $(APP)
	$(OBJCOPY) -O binary $< $@

$(APP): $(LDSCRIPT) $(OBJS)
	$(LD) -T $(LDSCRIPT) -o $@ $(OBJS)

$(ROM).rom:
	@echo "*********************************************"
	@echo "* $(ROM).rom is needed to build the app *"
	@echo "*********************************************"
	@exit 1

%.o: %.S
	$(AS) -o $@ $<

%.o: %.rom
	$(OBJCOPY) $(ROMFLAG) $< $@ \
		--redefine-sym _binary_$(ROM)_rom_start=basic_rom \
		--strip-symbol _binary_$(ROM)_rom_end \
		--strip-symbol _binary_$(ROM)_rom_size

# Test binary that runs on qemu user mode emulation for testing
test: 6502.S test.c
	$(CC) -mthumb -static $(FRAMEPTR) test.c 6502.S -o test && qemu-arm test 2> /dev/null

# Test binary that runs on qemu user mode emulation for functional tests
ftest: 6502.S ftest.c
	$(CC) -mthumb -static $(FRAMEPTR) ftest.c 6502.S -o ftest && qemu-arm ftest 2> flog

# Assume a CQ Mary comaptible board.
run: $(APP).bin
	$(LPC21ISP) -control -term -bin $(APP).bin $(SERIAL) $(SPEED) $(CLOCK)

clean:
	rm -rf $(APP).bin $(APP) $(OBJS) test ftest

# Use this build target to install required packages if you are on Ubuntu14.04.
install-deps:
	sudo apt-get install binutils-arm-none-eabi gcc-arm-none-eabi gcc-arm-linux-gnueabi lpc21isp
