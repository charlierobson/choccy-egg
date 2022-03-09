	.module AYFXPLAYER

;---------------------------------------------------------------;
;                                                               ;
; The simplest effects player.                                  ;
;                                                               ;
; Plays effects on one AY, without music on the background.     ;
;                                                               ;
; Priority of channel selection:                                ;
;  If there are free channels, one of them is selected.         ;
;  If there are no free channels, the longest sounding          ;
;  is selected.                                                 ;
;                                                               ;
; The playing procedure uses the registers AF, BC, DE, HL, IY.  ;
;                                                               ;
;  Initialization:                                              ;
;    ld hl, effects bank address                                ;
;    call AFXINIT                                               ;
;                                                               ;
;  Start the effect:                                            ;
;    ld a, effect number (1..255)                               ;
;    call AFXPLAY                                               ;
;                                                               ;
;  In the interrupt handler:                                    ;
;    call AFXFRAME                                              ;
;                                                               ;
;---------------------------------------------------------------;


;--------------------------------;
; Bugfixed and polished Feb 2022 ;
;--------------------------------;


; channel descriptors, 4 bytes per channel:
; +0 (2) current address (the channel is free if the high byte =$00)
; +2 (2) sound time
; ...

_chdesc	.fill 12 				; 3 channels * 4 bytes


;--------------------------------------------------------------;
; Initializing the effects player.                             ;
; Turns off all channels, sets variables.                      ;
; Input: HL = effects bank address                             ;
;--------------------------------------------------------------;

_INIT:
	inc		hl
	ld		(afxBnkAdr),hl		; save the address of the table of offsets

	ld		hl,_chdesc			; mark all channels as empty
	ld		de,$00ff
	ld		bc,$0300

-:	ld		(hl),d
	inc		hl
	ld		(hl),d
	inc		hl
	ld		(hl),e
	inc		hl
	ld		(hl),e
	inc		hl
	djnz	{-}

	ld		hl,$cf0f			; initialize AY
	ld		e,15

-:	dec		e
	ld		c,h
	out		(c),e
	ld		c,l
	out		(c),d
	jr		nz,{-}

	ld		(afxNseMix),de		; reset the player variables
	ret






;--------------------------------------------------------------;
; Launch the effect on a free channel. Without                 ;
; free channels is selected the longest sounding.              ;
; Input: A = Effect number 1..255                              ;
;--------------------------------------------------------------;

_PLAY:
	dec		a
	ld		de,0				; in DE the longest time in search
	ld		h,e
	ld		l,a
	add		hl,hl
afxBnkAdr=$+1
	ld		bc,0				; self modifies: address of the effect offsets table
	add		hl,bc
	ld		c,(hl)
	inc		hl
	ld		b,(hl)
	add		hl,bc				; the effect address is obtained in hl

	push	hl					; save the effect address on the stack
	
	ld		hl,_chdesc			; empty channel search
	ld		b,3

-:	inc		hl
	inc		hl
	ld		a,(hl)				; compare the channel time with the largest
	inc		hl
	cp		e
	jr		c,{+}

	ld		c,a
	ld		a,(hl)
	cp		d
	jr		c,{+}

	ld		e,c					; remember the longest time
	ld		d,a
	ld		(afxFreeChan),hl
+:	inc		hl
	djnz	{-}

	pop		de					; take the effect address from the stack
afxFreeChan=$+1
	ld		hl,0				; self modifies: address of free channel descriptor
	ld		(hl),b
	dec		hl
	ld		(hl),b
	dec		hl
	ld		(hl),d
	dec		hl
	ld		(hl),e
	ret





;--------------------------------------------------------------;
; Playing the current frame.                                   ;
; No parameters                                                ;
;--------------------------------------------------------------;

_FRAME:
	ld		bc,$0300
	ld		iy,_chdesc

_frameLoop:
	push	bc

	ld		a,11				; initial ay register value used below, also shonky comparison
	ld		h,(iy+1)			; the comparison of the high-order byte of the address to < $40
	cp		h
	jr		nc,_nextChan		; the channel does not play, we skip

	ld		l,(iy+0)
	ld		e,(hl)				; we take the value of the information byte
	inc		hl

	sub		b					; select the volume register:
	ld		d,b					; (11-3=8, 11-2=9, 11-1=10)

	ld		c,$cf				; output the volume value
	out		(c),a
	ld		a,e
	and		$0f
	ld		c,$0f
	out		(c),a
	
	bit		5,e					; will change the tone?
	jr		z,{+}				; tone does not change
	
	ld		a,3					; select the tone registers:
	sub		d					; 3-3=0, 3-2=1, 3-1=2
	add		a,a					; 0*2=0, 1*2=2, 2*2=4
	
	ld		c,$cf				; output the tone values
	out		(c),a
	ld		d,(hl)
	inc		hl
	ld		c,$0f
	out		(c),d
	inc		a
	ld		c,$cf
	out		(c),a
	ld		d,(hl)
	inc		hl
	ld		c,$0f
	out		(c),d
	
+:	bit		6,e					; will change the noise?
	jr		z,_processUpdate	; noise does not change
	
	ld		a,(hl)				; read the meaning of noise
	sub		$20
	jr		c,{+}				; less than $20, play on

	ld		h,a					; otherwise the end of the effect
	ld		l,h
	ld		b,$ff
	ld		c,b
	jr		_updateFxPtrs

+:	inc		hl
	ld		(afxNseMix),a		; keep the noise value

_processUpdate:
	pop		bc					; restore the value of the cycle in B
	push		bc
	inc		b					; number of shifts for flags TN
	ld		a,%01101111			; mask for flags TN
-:	rrc		e					; shift flags and mask
	rrca
	djnz	{-}

	ld		d,a

	ld		bc,afxNseMix+1		; store the values ​​of the flags
	ld		a,(bc)
	xor		e
	and		d
	xor		e					; E is masked by D
	ld		(bc),a

	ld		c,(iy+2)			; increase the time counter
	ld		b,(iy+3)
	inc		bc
	
_updateFxPtrs:
	ld		(iy+2),c
	ld		(iy+3),b
	ld		(iy+0),l			; save the changed address
	ld		(iy+1),h
	
_nextChan:
	ld		bc,4				; go to the next channel
	add		iy,bc
	pop		bc
	djnz	_frameLoop

	ld		hl,$cf0f			; output the value of noise and mixer
afxNseMix=$+1
	ld		de,0				; self modifies: +0 (E) = noise, +1 (D) = mixer
	ld		a,6
	ld		c,h
	out		(c),a
	ld		c,l
	out		(c),e
	inc		a
	ld		c,h
	out		(c),a
	ld		c,l
	out		(c),d
	
	ret




_soundbank:
	.incbin	"data\simple.afb"

; 1 - bellyplink
; 2 - shortshot
; 3 - bubblyriser
; 4 - aliensneeze
; 5 - bananaslip
; 6 - smallexplo
