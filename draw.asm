	.module	DRAW




_TILE:
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


_MAP:
	ld		iy,DISPLAY._dfilehr
	ld		c,24

--:	ld		b,32

-:	ld		a,(hl)
	call	_TILE
	inc		hl
	inc		iy
	djnz	{-}

	ld		de,32*7
	add		iy,de

	dec		c
	jr		nz,{--}
	ret





_x:
	.byte	16
_y:
	.byte	184

_prevx:
	.byte	0
_prevy:
	.byte	0

; bit 7 - moving left
; bit 6 - moving right
; bit 5 - in the air
; bit 4 - falling
;
; bit 1 - facing left
; bit 0 - walking animation
_frame:
	.byte	0

_counter:
	.byte	0

_MAN:
	ld		a,(_y)
	sub		14
	ld		b,a
	ld		a,(_x)
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
	ld		a,(_frame)
	and		3							; isolate frame bits
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
	call	adda2de

	djnz	{-}
	ret

