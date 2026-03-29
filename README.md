# gcio65

`gcio65` is a [`ca65`]() library used to communicate through the modern GameCube controller to NES input adaptor that
uses new firmware of the 
[discontinued GameCube to NES adaptor by raphnet](https://www.raphnet-tech.com/products/gc_to_nes_adapter/index.php).

To use, simply include the file with 
```
.include "gcio65.s"
```

`gc65io` gives the user rich control of how controllers in their software should act. Buttons you don't want can be
added to the mask to ensure you don't request a longer report than you need. For example

```
gcio65.CConfigureMask $ffff_ffff    ; only export L and C stick
```

If you were using 8 bit degrees and not interested in higher degrees of angular accuracy, you might also consider
precomputing the angles for example, by doing
```
.local behave = gcio65.LPrecalc | gcio65.CPrecalc
gcio65.CConfigureBehavior behave    ; writes result to low 8 bits of 16 bit report for each stick
```

Given the case where pointing a stick up decreases its pitch, you can invert the stick message by flipping all the bits
```
gcio65.CConfigureInvert $ff00_ff00  ; flips y axis of each input
```
Similarly, if precomputed you only need to mirror the Y component of the angles
```
gcio65.CConfigureInvert $88
```

> Todo : Add notes for rumble, update as firmware is changed prior to release.