;-------------------------------------------------------------------------------
;
.module	DISPLAY

; To install the display driver simply:
;	ld 	ix,DISPLAY._GENERATE

; Special thanks go to Paul Farrow.
;
; *******************************
; * ZX81 Lo-Res Display Drivers *
; *******************************
; (c)2022 Paul Farrow, www.fruitcake.plus.com
;
; You are free to use and modify these drivers in your own programs.


_FRAMESYNC:
	ld		hl,frames
	ld		a,(hl)
-:	cp		(hl)
	jr		z,{-}
	ret


_SETUPHIRES:
	ld 		hl,DISPLAY._GENERATE_HIRES
	jr		{+}

_SETUPLORES:
	ld 		hl,DISPLAY._GENERATE_LORES

+:	push	hl
	call	_FRAMESYNC
	pop		ix
	ld		(DISPLAY._displayfunc),ix
	ld		a,$1e
	ld		i,a
	ret


_GENERATE_VSYNC:
	IN		A,($FE)						; Start the VSync pulse.

	; The user actions must always take the same length of time.
	; Should be at least 3.3 scanlines (684 T-states) in duration for Chroma 81 compatibility.
	CALL	INPUT._read

	OUT		($FF),A						; End the VSync pulse.

	LD		HL,(frames)
	INC		HL
	LD		(frames),hl

_top_border:
	LD		A,(margin)					; Fetch or specify the number of lines in the top border (must be a multiple of 8).
_displayfunc=$+2
	LD		IX,_GENERATE_LORES			; Set the display routine pointer to generate the main picture area next.
	JP		$029E						; Commence generating the top border lines and return to the user program.


_GENERATE_HIRES:
	LD		B,7
-:	DJNZ	{-}

	DEC		B							; 0->ff resets Z flag, for ret nz instruction in d-file
	LD		HL,_dfilehr
	LD		DE,$20
	LD		B,$C0

-:	LD		A,H
	LD		I,A
	LD		A,L
	CALL	_lbuf + $8000
	ADD		HL,DE
	DEC		B
	JP		NZ,{-}
	JP		_bottom_border

_GENERATE_LORES:
	LD		A,R							; Fine tune delay.

	LD		BC,$1901					; B=Row count (24 in main display + 1 for the border). C=Scan line counter for the border 'row'.
	LD		A,$F5						; Timing constant to complete the current border line.
	CALL	$02B5						; Complete the current border line and then generate the main display area.

_bottom_border:
	LD		A,(margin)					; Fetch or specify the number of lines in the bottom border (does not have to be a multiple of 8).
	NEG									; The value could be precalculated to avoid the need for the NEG and INC A here.
	INC		A
	EX		AF,AF'

	OUT		($FE),A						; Turn on the NMI generator to commence generating the bottom border lines.

	; The user actions must not take longer than the time to generate the bottom border at either 50Hz or 60Hz.
	PUSH	IY
	CALL	AYFXPLAYER._FRAME			; (1-9 scanlines)
	POP		IY

	LD		IX,_GENERATE_VSYNC			; Set the display routine pointer to generate the VSync pulse next.
	JP		$02A4						; Return to the user program.



_lbuf:
	LD		R,A							; HFILE address LSB -> R
	.fill	32,0
	RET		NZ							; always returns



_CLSHR:
	xor		a
	ld		hl,_dfilehr
	ld		de,_dfilehr+1
	ld		bc,32*192-1
	ld		(hl),a
	ldir
	ret



_CLS:
	ld		hl,_dfile+1
	ld		c,24
	xor		a

--:	ld		b,32

-:	ld		(hl),a
	inc		hl
	djnz	{-}

	inc		hl
	dec		c
	jr		nz,{--}
	ret



_dfile:
	; empty d-file. You can put a sketchy screen here to be shown at load time.
	.repeat 24
	  .byte $76
	  .fill 32,0
	.loop
	.byte   $76

	.align	32
_dfilehr:
	.incbin	"data\hrmonk.bin"

.endmodule