	.module MAPS

_level1:
	.incbin	"data\cheg1.lz"
_level2:
	.incbin	"data\cheg2.lz"
_level3:
	.incbin	"data\cheg3.lz"
_levelT:
	.incbin	"data\chegt.lz"

_levels:
;	.word	_levelT
	.word	_level1,_level2,_level3

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
	ld		iy,(GAME._level)
	add		iy,bc
	ret
