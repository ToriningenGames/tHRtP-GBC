.INCLUDE map.i
.INCLUDE regs.i

.EMPTYFILL $FF

.BANK 0 SLOT 0
.ORG $00
;RST $00
  POP HL
  POP AF
  RETI
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
  LD B,B
.ORG $40
;vBlank
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  JP vBlank
.ORG $48
;LCD
  PUSH AF
  PUSH HL
  LD HL,LCDVecTab
  LDH A,(STAT)
  JR lcdintr
.ORG $50
;Timer
  RETI
.ORG $58
;Serial
  RETI
.ORG $60
;Joypad
  RETI

.SECTION "Interrupts" FORCE
lcdintr:
  AND %00000111
  ADD A
  ADD L
  LD L,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  JP HL
.ENDS

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
 .db $00,"TSA"
;Color Game Boy flag
 .db $C0
;New Licensee Code
 .db "TN"
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
;System check
  CP $11
  JR z,++
  ;Not GBC; annotate and error later
  LD A,$FF
  JR +
++
  LD A,$01
  AND B
  LD A,$80
  JR nz,+
  ;Use GBC palettes
  XOR A
+
  LD (System),A
;Fade to black
;Can't rely on vBlank interrupt yet; use LCD
  XOR A
  LD HL,LCDVecTab+2
  LDI (HL),A
  LDI (HL),A
  LD A,%00010000
  LDH (STAT),A
  LD A,%00000010
  LDH (IE),A
  EI
;Fade loop
-
  LD A,$80
  LDH (BGPI),A
  LDH A,(BGPD)
  SUB $21
  LDH (BGPD),A
  LDH A,(BGPD)
  SBC $04
  LDH (BGPD),A
  HALT
  CP $00
  JR nz,-
;Init
;Amusement Makers logo?
;Toriningen logo?
;Run title screen
;DEBUG
++
-
  HALT
  JR -
.ENDS
