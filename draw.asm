	.module	DRAW



; a -> character number
; iy -> screen dest
_CSET:
	push	bc
	push	hl
	push	de

	push	iy
	pop		hl

	ld		b,$1e
	ld		c,a
	sla		c
	sla		c
	sla		c
	jr		nc,_tileDraw
	inc		b
	jr		_tileDraw


; a -> tile offset
; iy -> screen dest
_TILE:
	push	bc
	push	hl
	push	de

	push	iy
	pop		hl

	ld		b,TILES._START / 256
	ld		c,a

_tileDraw:
	ld		de,32

	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a
	add		hl,de
	inc		bc
	ld		a,(bc)
	ld		(hl),a

	pop		de
	pop		hl
	pop		bc
	ret


_MAP:
	ld		hl,(GAME._level)
	ld		iy,DISPLAY._dfilehr
	ld		c,24

--:	ld		b,32

-:	ld		a,(hl)
	call	_TILE
	inc		hl
	inc		iy
	djnz	{-}

	ld		de,32*7
	add		iy,de

	dec		c
	jr		nz,{--}
	ret




; man position is centered on his foot, which is offset 6,14 pixels, marked by X below.
;
;    ###     
;    ####    
;    ####    
;############
;    ## #    
;    ####    
;     ##     
;    #####   
;   ## ####  
;   ## ####  
;   ## ###   
;    ####    
;     #      
;     #X#    

_MAN:
	ld		a,(GAME._y+1)				; modify x,y to get top left pixel indices
	sub		13
	ld		b,a
	ld		a,(GAME._x+1)
	sub		6
	ld		c,a

	; dr beep's optimised screen address calculation.
	; we'll see this a lot.
	srl		b
	rr		c
	srl		b
	rr		c
	srl		b
	rr		c
	ld		hl,DISPLAY._dfilehr
	add		hl,bc
	ex		de,hl						; de -> byte address containing topleft pixel

	and		7							; bottom 3 bits of x coord contains the number of shifts
	ld		b,a
	ld		a,(GAME._animState)			; bottom 2 bits are 'left facing' and 'frame2' 
	call	SPRITES._getFrame			; in: b-> x & 7, a-> sprite frame number

	ld		b,14

-:	ld		a,(de)						; get pixels from screen
	or		(hl)						; jam our pixels into it
	ld		(de),a
	inc		hl
	inc		de
	ld		a,(de)
	or		(hl)
	ld		(de),a
	inc		hl
	inc		de
	ld		a,(de)
	or		(hl)
	ld		(de),a
	inc		hl

	ld		a,30						; each screen line is 32 bytes, we've already added 2
	call	adda2de

	djnz	{-}
	ret


_chx:
	.byte	0

_chy:
	.byte	0

; draw 3x3 background tiles where the man _was_.
;
_NOMAN:
	ld		a,(GAME._prevx+1)			; move x to leftmost pixel of sprite
	sub		6
	ld		c,a

	and		$f8							; to char cell
	ld		e,a

	ld		a,c
	add		a,11
	and		$f8
	sub		e
	srl		a
	srl		a
	srl		a
	ld		(_chx),a

	ld		a,(GAME._prevy+1)			; but also for the Y resolve it to
	ld		e,a
	sub		13							; the start of a character cell...
	and		$f8							; ...by removing bottom 3 bits. 7->0, 13->8, 21->16 etc
	ld		b,a

	ld		a,e							; calculate how many rows we need to clear
	and		$f8
	sub		b
	srl		a
	srl		a
	srl		a
	ld		(_chy),a

	push	bc							; do the sums twice, once for bg map, once for screen.
	srl		b							; save the modified position for the second go,
	srl		b							; then divide y by 8 to yield a character cell location
	srl		b

	srl		b							; get character cell location in the map
	rr		c
	srl		b
	rr		c
	srl		b
	rr		c
	ld		hl,(GAME._level)
	add		hl,bc
	ex		de,hl						; de -> tile under top left of man's position

	pop		bc							; now calculate where on screen it will go
	srl		b
	rr		c
	srl		b
	rr		c
	srl		b
	rr		c
	ld		iy,DISPLAY._dfilehr
	add		iy,bc						; iy -> hires screen address

.define getbyte ld		a,(de)
;.define getbyte ld		a,$20

	getbyte							; draw 3x3 tiles. we could work out if fewer tiles
	call	_TILE						; are necessary, but we'll leave that 'till we have to.
	inc		de
	inc		iy
	getbyte
	call	_TILE
	inc		de
	inc		iy
	ld		a,(_chx)
	dec		a
	jr		z,{+}
	getbyte
	call	_TILE

+:	ld		a,30						; de -> next row of map
	call	adda2de
	ld		bc,(32*7)+30				; iy -> next _character_ row of hires display (8 x hires lines)
	add		iy,bc

	getbyte
	call	_TILE
	inc		de
	inc		iy
	getbyte
	call	_TILE
	inc		de
	inc		iy
	ld		a,(_chx)
	dec		a
	jr		z,{+}
	getbyte
	call	_TILE

+:	ld		a,(_chy)
	dec		a
	ret		z

	ld		a,30
	call	adda2de
	ld		bc,(32*7)+30
	add		iy,bc

	getbyte
	call	_TILE
	inc		de
	inc		iy
	getbyte
	call	_TILE
	inc		de
	inc		iy
	ld		a,(_chx)
	dec		a
	ret		z
	getbyte
	call	_TILE
	ret



_HEX:
	push	af
	srl		a
	srl		a
	srl		a
	srl		a
	call	_hexDigit
	pop		af
_hexDigit:
	and		$0f
	add		a,$1c

_RST8:
	; character code in a
	push	iy
	ld		iy,(pr_cc)
	inc		iy
	ld		(pr_cc),iy
	dec		iy
	call	_CSET
	pop		iy
	ret
