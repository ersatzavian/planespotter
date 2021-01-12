@ Lifted from http://www.martinhubacek.cz/arm/arm-cortex-bare-metal-assembly/02---arm-cortex-bare-metal-assembly-blinking-led
@ and https://gist.github.com/BobBurns/bb601d3432650073a8b4

@	.thumb
@	.syntax unified
	.cpu cortex-m0

@ Register addresses from STM32F0 reference manual
	.equ STACKINIT,					0x20001000
	.equ PERIPH_BASE,           	0x40000000
	.equ AHBPERIPH_BASE,        	(PERIPH_BASE + 0x00020000)
	.equ AHB2PERIPH_BASE, 			(PERIPH_BASE + 0x08000000)
	.equ RCC_BASE,             		(AHBPERIPH_BASE + 0x00001000)
	.equ RCC_AHBENR, 				(RCC_BASE + 0x14)
	.equ GPIOB_BASE,             	(AHB2PERIPH_BASE + 0x00000400)
	.equ MODER_OFFSET,				0x00
	.equ OTYPER_OFFSET,				0x04
	.equ OSPEEDR_OFFSET,			0x08
	.equ ODR_OFFSET,				0x14
	.equ BSRR_OFFSET,				0x18
	.equ LED_DELAY, 				80000

@ Make start function global so the linker can see it later
	.global _start

@ Vector table
	.word STACKINIT
	.word _start + 1
@	.word _nmi_handler + 1
@	.word _hard_fault + 1
@	.word _memory_fault + 1
@	.word _bus_fault + 1
@	.word _usage_fault + 1

_start:

    @ Enable clock for GPIOB peripheral in RCC registers
    ldr r0, =(RCC_AHBENR)
    ldr r1, =(1 << 18) @ Bit 18 is port B clock enable
    str r1, [r0]     @Store contents of r1 to the register at address stored in r0

    @ Enable GPIOB pins 5, 6 and 7 as output
    ldr r0, =(GPIOB_BASE + MODER_OFFSET)
    ldr r1, =((1 << (6*2)) | (1 << (7*2)) | (1 << (5*2)))    @ Every bin has 2 bit settings, hence *2
    str r1, [r0]     @Store contents of r1 to register at address stored in r0

    @ Do not need to write to the output type register because pins default to push-pull.

    @ GPIO can run up to 2 MHz in low speed mode
    @ Medium speed up to 10 MHz.
    @ High speed 20 MHz, sometimes faster if VDD > 2.7 V.
    @ Set GPIO 7 to medium speed
    @ldr r0, =(GPIOB_BASE + OSPEEDR_OFFSET)
    @ldr r1, =(1 << (7*2))
    @str r1, [r0]

	@ Turn on LED 1 only (GPIO 5 low)
	ldr r0, =(GPIOB_BASE + ODR_OFFSET)
	ldr r1, =(0xDF)
	str r1, [r0]

    @ Hold the GPIOB output data registerr in r0 for the remainder of the program
    @ ldr r0, =(GPIOB_BASE + ODR_OFFSET)

loop:

    @ Reset (write low) to pin PB6 (LED2), LED will be on
    ldr r1, =(0x9F)
    str r1, [r0]
   
    @ Dummy counter to slow down loop
    @ldr r1, =LED_DELAY
    @loop0:
	@sub r1, #1
    @bne loop0
   
    @ Set (write high) PB6, LED2 will be off
    ldr r1, =(0xDF)
    str r1, [r0]

    @ Dummy counter to slow down my loop
    @ldr r1, =LED_DELAY
    @loop1:
    @sub r1, #1
    @bne loop1

b loop
