;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module GAME


_drawtile:
	push	bc
	push	hl

	push	iy
	pop		hl

	ld		b,TILES._START / 256
	ld		c,a

	ld		de,32

	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a

	pop		hl
	pop		bc
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
	call	_drawtile
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

	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_loop

	ld		a,2
	call	AYFXPLAYER._PLAY

	call	DISPLAY._CLS
	call	DISPLAY._SETUPLORES

	ret

.endmodule
