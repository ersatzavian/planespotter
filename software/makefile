all: asmtest.bin

asmtest.o: asmtest.S
	arm-none-eabi-as -mcpu=cortex-m0 asmtest.S -o asmtest.o

asmtest.elf: asmtest.o
	arm-none-eabi-ld -V -Ttext 0x8000000 -o asmtest.elf asmtest.o

asmtest.bin: asmtest.elf
	arm-none-eabi-objcopy -S -O binary asmtest.elf asmtest.bin
	arm-none-eabi-size asmtest.elf

clean:
	rm asmtest.elf asmtest.o asmtest.bin
