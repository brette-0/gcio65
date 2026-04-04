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

#define SETUP_POLL              \
        POKE(IOPORT1, 1);       \
        (void*)PEEK(IOPORT1);   \
        (void*)PEEK(IOPORT1);   \
        POKE(IOPORT1, 0);   

#define IOPORT1 0x4016

__asm__(".include \"__CWriteBit.s\"")

#define WRITE_BIT(msg, s) __asm__("__CWriteBit %n, %n, a", msg, s)

#define CHANGE_BEHAVIOR(msg)              \
    POKE(IOPORT1, 1);                     \
    (void*)PEEK(IOPORT1);                 \
    (void*)PEEK(IOPORT1);                 \
    POKE(IOPORT1, 0);                     \
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

#define WRITE_QWORD(msg)                   \
    __asm__("pha\n"                        \
            "__CWriteBit %b, 0, a\n"       \
            "__CWriteBit %b, 1, a\n"       \
            "__CWriteBit %b, 2, a\n"       \
            "__CWriteBit %b, 3, a\n"       \
            "__CWriteBit %b, 4, a\n"       \
            "__CWriteBit %b, 5, a\n"       \
            "__CWriteBit %b, 6, a\n"       \
            "__CWriteBit %b, 7, a\n"       \
            "__CWriteBit %b, 8, a\n"       \
            "__CWriteBit %b, 9, a\n"       \
            "__CWriteBit %b, 10, a\n"      \
            "__CWriteBit %b, 11, a\n"      \
            "__CWriteBit %b, 12, a\n"      \
            "__CWriteBit %b, 13, a\n"      \
            "__CWriteBit %b, 14, a\n"      \
            "__CWriteBit %b, 15, a\n"      \
            "__CWriteBit %b, 16, a\n"      \
            "__CWriteBit %b, 17, a\n"      \
            "__CWriteBit %b, 18, a\n"      \
            "__CWriteBit %b, 19, a\n"      \
            "__CWriteBit %b, 20, a\n"      \
            "__CWriteBit %b, 21, a\n"      \
            "__CWriteBit %b, 22, a\n"      \
            "__CWriteBit %b, 23, a\n"      \
            "__CWriteBit %b, 24, a\n"      \
            "__CWriteBit %b, 25, a\n"      \
            "__CWriteBit %b, 26, a\n"      \
            "__CWriteBit %b, 27, a\n"      \
            "__CWriteBit %b, 28, a\n"      \
            "__CWriteBit %b, 29, a\n"      \
            "__CWriteBit %b, 30, a\n"      \
            "__CWriteBit %b, 31, a\n"      \
            "__CWriteBit %b, 32, a\n"      \
            "__CWriteBit %b, 33, a\n"      \
            "__CWriteBit %b, 34, a\n"      \
            "__CWriteBit %b, 35, a\n"      \
            "__CWriteBit %b, 36, a\n"      \
            "__CWriteBit %b, 37, a\n"      \
            "__CWriteBit %b, 38, a\n"      \
            "__CWriteBit %b, 39, a\n"      \
            "__CWriteBit %b, 40, a\n"      \
            "__CWriteBit %b, 41, a\n"      \
            "__CWriteBit %b, 42, a\n"      \
            "__CWriteBit %b, 43, a\n"      \
            "__CWriteBit %b, 44, a\n"      \
            "__CWriteBit %b, 45, a\n"      \
            "__CWriteBit %b, 46, a\n"      \
            "__CWriteBit %b, 47, a\n"      \
            "__CWriteBit %b, 48, a\n"      \
            "__CWriteBit %b, 49, a\n"      \
            "__CWriteBit %b, 50, a\n"      \
            "__CWriteBit %b, 51, a\n"      \
            "__CWriteBit %b, 52, a\n"      \
            "__CWriteBit %b, 53, a\n"      \
            "__CWriteBit %b, 54, a\n"      \
            "__CWriteBit %b, 55, a\n"      \
            "__CWriteBit %b, 56, a\n"      \
            "__CWriteBit %b, 57, a\n"      \
            "__CWriteBit %b, 58, a\n"      \
            "__CWriteBit %b, 59, a\n"      \
            "__CWriteBit %b, 60, a\n"      \
            "__CWriteBit %b, 61, a\n"      \
            "__CWriteBit %b, 62, a\n"      \
            "__CWriteBit %b, 63, a\n"      \
            "pla",                         \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg,            \
            msg, msg, msg, msg)

#define CHANGE_MASK(mask)                   \
    POKE(IOPORT1, 1);                       \
    (void*)PEEK(IOPORT1);                   \
    (void*)PEEK(IOPORT1);                   \
    (void*)PEEK(IOPORT1);                   \
    POKE(IOPORT1, 0);                       \
    WRITE_QWORD(mask)                       \

#define CHANGE_INVERT(invert)               \
    POKE(IOPORT1, 1);                       \
    (void*)PEEK(IOPORT1);                   \
    (void*)PEEK(IOPORT1);                   \
    (void*)PEEK(IOPORT1);                   \
    (void*)PEEK(IOPORT1);                   \
    POKE(IOPORT1, 0);                       \
    WRITE_QWORD(mask)                       \
#endif
