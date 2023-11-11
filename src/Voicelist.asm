;Voicelist

.SECTION "Voices" ALIGN 16 FREE
Wave:

;First four match the output of channels 1 and 2
;0 Duty 0
.db $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;1 Duty 1
.db $00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;2 Duty 2 (Square)
.db $00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;3 Duty 3
.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF

;4 Square (double octave)
.db $00,$00,$00,$00,$88,$88,$88,$88,$77,$77,$77,$77,$FF,$FF,$FF,$FF

;5 Triangle (Fifth)
.db $24,$57,$AC,$BB,$A7,$56,$67,$77,$77,$77,$66,$57,$AB,$BC,$A7,$54

;6 Triangle (Minor Third)
.db $8D,$B7,$34,$8B,$A6,$66,$98,$88,$88,$87,$79,$A9,$55,$7A,$DA,$64

;7 Saw
.db $00,$11,$22,$33,$45,$56,$67,$78,$99,$AA,$BB,$CD,$DE,$EF,$FC,$84

;8 Triangle
.db $01,$23,$45,$67,$89,$AB,$CD,$EF,$AF,$ED,$CB,$A9,$87,$65,$43,$21

;9 Four octaves up
.db $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF

;10 Three octaves up
.db $00,$00,$FF,$FF,$00,$00,$FF,$FF,$00,$00,$FF,$FF,$00,$00,$FF,$FF

;11 Triangle (messy)
.db $01,$22,$55,$68,$78,$AA,$DD,$DF,$BF,$DD,$CA,$98,$87,$75,$32,$32

;12 Lowpass Sawtooth
.hex 8DFFDCCCCBAAA9888776555433332002


.ENDS
