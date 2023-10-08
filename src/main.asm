.INCLUDE map.i

.EMPTYFILL $FF

.BANK 0 SLOT 0
.ORG $00
;RST $00
  RET
.ORG $08
;RST $08
  RET
.ORG $10
;RST $10
  RET
.ORG $18
;RST $18
  RET
.ORG $20
;RST $20
  RET
.ORG $28    ;CALL (DE)
  PUSH AF
  LD A,(DE)
  INC DE
  LD L,A
  LD A,(DE)
  LD H,A
  DEC DE
  POP AF
  ;Fall through to JP HL
.ORG $30    ;CALL HL
  JP HL
.ORG $38    ;HCF
  DI
  HALT
  HALT
.ORG $40
;vBlank
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  JP vBlank
.ORG $48
;LCD
  RETI
.ORG $50
;Timer
  RETI
.ORG $58
;Serial
  RETI
.ORG $60
;Joypad
  RETI

.ORG $0100
.SECTION "Header" SIZE $4D FORCE
;Entry
  DI
  JP Start
;Nintendo Logo (48 bytes)
 .db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
 .db $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
 .db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E
;Title (11 bytes)
 .db "TH1 REIIDEN"
;     123456789AB
;Manufacturer code
 .db "TRNG"
;Color Game Boy flag
 .db $C0
;New Licensee Code
 .db "SA"
;Super Game Boy flag
 .db $00
;Cartridge type
 .db $03
;ROM size
 .db $01
;RAM size
 .db $01
;Release destination
 .db $00            ;Japan
;Old Licensee code
 .db $33
;Mask ROM version
 .db $00

.COMPUTEGBCHECKSUM
.COMPUTEGBCOMPLEMENTCHECK

.ENDS

.SECTION "Init" FREE
Start:
;DEBUG
  LD B,B
  LD A,$0A
  LD ($0000),A
  LD A,$00
  LD ($A000),A
  LD A,($A000)
  LD A,($A800)
  LD A,$55
  LD ($A000),A
  LD A,($A000)
  LD A,($A800)
  LD ($0000),A
-
  HALT
  HALT
  NOP
  JR -
.ENDS

.SECTION "vBlank" FREE
;vBlank
vBlank:
;Sound
  CALL PlayTick
  POP AF
  POP BC
  POP DE
  POP HL
  RETI
.ENDS
