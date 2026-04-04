// vim: ft=c_cc65

#ifndef GCIO65_H
#define GCIO65_H

#include <stdint.h>

#define PEEK(addr)      (*(volatile unsigned char*)(addr))
#define POKE(addr, val) (*(volatile unsigned char*)(addr) = (val))

enum Tasks {
    LEGACY,
    REPORT,
    BEHAVE,
    INMASK,
    INVERT,
    RUMBLE,
    LSETUP,
    END
}

namespace gcio {
    void __fastcall__ RTChangeBehavior(const uint8_t behavior);
    void __fastcall__ RTChangeMask(const uint8_t* mask);
    void __fastcall__ RTChangeInvert(const uint8_t* invert);
}

#define IOPORT1 0x4016

__asm__(".include \"__CWriteBit.s\"")

#define WRITE_BIT(msg, s) __asm__("__CWriteBit %n, %n, a", msg, s)

#define CHANGE_BEHAVIOR(msg)              \
    __asm__("pha\n"                       \
            "__CWriteBit %b, 0, a\n"      \
            "__CWriteBit %b, 1, a\n"      \
            "__CWriteBit %b, 2, a\n"      \
            "__CWriteBit %b, 3, a\n"      \
            "__CWriteBit %b, 4, a\n"      \
            "__CWriteBit %b, 5, a\n"      \
            "__CWriteBit %b, 6, a\n"      \
            "__CWriteBit %b, 7, a\n"      \
            "pla", msg, msg, msg, msg,    \
            msg, msg, msg, msg)         

#endif
