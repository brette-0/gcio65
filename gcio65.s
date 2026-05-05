; vim: ft=asm_ca65

.feature line_continuations +

.include "__CWriteBit.s"

.enum
    GCIO_LEGACY
    GCIO_REPORT
    GCIO_BEHAVE
    GCIO_INVERT
    GCIO_RUMBLE
    GCIO_LSETUP
    GCIO_END
.endenum

.if ((1 << 31) + 1) < 0
    .ifndef ca6532
        .define ca6532
    .endif
.else
    .ifndef ca6564
        .define ca6564
    .endif
.endif

.scope gcio
    .segment ZP
        ptr:    .res 2
        size:   .res 1
        
    .import port1

    .define concat(foo, bar) foo ## bar
    .define ld(r) ld ## r
    .define st(r) st ## r
    .define de(i) de ## i
    .define in(i) in ## i

    .ifndef IOPORT1
        .define IOPORT1 $4016
        .define IOPORT2 $4017
    .endif

    .if ca6564
        .define sr(n, s) (n >> s)
    .else
        .define sr(n, s) ((                     \
                .mid( 0, 32, {n}) * (s > 31) +  \
                .mid(32, 32, {n}) * (s < 32)    \
            ) >> (s & $ffff_ffff)               \
        )
    .endif

    .segment CODE:

        ; in {
        ;   ptr = (const u64*)(x << 8 | a)
        ; }
        ;
        ; out {
        ;   n = 0
        ;   z = 1
        ;   c = *ptr & 0x80
        ;   x = 0
        ;   y = 0
        ;   a = 0
        ; }
        .proc ChangeInvert
            .local loop, bigLoop
            sta ptr
            stx ptr + 1
           
            lda #7
            tay
            stx IOPORT1

            ; switch mode
            .repeat _, GCIO_INVERT
                bit IOPORT1
            .endrepeat
            
            @bigLoop:
                ldx #8
            @loop:
                lda [ptr], y
                sta IOPORT1
                bit IOPORT1
                lsr
                dex
                bne loop
            dey
            bne @bigLoop
            rts
        .endproc

        ; in {
        ;   behave = a
        ; }
        ;
        ; out {
        ;   a = 64 - (
        ;           behave & 0x80
        ;               ? 16
        ;               : 0
        ;       ) - (
        ;           behave & 0x40 
        ;               ? 16
        ;               : 0
        ;       ) - (
        ;           behave & 0x20
        ;               ? 16
        ;               : behave & 0x10
        ;                   ? 8
        ;                   : 0
        ;       )
        ;
        ;   x = ((behave & 0xe0) >> 4) + (behave & 0x20
        ;       ? 0
        ;       : behave & 0x10
        ;           ? 1
        ;           : 0
        ;       )
        ;
        ;   z = 0
        ;   c = 1
        ;   n = 0
        ; }
        .proc ChangeBehavior
            .local loop

            ldx #9
            stx IOPORT1
            .repeat _, GCIO_BEHAVE
                bit IOPORT1
            .endrepeat
            dex
            stx IOPORT1
            
            ror
            @loop:
                sta IOPORT1
                bit IOPORT1
                ror
                dex
                bne @loop
            
            ldx #8
            ror
            bpl @checkLStick
            dex
            dex

            @checkLStick:
                asl
                bpl @checkHasTriggers
                dex
                dex

            @checkHasTriggers:
                asl
                bpl @checkUnifiedTriggers
                dex
                dex
                bne @apply

            @checkUnifiedTriggers:
                asl
                bpl @apply
                dex
            @apply: 
                stx len
                rts
        .endproc


        ; in {
        ;   out = (u64*)(a << 8 | x)
        ; }
        ;
        ; out {
        ;   *out = ?
        ;   x = 0
        ;   a = 0
        ;   c = 1
        ;   n = ?
        ;   z = ?
        ; }
        .proc Report
            stx ptr + 1
            sta ptr
            ldx len
            lda #1
            sta IOPORT1
            .repeat _, GCIO_REPORT
                bit IOPORT1
            .endrepeat
            lsr
            sta IOPORT1

            @bigLoop:
                lda #0
                sta port1, x
                rol port1, x
            @smallLoop:
                lda IOPORT1
                lsr
                rol port1, x
                bcc @smallLoop
                dex
                bne @bigLoop
            rts
        .endproc
.endscope

.export gcio::SetInvert
