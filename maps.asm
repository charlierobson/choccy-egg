	.module MAPS

_level1:
	.incbin	"data\cheg1.lz"
_level2:
	.incbin	"data\cheg2.lz"
_level3:
	.incbin	"data\cheg3.lz"
_level4:
	.incbin	"data\cheg4.lz"
_level5:
	.incbin	"data\cheg5.lz"
_level6:
	.incbin	"data\cheg6.lz"

_levels:
	.word	_level1,_level2,_level3,_level4,_level5,_level6

_title:
	.incbin "data\title.binlz"

_findStartPositions:
	ld		bc,0
	ld		(GAME._x),bc
	ld		(GAME._y),bc

	ld		hl,(GAME._level)
	ld		bc,22*32					; so far player is always on bottom row
	add		hl,bc
	ld		bc,32
	ld		a,TILES._MAN
	cpir
	inc		c
	ld		a,32
	sub		c
	sla		a
	sla		a
	sla		a
	ld		(GAME._x+1),a
	ld		a,22*8+7
	ld		(GAME._y+1),a

	ld		hl,(GAME._level)
	ld		bc,23*32
	add		hl,bc
	ld		bc,32
	ld		a,TILES._ELE
	cpir
	xor		a
	cp		c
	jr		z,{+}						; will be 0 if no elevator on this level

	inc		c
	ld		a,32
	sub		c
	sla		a
	sla		a
	sla		a

+:	ld		(GAME._elevatorX),a
	ret



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
