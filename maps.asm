	.module MAPS

; off file is result of passing map through cv_map2off.py
; which turns character codes into byte offsets into character set
;
_level1:
	.incbin	"data\cheg1.off"

_level3:
	.incbin	"data\cheg3.off"

_title:
	.incbin "data\title.binlz"


_getTileUnderFoot:
	push	bc
	ld		a,(DRAW._x)
	ld		c,a
	ld		a,(DRAW._y)
	srl		a
	srl		a
	srl		a
	ld		b,a

	srl		b
	rr		c
	srl		b
	rr		c
	srl		b
	rr		c
	ld		iy,MAPS._level1
	add		iy,bc
	pop		bc
	ret
