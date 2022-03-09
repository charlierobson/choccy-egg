;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module GAME

_drawtile:
	push	af
	push	bc
	push	iy
	ld		a,(de)
	ld		(iy+$00),a
	inc		de
	ld		a,(de)
	ld		(iy+$20),a
	inc		de
	ld		a,(de)
	ld		(iy+$40),a
	inc		de
	ld		a,(de)
	ld		(iy+$60),a
	inc		de
	ld		a,(de)
	ld		bc,128
	add		iy,bc
	ld		(iy+$00),a
	inc		de
	ld		a,(de)
	ld		(iy+$20),a
	inc		de
	ld		a,(de)
	ld		(iy+$40),a
	inc		de
	ld		a,(de)
	ld		(iy+$60),a
	pop		iy
	pop		bc
	pop		af
	ret

_run:
	call	INPUT._setgame

	call	DISPLAY._CLSHR
	call	DISPLAY._SETUPHIRES

	ld		hl,MAPS._level1

	ld		iy,DISPLAY._dfilehr
	ld		c,24

--:	ld		b,32

-:	ld		a,(hl)
	cp		$0a
	ld		de,TILES._tile_platform
	call	z,_drawtile
	cp		$07
	ld		de,TILES._tile_ladderl
	call	z,_drawtile
	cp		$84
	ld		de,TILES._tile_ladderr
	call	z,_drawtile
	cp		$9c
	ld		de,TILES._tile_thegg
	call	z,_drawtile
	cp		$97
	ld		de,TILES._tile_burbfud
	call	z,_drawtile
	inc		hl
	inc		iy
	djnz	{-}

	ld		de,32*7
	add		iy,de

	dec		c
	jr		nz,{--}

	ld		a,3
	call	AYFXPLAYER._PLAY

_loop:
	call	DISPLAY._FRAMESYNC

	ld		a,(INPUT._up)
	ld		de,DISPLAY._dfile+1+4*33
	call 	_binout

	ld		a,(INPUT._down)
	ld		de,DISPLAY._dfile+1+5*33
	call 	_binout

	ld		a,(INPUT._left)
	ld		de,DISPLAY._dfile+1+6*33
	call 	_binout

	ld		a,(INPUT._right)
	ld		de,DISPLAY._dfile+1+7*33
	call 	_binout

	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_loop

	ld		a,2
	call	AYFXPLAYER._PLAY

	call	DISPLAY._SETUPLORES

	ret


_binout:
	ld		b,8

-:	rlca
	push	af
	and		1
	add		a,$1c
	ld		(de),a
	pop		af
	inc		de
	djnz	{-}
	ret


_text:
			;--------========--------========
	.asc	"game.        press fire to lose."
_textend:

.endmodule
