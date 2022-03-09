	.module TILES

_tile_ladderl=$+$00
_tile_ladderr=$+$08
_tile_platform=$+$10
_tile_thegg=$+$18
_tile_burbfud=$+$20

	.byte	$60		; '##      '
	.byte	$60		; '##      '
	.byte	$60		; '##      '
	.byte	$60		; '##      '
	.byte	$7f		; '########'
	.byte	$7f		; '########'
	.byte	$60		; '##      '
	.byte	$60		; '##      '

	.byte	$06		; '      ##'
	.byte	$06		; '      ##'
	.byte	$06		; '      ##'
	.byte	$06		; '      ##'
	.byte	$fe		; '########'
	.byte	$fe		; '########'
	.byte	$06		; '      ##'
	.byte	$06		; '      ##'

	.byte	$fd		; '###### #'
	.byte	$00		; '        '
	.byte	$bf		; '# ######'
	.byte	$00		; '        '
	.byte	$ef		; '### ####'
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$30		; '  ##    '
	.byte	$7c		; ' #####  '
	.byte	$fe		; '####### '
	.byte	$fe		; '####### '
	.byte	$7c		; ' #####  '
	.byte	$30		; '  ##    '
	
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$08		; '    #   '
	.byte	$14		; '   # #  '
	.byte	$2a		; '  # # # '
	.byte	$55		; ' # # # #'
