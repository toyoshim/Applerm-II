  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func

  .extern basic_rom
  .extern uart_putd

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
ascii:
  .ascii "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ !\"#$%&'()*+,-./0123456789:;<=>?"

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
  movs r2, r0
  lsrs r0, #8
  cmp  r0, #0xd0
  bhs  1f
  cmp  r0, #0x04
  blo  2f
  cmp  r0, #0x08
  blo  3f
  cmp  r0, #0xc0
  bhs  4f
  // Load from Fake RAM (0x0800-0xbfff)
  ldr  r0, =#ramfake
  ldrb r0, [r0]
  mov  pc, lr
1:
  // Load from ROM (0xd000-0xffff)
  movs r0, #0xd0
  lsls r0, #8
  subs r2, r2, r0
  ldr  r0, =#basic_rom
  adds r0, r0, r2
  ldrb r0, [r0]
  mov  pc, lr
2:
  // Load from RAM (0x0000-0x03ff)
  ldr  r0, =#ram0000
  adds r0, r0, r2
  ldrb r0, [r0]
  mov  pc, lr
3:
  // Load from VRAM (0x0400-0x07ff)
  movs r0, #0xff
  mov  pc, lr
4:
  // Load from I/O (0xc000-0xcfff)
  movs r0, #0
  mov  pc, lr

  .global cpu6502_store
  .type cpu6502_store, %function
cpu6502_store:
  movs r2, r0
  lsrs r0, #8
  cmp  r0, #0xd0
  bhs  1f
  cmp  r0, #0x04
  blo  2f
  cmp  r0, #0x08
  blo  3f
  cmp  r0, #0xc0
  bhs  4f
  // Store to Fake RAM (0x0800-0xbfff)
  ldr  r0, =#ramfake
  strb r1, [r0]
  mov  pc, lr
1:
  // Store to ROM (0xd000-0xffff)
  mov  pc, lr
2:
  // Store to RAM (0x0000-0x0400)
  ldr  r0, =#ram0000
  adds r0, r0, r2
  strb r1, [r0]
  mov  pc, lr
3:
  // Store to VRAM (0x0400-0x07ff)
  cmp  r1, #0x7f
  bne  1f
  mov  pc, lr
1:
  push {lr}
  push {r1-r2}
  movs r0, #0x1b
  bl   uart_putc
  movs r0, #'['
  bl   uart_putc
  pop  {r1-r2}
  movs r3, #0x04
  lsls r3, r3, #8
  subs r3, r2, r3
  movs r2, r3
  movs r0, #0x7f
  ands r2, r2, r0
  lsrs r3, r3, #7
  cmp  r2, #0x50
  blo  1f
  subs r2, r2, #0x50
  adds r3, r3, #0x10
1:
  cmp  r2, #0x28
  blo  1f
  subs r2, r2, #0x28
  adds r3, r3, #0x08
1:
  mov  r0, r3
  adds r0, r0, #1
  push {r1-r2}
  bl   uart_putd
  movs r0, #';'
  bl   uart_putc
  pop  {r1-r2}
  mov  r0, r2
  adds r0, r0, #1
  push {r1}
  bl   uart_putd
  movs r0, #'H'
  bl   uart_putc
  pop  {r1}
  ldr  r2, =#ascii
  movs r3, #0x3f
  ands r3, r1, r3
  adds r3, r3, r2
  ldrb r0, [r3]
  bl   uart_putc
  pop  {pc}
4:
  // Load from I/O (0xc000-0xcfff)
  movs r0, #0
  mov  pc, lr

  .bss
ram0000:
  .skip 0x400
ramfake:
  .byte 0
