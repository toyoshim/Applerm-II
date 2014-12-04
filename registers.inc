  .equ U0RBR,         0x40008000
  .equ U0THR,         0x40008000
  .equ U0DLL,         0x40008000
  .equ U0DLM,         0x40008004
  .equ U0IER,         0x40008004
  .equ U0IIR,         0x40008008
  .equ U0FCR,         0x40008008
    .equ FIFO_ENABLE, (1 << 0)
    .equ RX_RESET,    (1 << 1)
    .equ TX_RESET,    (1 << 2)
  .equ U0LCR,         0x4000800c
    .equ WORD_LEN_5,    0
    .equ WORD_LEN_6,    1
    .equ WORD_LEN_7,    2
    .equ WORD_LEN_8,    3
    .equ STOP_BIT_1,    (0 << 2)
    .equ STOP_BIT_2,    (1 << 2)
    .equ PARITY_DISABLE,(0 << 3)
    .equ PARITY_ENABLE, (1 << 3)
    .equ PARITY_EVEN,   (0 << 4)
    .equ PARITY_ODD,    (1 << 4)
    .equ PARITY_1,      (2 << 4)
    .equ PARITY_0,      (3 << 4)
    .equ BREAK_DISABLE, (0 << 6)
    .equ BREAK_ENABLE,  (1 << 6)
    .equ DLAB_DISABLE,  (0 << 7)
    .equ DLAB_ENABLE,   (1 << 7)
  .equ U0MCR,         0x40008010
  .equ U0LSR,         0x40008014
    .equ LSR_THRE, (1 << 5)
  .equ U0MSR,         0x40008018
  .equ U0SCR,         0x4000801c
  .equ U0ACR,         0x40008020
  .equ U0FDR,         0x40008028
    .equ MULVAL_SHIFT, 4
  .equ U0TER,         0x40008030
    .equ TXEN, (1 << 7)
  .equ U0RS485CTRL,   0x4000804c
  .equ U0ADRMATCH,    0x40008050
  .equ U0RS485DLY,    0x40008054

  .equ IOCON_PIO2_0,  0x40044008
    .equ FUNC_PIO,  0
    .equ FUNC_DTR,  1
    .equ FUNC_SSEL, 2
    .equ MODE_DOWN, (1 << 3)
    .equ MODE_UP,   (2 << 3)
    .equ MODE_REP,  (3 << 3)
    .equ HYS_EN,    (1 << 5)
    .equ PIO_BASE,  (3 << 6)
    .equ PIO_MASK,  0x3f
  .equ IOCON_PIO1_5,  0x400440a0
    .equ FUNC_RTS,  1
    .equ FUNC_CT32, 2
  .equ IOCON_PIO1_6,  0x400440a4
    .equ FUNC_RXD,  1
  .equ IOCON_PIO1_7,  0x400440a8
    .equ FUNC_TXD,  1

  .equ SYSAHBCLKCTRL, 0x40048080
    .equ CLK_IOCON, (1 << 16)
    .equ CLK_UART,  (1 << 12)

  .equ UARTCLKDIV,    0x40048098

  .equ GPIO0DATA,     0x50003ffc
  .equ GPIO0DIR,      0x50008000
  .equ GPIO0IS,       0x50008004
  .equ GPIO0IBE,      0x50008008
  .equ GPIO0IEV,      0x5000800c
  .equ GPIO0IE,       0x50008010
  .equ GPIO0RIS,      0x50008014
  .equ GPIO0MIS,      0x50008018
  .equ GPIO0IC,       0x5000801c

  .equ GPIO1DATA,     0x50013ffc
  .equ GPIO1DIR,      0x50018000
  .equ GPIO1IS,       0x50018004
  .equ GPIO1IBE,      0x50018008
  .equ GPIO1IEV,      0x5001800c
  .equ GPIO1IE,       0x50018010
  .equ GPIO1RIS,      0x50018014
  .equ GPIO1MIS,      0x50018018
  .equ GPIO1IC,       0x5001801c

  .equ GPIO2DATA,     0x50023ffc
  .equ GPIO2DIR,      0x50028000
  .equ GPIO2IS,       0x50028004
  .equ GPIO2IBE,      0x50028008
  .equ GPIO2IEV,      0x5002800c
  .equ GPIO2IE,       0x50028010
  .equ GPIO2RIS,      0x50028014
  .equ GPIO2MIS,      0x50028018
  .equ GPIO2IC,       0x5002801c
