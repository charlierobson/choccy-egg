	.module	CHARLIE

; in
; b = x & 7
; a = frame num (0/1)
_getFrame:
	ld		hl,_charlie0Frames
	and		1
	jr		z,{+}
	ld		hl,_charlie1Frames
+:	ld		a,b
	sla		a
	add		a,l
	ld		l,a
	jr		nc,{+}
	inc		h
+:	ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a
	ret

_charlie0Frames:
	.word	_frame00,_frame01,_frame02,_frame03,_frame04,_frame05,_frame06,_frame07
_charlie1Frames:
	.word	_frame10,_frame11,_frame12,_frame13,_frame14,_frame15,_frame16,_frame17

_charlie0:
_frame00:
	.byte	$0e,$00,$00		; '    ###                 '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$ff,$f0,$00		; '############            '
	.byte	$0d,$00,$00		; '    ## #                '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$06,$00,$00		; '     ##                 '
	.byte	$0f,$80,$00		; '    #####               '
	.byte	$1b,$c0,$00		; '   ## ####              '
	.byte	$1b,$c0,$00		; '   ## ####              '
	.byte	$1b,$80,$00		; '   ## ###               '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$04,$00,$00		; '     #                  '
	.byte	$07,$00,$00		; '     ###                '
_frame01:
	.byte	$07,$00,$00		; '     ###                '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$7f,$f8,$00		; ' ############           '
	.byte	$06,$80,$00		; '     ## #               '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$03,$00,$00		; '      ##                '
	.byte	$07,$c0,$00		; '     #####              '
	.byte	$0d,$e0,$00		; '    ## ####             '
	.byte	$0d,$e0,$00		; '    ## ####             '
	.byte	$0d,$c0,$00		; '    ## ###              '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$02,$00,$00		; '      #                 '
	.byte	$03,$80,$00		; '      ###               '
_frame02:
	.byte	$03,$80,$00		; '      ###               '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$3f,$fc,$00		; '  ############          '
	.byte	$03,$40,$00		; '      ## #              '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$01,$80,$00		; '       ##               '
	.byte	$03,$e0,$00		; '      #####             '
	.byte	$06,$f0,$00		; '     ## ####            '
	.byte	$06,$f0,$00		; '     ## ####            '
	.byte	$06,$e0,$00		; '     ## ###             '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$01,$00,$00		; '       #                '
	.byte	$01,$c0,$00		; '       ###              '
_frame03:
	.byte	$01,$c0,$00		; '       ###              '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$1f,$fe,$00		; '   ############         '
	.byte	$01,$a0,$00		; '       ## #             '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$00,$c0,$00		; '        ##              '
	.byte	$01,$f0,$00		; '       #####            '
	.byte	$03,$78,$00		; '      ## ####           '
	.byte	$03,$78,$00		; '      ## ####           '
	.byte	$03,$70,$00		; '      ## ###            '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$00,$80,$00		; '        #               '
	.byte	$00,$e0,$00		; '        ###             '
_frame04:
	.byte	$00,$e0,$00		; '        ###             '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$0f,$ff,$00		; '    ############        '
	.byte	$00,$d0,$00		; '        ## #            '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$00,$60,$00		; '         ##             '
	.byte	$00,$f8,$00		; '        #####           '
	.byte	$01,$bc,$00		; '       ## ####          '
	.byte	$01,$bc,$00		; '       ## ####          '
	.byte	$01,$b8,$00		; '       ## ###           '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$00,$40,$00		; '         #              '
	.byte	$00,$70,$00		; '         ###            '
_frame05:
	.byte	$00,$70,$00		; '         ###            '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$07,$ff,$80		; '     ############       '
	.byte	$00,$68,$00		; '         ## #           '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$00,$30,$00		; '          ##            '
	.byte	$00,$7c,$00		; '         #####          '
	.byte	$00,$de,$00		; '        ## ####         '
	.byte	$00,$de,$00		; '        ## ####         '
	.byte	$00,$dc,$00		; '        ## ###          '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$00,$20,$00		; '          #             '
	.byte	$00,$38,$00		; '          ###           '
_frame06:
	.byte	$00,$38,$00		; '          ###           '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$03,$ff,$c0		; '      ############      '
	.byte	$00,$34,$00		; '          ## #          '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$00,$18,$00		; '           ##           '
	.byte	$00,$3e,$00		; '          #####         '
	.byte	$00,$6f,$00		; '         ## ####        '
	.byte	$00,$6f,$00		; '         ## ####        '
	.byte	$00,$6e,$00		; '         ## ###         '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$00,$10,$00		; '           #            '
	.byte	$00,$1c,$00		; '           ###          '
_frame07:
	.byte	$00,$1c,$00		; '           ###          '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$01,$ff,$e0		; '       ############     '
	.byte	$00,$1a,$00		; '           ## #         '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$00,$0c,$00		; '            ##          '
	.byte	$00,$1f,$00		; '           #####        '
	.byte	$00,$37,$80		; '          ## ####       '
	.byte	$00,$37,$80		; '          ## ####       '
	.byte	$00,$37,$00		; '          ## ###        '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$00,$08,$00		; '            #           '
	.byte	$00,$0e,$00		; '            ###         '

_frame10:
	.byte	$0e,$00,$00		; '    ###                 '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$ff,$f0,$00		; '############            '
	.byte	$0d,$00,$00		; '    ## #                '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$06,$00,$00		; '     ##                 '
	.byte	$0f,$80,$00		; '    #####               '
	.byte	$1b,$c0,$00		; '   ## ####              '
	.byte	$17,$c0,$00		; '   # #####              '
	.byte	$17,$80,$00		; '   # ####               '
	.byte	$0f,$00,$00		; '    ####                '
	.byte	$11,$40,$00		; '   #   # #              '
	.byte	$08,$80,$00		; '    #   #               '
_frame11:
	.byte	$07,$00,$00		; '     ###                '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$7f,$f8,$00		; ' ############           '
	.byte	$06,$80,$00		; '     ## #               '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$03,$00,$00		; '      ##                '
	.byte	$07,$c0,$00		; '     #####              '
	.byte	$0d,$e0,$00		; '    ## ####             '
	.byte	$0b,$e0,$00		; '    # #####             '
	.byte	$0b,$c0,$00		; '    # ####              '
	.byte	$07,$80,$00		; '     ####               '
	.byte	$08,$a0,$00		; '    #   # #             '
	.byte	$04,$40,$00		; '     #   #              '
_frame12:
	.byte	$03,$80,$00		; '      ###               '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$3f,$fc,$00		; '  ############          '
	.byte	$03,$40,$00		; '      ## #              '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$01,$80,$00		; '       ##               '
	.byte	$03,$e0,$00		; '      #####             '
	.byte	$06,$f0,$00		; '     ## ####            '
	.byte	$05,$f0,$00		; '     # #####            '
	.byte	$05,$e0,$00		; '     # ####             '
	.byte	$03,$c0,$00		; '      ####              '
	.byte	$04,$50,$00		; '     #   # #            '
	.byte	$02,$20,$00		; '      #   #             '
_frame13:
	.byte	$01,$c0,$00		; '       ###              '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$1f,$fe,$00		; '   ############         '
	.byte	$01,$a0,$00		; '       ## #             '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$00,$c0,$00		; '        ##              '
	.byte	$01,$f0,$00		; '       #####            '
	.byte	$03,$78,$00		; '      ## ####           '
	.byte	$02,$f8,$00		; '      # #####           '
	.byte	$02,$f0,$00		; '      # ####            '
	.byte	$01,$e0,$00		; '       ####             '
	.byte	$02,$28,$00		; '      #   # #           '
	.byte	$01,$10,$00		; '       #   #            '
_frame14:
	.byte	$00,$e0,$00		; '        ###             '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$0f,$ff,$00		; '    ############        '
	.byte	$00,$d0,$00		; '        ## #            '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$00,$60,$00		; '         ##             '
	.byte	$00,$f8,$00		; '        #####           '
	.byte	$01,$bc,$00		; '       ## ####          '
	.byte	$01,$7c,$00		; '       # #####          '
	.byte	$01,$78,$00		; '       # ####           '
	.byte	$00,$f0,$00		; '        ####            '
	.byte	$01,$14,$00		; '       #   # #          '
	.byte	$00,$88,$00		; '        #   #           '
_frame15:
	.byte	$00,$70,$00		; '         ###            '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$07,$ff,$80		; '     ############       '
	.byte	$00,$68,$00		; '         ## #           '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$00,$30,$00		; '          ##            '
	.byte	$00,$7c,$00		; '         #####          '
	.byte	$00,$de,$00		; '        ## ####         '
	.byte	$00,$be,$00		; '        # #####         '
	.byte	$00,$bc,$00		; '        # ####          '
	.byte	$00,$78,$00		; '         ####           '
	.byte	$00,$8a,$00		; '        #   # #         '
	.byte	$00,$44,$00		; '         #   #          '
_frame16:
	.byte	$00,$38,$00		; '          ###           '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$03,$ff,$c0		; '      ############      '
	.byte	$00,$34,$00		; '          ## #          '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$00,$18,$00		; '           ##           '
	.byte	$00,$3e,$00		; '          #####         '
	.byte	$00,$6f,$00		; '         ## ####        '
	.byte	$00,$5f,$00		; '         # #####        '
	.byte	$00,$5e,$00		; '         # ####         '
	.byte	$00,$3c,$00		; '          ####          '
	.byte	$00,$45,$00		; '         #   # #        '
	.byte	$00,$22,$00		; '          #   #         '
_frame17:
	.byte	$00,$1c,$00		; '           ###          '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$01,$ff,$e0		; '       ############     '
	.byte	$00,$1a,$00		; '           ## #         '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$00,$0c,$00		; '            ##          '
	.byte	$00,$1f,$00		; '           #####        '
	.byte	$00,$37,$80		; '          ## ####       '
	.byte	$00,$2f,$80		; '          # #####       '
	.byte	$00,$2f,$00		; '          # ####        '
	.byte	$00,$1e,$00		; '           ####         '
	.byte	$00,$22,$80		; '          #   # #       '
	.byte	$00,$11,$00		; '           #   #        '
