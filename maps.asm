	.module MAPS

; off file is result of passing map through cv_map2off.py
; which turns character codes into byte offsets into character set
;
_level1:
	.incbin	"data\cheg1.off"

_title:
	.incbin "data\title.binlz"

; returns with base map address in iy
;
_getAddrOfTileFromPixel:
	srl		b
	srl		b
	srl		b
	srl		b
	rr		c
	srl		b
	rr		c
	srl		b
	rr		c
	ld		iy,MAPS._level1
	add		iy,bc
	ret
