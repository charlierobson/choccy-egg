;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
	.module GAME


_run:
	call	INPUT._setgame

	call	DISPLAY._CLSHR
	call	DISPLAY._SETUPHIRES

	ld		hl,MAPS._level1
	call	DRAW._MAP

	ld		a,3
	call	AYFXPLAYER._PLAY

	ld		a,$68
	ld		(DRAW._x),a
	ld		a,56
	ld		(DRAW._y),a

_loop:
	call	DISPLAY._FRAMESYNC

	ld		hl,DRAW._frame			; motion state
	res		0,(hl)					; standing frame

	bit		5,(hl)					; in air?
	jr		z,_onGround

	; do in-air stuff

	ld		a,(DRAW._counter)
	ld		(_jtOff),a
	inc		a
	cp		12
	jr		nz,{+}

	set		4,(hl)					; falling

+:	cp		17
	jr		z,_adjustY

	ld		(DRAW._counter),a

_adjustY:
	ld		iy,_jumpTable
	ld		a,(DRAW._y)
_jtOff=$+2
	add		a,(iy+0)
	ld		(DRAW._y),a

	; check ground if falling

	ex		de,hl
	call	MAPS._getTileAtFoot
	ex		de,hl
	ld		a,(de)
	cp		$08
	jp		nz,_drawMan

	res		5,(hl)
	res		4,(hl)
	ld		a,(DRAW._y)
	and		%11111000
	ld		(DRAW._y),a
	jp		_drawMan

_jumpTable:
	.byte	-4,-3,-2,-2,-1,-1,-1,-1,0,0,0,0,0,1,2,3,4


_onGround:
	res		7,(hl)					; not moving
	res		6,(hl)					;
	res		1,(hl)					;

	ld		a,(INPUT._left)
	and		1
	jr		z,_tryRight

	set		7,(hl)					; he's a-walkin' left
	set		1,(hl)

_tryRight:
	ld		a,(INPUT._right)
	and		1
	jr		z,_checkJump

	set		6,(hl)					; he's a-walkin' right

_checkJump:
	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_drawMan

	set		5,(hl)					; in the air
	xor		a
	ld		(DRAW._counter),a

_drawMan:
	call	_updateHoriz

	ld		a,(hl)				; update manimation if moving
	and		$c0
	jr		z,{+}

	ld		a,(frames)
	rra
	rra
	rra
	jr		nc,{+}

	set		0,(hl)

+:	call	DRAW._MAN
	ld		a,(DRAW._x)
	ld		(DRAW._prevx),a
	ld		a,(DRAW._y)
	ld		(DRAW._prevy),a

	jp		_loop


_updateHoriz:
	ld		a,(DRAW._x)
	bit		7,(hl)
	jr		z,{+}

	cp		6
	ret		z

	dec		a
	ld		(DRAW._x),a
	ret

+:	bit		6,(hl)
	ret		z

	cp		250
	ret		z

	inc		a
	ld		(DRAW._x),a
	ret


_gameOver:
	ld		a,2
	call	AYFXPLAYER._PLAY

	call	DISPLAY._CLS
	call	DISPLAY._SETUPLORES

	ret

.endmodule
