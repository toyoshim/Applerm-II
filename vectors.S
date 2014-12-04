  .syntax unified
  .cpu cortex-m0
  .align 2
  .thumb
  .thumb_func

  .section .isr_vector

  .long _stack_top      // 0x0000
  .long _reset          // 0x0004
  .long _nmi            // 0x0008
  .long _hard_fault     // 0x000c
  .long _reserved       // 0x0010
  .long _reserved       // 0x0014
  .long _reserved       // 0x0018
  .long _reserved       // 0x001c
  .long _reserved       // 0x0020
  .long _reserved       // 0x0024
  .long _reserved       // 0x0028
  .long _svc            // 0x002c
  .long _reserved       // 0x0030
  .long _reserved       // 0x0034
  .long _pend_sv        // 0x0038
  .long _sys_tick       // 0x003c
  .long _pio0_0_wakeup  // 0x0040
  .long _pio0_1_wakeup  // 0x0044
  .long _pio0_2_wakeup  // 0x0048
  .long _pio0_3_wakeup  // 0x004c
  .long _pio0_4_wakeup  // 0x0050
  .long _pio0_5_wakeup  // 0x0054
  .long _pio0_6_wakeup  // 0x0058
  .long _pio0_7_wakeup  // 0x005c
  .long _pio0_8_wakeup  // 0x0060
  .long _pio0_9_wakeup  // 0x0064
  .long _pio0_10_wakeup // 0x0068
  .long _pio0_11_wakeup // 0x006c
  .long _pio1_0_wakeup  // 0x0070
  .long _c_can          // 0x0074
  .long _ssp1           // 0x0078
  .long _i2c            // 0x007c
  .long _ct16b0         // 0x0080
  .long _ct16b1         // 0x0084
  .long _ct32b0         // 0x0088
  .long _ct32b1         // 0x008c
  .long _ssp0           // 0x0090
  .long _uart           // 0x0094
  .long _reserved       // 0x0098
  .long _reserved       // 0x009c
  .long _adc            // 0x00a0
  .long _wdt            // 0x00a4
  .long _bod            // 0x00a8
  .long _reserved       // 0x00ac
  .long _int3           // 0x00b0
  .long _int2           // 0x00b4
  .long _int1           // 0x00b8
  .long _int0           // 0x00bc

  .text

_adc:
_bod:
_c_can:
_ct16b0:
_ct16b1:
_ct32b0:
_ct32b1:
_hard_fault:
_i2c:
_int0:
_int1:
_int2:
_int3:
_nmi:
_pend_sv:
_pio0_0_wakeup:
_pio0_1_wakeup:
_pio0_2_wakeup:
_pio0_3_wakeup:
_pio0_4_wakeup:
_pio0_5_wakeup:
_pio0_6_wakeup:
_pio0_7_wakeup:
_pio0_8_wakeup:
_pio0_9_wakeup:
_pio0_10_wakeup:
_pio0_11_wakeup:
_pio1_0_wakeup:
_reserved:
//_reset:
_ssp0:
_ssp1:
_svc:
_sys_tick:
_uart:
_wdt:
loop:
  b loop
