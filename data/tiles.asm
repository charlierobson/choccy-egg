	.module TILES

_AIR = $00
_EGG = $08
_SEED = $10

_MAN = $18
_ELE = $20

_GROUND = $40
_LADDERL = $70
_LADDERR = $78

_LADDER = $30

	.align	256
_START:

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$38		; '  ###   '
	.byte	$7e		; ' ###### '
	.byte	$ff		; '########'
	.byte	$ff		; '########'
	.byte	$7e		; ' ###### '
	.byte	$38		; '  ###   '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$08		; '    #   '
	.byte	$14		; '   # #  '
	.byte	$2a		; '  # # # '
	.byte	$55		; ' # # # #'

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$80		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$30		; '  ##    '
	.byte	$30		; '  ##    '
	.byte	$30		; '  ##    '
	.byte	$30		; '  ##    '
	.byte	$3f		; '  ######'
	.byte	$3f		; '  ######'
	.byte	$30		; '  ##    '
	.byte	$30		; '  ##    '

	.byte	$0c		; '    ##  '
	.byte	$0c		; '    ##  '
	.byte	$0c		; '    ##  '
	.byte	$0c		; '    ##  '
	.byte	$fc		; '######  '
	.byte	$fc		; '######  '
	.byte	$0c		; '    ##  '
	.byte	$0c		; '    ##  '

	.byte	$fb		; '##### ##'
	.byte	$00		; '        '
	.byte	$bf		; '# ######'
	.byte	$00		; '        '
	.byte	$ef		; '### ####'
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$80		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$80		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$80		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$80		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '
	.byte	$80		; '        '
	.byte	$00		; '        '
	.byte	$00		; '        '

	.byte	$33		; '  ##  ##'
	.byte	$30		; '  ##    '
	.byte	$37		; '  ## ###'
	.byte	$30		; '  ##    '
	.byte	$3f		; '  ######'
	.byte	$3f		; '  ######'
	.byte	$30		; '  ##    '
	.byte	$30		; '  ##    '

	.byte	$ec		; '### ##  '
	.byte	$0c		; '    ##  '
	.byte	$ac		; '# # ##  '
	.byte	$0c		; '    ##  '
	.byte	$fc		; '######  '
	.byte	$fc		; '######  '
	.byte	$0c		; '    ##  '
	.byte	$0c		; '    ##  '
