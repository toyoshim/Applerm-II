#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static uint8_t mem[0x10000];
extern uint32_t cpu6502_pc;

void prn(int c) {
  uint8_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  fprintf(stderr, "### $%02x ###\n", c);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
}

void cpu6502_dump(uint32_t pc, uint32_t a, uint32_t x, uint32_t y,
                  uint32_t sp, uint32_t sr) {
  uint32_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  fprintf(stderr, "*** dump *** PC=$%04x A=$%02x X=$%02x Y=$%02x SP=$%02x "
          "NV-B_DIZC=%d%d-%d_%d%d%d%d\n",
          pc, a, x, y, sp & 0xff, (sr >> 7) & 1, (sr >> 6) & 1, (sr >> 4) & 1,
          (sr >> 3) & 1, (sr >> 2) & 1, (sr >> 1) & 1, sr & 1);
  fflush(stderr);
  assert(pc < 0x10000);
  assert(a < 0x100);
  assert(x < 0x100);
  assert(y < 0x100);
  assert(sr < 0x100);
  assert(0x100 <= sp && sp < 0x200);
  __asm__("movs r12, %0":: "r"(fp));
}

uint8_t cpu6502_load(uint16_t addr) {
  uint32_t fp;
  uint8_t result = 0;
  __asm__("movs %0, r12": "=r"(fp));
  result = mem[addr];
  fprintf(stderr, "load  $%04x => $%02x\n", addr, result);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
  return result;
}

void cpu6502_store(uint16_t addr, uint8_t data) {
  uint32_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  mem[addr] = data;
  fprintf(stderr, "store $%04x <= $%02x\n", addr, data);
  fflush(stderr);
  __asm__("movs r12, %0":: "r"(fp));
}

int main(int argc, char** argv) {
  FILE* fp = fopen("6502_functional_test.bin", "rb");
  fread(mem, 1, 0x10000, fp);
  fclose(fp);
  cpu6502_reset();
  cpu6502_pc = 0x400;
  fprintf(stderr, "quit: $%04x\n", cpu6502_run());
  return 0;
}

