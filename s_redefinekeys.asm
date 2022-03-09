;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module REDEFINE


_run:
	ld		hl,_pkf					; install 'press key for:' text
	ld		de,DISPLAY._dfile+1
	ld		bc,32
	ldir

	ld		a,1
	call	AYFXPLAYER._PLAY

	xor		a						; clear key line
	ld		hl,DISPLAY._dfile+1+33
	ld		de,DISPLAY._dfile+1+34
	ld		(hl),a
	ld		bc,31
	ldir

	ld		hl,INPUT._gameinput+1	; start redefining here, with first game key
	ld		(_keyaddress),hl

	ld		hl,DISPLAY._dfile+1+3*33			; here's where we'll draw the texts
	ld		(_screenaddress),hl

	ld		hl,_upk					; these need to be in same order as inputs in table, u,d,l etc.
	ld		(_nameaddress),hl

	call	_redeffit
	call	_redeffit
	call	_redeffit
	call	_redeffit
	call	_redeffit

	ld		hl,(INPUT._fire-2)		; copy fire button definition to title screen input states
	ld		(INPUT._begin-2),hl

	ld		b,50					; pause a second

-:	call	DISPLAY._FRAMESYNC
	djnz	{-}

	ret



_redeffit:
	ld		hl,(_nameaddress)		; copy key text to screen
	ld		de,DISPLAY._dfile+16
	ld		bc,5
	ldir

_loop:
	call	DISPLAY._FRAMESYNC				; wait for a keypress
	call	_getcolbit
	cp		$ff
	jr		z,_loop

	xor		$ff						; flip bits to create column mask
	ld		c,a						; column mask in c, port num in b from getcolbit

	; prevent user from using the same key for multiple buttons

	ld		hl,INPUT._gameinput+1
	ld		de,(_keyaddress)

_testnext:
	and		a						; done checking when we are about to check the current input state
	sbc		hl,de
	jr		z,_oktogo

	add		hl,de					; otherwise check to see if port/mask combo is already used
	ld		a,(hl)
	inc		hl
	cp		b
	jr		nz,_nomatchport

	ld		a,(hl)
	cp		c
	jr		nz,_nomatchport

	ld		b,4						; combo already used, warn user by flashing screen
-:  call    DISPLAY._FRAMESYNC
	ld		e,b
	call	invertscreen
	ld		b,e
	djnz	{-}

	call	_waitnokey				; try try again
	jr		_loop

_nomatchport:
	inc		hl						; -> next input state
	inc		hl
	inc		hl
	jr		_testnext


_oktogo:
	ld		hl,(_keyaddress)		; store the redefined key data back into the input structure
	ld		(hl),b
	inc		hl
	ld		(hl),c

	; update the key descriptions

	ld		hl,(_nameaddress)		; zero out the key name part of the name string, "fire  space" -> "fire       " 
	ld		de,6
	add		hl,de
	push	hl
	pop		de
	push	de
	ld		bc,4
	ld		(hl),0
	inc		de
	ldir

	ld		hl,(_keyaddress)		; get pointer to HBT string of key name
	call	INPUT._getkeynameptr

	pop		de						; -> name string + 6

-:	ld		a,(hl)					; write the key name into the key string
	inc		hl
	ld		b,a
	res		7,a
	ld		(de),a
	inc		de
	bit		7,b
	jr		z,{-}

	ld		hl,(_nameaddress)		; copy name to screen
	ld		de,(_screenaddress)
	ld		bc,11
	ldir

	ld		(_nameaddress),hl		; -> next name string
	ld		hl,33-11
	add		hl,de
	ld		(_screenaddress),hl		; -> next screen line

	ld		hl,(_keyaddress)
	ld		de,4
	add		hl,de
	ld		(_keyaddress),hl

_waitnokey:
	call	DISPLAY._FRAMESYNC
	call	_getcolbit
	cp		$ff
	jr		nz,_waitnokey
	ret


_getcolbit:
	ld		bc,$fefe

-:	in		a,(c)					; byte will have a 0 bit if a key is pressed
	or		$e0
	cp		$ff
	ret		nz

	rlc		b						; rotate row selection bit through B & carry
	jr		c,{-}					; carry clear when we've done the once around
	ret


_keyaddress:
	.word	0

_screenaddress:
	.word	0

_nameaddress:
	.word	0

_pkf:
			;--------========--------========
	.asc	"press key for:                  "
_upk:
	.asc	"up    q    "
_dnk:
	.asc	"down  a    "
_lfk:
	.asc	"left  o    "
_rtk:
	.asc	"right p    "
_frk:
	.asc	"fire  space"

.endmodule
