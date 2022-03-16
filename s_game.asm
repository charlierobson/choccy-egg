;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
	.module GAME


_run:
	call	INPUT._setgame

	call	DISPLAY._CLSHR
	call	DISPLAY._SETUPHIRES

	ld		hl,MAPS._level1
	call	DRAW._MAP

	ld		bc,$6800
	ld		(_x),bc
	ld		(_prevx),bc
	ld		bc,$3700
	ld		(_y),bc
	ld		(_prevy),bc

	xor		a
	ld		(_state),a

_loop:
	ld		hl,_state					; motion state, try and keep hl set to this for entire loop

	ld		bc,(_x)						; keep previous position around for undrawing purposes
	ld		(_prevx),bc
	ld		bc,(_y)
	ld		(_prevy),bc

	call	_updateMovement

	ld		a,(_animState)
	ld		b,a
	srl		b

	ld		a,(_xforce+1)				; update manimation if moving or on ladder
	and		a
	jr		z,{+}

	ld		a,(frames)					; animation frame tied to frames counter
	rra
	rra
	rra

+:	rl		b
	ld		a,b
	ld		(_animState),a

	call	_debugOutput

	call	DISPLAY._FRAMESYNC

	call	DRAW._NOMAN					; undraw man at old position
	call	DRAW._MAN					; draw man at new position

	jp		_loop



_updateMovement:
	bit		5,(hl)
	jp		nz,_inAirUpdate

	bit		3,(hl)
	;call	nz,_onLadderUpdate

_onGroundUpdate:
	ld		bc,$0000
	ld		(_xforce),bc ; preserve force across updates?
	ld		(_yforce),bc

	ld		a,(INPUT._up)
	and		3
	cp		1
	jr		nz,{+}
	ld		bc,$3700
	ld		(_y),bc
+:

	ld		a,(INPUT._left)
	and		1
	jr		z,{+}

	ld		a,2							; face left
	ld		(_animState),a
	ld		bc,$ff00		; replace with call to addForceClampedTo1
	ld		(_xforce),bc

+:	ld		a,(INPUT._right)
	and		1
	jr		z,_onGroundMove

	ld		a,0							; face right
	ld		(_animState),a
	ld		bc,$0100		; replace with call to addForceClampedTo1
	ld		(_xforce),bc

_onGroundMove:
	call	_updatePosition
	ld		a,(iy+32)
	and		$C0
	call	z,_startFall
	ret



_inAirUpdate:
	push	hl
	ld		hl,(_yforce)
	ld		bc,$0040
	add		hl,bc
	ld		(_yforce),hl
	pop		hl

_inAirMove:
	call	_updatePosition
	ld		a,(iy)
	and		$40
	call	nz,_stopFall

	ret


_startFall:
	ld		bc,(_xforce)				; halve the x force each time, or better: subtract and clamp
	sra		b
	rr		c
	jr		nc,{+}
	set		6,c
+:	ld		(_xforce),bc
	ld		bc,$0100
	ld		(_yforce),bc
	ld		(hl),%00110000				; state = in air/falling
	ret


_stopFall:
	ld		bc,$0000
	ld		(_yforce),bc
	ld		(hl),%00000000				; state = on ground

	ld		bc,(_y)
	ld		a,b
	and		7							; are we part way into the ground below us?
	cp		7
	jr		z,{+}

	ld		a,b							; stamp player on the ground
	sub		8
	or		7
	ld		b,a

+:	ld		c,0							; delete fractional part
	ld		(_y),bc
	ret



_updatePosition:
	call	MAPS._getAddrAtFoot			; see what's there at current position
	ld		(_mapAddrAtFootBeforeMove),iy

	ld		iy,(_x)
	ld		bc,(_xforce)
	add		iy,bc
	ld		(_x),iy

	ld		iy,(_y)
	ld		bc,(_yforce)
	add		iy,bc
	ld		(_y),iy

	call	MAPS._getAddrAtFoot
	ld		(_mapAddrAtFootAfterMove),iy
	ret

_cancelUpdatePosition:
	ld		bc,(_prevx)
	ld		(_x),bc
	ld		bc,(_prevy)
	ld		(_y),bc
	ret



.endasm
;
;	bit		5,(hl)						; are we in the air?
;	jp		nz,_inAir
;
;	bit		3,(hl)						; are we in the air?
;	jp		nz,_onLadder
;
;	; not in air or on ladder, must be...
;
;_onGround:
;	res		7,(hl)						; not moving. use bits to indicate horizontal movement
;	res		6,(hl)						; so that we can apply it when jumping/falling
;
;	; check to see whether we're falling
;
;	call	_solidCheck
;	jr		z,_stillOnGround
;
;	set		4,(hl)						; wandered off into space
;	set		5,(hl)						; set in air/falling bits, jump table offset
;	ld		a,jtFallIdx
;	ld		(_counter),a
;	jp		_updates
;
;_stillOnGround:
;	ld		a,(_tileBelowFoot)
;	res		6,a
;	cp		TILES._LADDERA				; ladder meat
;	jr		nz,_checkAscend
;
;_checkDescend:
;	ld		a,(INPUT._down)
;	and		1
;	jr		z,_checkAscend
;
;_mountLadder:
;	set		3,(hl)						; we're on a ladder now..!
;	res		6,(hl)
;	res		7,(hl)
;	res		5,(hl)
;	res		4,(hl)
;	ld		a,(_x)
;	and		$f8
;	or		4
;	ld		(_x),a
;	jp		_updates
;
;_checkAscend:
;	ld		a,(_tileAtFoot)
;	res		6,a
;	cp		TILES._LADDERA
;	jr		nz,_checkLeft
;
;	ld		a,(INPUT._up)
;	and		1
;	jr		nz,_mountLadder
;
;_checkLeft:
;	ld		a,(INPUT._left)
;	and		1
;	jr		z,_checkRight
;
;	set		7,(hl)						; he's a-walkin' left
;	set		1,(hl)
;
;_checkRight:
;	ld		a,(INPUT._right)
;	and		1
;	jr		z,_checkJump
;
;	set		6,(hl)						; he's a-walkin' right
;	res		1,(hl)
;
;_checkJump:
;	ld		a,(INPUT._fire)
;	and		3
;	cp		1
;	jp		nz,_updates
;
;	set		5,(hl)						; in the air
;	xor		a							; reset jumping table index
;	ld		(_counter),a
;	jp		_updates
;
;
;
;_inAir:
;	ld		a,(_tileAtFoot)
;	res		6,a
;	cp		TILES._LADDERA
;	jr		nz,_noCheckClimb
;
;	ld		a,(INPUT._up)
;	and		1
;	jp		nz,_mountLadder
;
;_noCheckClimb:
;	ld		a,(_counter)			; whilst in air draw counter is offset into jumping table
;	ld		(_jtOff),a					; self-modify
;	inc		a
;	cp		jtFallIdx					; is where we start falling
;	jr		nz,{+}
;
;	set		4,(hl)						; set falling bit
;
;+:	cp		jtEndIdx					; is last entry, so stop advancing counter
;	jr		z,_adjustY
;
;	ld		(_counter),a
;
;_adjustY:
;	ld		iy,_jumpTable
;	ld		a,(_y)
;_jtOff=$+2
;	add		a,(iy+0)					; !self modifies!
;	ld		(_y),a
;
;	bit		4,(hl)						; check ground if falling
;	jp		z,_updates
;
;	call	_solidCheck
;	jp		nz,_updates
;
;_soSolid:
;	res		5,(hl)						; he's hit the ground, so stop falling,
;	res		4,(hl)
;	ld		a,(_y)					; adjust y pos to be on the ground (likely we were part way into it).
;	and		%11111000
;	ld		(_y),a
;	jp		_updates
;
;
;
;
;_onLadder:
;	res		0,(hl)
;	ld		b,0
;	ld		a,(INPUT._right)
;	srl		a
;	rl		b
;	ld		a,(INPUT._left)
;	srl		a
;	rl		b
;
;	ld		a,(INPUT._up)
;	and		1
;	jr		z,_noUp
;
;	ld		a,(_tileAtFoot)
;	res		6,a
;	cp		TILES._LADDERA
;	jr		nz,_noUp
;
;	ld		a,(_y)
;	dec		a
;	ld		(_y),a
;
;_noUp:
;	ld		a,(INPUT._down)
;	and		1
;	jr		z,_noDown
;
;	ld		a,(_tileAtFoot)
;	res		6,a
;	cp		TILES._LADDERA
;	jr		nz,_noDown
;
;	ld		a,(_y)
;	inc		a
;	ld		(_y),a
;
;_noDown:
;	ld		a,(INPUT._fire)
;	and		3
;	cp		1
;	jr		nz,_noJumpOff
;
;	bit		0,b
;	jr		z,_tryJumpOffRight
;
;	res		3,(hl)						; clear climbing bit
;	set		7,(hl)						; set moving left, in air, facing left and offset
;	set		5,(hl)
;	set		1,(hl)
;	xor		a
;	ld		(_counter),a
;	ld		a,(_x)					; move off ladder
;	sub		4
;	ld		(_x),a
;	jp		_updates
;
;_tryJumpOffRight:
;	bit		1,b
;	jr		z,_noJumpOff
;
;	res		3,(hl)						; clear climbing bit
;	set		6,(hl)						; set moving right bit, in air bit and offset
;	set		5,(hl)
;	res		1,(hl)						; clear facing left
;	xor		a
;	ld		(_counter),a
;	ld		a,(_x)					; move off ladder
;	add		a,4
;	ld		(_x),a
;	jp		_updates
;
;_noJumpOff:
;	ld		a,(_y)
;	and		7
;	jp		nz,_updates
;
;	ld		a,b							; cached l/r buttons
;	and		3
;	jp		z,_updates
;
;	res		3,(hl)						; just walk off
;	jp		_updates
;
;
;
;; returns with z set if ground underfoot is solid
;_solidCheck:
;	ld		a,(_tileBelowFoot)
;	xor		$ff
;	bit		6,a
;	ret
;
;
;
;_updateHoriz:
;	ld		a,(_x)
;
;	bit		7,(hl)						; moving left?
;	jr		z,{+}
;
;	cp		6
;	ret		z
;
;	dec		a
;	ld		(_x),a
;	ret
;
;+:	bit		6,(hl)						; moving right?
;	ret		z
;
;	cp		250
;	ret		z
;
;	inc		a
;	ld		(_x),a
;	ret
;
;
.asm

_gameOver:
	ld		a,2
	call	AYFXPLAYER._PLAY

	call	DISPLAY._CLS
	call	DISPLAY._SETUPLORES

	ret



; 8.8 fixed point for man coords, forces
_x:
	.word	0
_y:
	.word	0

_prevx:
	.word	0
_prevy:
	.word	0

_xforce:
	.word	0
_yforce:
	.word	0

_mapAddrAtFootBeforeMove:
	.word	 0
_mapAddrAtFootAfterMove:
	.word	 0


; bit 7 - moving left
; bit 6 - moving right
; bit 5 - in the air
; bit 4 - falling
; bit 3 - climbing
_state:
	.byte	0

; bit 1 - facing left
; bit 0 - walking
_animState:
	.byte	0


_debugOutput:
	push	iy
	push	hl

	ld		iy,(_mapAddrAtFootAfterMove)
	ld		b,(iy)
	ld		c,(iy+32)

	ld		iy,DISPLAY._dfilehr+(2*32)
	ld		a,$ff
	ld		(iy),a

	ld		iy,DISPLAY._dfilehr+(4*32)
	ld		a,b
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(12*32)
	ld		a,c
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(21*32)
	ld		a,$ff
	ld		(iy),a

	ld		iy,DISPLAY._dfilehr+2
	ld		(pr_cc),iy
	ld		a,(_x+1)
	call	DRAW._HEX
	ld		a,(_y+1)
	call	DRAW._HEX

	ld		iy,DISPLAY._dfilehr+2+320
	ld		(pr_cc),iy
	ld		a,(_xforce+1)
	call	DRAW._HEX
	ld		a,(_xforce)
	call	DRAW._HEX

	ld		iy,DISPLAY._dfilehr+7+320
	ld		(pr_cc),iy
	ld		a,(_yforce+1)
	call	DRAW._HEX
	ld		a,(_yforce)
	call	DRAW._HEX

	pop		hl
	pop		iy
	ret


.endmodule
