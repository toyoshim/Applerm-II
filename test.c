#include <stdio.h>
#include <stdint.h>
#include <string.h>

uint8_t mem[0x10000];

void prn(int c) {
  uint8_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  printf("### $%02x ###\n", c);
  __asm__("movs r12, %0":: "r"(fp));
}

void cpu6502_dump(
    uint16_t pc, uint8_t a, uint8_t x, uint8_t y, uint8_t sp, uint8_t sr) {
  uint8_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  printf("*** dump *** PC=$%04x A=$%02x X=$%02x Y=$%02x SP=$%02x "
         "NV-B_DIZC=%d%d-%d_%d%d%d%d\n",
         pc, a, x, y, sp, (sr >> 7) & 1, (sr >> 6) & 1, (sr >> 4) & 1,
         (sr >> 3) & 1, (sr >> 2) & 1, (sr >> 1) & 1, sr & 1);
  fflush(stdout);
  __asm__("movs r12, %0":: "r"(fp));
}

uint8_t cpu6502_load(uint16_t addr) {
  uint8_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  printf("load  $%04x => $%02x\n", addr, mem[addr]);
  fflush(stdout);
  __asm__("movs r12, %0":: "r"(fp));
  return mem[addr];
}

void cpu6502_store(uint16_t addr, uint8_t data) {
  uint8_t fp;
  __asm__("movs %0, r12": "=r"(fp));
  printf("store $%04x <= $%02x\n", addr, data);
  fflush(stdout);
  __asm__("movs r12, %0":: "r"(fp));
  mem[addr] = data;
}

int main(int argc, char** argv) {
  FILE* fp = fopen("applebasic.rom", "rb");
  memset(mem, 0, 0x10000);
  fread(&mem[0xd000], 1, 0x3000, fp);
  fclose(fp);
  cpu6502_reset();
  printf("quit: $%04x\n", cpu6502_run());
  return 0;
}

