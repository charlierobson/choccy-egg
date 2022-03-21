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
	ld		b,0
	ld		a,(INPUT._fire)
	srl		a
	rr		b
	ld		a,(INPUT._right)
	srl		a
	rr		b
	ld		a,(INPUT._left)
	srl		a
	rr		b
	ld		a,(INPUT._down)
	srl		a
	rr		b
	ld		a,(INPUT._up)
	srl		a
	rr		b
	ld		a,b
	ld		(_inputs),a

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
	jp		nz,_onLadderUpdate

_onGroundUpdate:
	ld		bc,(_xforce)				; halve the x force each time
	sra		b
	rr		c
	ld		a,b
	cp		c
	jr		nz,{+}
	cp		$ff
	jr		nz,{+}
	ld		bc,0
+:	ld		(_xforce),bc

	call	_checkLeftRight

_checkDown:
	ld		a,(INPUT._down)
	and		1
	jr		z,_checkUp

	ld		iy,(_mapAddrAtFootAfterMove)
	ld		a,(iy)
	cp		TILES._LADDERA
	jr		nz,_checkUp
	ld		a,(iy+32)
	cp		TILES._LADDERS
	jr		nz,_checkUp

	jp		_mountLadder

_checkUp:
	ld		a,(INPUT._down)
	and		1
	jr		z,_checkJump

_checkJump:
	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_move

	call	_jump
	call	_updatePosition
	ret


_move:
	call	_updatePosition
	ld		a,(_x+1)
	cp		7
	jr		nc,{+}	

	ld		a,6
	ld		(_x+1),a
	xor		a
	ld		(_x),a

+:	ld		a,(_x+1)
	cp		250
	jr		c,{+}	

	ld		a,250
	ld		(_x+1),a
	xor		a
	ld		(_x),a

+:	ld		a,(iy+32)
	and		$C0
	call	z,_startFall
	ret


_checkLeftRight:
	ld		a,(INPUT._left)
	and		1
	jr		z,{+}

	ld		a,2							; face left
	ld		(_animState),a

	ld		bc,$ff00		; replace with call to addForceClampedTo1?
	ld		(_xforce),bc

+:	ld		a,(INPUT._right)
	and		1
	ret		z

	ld		a,0							; face right
	ld		(_animState),a
	ld		bc,$0100		; replace with call to addForceClampedTo1
	ld		(_xforce),bc
	ret



_jump:
	ld		a,%00100000
	ld		(_state),a
	ld		bc,$fe80
	ld		(_yforce),bc
	ret


_inAirUpdate:
	push	hl
	ld		hl,(_yforce)				; 'gravity'
	ld		bc,$0020
	add		hl,bc
	ld		(_yforce),hl
	pop		hl

	call	_updatePosition

	ld		a,(_x+1)
	cp		7
	jr		nc,{+}

	ld		a,6
	ld		(_x+1),a
	ld		a,(_xforce)
	neg
	ld		(_xforce),a
	ld		a,(_xforce+1)
	neg
	ld		(_xforce+1),a

+:	ld		a,(_x+1)
	cp		250
	jr		c,{+}

	ld		a,250
	ld		(_x+1),a
	ld		a,(_xforce)
	neg
	ld		(_xforce),a
	ld		a,(_xforce+1)
	neg
	ld		(_xforce+1),a

+:	ld		a,(iy)						; can land on a ladder iff there is ladder at foot and head
	ld		b,a
	res		6,a
	cp		TILES._LADDERA
	jr		nz,_noLadderLanding
	ld		a,(iy-32)
	ld		b,a
	res		6,a
	cp		TILES._LADDERA
	jr		nz,_noLadderLanding

	ld		a,(_inputs)					; can land if up or down pressed
	and		%11000000
	jr		z,_noLadderLanding

	call	_mountLadder
	call	_updateMapAddrAtFoot
	ret

_noLadderLanding:
	ld		a,(_yforce+1)				; only check for floor when falling
	bit		7,a
	ret		nz

	bit		6,b							; solidity check
	ret		z

	call	_stopFall
	call	_updateMapAddrAtFoot
	ret


_startFall:
	ld		bc,(_xforce)				; halve the x force
	sra		b
	rr		c
	ld		(_xforce),bc

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



_onLadderUpdate:
	ld		bc,$0000

	ld		a,(INPUT._up)
	and		1
	jr		z,{+}

	ld		iy,(_mapAddrAtFootAfterMove)
	ld		a,(iy-32)
	cp		TILES._AIR
	jr		z,{+}

	ld		bc,$ff00

+:	ld		a,(INPUT._down)
	and		1
	jr		z,{+}

	ld		bc,$0100

+:	ld		(_yforce),bc
	call	_updatePosition

	ld		a,(iy)
	cp		TILES._GROUND
	jr		nz,{+}

	call	_cancelUpdatePosition

+:	ld		a,(_inputs)
	ld		b,a
	and		%00110000
	jr		z,_noDismount

	ld		a,(_y+1)
	and		7
	cp		7
	jr		nz,{+}

	ld		a,(iy+32)
	and		$40
	jp		nz,_dismountLadder

+:	bit		3,b							; jumping off?
	jr		z,_noDismount

	call	_dismountLadder
	call	_jump
	call	_checkLeftRight

_noDismount:
	ret


_mountLadder:
	ld		a,%00001000					; on ladder
	ld		(_state),a
	ld		a,(_x+1)
	ld		bc,0
	ld		(_x),bc
	ld		(_xforce),bc
	ld		(_yforce),bc

	and		%11111000
	or		4
	ld		(_x+1),a
	ret

_dismountLadder:
	xor		a
	ld		(_state),a
	ld		(_xforce),a
	ld		(_xforce+1),a
	ld		(_yforce),a
	ld		(_yforce+1),a
	ld		a,(_x+1)
	or		7

	bit		5,b							; left
	jr		z,{+}

	sub		8

+:	bit		4,b							; right
	jr		z,{+}

	inc		a

+:	ld		(_x+1),a
	ret


_updatePosition:
	ld		iy,(_mapAddrAtFootAfterMove)
	ld		(_mapAddrAtFootBeforeMove),iy

	ld		iy,(_x)
	ld		bc,(_xforce)
	add		iy,bc
	ld		(_x),iy

	ld		iy,(_y)
	ld		bc,(_yforce)
	add		iy,bc
	ld		(_y),iy

_updateMapAddrAtFoot:
	call	MAPS._getAddrAtFoot
	ld		(_mapAddrAtFootAfterMove),iy
	ret

_cancelUpdatePosition:
	ld		bc,(_prevx)
	ld		(_x),bc
	ld		bc,(_prevy)
	ld		(_y),bc
	ret


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

_inputs:
	.byte	0

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
	ld		e,(iy-32)
	ld		b,(iy)
	ld		c,(iy+32)

	ld		iy,DISPLAY._dfilehr+(2*32)
	ld		a,$ff
	ld		(iy),a

	ld		iy,DISPLAY._dfilehr+(4*32)
	ld		a,e
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(12*32)
	ld		a,b
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(20*32)
	ld		a,c
	call	DRAW._TILE

	ld		iy,DISPLAY._dfilehr+(29*32)
	ld		a,$ff
	ld		(iy),a

;	ld		iy,DISPLAY._dfilehr+2
;	ld		(pr_cc),iy
;	ld		a,(_x+1)
;	call	DRAW._HEX
;	ld		a,(_y+1)
;	call	DRAW._HEX

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
