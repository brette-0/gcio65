// vim: ft=c_cc65

#include <stdint.h>
#include "gcio65.h"

#define SEND_QWORD(buffer)                  \
    __asm__("  tya");                       \
    __asm__("  pha");                       \
    __asm__("  ldx #0");                    \
    __asm__(": ldy #8");                    \
    __asm__(": lsr %v,x", buffer);          \
    __asm__("  lda #0");                    \
    __asm__("  rol a");                     \
    __asm__("  sta $4016");                 \
    __asm__("  bit $4016");                 \
    __asm__("  dey");                       \
    __asm__("  bne :-");                    \
    __asm__("  inx");                       \
    __asm__("  cpx #8");                    \
    __asm__("  bne :---");                  \
    __asm__("  pla");                       \
    __asm__("  tay")

namespace gcio {
    void __fastcall__ RTChangeBehavior(uint8_t behavior) {
        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);             // switch to behavior change mode

        __asm__("ldx #8");
        __asm__(": lsr a");
        __asm__("pha");
        __asm__("lda #0");
        __asm__("rol a");
        __asm__("sta $4016");
        __asm__("bit $4016");
        __asm__("pla");
        __asm__("dex");
        __asm__("bne :-");
        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1); 
        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);            // reset to poll
    }

    void __fastcall__ RTChangeMask(const uint8_t* mask){
        static uint8_t bits;
        static uint8_t byte;

        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);
        POKE(IOPORT1, 1);   // set mode to change mask

        SEND_QWORD(mask);

        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);  // reset to poll
    }

    void __fastcall__ RTChangeInvert(const uint8_t* invert){
        static uint8_t _nInvert = nInvert;
        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1); 
        POKE(IOPORT1, 1);  // set mode to invert
        
        SEND_QWORD(invert);

        (void)PEEK(IOPORT1);
        (void)PEEK(IOPORT1);    
    } 
}
