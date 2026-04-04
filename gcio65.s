; vim: ft=asm_ca65

.feature line_continuations +

.include "__CWriteBit.s"

.enum
    GCIO_LEGACY
    GCIO_REPORT
    GCIO_BEHAVE
    GCIO_INMASK
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
 
    ; internal function to write paylods to the adaptor
    .macro __CWritePayload msg, type, r
        .if type = GCIO_BEHAVE
            .if message > 8
                .error "gcio65.payload message is too big!"
            .endif
            
            .repeat 8, s
                __CWriteBit msg, s, r
            .endrepeat
        .elseif type = GCIO_INMASK .or type = GCIO_INVERT
            .if message > 64
                .error "gcio65.payload message is too big!"
            .endif

            .repeat 64, s
                __CWriteBit msg, s, r
            .endrepeat
        .endif
    .endmacro

    .macro __ChangeTask task, r
        .if task > GCIO_RUMBLE
            .error "gcio.__ChangeTask task is not a valid task!"
        .endif
        
        ldr #1
        sta IOPORT1         ; begin mode select
        .repeat task, _
            ld(r) IOPORT1   ; increment task index n times
        .endrepeat
        .if r = a
            lda #0
        .else
            de(r)
        .endif
        st(r) IOPORT1       ; confirm task
    .endmacro

    .macro __WriteQWord qword
        .local fetch, loop

                ldy #0
        loop:   ldx #8
                lda pMask, y
                sta $4016
                lsr
                dex
                bne loop
        fetch:  iny
                cpy #8
                bne loop
    .endmacro

    ; waste [a,x,y]
    ; ptr   [invert]
    .macro RTChangeInvert invert, temp, i
        __SwitchTask GCIO_INVERT, a
        __WriteQWord invert
    .endmacro


    .macro CChangeInvert invert, nInvert, r
        .if .blank(r)
            _r = a
        .elseif r = a
            _r = a
        .elseif r = x
            _r = x
        .elseif r = y
            _r = y
        .else
            .error "gcio65.CChangeInvert ... r is not a register!"
        .endif

        __SwitchTask GCIO_INVERT, _r

        .repeat nInvert, s
            .if sr(invert, s) & 1
                st(_r) IOPORT1
            .else
                ld(_r) IOPORT1
            .endif
        .endrepeat
    .endmacro

    ; waste [a,i]
    .macro RTChangeMask pMask, i
        .if i = x
            _i = x
        .elseif i = y
            _i = y
        .else
            .error "gcio65.RTChangeBehavior i is not an indexing capable register"
        .endif
    
        __SwitchTask GCIO_INMASK, _i
        __WriteQWord pMask
    .endmacro

    .macro CChangeMask mask, r
        .if .blank(r)
            _r = a
        .elseif r = a
            _r = a
        .elseif r = x
            _r = x
        .elseif r = y
            _r = y
        .else
            .error "gcio65.ChangeBehavior ... r is not a register!"
        .endif

        __SwitchTask GCIO_INMASK, _r
        __WritePayload mask, GCIO_INMASK, _r
    .endmacro


    ; change the behavior of polling (does not change output size) -> first phase of input preprocessing
    ; assumes the task ptr in the adaptor is pointing towards REPORT and is unlatched
    .macro CChangeBehavior behavior, r
        .if .blank(r)
            _r = a
        .elseif r = a
            _r = a
        .elseif r = x
            _r = x
        .elseif r = y
            _r = y
        .else
            .error "gcio65.ChangeBehavior ... r is not a register!"
        .endif

        __SwitchTask GCIO_BEHAVE, _r
        __CWritePayload behave, GCIO_BEHAVE, _r
    .endmacro 

    ; in    [a] behavior
    ; waste [i] 
    .macro RTChangeBehavior i
        .local loop
        
        .if i = x
            _i = x
        .elseif i = y
            _i = y
        .else
            .error "gcio65.RTChangeBehavior i is not an indexing capable register"
        .endif
        
        __ChangeTask GCIO_BEHAVE, _i

        ld(_i) #8
        
        loop:
            lsr
            sta IOPORT1
            bit IOPORT1
            dex
            bne loop 
    .endmacro

    .export RTChangeInvert
    .export CCHangeInvert
    .export RTChangeBehavior
    .export CChangeBehavior
    .export RTChangeMask
    .export CChangeMask
.endscope
