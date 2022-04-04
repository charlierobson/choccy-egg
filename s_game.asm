;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
	.module GAME


_run:
	call	INPUT._setgame

	call	DISPLAY._CLSHR
	call	DISPLAY._SETUPHIRES

	xor		a
	ld		(_levelNum),a

_newLevel:
	ld		a,(_levelNum)
	ld		hl,MAPS._levels
	call	tableget
	ld		de,DISPLAY._dfile
	ld		(_level),de
	call	LZ48._DECRUNCH

	xor		a
	ld		(_state),a
	ld		(_eggs),a

_restartLevel:
	call	DRAW._MAP

	call	MAPS._findStartPositions
	ld		hl,(_x)
	ld		(_prevx),hl
	ld		hl,(_y)
	ld		(_prevy),hl

_loop:
	ld		hl,_state					; motion state, try and keep hl set to this for entire loop

	ld		a,(INPUT._up)				; udenable: set to 1 when either up or down freshly pressed
	and		3							; this can be used as a mask to enable mounting of ladder
	cp		1							; to prevent re-attachment after leaving it
	jr		nz,{+}

	ld		(_udEnable),a

+:	ld		a,(INPUT._down)
	and		3
	cp		1
	jr		nz,{+}

	ld		(_udEnable),a

+:	ld		bc,(_x)						; keep previous position around for undrawing purposes
	ld		(_prevx),bc
	ld		bc,(_y)
	ld		(_prevy),bc

	ld		a,(_x+1)
	ld		c,a
	ld		a,(_y+1)
	ld		b,a
	call	MAPS._getAddrOfTileFromPixel
	ld		(_mapAddrAtFootBeforeMove),iy

	ld		a,(iy)
	cp		TILES._EGG
	call	z,_collectEgg
	cp		TILES._SEED
	call	z,_collectSeed

	ld		a,(_x+1)					; get position of tummy
	ld		c,a
	ld		a,(_y+1)
	ld		b,a
	ld		a,(_animState)
	and		2							; test if facing right
	ld		a,4							; tummy is 4 pixels right
	jr		z,{+}
	ld		a,-5						; tummy is 5 pixels left
+:	add		a,c
	ld		c,a
	call	MAPS._getAddrOfTileFromPixel
	ld		(_mapAddrAtTummyBeforeMove),iy
	ld		a,(iy)
	ld		(_tileAtTummyBeforeMove),a

	call	_updateMovement

	ld		a,(_y+1)
	cp		191
	jr		c,{+}						; ok

	ld		a,191						; oh dear oh dead
	call	_setY

	call	_pause
	jp		_restartLevel

+:	ld		a,(_animState)
	ld		b,a
	srl		b

	ld		a,(_state)
	bit		BONLADDER,a
	jr		z,{+}

	ld		a,(_y+1)					; ladder anim update
	rra
	rra
	jr		_setFrame

+:	ld		a,(_xforce+1)				; update manimation if moving
	and		a
	jr		z,_setFrame

	ld		a,(frames)					; animation frame tied to frames counter
	rra
	rra
	rra

_setFrame:
	rl		b
	ld		a,b
	ld		(_animState),a

;	call	_debugOutput

	call	DISPLAY._FRAMESYNC

	call	DRAW._NOMAN					; undraw man at old position
	call	DRAW._MAN					; draw man at new position

	ld		a,(_elevatorX)
	and		a
	jr		z,{+}

	ld		c,a
	ld		a,(_elevator1Y+1)
	ld		b,a
	call	DRAW._ELEVATOR

	ld		a,(_elevatorX)
	ld		c,a
	ld		a,(_elevator2Y+1)
	ld		b,a
	call	DRAW._ELEVATOR

	ld		a,(_elevatorX)
	ld		c,a
	ld		b,0
	call	DRAW._NOELEVATOR
+:

_ea:
	ld		bc,$ff80
	ld		a,186
	ld		hl,(_elevator1Y)
	add		hl,bc
	cp		h
	jr		nc,{+}
	ld		h,a
+:	ld		(_elevator1Y),hl
	ld		hl,(_elevator2Y)
	add		hl,bc
	cp		h
	jr		nc,{+}
	ld		h,a
+:	ld		(_elevator2Y),hl

	; ld		bc,$0000
	; call	DRAW._HEN
	; ld		bc,$0010
	; call	DRAW._HEN
	; ld		bc,$0020
	; call	DRAW._HEN
	; ld		bc,$0030
	; call	DRAW._HEN

	ld		a,(_eggs)
	cp		12
	jp		nz,_loop

	ld		a,(_levelNum)
	inc		a
	ld		(_levelNum),a
	cp		6
	jp		nz,_newLevel

	jp		_gameOver


_collectEgg:
	ld		(iy),0
	ld		a,(_eggs)
	inc		a
	ld		(_eggs),a
	ld		a,2
	push	hl
	call	AYFXPLAYER._PLAY
	pop		hl
	ret

_collectSeed:
	ld		(iy),0
	ld		a,5
	push	hl
	call	AYFXPLAYER._PLAY
	pop		hl
	ret



_updateMovement:
	bit		BINAIR,(hl)
	jp		nz,_inAirUpdate

	bit		BONLADDER,(hl)
	jp		nz,_onLadderUpdate

	bit		BONELEVATOR,(hl)
	jp		nz,_onElevatorUpdate

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
	ld		a,(INPUT._down)				; only mount ladder when down is just pressed
	and		1
	jr		z,_checkUp

	ld		a,(_udEnable)
	and		a
	jr		z,_checkUp

	ld		iy,(_mapAddrAtFootAfterMove)
	ld		a,(iy)
	and		$30
	cp		TILES._LADDER
	jr		nz,_checkUp
	ld		a,(iy+32)
	and		$30
	cp		TILES._LADDER
	jp		z,_mountLadder

_checkUp:
	ld		a,(INPUT._up)				; only mount ladder when
	and		1
	jr		z,_checkJump

	ld		a,(_udEnable)
	and		a
	jr		z,_checkJump

	ld		iy,(_mapAddrAtFootAfterMove)
	ld		a,(iy)
	and		$30
	cp		TILES._LADDER
	jp		z,_mountLadder

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

	ld		a,(_tileAtTummyBeforeMove)
	bit		6,a
	jr		nz,{+}

	ld		bc,$ff00		; replace with call to addForceClampedTo1?
	ld		(_xforce),bc

+:	ld		a,(INPUT._right)
	and		1
	ret		z

	ld		a,0							; face right
	ld		(_animState),a

	ld		a,(_tileAtTummyBeforeMove)
	bit		6,a
	ret		nz

	ld		bc,$0100		; replace with call to addForceClampedTo1
	ld		(_xforce),bc
	ret



_jump:
	set		BINAIR,(hl)
	ld		bc,$fe80
	ld		(_yforce),bc
	ret


_inAirUpdate:
	push	hl
	ld		hl,(_yforce)				; 'gravity'
	ld		bc,$001b
	add		hl,bc
	ld		(_yforce),hl
	pop		hl

	call	_updatePosition

	ld		a,(_x+1)
	cp		7
	jr		nc,{+}

	ld		a,6
	ld		(_x+1),a
	call	_rebound

+:	ld		a,(_x+1)
	cp		250
	jr		c,{+}

	ld		a,250
	ld		(_x+1),a
	call	_rebound

+:	ld		a,(_tileAtTummyBeforeMove)
	bit		6,a
	call	nz,_rebound

	ld		a,(iy)						; can land on a ladder iff there is ladder at foot and head
	ld		b,a
	and		$30
	cp		TILES._LADDER
	jr		nz,_clearLadderEx
	ld		a,(iy-32)
	and		$30
	cp		TILES._LADDER
	jr		nz,_noLadderLanding

	bit		BLADDEREX,(hl)				; can land on ladder if not exiting it
	jr		nz,_noLadderLanding

	ld		a,(INPUT._impulse)			; can land if up or down pressed
	and		%00011000					; ---UDlrf
	jr		z,_noLadderLanding

	call	_mountLadder
	call	_updateMapAddrAtFoot
	ret

_rebound:
	ld		a,(_xforce)
	neg
	ld		(_xforce),a
	ld		a,(_xforce+1)
	neg
	ld		(_xforce+1),a
	ret

_clearLadderEx:
	res		BLADDEREX,(hl)

_noLadderLanding:
	ld		a,(_yforce+1)				; only check for floor when falling
	bit		7,a
	ret		nz

	bit		6,b							; solidity check
	jr		z,_tryLandOnElevator

	call	_stopFall
	call	_updateMapAddrAtFoot
	ret

_tryLandOnElevator:
	ld		a,(_x+1)					; x is within elevator x->x+16?
	ld		b,a
	ld		a,(_elevatorX)
	cp		b
	ret		nc
	add		a,16
	cp		b
	ret		c

	; is within elevatorX, test Ys

	push	hl
	ld		hl,(_y)
	ld		b,h
	ld		de,(_yforce)
	add		hl,de
	ld		c,h
	pop		hl
	ld		de,_elevator1Y+1
	ld		a,(de)
	call	_isABetweenBAndC
	jr		z,_willLand

	ld		de,_elevator2Y+1
	ld		a,(de)
	call	_isABetweenBAndC
	ret		nz

_willLand:
	ld		(_attachedElevator),de
	ld		(hl),NONELEVATOR
	ld		bc,0
	ld		(_xforce),bc
	ld		(_yforce),bc
	ret


; returns z=set if true
;

_isABetweenBAndC:
	cp		b
	ret		z			; a == b
	jr		c,{+}		; a < b

	cp		c
	ret		z
	jr		nc,{+}		; a > c

	; is between b & c
	xor		a
	ret

+:	or		$ff
	ret



_startFall:
	ld		bc,(_xforce)				; halve the x force
	sra		b
	rr		c
	ld		(_xforce),bc

	ld		bc,$0100
	ld		(_yforce),bc
	ld		(hl),NINAIR
	ret


_stopFall:
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
	ld		bc,$0000
	ld		(_yforce),bc
	ld		(hl),0						; state = on ground
	ret



_onLadderUpdate:
	ld		bc,$0000
	ld		iy,(_mapAddrAtFootBeforeMove)

	ld		a,(INPUT._up)
	and		1
	jr		z,_notUp

	ld		a,(iy-32)
	cp		TILES._AIR
	jr		z,_notUp

	ld		bc,$ff00

_notUp:
	ld		a,(INPUT._down)
	and		1
	jr		z,_notDown

	ld		e,(iy)						; tile at foot

	ld		a,(_y+1)					; if we're about to move into tile below ...
	and		7
	cp		7
	jr		nz,{+}

	ld		e,(iy+32)					; ... check further down

+:	xor		a							; is it air?
	cp		e
	jr		nz,{+}

	jp		_dismountLadder				; weeeee!

+:	ld		a,$40
	cp		e							; ground underfoot?
	jr		z,_notDown

	ld		bc,$0100

_notDown:
	ld		(_yforce),bc
	call	_updatePosition

	ld		a,(INPUT._impulse)
	ld		b,a
	and		%00000110					; ---udLRf
	ret		z							; no exiting of ladder at this point

	bit		0,b							; ---udlrF  jumping off?
	jr		nz,_jumpOffCheck

	ld		a,(_y+1)					; at ground level?
	and		7
	cp		7
	ret		nz

	ld		a,(iy+32)					; is solid beneath feet?
	and		$40
	ret		z

	call	_dismountLadder
	jp		_updatePosition

_jumpOffCheck:
	ld		a,(iy-32)
	and		a							; at top of ladder?
	jr		z,{+}

	and		$f0
	cp		TILES._LADDER
	ret		nz

	ld		a,(iy)
	and		$f0
	cp		TILES._LADDER
	ret		nz

+:	call	_dismountLadder
	call	_jump
	call	_checkLeftRight
	jp		_updatePosition

_mountLadder:
	ld		(hl),NONLADDER

	ld		a,(_animState)
	set		5,a							; climbing frames
	ld		(_animState),a

	ld		a,(_x+1)

	ld		bc,0
	ld		(_x),bc
	ld		(_xforce),bc
	ld		(_yforce),bc

	and		%11111000
	ld		(_x+1),a
	ld		e,a

	ld		bc,(_mapAddrAtFootAfterMove)
	ld		a,(bc)
	cp		TILES._LADDER
	ret		nz

	ld		a,8
	add		a,e
	ld		(_x+1),a
	ret


_dismountLadder:
	xor		a
	ld		b,a
	ld		c,a
	ld		(_udEnable),a
	ld		(_xforce),bc
	ld		(_yforce),bc
	ld		a,(_animState)
	res		5,a							; walk again
	ld		(_animState),a
	ld		(hl),NLADDEREX				; clear state flags, default on ground, exiting ladder
	ret


_onElevatorUpdate:
	ld		bc,0
	ld		(_xforce),bc
	call	_checkLeftRight
	call	_updatePosition
	ld		a,(INPUT._fire)
	and		1
	jr		z,{+}

	ld		(hl),0
	jp		_jump

+:	ld		a,(_x+1)
	ld		b,a
	ld		a,(_elevatorX)
	cp		b
	jr		nc,_fallOffElevator
	add		a,16
	cp		b
	jr		c,_fallOffElevator

	ld		de,(_attachedElevator)
	ld		a,(de)
	dec		a
	ld		(_y+1),a
	cp		16							; can't go off top of screen
	ret		nz

_fallOffElevator:
	ld		(hl),0						; abort!
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
	ld		a,(_x+1)
	ld		c,a
	ld		a,(_y+1)
	ld		b,a
	call	MAPS._getAddrOfTileFromPixel
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
	call	_pause
	call	DISPLAY._CLS
	call	DISPLAY._SETUPLORES
	ret


_pause:
	call	DISPLAY._FRAMESYNC
	call	DRAW._NOMAN					; undraw man at old position
	call	DRAW._MAN					; draw man at new position

	ld		b,75
-:	call	DISPLAY._FRAMESYNC
	djnz	{-}
	ret


_setX:
	ld		(_x+1),a
	xor		a
	ld		(_x),a
	ret

_setY:
	ld		(_y+1),a
	xor		a
	ld		(_y),a
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

_level:
	.word	0

_levelNum:
	.byte	0

_eggs:
	.byte	0

_elevatorX:
	.byte	0

_elevator1Y:
	.word	$0000

_elevator2Y:
	.word	$4000

_attachedElevator:
	.word	0

_isWithinX:
	.byte	0


_mapAddrAtFootBeforeMove:
	.word	 0
_mapAddrAtTummyBeforeMove:
	.word	 0
_tileAtTummyBeforeMove:
	.byte	 0
_mapAddrAtFootAfterMove:
	.word	 0


; bit positions for various states
BINAIR=7
NINAIR=1<<BINAIR

BONLADDER=6
NONLADDER=1<<BONLADDER

BLADDEREX=5
NLADDEREX=1<<BLADDEREX

BONELEVATOR=4
NONELEVATOR=1<<BONELEVATOR

_state:
	.byte	0

; bit 1 - facing left
; bit 0 - walking
_animState:
	.byte	0

_udEnable:
	.byte	0


#include "s_game.debug.asm"

.endmodule
