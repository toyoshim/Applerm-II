  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func
  .text

  .extern cpu6502_dump
  .extern cpu6502_load
  .extern cpu6502_store

#define T0 r4
#define T1 r5
#define PC r6
#define SR r7
#define RA r8
#define RX r9
#define RY r10
#define SP r11
#define ADDR r12

#define FLAG_N (1 << 7)
#define FLAG_V (1 << 6)
#define FLAG_D (1 << 3)
#define FLAG_I (1 << 2)
#define FLAG_Z (1 << 1)
#define FLAG_C (1 << 0)

.macro _ldb
  bl   cpu6502_load
.endm

.macro _ldw
  mov  T0, r0
  bl   cpu6502_load
  mov  T1, r0
  adds r0, T0, #1
  bl   cpu6502_load
  lsls r0, r0, #8
  adds r0, r0, T1
.endm

.macro _stb
  bl   cpu6502_store
.endm

.macro _stw
  mov  T0, r0
  mov  T1, r1
  bl   cpu6502_store
  adds r0, T0, #1
  lsrs r1, T1, #8
  bl   cpu6502_store
.endm

.macro _pushb reg
  mov  r0, SP
  mov  r1, \reg
  _stb
  mov  r0, SP
  subs r0, r0, #1
  mov  SP, r0
.endm

.macro _pushw reg
  mov  r0, SP
  mov  r1, \reg
  lsrs r1, r1, #8
  _stb
  mov  r0, SP
  subs r0, r0, #1
  mov  r1, \reg
  _stb
  mov  r0, SP
  subs r0, r0, #2
  mov  SP, r0
.endm

.macro _popb
  mov  r0, SP
  adds r0, r0, #1
  mov  SP, r0
  _ldb
.endm

.macro _popw
  mov  T0, SP
  adds r0, T0, #1
  _ldb
  mov  T1, r0
  adds r0, T0, #2
  mov  SP, r0
  _ldb
  lsls r0, r0, #8
  adds r0, r0, T1
.endm

.macro _decode
  bl   dump
  mov  r0, PC
  _ldb
  lsls r1, r0, #2
  ldr  r2, 1f
  adds r3, r2, r1
  ldr  r1, [r3]
  mov  pc, r1
  .align 4
1:
  .long op_table
.endm

.macro _fromAbsb
  adds PC, PC, #1
  mov  r0, PC
  _ldw
  mov  ADDR, r0
  _ldb
.endm

.macro _fromAbsoluteIndexed reg
  adds PC, PC, #1
  mov  r0, PC
  _ldw
  add  r0, r0, \reg
  mov  ADDR, r0
  _ldb
.endm

.macro _fromImmb
  adds PC, PC, #1
  mov  r0, PC
  _ldb
.endm

.macro _fromIndexedIndirect
  _fromImmb
  mov  r1, RX
  adds r0, r0, R1
  uxtb r0, r0
  mov  T0, r0
  _ldb
  mov  T1, r0
  adds r0, T0, #1
  uxtb r0, r0
  _ldb
  lsls r0, r0, #8
  adds r0, r0, T1
  mov  ADDR, r0
  _ldb
.endm

.macro _fromIndirectIndex
  _fromImmb
  mov  T0, r0
  _ldb
  mov  T1, r0
  mov  r0, T0
  adds r0, r0, #1
  uxtb r0, r0
  _ldb
  lsls r0, r0, #8
  add  r0, r0, T1
  add  r0, r0, RY
  mov  ADDR, r0
  _ldb
.endm

.macro _fromReg reg
  mov  r0, \reg
.endm

.macro _fromZero
  _fromImmb
  mov  ADDR, r0
  _ldb
.endm


.macro _fromZeroIndex reg
  _fromImmb
  add  r0, r0, \reg
  uxtb r0, r0
  mov  ADDR, r0
  _ldb
.endm

.macro _toAddr
  mov  r0, ADDR
  mov  r1, T0
  _stb
.endm

.macro _toReg reg
  mov  \reg, T0
.endm

.macro _toZero
  _fromImmb
  mov  r1, T0
  _stb
.endm

.macro __cl flag
  movs T0, #\flag
  bics SR, SR, T0
.endm

.macro __se flag
  movs T0, #\flag
  orrs SR, SR, T0
.endm

.macro _flag_nz
  __cl (FLAG_N | FLAG_Z)
  movs r0, r0
  bne  1f
  __se FLAG_Z
1:
  movs r1, #0x80
  tst  r0, r1
  beq  1f
  __se FLAG_N
1:
.endm

.macro _clx flag
  __cl \flag
  adds PC, PC, #1
.endm

.macro _sex flag
  __se \flag
  adds PC, PC, #1
.endm

.macro _asl
  __cl (FLAG_N | FLAG_Z | FLAG_C)
  movs r1, #0x80
  tst  r0, r1
  beq 1f
  bics r0, r0, r1
  __se FLAG_C
1:
  lsls r0, r0, #1
  bne 1f
  __se FLAG_Z
1:
  tst  r0, r1
  beq 1f
  __se FLAG_N
1:
  adds PC, PC, #1
.endm

.macro _bit
  __cl (FLAG_N | FLAG_Z | FLAG_V)
  mov  r1, RA
  ands r0, r1, r0
  bne 1f
  __se FLAG_Z
1:
  movs r1, #0x80
  tst  r0, r1
  beq 1f
  __se FLAG_N
1:
  movs r1, #0x40
  tst  r0, r1
  beq 1f
  __se FLAG_V
1:
.endm

.macro _bxx
  _fromImmb
  sxtb r0, r0
  add  PC, PC, r0
.endm

.macro _jmp
  mov  PC, r0
.endm

.macro _ld reg
  mov  \reg, r0
  _flag_nz
  adds PC, PC, #1
.endm

.macro _lop op
  mov  r1, RA
  \op  r0, r1, r0
  mov  RA, r0
  _flag_nz
  adds PC, PC, #1
.endm

.macro _lsr
  __cl (FLAG_N | FLAG_Z | FLAG_C)
  movs r1, #0x01
  tst  r0, r1
  beq 1f
  __se FLAG_C
1:
  lsrs r0, r0, #1
  bne 1f
  __se FLAG_Z
1:
  movs r1, #0x80
  tst  r0, r1
  beq 1f
  __se FLAG_N
1:
  adds PC, PC, #1
.endm

.macro _nop
  adds PC, PC, #1
.endm

.macro _rol
  movs r2, #FLAG_C
  ands r2, SR, r2
  __cl (FLAG_N | FLAG_Z | FLAG_C)
  movs r1, #0x80
  tst  r0, r1
  beq 1f
  __se FLAG_C
1:
  lsls r0, r0, #1
  uxtb r0, r0
  adds r0, r0, r2
  bne 1f
  __se FLAG_Z
1:
  tst  r0, r1
  beq 1f
  __se FLAG_N
1:
  adds PC, PC, #1
.endm

.macro _ror
  movs r2, #FLAG_C
  ands r2, SR, r2
  lsls r2, r2, #7
  __cl (FLAG_N | FLAG_Z | FLAG_C)
  movs r1, #0x01
  tst  r0, r1
  beq 1f
  __se FLAG_C
1:
  lsrs r0, r0, #1
  adds r0, r0, r2
  bne 1f
  __se FLAG_Z
1:
  movs r1, #0x80
  tst  r0, r1
  beq 1f
  __se FLAG_N
1:
  adds PC, PC, #1
.endm

.macro _rti
  _popb
  mov  SR, r0
  _popw
  mov  PC, r0
.endm

.macro _resume
  ldr  r0, =#r_pc
  ldr  PC, [r0]
  ldr  r0, =#r_sr
  ldr  SR, [r0]
  ldr  r0, =#r_a
  ldr  T0, [r0]
  mov  RA, T0
  ldr  r0, =#r_x
  ldr  T0, [r0]
  mov  RX, T0
  ldr  r0, =#r_y
  ldr  T0, [r0]
  mov  RY, T0
  ldr  r0, =#r_sp
  ldr  T0, [r0]
  mov  SP, T0
  ldr  T0, =#op_table
.endm

.macro _suspend
  ldr  r0, =#r_pc
  str  PC, [r0]
  ldr  r0, =#r_sr
  str  SR, [r0]
  ldr  r0, =#r_a
  mov  T0, RA
  str  T0, [r0]
  ldr  r0, =#r_x
  mov  T0, RX
  str  T0, [r0]
  ldr  r0, =#r_y
  mov  T0, RY
  str  T0, [r0]
  ldr  r0, =#r_sp
  mov  T0, SP
  str  T0, [r0]
.endm

// NOP
op02:
op03:
op04:
op07:
op0b:
op0c:
op0f:
op12:
op13:
op14:
op17:
op1a:
op1b:
op1c:
op1f:
op22:
op23:
op27:
op2b:
op2f:
op32:
op33:
op34:
op37:
op3a:
op3b:
op3c:
op3f:
op42:
op43:
op44:
op47:
op4b:
op4f:
op52:
op53:
op54:
op57:
op5a:
op5b:
op5c:
op5f:
  _nop
  _decode

op00:  // BRK
  adds T0, PC, #2
  _pushw T0
  _pushb SR
  movs r0, #0xff
  lsls r0, r0, #8
  adds r0, r0, #0xfe
  _ldw
  mov  PC, r0
  _decode

op01:  // ORA - (Indirect, X)
  _fromIndexedIndirect
  _lop orrs
  _decode

op05:  // ORA - Zero Page
  _fromZero
  _lop orrs
  _decode

op06:  // ASL - Zero Page
  _fromZero
  _asl
  _toAddr
  _decode

op08:  // PHP
  _pushb SR
  adds PC, PC, #1
  _decode

op09:  // ORA - Immediate
  _fromImmb
  _lop orrs
  _decode

op0a:  // ASL - Accumulator
  _fromReg RA
  _asl
  _toReg RA
  _decode

op0d:  // ORA - Absolute
  _fromAbsb
  _lop orrs
  _decode

op0e:  // ASL - Absolute
  _fromAbsb
  _asl
  _toAddr
  _decode

op10:  // BPL (N==0)
  movs r0, #FLAG_N
  tst  SR, r0
  bne 1f
  _bxx
1:
  _decode

op11:  // ORA - (Indirect), Y
  _fromIndirectIndex
  _lop orrs
  _decode

op15:  // ORA - Zero Page, X
  _fromZeroIndex RX
  _lop orrs
  _decode

op16:  // ASL - Zero Page, X
  _fromZeroIndex RX
  _asl
  _toAddr
  _decode

op18:  // CLC
  _clx FLAG_C
  _decode

op19:  // ORA - Absolute, Y
  _fromAbsoluteIndexed RY
  _lop orrs
  _decode

op1d:  // ORA - Absolute, X
  _fromAbsoluteIndexed RX
  _lop orrs
  _decode

op1e:  // ASL - Absolute, X
  _fromAbsoluteIndexed RX
  _asl
  _toAddr
  _decode

op20:  // JSR
  adds T0, PC, #2
  _pushw T0
  adds r0, PC, #1
  _ldw
  mov  PC, r0
  _decode

op21:  // AND - (Indirect, X)
  _fromIndexedIndirect
  _lop ands
  _decode

op24:  // BIT - Zero Page
  _fromZero
  _bit
  _decode

op25:  // AND - Zero Page
  _fromZero
  _lop ands
  _decode

op26:  // ROR - Zero Page
  _fromZero
  _ror
  _toAddr
  _decode

op28:  // PLP
  _popb
  mov  SR, r0
  adds PC, PC, #1
  _decode

op29:  // AND - Immediate
  _fromImmb
  _lop ands
  _decode

op2a:  // ROR - Accumulator
  _fromReg RA
  _ror
  _toReg RA
  _decode

op2c:  // BIT - Absolute
  _fromAbsb
  _bit
  _decode

op2d:  // AND - Absolute
  _fromAbsb
  _lop ands
  _decode

op2e:  // ROL - Absolute
  _fromAbsb
  _rol
  _toAddr
  _decode

op30:  // BMI (N==1)
  movs r0, #FLAG_N
  tst  SR, r0
  beq 1f
  _bxx
1:
  _decode

op31:  // AND - (Indirect), Y
  _fromIndirectIndex
  _lop ands
  _decode

op35:  // AND - Zero Page, X
  _fromZeroIndex RX
  _lop ands
  _decode

op36:  // ROL - Zero Page, X
  _fromZeroIndex RX
  _rol
  _toAddr
  _decode

op38:  // SEC
  _sex FLAG_C
  _decode

op39:  // AND - Absolute, Y
  _fromAbsoluteIndexed RY
  _lop ands
  _decode

op3d:  // AND - Absolute, X
  _fromAbsoluteIndexed RX
  _lop ands
  _decode

op3e:  // ROL - Absolute, X
  _fromAbsoluteIndexed RX
  _rol
  _toAddr
  _decode

op40:  // RTI
  _rti
  _decode

op41:  // EOR - (Indirect), X
  _fromIndexedIndirect
  _lop eors
  _decode

op45:  // EOR - Zero Page
  _fromZero
  _lop eors
  _decode

op46:  // LSR - Zero Page
  _fromZero
  _lsr
  _toAddr
  _decode

op48:  // PHA
  _pushb RA
  adds PC, PC, #1
  _decode

op49:  // EOR - Immediate
  _fromImmb
  _lop eors
  _decode

op4a:  // LSR - Accumulator
  _fromReg RA
  _lsr
  _toReg RA
  _decode

op4c:  // JMP - Absolute
  adds r0, PC, #1
  _ldw
  _jmp
  _decode

op4d:  // EOR - Absolute
  _fromAbsb
  _lop eors
  _decode

op4e:  // LSR - Absolute
  _fromAbsb
  _lsr
  _toAddr
  _decode

op50:  // BVC (V==0)
  movs r0, #FLAG_V
  tst  SR, r0
  bne 1f
  _bxx
1:
  _decode

op51:  // EOR - (Indirect), Y
  _fromIndirectIndex
  _lop eors
  _decode

op55:  // EOR - Zero Page, X
  _fromZeroIndex RX
  _lop eors
  _decode

op56:  // LSR - Zero Page, X
  _fromZeroIndex RX
  _lsr
  _toAddr
  _decode

op58:  // CLI
  _clx FLAG_I
  _decode

op59:  // EOR - Absolute, Y
  _fromAbsoluteIndexed RY
  _lop eors
  _decode

op5d:  // EOR - Absolute, X
  _fromAbsoluteIndexed RX
  _lop eors
  _decode

op5e:  // LSR - Absolute, X
  _fromAbsoluteIndexed RX
  _lsr
  _toAddr
  _decode

op60:
  b    quit
op61:
  b    quit
op62:
  b    quit
op63:
  b    quit
op64:
  b    quit
op65:
  b    quit
op66:
  b    quit
op67:
  b    quit
op68:
  b    quit
op69:
  b    quit
op6a:
  b    quit
op6b:
  b    quit
op6c:
  b    quit
op6d:
  b    quit
op6e:
  b    quit
op6f:
  b    quit
op70:
  b    quit
op71:
  b    quit
op72:
  b    quit
op73:
  b    quit
op74:
  b    quit
op75:
  b    quit
op76:
  b    quit
op77:
  b    quit
op78:  // SEI
  _sex FLAG_I
  _decode
op79:
  b    quit
op7a:
  b    quit
op7b:
  b    quit
op7c:
  b    quit
op7d:
  b    quit
op7e:
  b    quit
op7f:
  b    quit
op80:
  b    quit
op81:
  b    quit
op82:
  b    quit
op83:
  b    quit
op84:  // STY - Zero Page
  mov  T0, RY
  _toZero
  _decode

op85:
  b    quit
op86:
  b    quit
op87:
  b    quit
op88:
  b    quit
op89:
  b    quit
op8a:
  b    quit
op8b:
  b    quit
op8c:
  b    quit
op8d:
  b    quit
op8e:
  b    quit
op8f:
  b    quit
op90:
  b    quit
op91:
  b    quit
op92:
  b    quit
op93:
  b    quit
op94:
  b    quit
op95:
  b    quit
op96:
  b    quit
op97:
  b    quit
op98:
  b    quit
op99:
  b    quit
op9a:
  b    quit
op9b:
  b    quit
op9c:
  b    quit
op9d:
  b    quit
op9e:
  b    quit
op9f:
  b    quit
opa0:  // LDY - Immediate
  _fromImmb
  _ld  RY
  _decode
opa1:
  b    quit
opa2:  // LDX - Immediate
  _fromImmb
  _ld  RX
  _decode
opa3:
  b    quit
opa4:
  b    quit
opa5:
  b    quit
opa6:
  b    quit
opa7:
  b    quit
opa8:
  b    quit
opa9:  // LDA - Immediate
  _fromImmb
  _ld  RA
  _decode
opaa:
  b    quit
opab:
  b    quit
opac:
  b    quit
opad:
  b    quit
opae:
  b    quit
opaf:
  b    quit
opb0:
  b    quit
opb1:
  b    quit
opb2:
  b    quit
opb3:
  b    quit
opb4:
  b    quit
opb5:
  b    quit
opb6:
  b    quit
opb7:
  b    quit
opb8:  // CLV
  _clx FLAG_V
  _decode
opb9:
  b    quit
opba:
  b    quit
opbb:
  b    quit
opbc:
  b    quit
opbd:
  b    quit
opbe:
  b    quit
opbf:
  b    quit
opc0:
  b    quit
opc1:
  b    quit
opc2:
  b    quit
opc3:
  b    quit
opc4:
  b    quit
opc5:
  b    quit
opc6:
  b    quit
opc7:
  b    quit
opc8:
  b    quit
opc9:
  b    quit
opca:
  b    quit
opcb:
  b    quit
opcc:
  b    quit
opcd:
  b    quit
opce:
  b    quit
opcf:
  b    quit
opd0:  // BNE (Z==0)
  movs r0, #FLAG_Z
  tst  SR, r0
  bne  1f
  _bxx
1:
  _decode
opd1:
  b    quit
opd2:
  b    quit
opd3:
  b    quit
opd4:
  b    quit
opd5:
  b    quit
opd6:
  b    quit
opd7:
  b    quit
opd8:  // CLD
  _clx FLAG_D
  _decode
opd9:
  b    quit
opda:
  b    quit
opdb:
  b    quit
opdc:
  b    quit
opdd:
  b    quit
opde:
  b    quit
opdf:
  b    quit
ope0:
  b    quit
ope1:
  b    quit
ope2:
  b    quit
ope3:
  b    quit
ope4:
  b    quit
ope5:
  b    quit
ope6:
  b    quit
ope7:
  b    quit
ope8:
  b    quit
ope9:
  b    quit
opea:
  b    quit
opeb:
  b    quit
opec:
  b    quit
oped:
  b    quit
opee:
  b    quit
opef:
  b    quit
opf0:
  b    quit
opf1:
  b    quit
opf2:
  b    quit
opf3:
  b    quit
opf4:
  b    quit
opf5:
  b    quit
opf6:
  b    quit
opf7:
  b    quit
opf8:  // SED
  _sex FLAG_D
  _decode
opf9:
  b    quit
opfa:
  b    quit
opfb:
  b    quit
opfc:
  b    quit
opfd:
  b    quit
opfe:
  b    quit
opff:
  b    quit

  .global cpu6502_reset
  .type cpu6502_reset, %function
cpu6502_reset:
  push {r4-r7,lr}
  movs r4, #0x00
  movs r5, #0x01
  lsls r5, r5, #8
  adds r5, r5, #0xff
  movs r6, #0x30
  ldr  r7, =#r_a
  str  r4, [r7]
  ldr  r7, =#r_x
  str  r4, [r7]
  ldr  r7, =#r_y
  str  r4, [r7]
  ldr  r7, =#r_sp
  str  r5, [r7]
  ldr  r7, =#r_sr
  str  r6, [r7]
  ldr  r0, =#0xfffc
  _ldw
  ldr  r7, =#r_pc
  str  r0, [r7]
  pop  {r4-r7,pc}

  .global cpu6502_run
  .type cpu6502_run, %function
cpu6502_run:
  push {r4-r7,lr}
  mov  r0, r8
  mov  r1, r9
  mov  r2, r10
  mov  r3, r11
  mov  r4, r12
  push {r0-r4}
  _resume
  _decode
quit:
  mov  r12, r0
  _suspend
  pop  {r0-r4}
  mov  r8, r0
  mov  r9, r1
  mov  r10, r2
  mov  r11, r3
  mov  r0, r12
  mov  r12, r4
  pop  {r4-r7,pc}

// void dump(uint16_t pc);
  .type dump, %function
dump:
  push {lr}
  _suspend
  ldr  r0, =#r_sp
  ldr  r1, [r0]
  ldr  r0, =#r_sr
  ldr  r2, [r0]
  push {r1,r2}
  ldr  r3, =#r_pc
  ldr  r0, [r3]
  ldr  r3, =#r_a
  ldr  r1, [r3]
  ldr  r3, =#r_x
  ldr  r2, [r3]
  ldr  r3, =#r_y
  ldr  r3, [r3]
  // r0=pc, r1=a, r2=x, r3=y, [sp]=sp, [sp+4]=sr
  bl   cpu6502_dump
  mov  r0, sp
  adds r0, r0, #8
  mov  sp, r0
  pop  {pc}

  .section .rodata
op_table:
  .long op00
  .long op01
  .long op02
  .long op03
  .long op04
  .long op05
  .long op06
  .long op07
  .long op08
  .long op09
  .long op0a
  .long op0b
  .long op0c
  .long op0d
  .long op0e
  .long op0f
  .long op10
  .long op11
  .long op12
  .long op13
  .long op14
  .long op15
  .long op16
  .long op17
  .long op18
  .long op19
  .long op1a
  .long op1b
  .long op1c
  .long op1d
  .long op1e
  .long op1f
  .long op20
  .long op21
  .long op22
  .long op23
  .long op24
  .long op25
  .long op26
  .long op27
  .long op28
  .long op29
  .long op2a
  .long op2b
  .long op2c
  .long op2d
  .long op2e
  .long op2f
  .long op30
  .long op31
  .long op32
  .long op33
  .long op34
  .long op35
  .long op36
  .long op37
  .long op38
  .long op39
  .long op3a
  .long op3b
  .long op3c
  .long op3d
  .long op3e
  .long op3f
  .long op40
  .long op41
  .long op42
  .long op43
  .long op44
  .long op45
  .long op46
  .long op47
  .long op48
  .long op49
  .long op4a
  .long op4b
  .long op4c
  .long op4d
  .long op4e
  .long op4f
  .long op50
  .long op51
  .long op52
  .long op53
  .long op54
  .long op55
  .long op56
  .long op57
  .long op58
  .long op59
  .long op5a
  .long op5b
  .long op5c
  .long op5d
  .long op5e
  .long op5f
  .long op60
  .long op61
  .long op62
  .long op63
  .long op64
  .long op65
  .long op66
  .long op67
  .long op68
  .long op69
  .long op6a
  .long op6b
  .long op6c
  .long op6d
  .long op6e
  .long op6f
  .long op70
  .long op71
  .long op72
  .long op73
  .long op74
  .long op75
  .long op76
  .long op77
  .long op78
  .long op79
  .long op7a
  .long op7b
  .long op7c
  .long op7d
  .long op7e
  .long op7f
  .long op80
  .long op81
  .long op82
  .long op83
  .long op84
  .long op85
  .long op86
  .long op87
  .long op88
  .long op89
  .long op8a
  .long op8b
  .long op8c
  .long op8d
  .long op8e
  .long op8f
  .long op90
  .long op91
  .long op92
  .long op93
  .long op94
  .long op95
  .long op96
  .long op97
  .long op98
  .long op99
  .long op9a
  .long op9b
  .long op9c
  .long op9d
  .long op9e
  .long op9f
  .long opa0
  .long opa1
  .long opa2
  .long opa3
  .long opa4
  .long opa5
  .long opa6
  .long opa7
  .long opa8
  .long opa9
  .long opaa
  .long opab
  .long opac
  .long opad
  .long opae
  .long opaf
  .long opb0
  .long opb1
  .long opb2
  .long opb3
  .long opb4
  .long opb5
  .long opb6
  .long opb7
  .long opb8
  .long opb9
  .long opba
  .long opbb
  .long opbc
  .long opbd
  .long opbe
  .long opbf
  .long opc0
  .long opc1
  .long opc2
  .long opc3
  .long opc4
  .long opc5
  .long opc6
  .long opc7
  .long opc8
  .long opc9
  .long opca
  .long opcb
  .long opcc
  .long opcd
  .long opce
  .long opcf
  .long opd0
  .long opd1
  .long opd2
  .long opd3
  .long opd4
  .long opd5
  .long opd6
  .long opd7
  .long opd8
  .long opd9
  .long opda
  .long opdb
  .long opdc
  .long opdd
  .long opde
  .long opdf
  .long ope0
  .long ope1
  .long ope2
  .long ope3
  .long ope4
  .long ope5
  .long ope6
  .long ope7
  .long ope8
  .long ope9
  .long opea
  .long opeb
  .long opec
  .long oped
  .long opee
  .long opef
  .long opf0
  .long opf1
  .long opf2
  .long opf3
  .long opf4
  .long opf5
  .long opf6
  .long opf7
  .long opf8
  .long opf9
  .long opfa
  .long opfb
  .long opfc
  .long opfd
  .long opfe
  .long opff

  .bss
r_pc: .long 0
r_a:  .long 0
r_x:  .long 0
r_y:  .long 0
r_sp: .long 0
r_sr: .long 0

