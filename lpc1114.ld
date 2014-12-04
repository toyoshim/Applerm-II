MEMORY
{
  flash (rx)  : ORIGIN = 0x00000000, LENGTH = 32K
  sram  (rwx) : ORIGIN = 0x10000000, LENGTH = 4K
}

SECTIONS
{
  .text : ALIGN(4) {
    _vector_start = .;
    KEEP(*(.isr_vector))
    _vector_end = .;

    _text_start = .;
    KEEP(*(.text))
    _text_end = .;

    _rodata_start = .;
    KEEP(*(.rodata))
    _rodata_end = .;
  } > flash

  .data : ALIGN(4) {
    _data_start = .;
    KEEP(*(.data))
    _data_end = .;
  } > sram AT > flash

  .bss : ALIGN(4) {
    _bss_start = .;
    KEEP(*(.bss))
    _bss_end = .;
  } > sram

  _stack_top = 0x10001000;
}

