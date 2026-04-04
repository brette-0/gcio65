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

