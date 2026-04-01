; vim: ft=asm_ca65

.feature line_continuations +

.enum
    GCIO_REPORT
    GCIO_BEHAVE
    GCIO_INMASK
    GCIO_INVERT
    GCIO_RUMBLE
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

    .macro __CWriteBit msg, s, r
        .local d0, d1

        .if s = 0
            ld(r) #msg & 1
            st(r) IOPORT1
            bit   IOPORT1

            .exitmacro
        .endif

        d0 = (sr(msg, s))       & 1
        d1 = (sr(msg, (s + 1))) & 1

        .if d0 <> d1
            .if r = a
                eor #$01
            .else
                .if d1
                    in(r)
                .else
                    de(r)
                .endif
            .endif
        .endif

        st(r) IOPORT1
        bit   IOPORT1
    .endmacro

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
        
        .repeat task, _
            ld(r) IOPORT1
        .endrepeat
    .endmacro

    .macro __RestoreTask task, r
        .repeat GCIO_RUMBLE + 1 - task, _
            ld(r) IOPORT1
        .endrepeat
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
        __RestoreTask GCIO_INVERT, a
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

        __RestoreTask GCIO_INVERT, _r
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
        __RestoreTask GCIO_INMASK, _i
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
        __RestoreTask GCIO_INMASK, _r
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
        __RestoreTask GCIO_BEHAVE, _r
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
        
        __RestoreTask GCIO_BEHAVE, _i
    .endmacro

    .export RTChangeInvert
    .export CCHangeInvert
    .export RTChangeBehavior
    .export CChangeBehavior
    .export RTChangeMask
    .export CChangeMask
.endscope
