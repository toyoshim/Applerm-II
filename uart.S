  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func

  .include "registers.inc"

  .text

  // void uart_init()
  .global uart_init
  .type uart_init, %function
uart_init:
  // 0) Set to provide I/O clock
  ldr  r0, =#SYSAHBCLKCTRL
  ldr  r1, [r0]
  ldr  r2, =#CLK_IOCON
  orrs r1, r1, r2
  str  r1, [r0]
  // 1) IO port configuration to use UART
  ldr  r0, =#IOCON_PIO1_6
  movs r1, #(PIO_BASE | FUNC_RXD)
  str  r1, [r0]
  ldr  r0, =#IOCON_PIO1_7
  movs r1, #(PIO_BASE | FUNC_TXD)
  str  r1, [r0]
  // 2) Set to provide UART clock
  ldr  r0, =#SYSAHBCLKCTRL
  ldr  r1, [r0]
  ldr  r2, =#CLK_UART
  orrs r1, r1, r2
  str  r1, [r0]
  // 3) Set clock divider to enable UART clock
  ldr  r0, =#UARTCLKDIV
  movs r1, #1
  str  r1, [r0]

  // UART_PCLK = 12MHz, BR = 115200
  // DLM=0, DLL=4, DIVADDVAL = 5, MULVAL = 8
  ldr  r0, =#U0LCR
  movs r1, #DLAB_ENABLE
  str  r1, [r0]
  ldr  r0, =#U0DLM
  movs r1, #0
  str  r1, [r0]
  ldr  r0, =#U0DLL
  movs r1, #4
  str  r1, [r0]
  ldr  r0, =#U0FDR
  movs r1, #((8 << MULVAL_SHIFT) | 5)
  str  r1, [r0]

  // Configure as 8-bit, 1 stop bit, no parity mode
  ldr  r0, =#U0LCR
  movs r1, #(WORD_LEN_8 | STOP_BIT_1)
  str  r1, [r0]

  // Enable TX
  ldr  r0, =#U0TER
  movs r1, #TXEN
  str  r1, [r0]

  // Reset FIFO
  ldr  r0, =#U0FCR
  movs r1, #(FIFO_ENABLE | RX_RESET | TX_RESET)
  str  r1, [r0]

  mov  pc, lr
  .size uart_init, .-uart_init

  // void uart_putc(char c);
  .global uart_putc
  .type uart_putc, %function
uart_putc:
  ldr  r1, =#U0LSR
  movs r2, #LSR_THRE
1:
  ldr  r3, [r1]
  ands r3, r2, r3
  beq  1b
  ldr  r1, =#U0THR
  str  r0, [r1]
  mov  pc, lr
  .size uart_putc, .-uart_putc

  // void uart_putstr(const char* str);
  .global uart_putstr
  .type uart_putstr, %function
uart_putstr:
  push {r4, lr}
  mov  r4, r0
1:
  ldrb r0, [r4]
  movs r0, r0
  beq  1f
  bl   uart_putc
  movs r0, #1
  adds r4, r4, r0
  b    1b
1:
  pop  {r4, pc}
  .size uart_putstr, .-uart_putstr

  // void uart_putx(char x);
  .global uart_putx
  .type uart_putx, %function
uart_putx:
  push {lr}
  movs r1, #10
  cmp  r0, r1
  bhs  1f
  movs r1, #'0'
  adds r0, r0, r1
  bl   uart_putc
  pop  {pc}
1:
  movs r1, #('a' - 10)
  adds r0, r0, r1
  bl   uart_putc
  pop  {pc}
  .size uart_putx, .-uart_putx

  // void uart_puthex(char n);
  .global uart_puthex
  .type uart_puthex, %function
uart_puthex:
  push {lr}
  push {r0}
  lsrs r0, r0, #4
  bl   uart_putx
  pop  {r0}
  movs r1, #0xf
  ands r0, r0, r1
  bl   uart_putx
  pop  {pc}
  .size uart_puthex, .-uart_puthex

  // void uart_puthex16(short n);
  .global uart_puthex16
  .type uart_puthex16, %function
uart_puthex16:
  push {lr}
  push {r0}
  lsrs r0, r0, #8
  bl   uart_puthex
  pop  {r0}
  movs r1, #0xff
  ands r0, r0, r1
  bl   uart_puthex
  pop  {pc}
  .size uart_puthex16, .-uart_puthex16

