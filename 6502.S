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

.macro _push16 reg
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

.macro _decode
  b    decode
.endm

.macro _fromImm8
  adds PC, PC, #1
  mov  r0, PC
  _ldb
.endm

.macro _clx flag
  movs T0, #\flag
  bics SR, SR, T0
  adds PC, PC, #1
.endm

.macro _sex flag
  movs T0, #\flag
  orrs SR, SR, T0
  adds PC, PC, #1
.endm

.macro _ld reg
  _clx (FLAG_N | FLAG_Z)
  mov  \reg, r0
  beq  1f
  _sex FLAG_Z
1:
  movs r1, #0x80
  tst  r0, r1
  beq  1f
  _sex FLAG_N
1:
  adds PC, PC, #1
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

op00:
  b    quit
op01:
  b    quit
op02:
  b    quit
op03:
  b    quit
op04:
  b    quit
op05:
  b    quit
op06:
  b    quit
op07:
  b    quit
op08:
  b    quit
op09:
  b    quit
op0a:
  b    quit
op0b:
  b    quit
op0c:
  b    quit
op0d:
  b    quit
op0e:
  b    quit
op0f:
  b    quit
op10:
  b    quit
op11:
  b    quit
op12:
  b    quit
op13:
  b    quit
op14:
  b    quit
op15:
  b    quit
op16:
  b    quit
op17:
  b    quit
op18:  // CLC
  _clx FLAG_C
  _decode
op19:
  b    quit
op1a:
  b    quit
op1b:
  b    quit
op1c:
  b    quit
op1d:
  b    quit
op1e:
  b    quit
op1f:
  b    quit
op20:  // JSR
  adds T0, PC, #2
  _push16 T0
  adds r0, PC, #1
  _ldw
  mov  PC, r0
  _decode
op21:
  b    quit
op22:
  b    quit
op23:
  b    quit
op24:
  b    quit
op25:
  b    quit
op26:
  b    quit
op27:
  b    quit
op28:
  b    quit
op29:
  b    quit
op2a:
  b    quit
op2b:
  b    quit
op2c:
  b    quit
op2d:
  b    quit
op2e:
  b    quit
op2f:
  b    quit
op30:
  b    quit
op31:
  b    quit
op32:
  b    quit
op33:
  b    quit
op34:
  b    quit
op35:
  b    quit
op36:
  b    quit
op37:
  b    quit
op38:  // SEC
  _sex FLAG_C
  _decode
op39:
  b    quit
op3a:
  b    quit
op3b:
  b    quit
op3c:
  b    quit
op3d:
  b    quit
op3e:
  b    quit
op3f:
  b    quit
op40:
  b    quit
op41:
  b    quit
op42:
  b    quit
op43:
  b    quit
op44:
  b    quit
op45:
  b    quit
op46:
  b    quit
op47:
  b    quit
op48:
  b    quit
op49:
  b    quit
op4a:
  b    quit
op4b:
  b    quit
op4c:
  b    quit
op4d:
  b    quit
op4e:
  b    quit
op4f:
  b    quit
op50:
  b    quit
op51:
  b    quit
op52:
  b    quit
op53:
  b    quit
op54:
  b    quit
op55:
  b    quit
op56:
  b    quit
op57:
  b    quit
op58:  // CLI
  _clx FLAG_I
  _decode
op59:
  b    quit
op5a:
  b    quit
op5b:
  b    quit
op5c:
  b    quit
op5d:
  b    quit
op5e:
  b    quit
op5f:
  b    quit
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
op84:
  b    quit
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
  _fromImm8
  _ld  RY
  _decode
opa1:
  b    quit
opa2:  // LDX - Immediate
  _fromImm8
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
  _fromImm8
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
opd0:
  b    quit
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

// void decode();
  .type decode, %function
decode:
  bl   dump
  mov  r0, PC
  _ldb
  lsls r1, r0, #2
  ldr  r2, =#op_table
  adds r3, r2, r1
  ldr  r1, [r3]
  mov  pc, r1

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

