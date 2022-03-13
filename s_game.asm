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
	ld		(DRAW._prevx),a
	ld		a,56
	ld		(DRAW._y),a
	ld		(DRAW._prevy),a

	xor		a
	ld		(DRAW._frame),a

_loop:
	call	DISPLAY._FRAMESYNC

	ld		hl,DRAW._frame				; motion state, try and heep hl set to this for entire loop
	res		0,(hl)						; default to standing frame, in case no movement
	bit		5,(hl)						; are we in the air?
	jr		z,_onGround

	; do in-air stuff

	ld		a,(DRAW._counter)			; whilst in air draw counter is offset into jumping table
	ld		(_jtOff),a					; self-modify
	inc		a
	cp		12							; index 12 is where we start falling
	jr		nz,{+}

	set		4,(hl)						; set falling bit

+:	cp		17							; index 17 is last entry, so stop advancing counter
	jr		z,_adjustY

	ld		(DRAW._counter),a

_adjustY:
	ld		iy,_jumpTable
	ld		a,(DRAW._y)
_jtOff=$+2
	add		a,(iy+0)					; !self modifies!
	ld		(DRAW._y),a

	bit		4,(hl)						; check ground if falling
	jp		z,_drawMan

	ex		de,hl
	call	MAPS._getTileAtFoot
	ex		de,hl
	ld		a,(de)
	cp		$08
	jp		nz,_drawMan

	res		5,(hl)						; he's hit the ground, so stop falling,
	res		4,(hl)
	ld		a,(DRAW._y)					; adjust y pos to be on the ground (likely we were part way into it).
	and		%11111000
	ld		(DRAW._y),a
	jp		_drawMan

_jumpTable:
	.byte	-4,-3,-2,-2,-1,-1,-1,-1,0,0,0,0,0,1,2,3,4

_onGround:
	res		7,(hl)						; not moving. use bits to indicate horizontal movement
	res		6,(hl)						; so that we can apply it when jumping/falling

	ld		a,(INPUT._left)
	and		1
	jr		z,_tryRight

	set		7,(hl)						; he's a-walkin' left
	set		1,(hl)

_tryRight:
	ld		a,(INPUT._right)
	and		1
	jr		z,_checkJump

	set		6,(hl)						; he's a-walkin' right
	res		1,(hl)

_checkJump:
	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_drawMan

	set		5,(hl)						; in the air
	xor		a							; reset jumping table index
	ld		(DRAW._counter),a

_drawMan:
	call	_updateHoriz				; apply horizontal movement if any

	ld		a,(hl)						; if not falling then check to see if we should be
	and		%00110000
	jr		nz,{+}

	ex		de,hl						; see if there's solid beneath his feet
	call	MAPS._getTileAtFoot
	ex		de,hl
	ld		a,(de)
	and		a
	jr		nz,{+}

	set		4,(hl)						; set in air/falling bits, jump table offset
	set		5,(hl)
	ld		a,13
	ld		(DRAW._counter),a

	; hack
+:	ld		a,(INPUT._up)				; !HACK! to move player to top of screen
	and		3
	cp		1
	jr		nz,{+}
	ld		a,24
	ld		(DRAW._y),a
+:	ld		a,(INPUT._down)
	and		3
	cp		1
	jp		z,_gameOver
	; end hack

	ld		a,(hl)						; update manimation if moving
	and		%11000000
	jr		z,{+}

	ld		a,(frames)					; animation frame tied to frames counter
	rra
	rra
	rra
	jr		nc,{+}

	set		0,(hl)

+:	call	DRAW._NOMAN					; undraw man at old position
	call	DRAW._MAN					; draw man at new position

	ld		a,(DRAW._x)					; make what is new old again
	ld		(DRAW._prevx),a
	ld		a,(DRAW._y)
	ld		(DRAW._prevy),a

	jp		_loop


_updateHoriz:
	ld		a,(DRAW._x)

	bit		7,(hl)						; moving left?
	jr		z,{+}

	cp		6
	ret		z

	dec		a
	ld		(DRAW._x),a
	ret

+:	bit		6,(hl)						; moving right?
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
