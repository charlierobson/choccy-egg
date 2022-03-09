.endasm

This file configures the assembler's '.asc' data macro to translate between ascii
and zx81 character set values.

whenever you see:

    .asc    "a message"

the output will be a character stream in the ZX81 character set. Useful!

Be aware that only .asc converts, regular data defines such as .byte don't. So:

    .asc    "A"

does not equal

    .byte   'A'

The output of .asc can be used in expressions as it yields a value. So the following
is valid:

    .asc    "A"+$80

See the assembler manual for all the nitty gritty.

I have mapped upper case alpha characters to their inverses, but it's not super
useful I'll admit, as you will still need to manually translate the puntuation and
numbers etc.

.asm

    .asciimap 0,255,$0f             ; default case, '?'
    .asciimap ' ',' ',0
    .asciimap '"','"',$0b
    .asciimap '£','£',$0c
    .asciimap '$','$',$0d
    .asciimap ':',':',$0e
    .asciimap '(','(',$10
    .asciimap ')',')',$11
    .asciimap '>','>',$12
    .asciimap '<','<',$13
    .asciimap '=','=',$14
    .asciimap '+','+',$15
    .asciimap '-','-',$16
    .asciimap '*','*',$17
    .asciimap '/','/',$18
    .asciimap ';',';',$19
    .asciimap ',',',',$1a
    .asciimap '.','.',$1b
    .asciimap '0','9',{*}-'0'+$1c
    .asciimap 'a','z',{*}-'a'+$26
    .asciimap 'A','Z',{*}-'A'+$A6
