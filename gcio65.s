; vim: ft=asm_ca65

.enum
    GCIO_REPORT
    GCIO_BEHAVE
    GCIO_INMASK
    GCIO_INVERT
    GCIO_RUMBLE
.endenum

.scope gcio
    .ifndef IOPORT1
        .define IOPORT1 $4016
        .define IOPORT2 $4017

    .endif

    ; waste [a,x,y]
    ; ptr   [invert]
    ; size  [nInvert]
    ; ptr   [temp]
    .macro RTChangeInvert invert, nInvert, temp, i
        .local loop, exit, enter

        __SwitchTask GCIO_INVERT, a

        ldx #0
        lda #1
        ldy #8
        sec
        bcs enter

        sLoop:
            sta IOPORT1
            bcs check
        cLoop:
            nop IOPORT0
        check:
            dey
            bne enter
            ldy #8
            dec temp
            bmi exit
            bne enter
            ldy #2
            inx
        enter:
            rol invert, x
            bcc cLoop
            bcs sLoop
        exit:
        
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
            .if (invert >> s) & 1
                st(_r) IOPORT1
            .else
                ld(_r) IOPORT1
            .endif
        .endrepeat

        __RestoreTask GCIO_INVERT, _r
    .endmacro

    ; in    [a]
    ; waste [i]
    .macro RTChangeMask pMask, i
        .local loop, exit, enter

        .if i = x
            _i = x
        .elseif i = y
            _i = y
        .else
            .error "gcio65.RTChangeBehavior i is not an indexing capable register"
        .endif
    
        __SwitchTask GCIO_INMASK, _i

        .repeat 6, o
            lda pMask + o

            .if o = 5
                ld(_i) #2
            .else
                ld(_i) #8
            .endif

            bne enter
        
            loop:
                dex
                beq exit

            enter:
                lsr
                bcc r
                bcs w

                r:
                    ld(r) IOPORT1
                    bcc loop
                w:
                    st(r) IOPORT1
                    bcs loop
        .endrepeat
        exit:
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
        .local loop, exit, enter
        
        .if i = x
            _i = x
        .elseif i = y
            _i = y
        .else
            .error "gcio65.RTChangeBehavior i is not an indexing capable register"
        .endif
        
        __ChangeTask GCIO_BEHAVE, _i

        ld(_i) #8
        bne enter
        
        loop:
            dex
            beq exit

        enter:
            lsr
            bcc r
            bcs w

            r:
                ld(r) IOPORT1
                bcc loop
            w:
                st(r) IOPORT1
                bcs loop
        exit:
        __RestoreTask GCIO_BEHAVE, _i
    .endmacro

    ; internal function to write paylods to the adaptor
    .macro __CWritePayload msg, type, r
        .if type = GCIO_BEHAVE
            .if message > 8
                .error "gcio65.payload message is too big!"
            .endif
            
            .repeat 8, s
                .if (message >> s) & 1
                    st(r) IOPORT1
                .else
                    ld(r) IOPORT1
                .endif
            .endrepeat
        .elseif type = GCIO_INMASK
            .if message > 42
                .error "gcio65.payload message is too big!"
            .endif

            .repeat 42, s
                .if (message >> s) & 1
                    st(r) IOPORT1
                .else
                    ld(r) IOPORT1
                .endif
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

    .define concat(foo, bar) foo ## bar
    .define ld(r) ld ## r
    .define st(r) st ## r
.endscope
