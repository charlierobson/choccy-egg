
_debugOutput:
	push	iy
	push	hl

	ld		iy,(_mapAddrAtFootAfterMove)
	ld		a,(iy+32)
	push	af
	ld		a,(iy)
	push	af
	ld		a,(iy-32)
	push	af

	ld		iy,DISPLAY._dfilehr+(2*32+1)
	ld		a,$ff
	ld		(iy),a

	ld		iy,DISPLAY._dfilehr+(4*32+1)
	pop		af
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(12*32+1)
	pop		af
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(20*32+1)
	pop		af
	call	DRAW._TILE

	ld		iy,(_mapAddrAtTummyBeforeMove)
	ld		a,(iy)
	ld		iy,DISPLAY._dfilehr+(12*32+2)
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(29*32+1)
	ld		a,$ff
	ld		(iy),a

	ld		iy,DISPLAY._dfilehr+2
	ld		(pr_cc),iy
	ld		a,(_x+1)
	and		7
	call	DRAW._HEX
;	ld		a,(_y+1)
;	and		7
;	call	DRAW._HEX
;
;	ld		iy,DISPLAY._dfilehr+8
;	ld		(pr_cc),iy
;	ld		a,(DRAW._chx)
;	call	DRAW._HEX
;	ld		a,(DRAW._chy)
;	call	DRAW._HEX

;	ld		iy,DISPLAY._dfilehr+2+320
;	ld		(pr_cc),iy
;	ld		a,(_xforce+1)
;	call	DRAW._HEX
;	ld		a,(_xforce)
;	call	DRAW._HEX
;
;	ld		iy,DISPLAY._dfilehr+7+320
;	ld		(pr_cc),iy
;	ld		a,(_yforce+1)
;	call	DRAW._HEX
;	ld		a,(_yforce)
;	call	DRAW._HEX

	pop		hl
	pop		iy
	ret


_updateMovementX:
	ld		a,(INPUT._up)
	and		3
	cp		1
	jr		nz,{+}

	ld		a,(_y+1)
	dec		a
	ld		(_y+1),a
	ret

+:	ld		a,(INPUT._down)
	and		3
	cp		1
	jr		nz,{+}

	ld		a,(_y+1)
	inc		a
	ld		(_y+1),a
	ret

+:	ld		a,(INPUT._left)
	and		3
	cp		1
	jr		nz,{+}

	ld		a,(_x+1)
	dec		a
	ld		(_x+1),a
	ld		a,2
	ld		(_animState),a
	ret

+:	ld		a,(INPUT._right)
	and		3
	cp		1
	jr		nz,{+}

	ld		a,(_x+1)
	inc		a
	ld		(_x+1),a
	ld		a,0
	ld		(_animState),a
	ret

+:	ld		a,(INPUT._fire)
	and		3
	cp		1
	ret		nz

	ld		hl,MAPS._level1
	jp		DRAW._MAP

