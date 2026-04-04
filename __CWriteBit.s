.macro __CWriteBit msg, s, r
    .local c, p

    .if !s
        ld(r) #msg & 1
        st(r) IOPORT1
        bit   IOPORT1

        .exitmacro
    .endif

    c = (sr(msg, s))       & 1
    p = (sr(msg, (s + 1))) & 1

    .if c <> p
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
