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

x:
	.byte	16
y:
	.byte	184

prevx:
	.byte	0
prevy:
	.byte	0

frame:
	.byte	0

drawmap:
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
	ret


drawman:
	ld		a,(y)
	sub		14
	ld		b,a
	ld		a,(x)
	sub		6
	ld		c,a

	; dr beep's optimised screen address calculation
	srl		b
	rr		c
	srl		b
	rr		c
	srl		b
	rr		c
	ld		hl,DISPLAY._dfilehr
	add		hl,bc
	ex		de,hl

	and		7
	ld		b,a
	ld		a,(frame)
	call	CHARLIE._getFrame

	ld		b,14

-:	ld		a,(hl)
	or		(hl)
	ld		(de),a
	inc		hl
	inc		de
	ld		a,(hl)
	or		(hl)
	ld		(de),a
	inc		hl
	inc		de
	ld		a,(hl)
	or		(hl)
	ld		(de),a
	inc		hl

	ld		a,30
	call	addAtoDE

	djnz	{-}
	ret

addAtoDE:
	add		a,e
	ld		e,a
	ret		nc
	inc		d
	ret



_run:
	call	INPUT._setgame

	call	DISPLAY._CLSHR
	call	DISPLAY._SETUPHIRES

	ld		hl,MAPS._level1
	call	drawmap

	ld		a,3
	call	AYFXPLAYER._PLAY

_loop:
	call	DISPLAY._FRAMESYNC

	ld		hl,frame				; animation base
	res		0,(hl)					; remove 'walking' bit

	ld		a,(INPUT._left)
	and		1
	jr		z,_tryRight

	set		1,(hl)					; he's a-walkin', left
	ld		a,(frames)
	rra
	rra
	rra
	jr		nc,{+}

	set		0,(hl)

+:	ld		a,(x)
	cp		6
	jr		z,_tryRight

	dec		a
	ld		(x),a

_tryRight:
	ld		a,(INPUT._right)
	and		1
	jr		z,_drawman

	res		1,(hl)					; he's a-walkin', right
	ld		a,(frames)
	rra
	rra
	rra
	jr		nc,{+}

	set		0,(hl)

+:	ld		a,(x)
	cp		250
	jr		z,_drawman

	inc		a
	ld		(x),a

_drawman:
	call	drawman
	ld		a,(x)
	ld		(prevx),a
	ld		a,(y)
	ld		(prevy),a

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
