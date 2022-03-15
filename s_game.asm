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

	call	_updateHoriz

	call	MAPS._getTileUnderFoot
	ld		a,(iy)
	ld		(_tileBelowFoot),a
	push	iy
	ld		iy,DISPLAY._dfilehr+(12*32)
	call	DRAW._TILE
	pop		iy
	ld		a,(iy-32)
	ld		(_tileAtFoot),a
	ld		iy,DISPLAY._dfilehr+(4*32)
	call	DRAW._TILE

	bit		5,(hl)						; are we in the air?
	jp		nz,_inAir

	bit		3,(hl)						; are we in the air?
	jp		nz,_onLadder

	; not in air or on ladder, must be...

_onGround:
	res		7,(hl)						; not moving. use bits to indicate horizontal movement
	res		6,(hl)						; so that we can apply it when jumping/falling

	; check to see whether we're falling

	call	_solidCheck
	jr		z,_stillOnGround

	set		4,(hl)						; wandered off into space
	set		5,(hl)						; set in air/falling bits, jump table offset
	ld		a,jtFallIdx
	ld		(DRAW._counter),a
	jp		_updates

_stillOnGround:
	ld		a,(_tileBelowFoot)
	cp		$10							; ladder meat
	jr		nz,_checkAscend

_checkDescend:
	ld		a,(INPUT._down)
	and		1
	jr		z,_checkAscend

_mountLadder:
	set		3,(hl)						; we're on a ladder now..!
	ld		a,(DRAW._x)
	and		$f8
	or		4
	ld		(DRAW._x),a
	jp		_updates

_checkAscend:
	ld		a,(_tileAtFoot)
	cp		$10
	jr		nz,_checkLeft

	ld		a,(INPUT._up)
	and		1
	jr		nz,_mountLadder

_checkLeft:
	ld		a,(INPUT._left)
	and		1
	jr		z,_checkRight

	set		7,(hl)						; he's a-walkin' left
	set		1,(hl)

_checkRight:
	ld		a,(INPUT._right)
	and		1
	jr		z,_checkJump

	set		6,(hl)						; he's a-walkin' right
	res		1,(hl)

_checkJump:
	ld		a,(INPUT._fire)
	and		3
	cp		1
	jp		nz,_updates

	set		5,(hl)						; in the air
	xor		a							; reset jumping table index
	ld		(DRAW._counter),a
	jp		_updates



_inAir:
	ld		a,(DRAW._counter)			; whilst in air draw counter is offset into jumping table
	ld		(_jtOff),a					; self-modify
	inc		a
	cp		jtFallIdx					; is where we start falling
	jr		nz,{+}

	set		4,(hl)						; set falling bit

+:	cp		jtEndIdx					; is last entry, so stop advancing counter
	jr		z,_adjustY

	ld		(DRAW._counter),a

_adjustY:
	ld		iy,_jumpTable
	ld		a,(DRAW._y)
_jtOff=$+2
	add		a,(iy+0)					; !self modifies!
	ld		(DRAW._y),a

	bit		4,(hl)						; check ground if falling
	jp		z,_updates

	call	_solidCheck
	jp		nz,_updates

_soSolid:
	res		5,(hl)						; he's hit the ground, so stop falling,
	res		4,(hl)
	ld		a,(DRAW._y)					; adjust y pos to be on the ground (likely we were part way into it).
	and		%11111000
	ld		(DRAW._y),a
	jp		_updates




_onLadder:
	ld		b,0
	ld		a,(INPUT._right)
	srl		a
	rl		b
	ld		a,(INPUT._left)
	srl		a
	rl		b

	ld		a,(INPUT._up)
	and		1
	jr		z,_noUp

	ld		a,(DRAW._y)
	dec		a
	ld		(DRAW._y),a

_noUp:
	ld		a,(INPUT._down)
	and		1
	jr		z,_noDown

	ld		a,(DRAW._y)
	inc		a
	ld		(DRAW._y),a
	; check for floor here

_noDown:
	ld		a,(INPUT._fire)
	and		1
	jr		z,_noJumpOff

	bit		0,b
	jr		z,_tryJumpOffRight

	set		7,(hl)						; set moving left bit, in air bit and offset
	set		5,(hl)
	res		3,(hl)						; clear climbing bit
	xor		a
	ld		(DRAW._counter),a
	jp		_updates

_tryJumpOffRight:
	bit		1,b
	jr		z,_noJumpOff

	set		6,(hl)						; set moving right bit, in air bit and offset
	set		5,(hl)
	res		3,(hl)						; clear climbing bit
	xor		a
	ld		(DRAW._counter),a
	jp		_updates

_noJumpOff:
	ld		a,(DRAW._y)
	and		7
	jp		nz,_updates

	ld		a,b
	and		3
	jp		z,_updates

	res		3,(hl)
	jp		_updates



; FLOOROFF = 0x08
; LADDERCOFF = 0x10
; LADDERLFOFF = 0x18
; LADDERRFOFF = 0x20
; LADDERLOFF = 0x28
; LADDERROFF = 0x30
; EGGOFF = 0x38
; SEEDOFF = 0x40


; returns with z set if ground underfoot is solid
_solidCheck:
	ld		a,(_tileBelowFoot)
	sub		8							; floor, c set if zero
	ret		c
	cp		$1f							; ladderl-8, sub extra 1 so result won't be 0
	ret		nc
	xor		a
	ret




_updates:
	ld		a,(hl)						; update manimation if moving or on ladder
	and		%11001000
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

_tileBelowFoot:
	.byte	0
_tileAtFoot:
	.byte	0

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



_jumpTable:
	.byte	-2,-2,-2,-2,-1,-1,-1,-1,0,0,0,0,0,0
_jumpTableFall:
	.byte	1,1,1,1,2,2,2,2,3,4

jtFallIdx=_jumpTableFall-_jumpTable-1
jtEndIdx=$-_jumpTable-1


.endmodule
