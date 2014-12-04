  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func

  .extern basic_rom

  .section .rodata
dump0:
  .ascii "*** dump *** PC=$\000"
dump1:
  .ascii " A=$\000"
dump2:
  .ascii " X=$\000"
dump3:
  .ascii " Y=$\000"
dump4:
  .ascii " SP=$\000"
dump5:
  .ascii " NV-B_DIZC=\000"

  .text
  .global cpu6502_dump
  .type cpu6502_dump, %function
cpu6502_dump:
  push {r4-r7, lr}
  mov  r4, r0
  mov  r5, r1
  mov  r6, r2
  mov  r7, r3
  ldr  r0, =#dump0
  bl   uart_putstr
  mov  r0, r4
  bl   uart_puthex16
  ldr  r0, =#dump1
  bl   uart_putstr
  mov  r0, r5
  bl   uart_puthex
  ldr  r0, =#dump2
  bl   uart_putstr
  mov  r0, r6
  bl   uart_puthex
  ldr  r0, =#dump3
  bl   uart_putstr
  mov  r0, r7
  bl   uart_puthex
  ldr  r0, =#dump4
  bl   uart_putstr
  ldr  r0, [sp, #20]
  bl   uart_puthex
  ldr  r0, =#dump5
  bl   uart_putstr
  ldr  r4, [sp, #24]
  mov  r0, r4
  lsrs r0, #7
  bl   uart_putx
  mov  r0, r4
  movs r5, #1
  lsrs r0, #6
  ands r0, r5
  bl   uart_putx
  movs r0, #'-'
  bl   uart_putc
  mov  r0, r4
  lsrs r0, #4
  ands r0, r5
  bl   uart_putx
  movs r0, #'_'
  bl   uart_putc
  mov  r0, r4
  lsrs r0, #3
  ands r0, r5
  bl   uart_putx
  mov  r0, r4
  lsrs r0, #2
  ands r0, r5
  bl   uart_putx
  mov  r0, r4
  lsrs r0, #1
  ands r0, r5
  bl   uart_putx
  mov  r0, r4
  ands r0, r5
  bl   uart_putx
  movs r0, #'\n'
  bl   uart_putc
  pop  {r4-r7, pc}

  .global cpu6502_load
  .type cpu6502_load, %function
cpu6502_load:
  movs r1, r0
  lsrs r0, #8
  movs r2, #0xd0
  cmps r0, r2
  bhs  1f
  // TODO: Load from RAM
  movs r0, #0
  mov  pc, lr
1:
  // Load from ROM (0xd000-0xffff)
  lsls r2, #8
  subs r1, r1, r2
  ldr  r0, =#basic_rom
  adds r0, r0, r1
  ldrb r0, [r0]
  mov  pc, lr

  .global cpu6502_store
  .type cpu6502_store, %function
cpu6502_store:
  // TODO
  mov  pc, lr

