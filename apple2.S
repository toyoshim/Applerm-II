  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func

  .extern basic_rom
  .extern uart_putd
  .extern uart_getc
  .extern uart_ready

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
logoi:
  .ascii "\033[24C\000"
curleft:
  .ascii "\033[2D\000"

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
  push {lr}
  movs r2, r0
  lsrs r0, #8
  cmp  r0, #0xd0
  bhs  1f
  cmp  r0, #0x04
  blo  2f
  cmp  r0, #0x08
  blo  3f
  cmp  r0, #0x10
  blo  4f
  cmp  r0, #0xc0
  bhs  5f
  // Load from Fake RAM (0x1000-0xbfff)
  ldr  r0, =#ramfake
  ldrb r0, [r0]
  pop  {pc}
1:
  // Load from ROM (0xd000-0xffff)
  movs r0, #0xd0
  lsls r0, #8
  subs r2, r2, r0
  ldr  r0, =#basic_rom
  adds r0, r0, r2
  ldrb r0, [r0]
  pop  {pc}
2:
  // Load from RAM (0x0000-0x03ff)
  ldr  r0, =#ram0000
  adds r0, r0, r2
  ldrb r0, [r0]
  pop  {pc}
3:
  // Load from VRAM (0x0400-0x07ff)
  movs r0, #0xff
  pop  {pc}
4:
  // Load from RAM (0x0800-0x0fff)
  movs r0, #0x08
  lsls r0, r0, #8
  subs r2, r2, r0
  ldr  r0, =#ram0800
  adds r0, r0, r2
  ldrb r0, [r0]
  pop  {pc}
5:
  // Load from I/O (0xc000-0xcfff)
  mov  r0, r2
  uxtb r0, r0
  cmp  r0, #0x00
  bne  1f
  // 0xc000 KBD (Last Key Pressed + 128)
3:
  bl   uart_ready
  cmp  r0, #0x00
  beq  2f
  bl   uart_getc
  cmp  r0, #0x0a
  bne  4f
  movs r0, #0x0d
4:
  movs r1, #0x80
  orrs r0, r0, r1
  ldr  r1, =#kbddata
  strb r0, [r1]
  b    3b
2:
  ldr  r2, =#kbddata
  ldrb r0, [r2]
  pop  {pc}
1:
  cmp  r0, #0x10
  bne  1f
  // 0xc010 KBDSTRB (Keyboard Strobe)
  ldr  r2, =#kbddata
  ldrb r0, [r2]
  movs r1, #0x7f
  ands r0, r0, r1
  strb r0, [r2]
1:
  movs r0, #0
  pop  {pc}

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
  cmp  r0, #0x10
  blo  4f
  cmp  r0, #0xc0
  bhs  5f
  // Store to Fake RAM (0x1000-0xbfff)
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
1:
  mov  pc, lr
3:
  // Store to VRAM (0x0400-0x07ff)
  ldr  r0, =#scrmode
  ldrb r0, [r0]
  cmp  r0, #0
  beq  2f
  push {lr}
  bl   a2_tty
  pop  {pc}
2:
  cmp  r1, #0xff
  beq  1b
  cmp  r1, #0x7f
  beq  1b
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
  pop  {r0}
  bl   a2_putc
  pop  {pc}
4:
  // Store to (0x0800-0x0fff)
  movs r0, #0x08
  lsls r0, r0, #8
  subs r2, r2, r0
  ldr  r0, =#ram0800
  adds r0, r0, r2
  strb r1, [r0]
  mov  pc, lr
5:
  // Store to I/O (0xc000-0xcfff)
  mov  r0, r2
  uxtb r0, r0
  cmp  r0, #0x00
  bne  1f
  // 0xc000 KBD (Last Key Pressed + 128)
  ldr  r2, =#kbddata
  strb r1, [r2]
1:
  mov  pc, lr

  .global a2_init
  .type a2_init, %function
a2_init:
  ldr  r0, =#scrmode
  movs r1, #1
  strb r1, [r0]
  ldr  r0, =#scrline
  movs r1, #0
  strb r1, [r0]
  mov  pc, lr

a2_putc:
  cmp  r0, #0xff
  bne  1f
  mov  pc, lr
1:
  cmp  r0, #0x7f
  bne  1f
  mov  pc, lr
1:
  push {lr}
  ldr  r1, =#ascii
  movs r2, #0x3f
  ands r0, r0, r2
  adds r1, r1, r0
  ldrb r0, [r1]
  bl   uart_putc
  pop  {pc}

a2_tty:
  push {lr}
  cmp  r0, #1
  bne  1f
  // scrmode 1 (waiting for Apple ][ logo)
  cmp  r1, #0xdb
  beq  2f
  pop  {pc}
2:
  ldr  r0, =#logoi
  push {r1}
  bl   uart_putstr
  pop  {r1}
  movs r0, #2
  ldr  r3, =#scrmode
  strb r0, [r3]
1:
  cmp  r0, #2
  bne  1f
  // scrmode 2 (showing Apple ][ logo)
  ldr  r0, =#curleft
  push {r1}
  bl   uart_putstr
  pop  {r1}
  mov  r0, r1
  cmp  r0, #0xc1
  bne  2f
  ldr  r1, =#scrmode
  movs r2, #3
  strb r2, [r1]
2:
  bl   a2_putc
1:
  cmp  r0, #3
  bne  1f
  // scrmode 3 (waiting for prompt)
  cmp  r1, #0xdd
  beq  2f
  pop  {pc}
2:
  ldr  r3, =#scrmode
  movs r0, #4
  strb r0, [r3]
1:
  cmp  r0, #4
  bne 2f
  // scrmode 4 (normal)
  //cmp  r1, #0xff
  //bne  1f
  //pop  {pc}
1:
  //cmp  r1, #0x7f
  //bne  1f
  //pop  {pc}
1:
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
  subs r2, r2, #0x28  // x
  adds r3, r3, #0x08  // y
1:
  ldr  r0, =#scrline
  ldrb r0, [r0]
  cmp  r0, r3
  beq  1f
  movs r0, #0x0a
  push {r1-r3}
  bl   uart_putc
  ldr  r0, =#scrline
  ldrb r1, [r0]
  adds r1, r1, #1
  strb r1, [r0]
  pop  {r1-r3}
  b    1b
1:
  mov  r0, r1
  bl   a2_putc
2:
  // TODO: scroll
  pop  {pc}

  .bss
ram0000:
  .skip 0x400
ram0800:
  .skip 0x800
ramfake:
  .byte 0
kbddata:
  .byte 0
scrmode:
  .byte 0
scrline:
  .byte 0
