;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module GAMEOVER

_run:
	call	INPUT._settitle
	call	DISPLAY._CLS

	ld		hl,_text
	ld		de,DISPLAY._dfile+1
	ld		bc,_textend-_text
	ldir

	ld		b,100

-:	call	DISPLAY._FRAMESYNC
	djnz	{-}

	ret


_text:
			;--------========--------========
	.asc	"game over.       wait 2 seconds."
_textend:

.endmodule
