;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module LZ48

; http://www.cpcwiki.eu/forum/programming/lz48-cruncherdecruncher/

_DECRUNCH:
	ldi
	ld		b,0

nextsequence:
	ld		a,(hl)
	inc		hl
	ld		(lx),a
	and		$f0
	jr		z,lzunpack ; no litteral bytes
	rrca
	rrca
	rrca
	rrca

	ld		c,a
	cp		15 ; more bytes for length?
	jr		nz,copyliteral

getadditionallength:
	ld		a,(hl)
	inc		hl
	inc		a
	jr		nz,lengthnext
	inc		b
	dec		bc
	jr		getadditionallength

lengthnext:
	dec		a
	add		a,c
	ld		c,a
	ld		a,b
	adc		a,0
	ld		b,a ; bc=length

copyliteral:
	ldir

lzunpack:
	ld		a,(lx)
	and		$f
	add		a,3
	ld		c,a
	cp		18 ; more bytes for length?
	jr		nz,readoffset

getadditionallengthbis:
	ld		a,(hl)
	inc		hl
	inc		a
	jr		nz,lengthnextbis
	inc		b
	dec		bc
	jr		getadditionallengthbis

lengthnextbis:
	dec		a
	add		a,c
	ld		c,a
	ld		a,b
	adc		a,0
	ld		b,a ; bc=length

readoffset:
	; read encoded offset
	ld		a,(hl)
	inc		a
	ret		z ; LZ48 end with zero offset
	inc		hl
	push	hl
	ld		l,a
	ld		a,e
	sub		l
	ld		l,a
	ld		a,d
	sbc		a,0
	ld		h,a
	; source=dest-copyoffset

copykey:
	ldir
	pop		hl
	jr		nextsequence


lx:
	.byte	0