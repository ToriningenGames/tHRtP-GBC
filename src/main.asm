.INCLUDE map.i
.INCLUDE regs.i

.EMPTYFILL $FF

.BANK 0 SLOT 0
.ORG $00
;RST $00
  POP HL
  POP AF
  RETI
  
;RST $08
;Swap ROM banks
;A = new bank
;Returns
;A = old bank
;Nothing destroyed
.ORG $08
  PUSH BC
    LD B,A
    LD A,(CurrROMBank)
    LD C,A
    JR swaprombank
;Swap RAM banks
;A = new bank
;Returns
;A = old bank
;Nothing destroyed
.ORG $10
  PUSH BC
    LD B,A
    LD A,(CurrRAMBank)
    LD C,A
    JR swaprambank
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
  JP $FF00|OAMStart   ;vBlank   ;Tail call
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

.SECTION "Bankswitch" FORCE
swaprombank:
    LD A,B
    LD (CurrROMBank),A
    LD ($2000),A
    LD A,C
  POP BC
  RET
swaprambank:
    LD A,B
    LD (CurrRAMBank),A
    LDH (WBK),A
    LD A,C
  POP BC
  RET
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
;Get vBlank up and running
;OAM routine
  LD HL,OAMRoutine
  LD B,OAMSize
  LD C,OAMStart
-
  LDI A,(HL)
  LDH (C),A
  INC C
  DEC B
  JR nz,-
;Clear vRAM data area
  LD HL,OAMData
  LD A,$FF
  LD C,2
-
  LDI (HL),A
  DEC B
  JR nz,-
  DEC C
  JR nz,-
;Bank byte
  XOR A
  LD (CurrROMBank),A
  LD (CurrRAMBank),A
  LD ($2000),A
  LDH (WBK),A
;Enable interrupts!
  LDH (IF),A
  LD A,%00000001
  LDH (IE),A
  EI
;Amusement Makers logo?
;Toriningen logo?
;Begin music
  LD HL,channelonebase+$2A
  LD A,<Channel1Pitch
  LDI (HL),A
  LD (HL),>Channel1Pitch
  LD HL,channeltwobase+$2A
  LD A,<Channel2Pitch
  LDI (HL),A
  LD (HL),>Channel2Pitch
  LD HL,channelthreebase+$2A
  LD A,<Channel3Pitch
  LDI (HL),A
  LD (HL),>Channel3Pitch
  LD HL,channelfourbase+$2A
  LD A,<Channel4Pitch
  LDI (HL),A
  LD (HL),>Channel4Pitch
  LD A,%11110011
  LD (musicglobalbase+1),A
  LD BC,SongTitle
  CALL MusicLoad
;Load some tiles
;Thankfully the screen is already black, so we don't care what we overwrite
;It's the very beginning, so use a whole bank; why not?
  LD A,2
  RST $08
  LD HL,InitTemp
  PUSH HL
    LD HL,TileDataTitle
    LD DE,$D000
    CALL ExtractSpec
  POP BC
  LD L,15
-
  PUSH HL
  PUSH BC
    CALL ExtractRestoreSP
  POP BC
  POP HL
  DEC L
  JR nz,-
  PUSH BC
    LD A,$7F  ;Transfer size: $800
    LD DE,$8000
    LD HL,$D000
    CALL AddTransfer
    HALT
    LD A,$7F
    LD DE,$8800
    LD HL,$D800
    CALL AddTransfer
    HALT
  ;Copy the top half to the bottom of the bank
  ;so we can decompress the rest
    LD HL,$D000
    LD DE,$D800
-
    LD A,(DE)
    LDI (HL),A
    INC E
    JR nz,-
    INC D
    LD A,$E0
    CP D
    JR nz,-
  POP HL
  PUSH HL
  ;Tweak the extract structure to see the new data location
    INC HL
    LD A,(HL)
    BIT 7,A
    JR z,+
    SUB $08
    LD (HL),A
+
    INC HL
    INC HL
    INC HL
    INC HL
    LD A,(HL)
    SUB $08
    LD (HL),A
  POP BC
  LD L,8
-
  PUSH HL
  PUSH BC
    CALL ExtractRestoreSP
  POP BC
  POP HL
  DEC L
  JR nz,-
  LD A,$7F
  LD DE,$9000
  LD HL,$D800
  CALL AddTransfer
  HALT
;Run title screen
;DEBUG
++
-
  HALT
  JR -
.ENDS

.SECTION "OAM Routine" FREE
OAMRoutine:
  LD A,>OAMData
  LDH (DMA),A
  LD A,40
-
  DEC A
  JR nz,-
  JP OAMEnd

.DEFINE OAMSize 12
.ENDS
