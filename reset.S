  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func

  .include "registers.inc"

  .extern cpu6502_reset
  .extern cpu6502_run
  .extern uart_init
  .extern uart_putc

  .text
  .global _reset
  .type _reset, %function
_reset:
  ldr  r0, =#(_stack_top - 32)
  mov  sp, r0
  bl   uart_init
  movs r0, #'>'
  bl   uart_putc

  bl   cpu6502_reset
  bl   cpu6502_run
1:
  b    1b
  .size _reset, .-_reset
