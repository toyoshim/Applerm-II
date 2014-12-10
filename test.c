#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static uint8_t mem[0x10000];
static uint8_t key = 0x80;
static char keyString[] = "10 print \"hello\"\r20 end\rlist\rrun\r";
static uint32_t keyCount = 0;
static uint8_t last = 0x00;

void prn(int c) {
  uint32_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  fprintf(stderr, "### $%02x ###\n", c);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
}

void cpu6502_dump(uint32_t pc, uint32_t a, uint32_t x, uint32_t y,
                  uint32_t sp, uint32_t sr) {
  /*
  uint32_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  assert(pc < 0x10000);
  assert(a < 0x100);
  assert(x < 0x100);
  assert(y < 0x100);
  assert(sr < 0x100);
  assert(0x100 <= sp && sp < 0x200);
  fprintf(stderr, "*** dump *** PC=$%04x A=$%02x X=$%02x Y=$%02x SP=$%02x "
          "NV-B_DIZC=%d%d-%d_%d%d%d%d\n",
          pc, a, x, y, sp & 0xff, (sr >> 7) & 1, (sr >> 6) & 1, (sr >> 4) & 1,
          (sr >> 3) & 1, (sr >> 2) & 1, (sr >> 1) & 1, sr & 1);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
  */
}

uint8_t cpu6502_load(uint16_t addr) {
  uint32_t fp;
  uint8_t result = 0;
  __asm__("movs %0, r12": "=r"(fp));
  if (0x0400 <= addr && addr <= 0x7ff) {
    // Fake text VRAM.
    result = mem[addr];
    result = '@';
  } else if ((0x0300 <= addr && addr <= 0x03ff) ||
             (0x0900 <= addr && addr <= 0x0fff)) {
    // Fake memory impl to make it run on low memory chip.
    result = last;
  } else if (0x1000 <= addr & addr < 0xbfff) {
    // Bus error due to minimum memory installation.
    return 0xff;
    fprintf(stdout, "\e[1;1Hinvalid load $%04x\n", addr);
    fflush(stdout);
    abort();
  } else if (0xc000 <= addr & addr < 0xcfff) {
    // I/O emulation.
    if (0xc000 == addr) {
      keyCount++;
      if (keyCount < 0x800) {
        result = key;
      } else if (keyCount & 0xff) {
        result = key;
      } else {
        uint32_t n = (keyCount - 0x800) >> 8;
        if (n < sizeof(keyString))
          key = keyString[n] | 0x80;
        result = key;
      }
    } else if (0xc010 == addr) {
      key &= 0x7f;
      result = 0;
    }
  } else {
    // Installed memory.
    result = mem[addr];
  }
  fprintf(stderr, "load  $%04x => $%02x\n", addr, result);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
  return result;
}

void cpu6502_store(uint16_t addr, uint8_t data) {
  uint32_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  if (0x0400 <= addr && addr <= 0x7ff) {
    // Fake text VRAM.
    char ascii[0x40] =
        "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ !\"#$%&'()*+,-./0123456789:;<=>?";
    mem[addr] = data;
    int y = (addr - 0x400) >> 7;
    int x = addr & 0x7f;
    if (x >= 0x50) {
      x -= 0x50;
      y += 0x10;
    } else if (x >= 0x28) {
      x -= 0x28;
      y += 0x08;
    }
    // Note: Apple2 BASIC initializes screen as:
    // 1) Fill screen with ' ' from left to right, then up to down.
    //   for (var y = 0; y < 24; ++y)
    //     for (var x = 0; x < 40; ++x)
    //       clear x, y
    // 2) Show "APPLE ][" from back to forth.
    // 3) Count down from G to A at x = 40, y = 23
    // 4) Scroll happens on CR at line 22 or 23, left to right, up to down
    //   for (var y = 0; y < 23; ++y)
    //     for (var x = 39; x >= 0; --x)
    //       reset x, y
    //   for (var x = 0; x < 40; ++x)
    //     clear x, 23
    //   prompt 0, 23
    //fprintf(stdout, "\e[%d;%dH%c", y + 7, x + 1, ascii[data & 0x3f]);
    fprintf(stdout, "(%2d,%2d)%c($%02x)\n", x, y, ascii[data & 0x3f], data);
    fflush(stdout);
  } else if ((0x0300 <= addr && addr <= 0x03ff) ||
             (0x0900 <= addr && addr <= 0x0fff)) {
    // Fake memory impl to make it run on low memory chip.
    last = data;
  } else if (0x1000 <= addr & addr < 0xbfff) {
    // Bus error due to minimum memory installation.
    return;
    fprintf(stdout, "\e[1;1Hinvalid store $%04x\n", addr);
    fflush(stdout);
    abort();
  } else if (0xc000 <= addr & addr < 0xcfff) {
    // I/O emulation.
    if (0xc000 == addr)
      key = data;
  } else {
    // Installed memory.
    mem[addr] = data;
  }
  fprintf(stderr, "store $%04x <= $%02x\n", addr, data);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
}

int main(int argc, char** argv) {
  FILE* fp = fopen("applebasic.rom", "rb");
  //FILE* fp = fopen("apple2o.rom", "rb");
  memset(mem, 0, 0x10000);
  fread(&mem[0xd000], 1, 0x3000, fp);
  fclose(fp);
  cpu6502_reset();
  fprintf(stderr, "quit: $%04x\n", cpu6502_run());
  return 0;
}

