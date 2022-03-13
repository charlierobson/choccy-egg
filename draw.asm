	.module	DRAW



; a -> tile number
; iy -> screen dest
_TILE:
	push	bc
	push	hl
	push	de

	push	iy
	pop		hl

	ld		b,TILES._START / 256
	ld		c,a

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





_x:
	.byte	16
_y:
	.byte	184

_prevx:
	.byte	0
_prevy:
	.byte	0

; bit 7 - moving left
; bit 6 - moving right
; bit 5 - in the air
; bit 4 - falling
;
; bit 1 - facing left
; bit 0 - walking animation
_frame:
	.byte	0

_counter:
	.byte	0


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
	ld		a,(_y)						; modify x,y to get top left pixel indices
	sub		14
	ld		b,a
	ld		a,(_x)
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
	ld		a,(_frame)					; bottom 2 bits are 'left facing' and 'frame2' 
	and		3							;
	call	CHARLIE._getFrame			; in: b-> x & 7, a-> sprite frame number

	ld		b,14

-:	ld		a,(de)						; get pixels from screen
	or		(hl)						; jam out pixels into it
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



; draw 3x3 background tiles where the man _was_.
;
_NOMAN:
	ld		a,(_prevx)					; move x,y to top left
	sub		6
	ld		c,a

	ld		a,(_prevy)					; but also for the Y resolve it to
	sub		14							; the start of a character cell...
	and		$f8							; ...by removing bottom 3 bits. 7->0, 13->8, 21->16 etc
	ld		b,a

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
	ld		hl,MAPS._level1
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

	ld		a,(de)						; draw 3x3 tiles. we could work out if fewer tiles
	call	_TILE						; are necessary, but we'll leave that 'till we have to.
	inc		de
	inc		iy
	ld		a,(de)
	call	_TILE
	inc		de
	inc		iy
	ld		a,(de)
	call	_TILE

	ld		a,30						; de -> next row of map
	call	adda2de
	ld		bc,(32*7)+30				; iy -> next _character_ row of hires display (8 x hires lines)
	add		iy,bc

	ld		a,(de)
	call	_TILE
	inc		de
	inc		iy
	ld		a,(de)
	call	_TILE
	inc		de
	inc		iy
	ld		a,(de)
	call	_TILE

	ld		a,30
	call	adda2de
	ld		bc,(32*7)+30
	add		iy,bc

	ld		a,(de)
	call	_TILE
	inc		de
	inc		iy
	ld		a,(de)
	call	_TILE
	inc		de
	inc		iy
	ld		a,(de)
	call	_TILE

	ret
