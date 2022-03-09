;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INPUT


_settitle:
	ld		hl,_titleinput
	ld		a,(_fire)
	ld		(_begin),a
	jr		{+}

_setgame:
	ld		hl,_gameinput
	ld		a,(_begin)
	ld		(_fire),a
+:	ld		(_inputptr),hl
	ret


; 724T, constant

_read:
	ld		bc,$e007				; initiate a zxpand joystick read
	ld		a,$a0
	out		(c),a

_inputptr=$+1
	ld		hl,_titleinput			; !! self modified
	nop								; timing

	in		a,(c)
	ld		d,a

	ld		c,$fe					; keyboard input port

	; point at first input state block,
	; return from update function pointing to next
	;
	call	_update ; (up)
	call	_update ; (down)
	call	_update ;  etc.
	call	_update ;

	; fall into here for last input

_update:
	ld		a,d						; js value
	and		(hl)					; and with js mask, 0 if dirn pressed
	sub		1						; carry set if result was 0. have to SUB, DEC doesnt affect carry :(
	rl		e						; js result: bit 0 set if dirn detected. starting value of e is irrelevant
	inc		hl						; -> kb port address
	ld		b,(hl)
	in		a,(c)					; read keyboard
	inc		hl						; -> key row mask
	and		(hl)					; result will be 0 if key pressed
	sub		1						; carry set if key pressed
	rla								; carry into bit 0
	or		e						; integrate js results, only care about bit 0
	rra								; completed result back into carry
	inc		hl						; ->key state
	rl		(hl)					; shift carry into input bit train, job done
	inc		hl						; -> next input in table
	ret


; Get the name of the key using the half row port address and column mask
;  from an input structure pointed at by hl
; Returns with pointer to high-bit terminated string in hl
;
_getkeynameptr:
	ld		a,(hl)					; keyboard port number / half row address
	xor		$ff						; active low to active hi
	call	_bit2index
	ld		a,b						; a = b * 5
	sla		a
	sla		a
	add		a,b
	ld		e,a						; stash partial result
	inc		hl						; -> column mask
	ld		a,(hl)
	call	_bit2index
	ld		a,b
	add		a,e						; full result
	ld		hl,_keynametable
	call	adda2hl				; pointer to character
	bit		6,(hl)					; check if it's a wide name
	ret		z						; return if not wide
	ld		a,(hl)					; get index of wide name
	and		63
	ld		hl,_keynametablewide	
	jp		adda2hl



_bit2index:
	ld		bc,7
-:	rra								; shift bit 0 into carry
	ret		c						; return with bit number in B if C set
	inc		b						; next bit 
	dec		c
	jr		nz,{-}
	ret



_keynametable:
	.byte	64+0					; marker bit 6 + offset into _keynametablewide
	.asc	"ZXCV"
	.asc	"ASDFG"
	.asc	"QWERT"
	.asc	"1"+$80,"2"+$80,"3"+$80,"4"+$80,"5"+$80
	.asc	"0"+$80,"9"+$80,"8"+$80,"7"+$80,"6"+$80
	.asc	"POIUY"
	.byte	64+5
	.asc	"LKJH"
	.byte	64+10,$9b				; $9b = inverse period
	.asc	"MNB"
_keynametablewide:
	.asc	"shifTnewlNspacE"


;	-input port- 			-bit-
;							4  3  2  1  0

;	$FE %11111110			V, C, X, Z, SH	
;	$FD %11111101			G, F, D, S, A	
;	$FB %11111011			T, R, E, W, Q	
;	$F7 %11110111			5, 4, 3, 2, 1	
;	$EF %11101111			6, 7, 8, 9, 0	
;	$DF %11011111			Y, U, I, O, P	
;	$BF %10111111			H, J, K, L, NL	
;	$7F %01111111			B, N, M, ., SP
;
; input state data:
;
; joystick bit, or $ff/%11111111 for no joy
; key row input port address,
; key mask, or $ff/%11111111 for no key
; output trigger impulse

_titleinput:
	.byte	%00001000,$7F,%00000001,0		; begin        (SP)
	.byte	%11111111,$FB,%00001000,0		; redefine      (R)
	.byte	%11111111,$DF,%00000100,0		; instructions  (I)
	.byte	%11111111,$FE,%11111111,0
	.byte	%11111111,$FE,%11111111,0

_gameinput:
	.byte	%10000000,$FB,%00000001,0		; up    (Q)
	.byte	%01000000,$FD,%00000001,0		; down	(A)
	.byte	%00100000,$DF,%00000010,0		; left	(O)
	.byte	%00010000,$DF,%00000001,0		; right	(P)
	.byte	%00001000,$7F,%00000001,0		; fire	(SP)


; calculate actual input impulse addresses
;
_begin	= _titleinput + 3
_redef	= _titleinput + 7
_instr	= _titleinput + 11

_up		= _gameinput + 3
_down	= _gameinput + 7
_left	= _gameinput + 11
_right	= _gameinput + 15
_fire	= _gameinput + 19

.endmodule
