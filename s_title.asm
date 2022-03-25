;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module TITLE

_run:
	call	INPUT._settitle

	ld		a,1
	call	AYFXPLAYER._PLAY

	ld		hl,0
	ld		(frames),hl

_redraw:
	ld		hl,MAPS._title
	ld		de,DISPLAY._dfile
	call	LZ48._DECRUNCH

_loop:
	call	DISPLAY._FRAMESYNC

	ld		a,(frames)	; AB------
	rlca				; -------A
	rlca				; ------AB
	and		3			; 000000AB  :- 0,1,2,3

	ld		hl,_titletextlist
	call	tableget

	ld		de,DISPLAY._dfile+1
	ld		bc,32
	ldir

_nochangetext:
	ld		a,(frames)
	and		16						; new text is chosen every 32 frames, invert every 16
	jr		nz,_noflash

	ld		hl,DISPLAY._dfile+1
	ld		b,32

-:	set		7,(hl)
	inc		hl
	djnz	{-}

_noflash:
	ld		a,(INPUT._redef)
	and		3						; check for key just released
	cp		2						; %xxxxxx10    pressed last frame, not pressed this
	jr		nz,{+}

	call	REDEFINE._run
	jr		_redraw

+:
	ld		a,(INPUT._instr)
	and		3
	cp		2
	jr		nz,{+}

	call	INSTRUCTIONS._run
	jr		_redraw

+:	ld		a,(INPUT._begin)
	and		3
	cp		1						; %xxxxxx01    not pressed last frame, pressed this
	jr		nz,_loop

	call	seedrnd

	ret


_titletextlist:
	.word	_t1,_t2,_t3,_t2

			;--------========--------========
_t1	.asc	"      i for instructions        "
_t2	.asc	"         fire to start          "
_t3	.asc	"      r to redefine keys        "

.endmodule
