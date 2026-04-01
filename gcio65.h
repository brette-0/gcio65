// vim: ft=c_cc65

#ifndef GCIO65_H
#define GCIO65_H

#include <stdint.h>

#define PEEK(addr)      (*(volatile unsigned char*)(addr))
#define POKE(addr, val) (*(volatile unsigned char*)(addr) = (val))

enum Tasks {
    REPORT,
    BEHAVE,
    INMASK,
    INVERT,
    RUMBLE,
    END
}

namespace gcio {
    void __fastcall__ RTChangeBehavior(const uint8_t behavior);
}

#define IOPORT1 0x4016

#define SEND_BIT(val, bit)                 \
    if ((val) & (1 << (bit))) {            \
        POKE(IOPORT1, 1);                  \
    } else {                               \
        ((void)PEEK(IOPORT1));             \
    }

#define CChangeBehavior(behavior) \
    ((void)PEEK(IOPORT1));        \
    SEND_BIT(behavior, 0);        \
    SEND_BIT(behavior, 1);        \
    SEND_BIT(behavior, 2);        \
    SEND_BIT(behavior, 3);        \
    SEND_BIT(behavior, 4);        \
    SEND_BIT(behavior, 5);        \
    SEND_BIT(behavior, 6);        \
    SEND_BIT(behavior, 7);        \
    ((void)PEEK(IOPORT1));        \
    ((void)PEEK(IOPORT1));        \
    ((void)PEEK(IOPORT1));        \
    ((void)PEEK(IOPORT1));

#define CChangeMask(mask)  \
    ((void)PEEK(IOPORT1)); \
    ((void)PEEK(IOPORT1)); \
    SEND_BIT(mask,  0);    \
    SEND_BIT(mask,  1);    \
    SEND_BIT(mask,  2);    \
    SEND_BIT(mask,  3);    \
    SEND_BIT(mask,  4);    \
    SEND_BIT(mask,  5);    \
    SEND_BIT(mask,  6);    \
    SEND_BIT(mask,  7);    \
    SEND_BIT(mask,  8);    \
    SEND_BIT(mask,  9);    \
    SEND_BIT(mask, 10);    \
    SEND_BIT(mask, 11);    \
    SEND_BIT(mask, 12);    \
    SEND_BIT(mask, 13);    \
    SEND_BIT(mask, 14);    \
    SEND_BIT(mask, 15);    \
    SEND_BIT(mask, 16);    \
    SEND_BIT(mask, 17);    \
    SEND_BIT(mask, 18);    \
    SEND_BIT(mask, 19);    \
    SEND_BIT(mask, 20);    \
    SEND_BIT(mask, 21);    \
    SEND_BIT(mask, 22);    \
    SEND_BIT(mask, 23);    \
    SEND_BIT(mask, 24);    \
    SEND_BIT(mask, 25);    \
    SEND_BIT(mask, 26);    \
    SEND_BIT(mask, 27);    \
    SEND_BIT(mask, 28);    \
    SEND_BIT(mask, 29);    \
    SEND_BIT(mask, 30);    \
    SEND_BIT(mask, 31);    \
    SEND_BIT(mask, 32);    \
    SEND_BIT(mask, 33);    \
    SEND_BIT(mask, 34);    \
    SEND_BIT(mask, 35);    \
    SEND_BIT(mask, 36);    \
    SEND_BIT(mask, 37);    \
    SEND_BIT(mask, 38);    \
    SEND_BIT(mask, 39);    \
    SEND_BIT(mask, 40);    \
    SEND_BIT(mask, 41);    \
    SEND_BIT(mask, 42);    \
    SEND_BIT(mask, 43);    \
    SEND_BIT(mask, 44);    \
    SEND_BIT(mask, 45);    \
    SEND_BIT(mask, 46);    \
    SEND_BIT(mask, 47);    \
    SEND_BIT(mask, 48);    \
    SEND_BIT(mask, 49);    \
    SEND_BIT(mask, 50);    \
    SEND_BIT(mask, 51);    \
    SEND_BIT(mask, 52);    \
    SEND_BIT(mask, 53);    \
    SEND_BIT(mask, 54);    \
    SEND_BIT(mask, 55);    \
    SEND_BIT(mask, 56);    \
    SEND_BIT(mask, 57);    \
    SEND_BIT(mask, 58);    \
    SEND_BIT(mask, 59);    \
    SEND_BIT(mask, 60);    \
    SEND_BIT(mask, 61);    \
    SEND_BIT(mask, 62);    \
    SEND_BIT(mask, 63);    \
    ((void)PEEK(IOPORT1)); \
    ((void)PEEK(IOPORT1)); \
    ((void)PEEK(IOPORT1)); \

#define CChangeInvert(invert)  \
    ((void)PEEK(IOPORT1)); \
    ((void)PEEK(IOPORT1)); \
    ((void)PEEK(IOPORT1)); \
    SEND_BIT(invert,  0);  \
    SEND_BIT(invert,  2);  \
    SEND_BIT(invert,  3);  \
    SEND_BIT(invert,  4);  \
    SEND_BIT(invert,  5);  \
    SEND_BIT(invert,  6);  \
    SEND_BIT(invert,  7);  \
    SEND_BIT(invert,  8);  \
    SEND_BIT(invert,  9);  \
    SEND_BIT(invert, 10);  \
    SEND_BIT(invert, 11);  \
    SEND_BIT(invert, 13);  \
    SEND_BIT(invert, 14);  \
    SEND_BIT(invert, 15);  \
    SEND_BIT(invert, 16);  \
    SEND_BIT(invert, 17);  \
    SEND_BIT(invert, 18);  \
    SEND_BIT(invert, 19);  \
    SEND_BIT(invert, 20);  \
    SEND_BIT(invert, 21);  \
    SEND_BIT(invert, 22);  \
    SEND_BIT(invert, 23);  \
    SEND_BIT(invert, 24);  \
    SEND_BIT(invert, 25);  \
    SEND_BIT(invert, 26);  \
    SEND_BIT(invert, 27);  \
    SEND_BIT(invert, 28);  \
    SEND_BIT(invert, 29);  \
    SEND_BIT(invert, 30);  \
    SEND_BIT(invert, 31);  \
    SEND_BIT(invert, 32);  \
    SEND_BIT(invert, 33);  \
    SEND_BIT(invert, 34);  \
    SEND_BIT(invert, 35);  \
    SEND_BIT(invert, 36);  \
    SEND_BIT(invert, 37);  \
    SEND_BIT(invert, 38);  \
    SEND_BIT(invert, 39);  \
    SEND_BIT(invert, 40);  \
    SEND_BIT(invert, 41);  \
    SEND_BIT(invert, 42);  \
    SEND_BIT(invert, 43);  \
    SEND_BIT(invert, 44);  \
    SEND_BIT(invert, 45);  \
    SEND_BIT(invert, 46);  \
    SEND_BIT(invert, 47);  \
    SEND_BIT(invert, 48);  \
    SEND_BIT(invert, 49);  \
    SEND_BIT(invert, 50);  \
    SEND_BIT(invert, 51);  \
    SEND_BIT(invert, 52);  \
    SEND_BIT(invert, 53);  \
    SEND_BIT(invert, 54);  \
    SEND_BIT(invert, 55);  \
    SEND_BIT(invert, 56);  \
    SEND_BIT(invert, 57);  \
    SEND_BIT(invert, 58);  \
    SEND_BIT(invert, 59);  \
    SEND_BIT(invert, 60);  \
    SEND_BIT(invert, 61);  \
    SEND_BIT(invert, 62);  \
    SEND_BIT(invert, 63);  \
    ((void)PEEK(IOPORT1)); \
    ((void)PEEK(IOPORT1)); \
#endif
