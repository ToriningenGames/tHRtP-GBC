.INCLUDE map.i
.INCLUDE regs.i

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
    LDH A,(CurrROMBank)
    LD C,A
    LD A,B
    JR swaprombank
;Swap RAM banks
;A = new bank
;Returns
;A = old bank
;Nothing destroyed
.ORG $10
  PUSH BC
    LD B,A
    LDH A,(CurrRAMBank)
    LD C,A
    LD A,B
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
  LDH A,(LCDVec)
  LD L,A
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
  LDH A,(LCDVec+1)
  LD H,A
  JP HL
.ENDS

.SECTION "Bankswitch" FORCE
swaprombank:
    LDH (CurrROMBank),A
    LD ($2000),A
    LD A,C
  POP BC
  RET
swaprambank:
    LDH (CurrRAMBank),A
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
  LD SP,StackTop+1
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
  LDH (System),A
;Fade to black
;Can't rely on vBlank interrupt yet; use LCD
  XOR A
  LD HL,$FF00|LCDVec
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
  RST $10
  INC A
  RST $08
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
  LD A,4
  LD C,0
  LD HL,MapTitlePal
  CALL AddPalette
  ;1152 bytes of map data
  LD HL,InitTemp
  PUSH HL
    LD HL,MapTitle
    LD DE,MapTemp
    CALL ExtractSpec
    CALL ExtractRestoreSP
    CALL ExtractRestoreSP
    CALL ExtractRestoreSP
    CALL ExtractRestoreSP
  POP HL
  LD A,$23
  LD DE,$9800
  LD HL,MapTemp
  CALL AddTransfer
  LD A,$23
  LD DE,$9801
  LD HL,MapTemp+$240
  CALL AddTransfer
  ;Hide the title
  LD A,%10011001
  LDH (LCDC),A
;Wait for song to kick in
  LD DE,$0249
-
  HALT
  DEC E
  JR nz,-
  DEC D
  JR nz,-
;Do the line thing!
  LD A,<LineThing
  LDH (LCDVec),A
  LD A,>LineThing
  LDH (LCDVec+1),A
  LD A,%01000000
  LDH (STAT),A
  LD A,%00000011
  LDH (IE),A
  LD C,$7B
-
  CALL Rand
  AND $7F
  LDH (LYC),A
  HALT
  DEC C
  JR nz,-
;Show the title
  LD A,%10000000
  LDH (LCDC),A
  LDH (STAT),A
  LD A,%00000001
  LDH (IE),A
;Run title loop
  LD A,15
  LDH (ModeTimer),A
  JP AttractEnter

LineThing:
;Flash a line white
-
  LDH A,(STAT)
  AND 3
  JR nz,-
  LD A,$80
  LDH (BGPI),A
  LD A,$FF
  LDH (BGPD),A
  LDH (BGPD),A
;Wait a line
-
  LDH A,(STAT)
  AND 3
  JR z,-
-
  LDH A,(STAT)
  AND 3
  JR nz,-
;Return color
  LD A,$80
  LDH (BGPI),A
  XOR A
  LDH (BGPD),A
  LDH (BGPD),A
  POP HL
  POP AF
  RETI
.ENDS

.SECTION "Title Loop" FREE ALIGN 16
AttractText:
.db $80,$80,$80,$80,$80,$80,$9A,10,11, 12, 13, 14, 15,$80,$80,$80
AttractNoText:
.db $80,$80,$80,$80,$80,$80,$9A, 7, 8,$80,$80,$80,$80,$80,$80,$80
AttractEnter:
  LD B,$FF
AttractLoop:
  HALT
  ;Check for buttons
  LDH A,(Buttons)
  LD C,A
  XOR B
  LD B,C
  AND C
  ;Any button pressed, go to the menu
  JR nz,MenuEnter
  ;Check for blink
  LDH A,(ModeTimer)
  DEC A
  LDH (ModeTimer),A
  JR nz,+
  LD A,30
  LDH (ModeTimer),A
  ;Blink the text
  LDH A,(ModeVar0)
  INC A
  LDH (ModeVar0),A
  AND 1
  LD HL,AttractText
  JR z,++
  LD HL,AttractNoText
++
  PUSH BC
    XOR A
    LD DE,$99C0
    CALL AddTransfer
  POP BC
+
  JR AttractLoop
MenuEnter:
  LD HL,AttractNoText
  XOR A
  LD DE,$99C0
  CALL AddTransfer
  ;Add a palette entry
  LD A,4
  LD C,1*8
  LD HL,MapMenuPal
  CALL AddPalette
  ;Extract the adjustments
  LD HL,$D000
  PUSH HL
    LD HL,MapMenu
    LD DE,InitTemp
    CALL ExtractSpec
    CALL ExtractRestoreSP
    CALL ExtractRestoreSP
  POP HL
  ;Apply the adjustments to the map
  LD HL,InitTemp
  LD DE,MapTemp+11*32
  LD C,7*32
-
  LDI A,(HL)
  LD (DE),A
  INC DE
  DEC C
  JR nz,-
  LD DE,MapTemp+11*32+$240
  LD C,7*32
-
  LDI A,(HL)
  LD (DE),A
  INC DE
  DEC C
  JR nz,-
  ;Copy the map to the second tilemap
  LD A,$27
  LD HL,MapTemp
  LD DE,$9C00
  CALL AddTransfer
  LD A,$27
  LD HL,MapTemp+$240
  LD DE,$9C01
  CALL AddTransfer
  ;Slide in
  LD D,$58  ;Head of menu box on screen
  LD B,%10000000  ;The value of LCDC now
  LD C,%10001000  ;The value of LCDC soon
  HALT
  XOR A
  LDH (LCDVec),A
  LDH (LCDVec+1),A
  LD A,$40
  LDH (STAT),A
  LD A,$03
  LDH (IE),A
-
  LD A,D
  LDH (LYC),A
  HALT
  LD A,B
  LDH (LCDC),A
  HALT
  LD A,C
  LDH (LCDC),A
  INC D
  LD A,$8F
  CP D
  JR nz,-
  XOR A
  LDH (STAT),A
  ;Register setup
MenuLoop:
  ;...
  HALT
  JR MenuLoop
.ENDS

.SECTION "Options" FREE ALIGN 16
OptionsEnter:
OptionsLoop:
  HALT
  JR OptionsLoop
.ENDS

.SECTION "Music Test" FREE ALIGN 16
MusicTitles:
.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
.INCBIN TitleMusicNames.gbm   ;Unzipped!
MusicUpdateText:
  PUSH AF
  PUSH BC
  PUSH DE
    ;Get the right text
    LD A,D
    ADD A
    ADD A
    ADD D
    ADD A
    ADD <MusicTitles
    LD L,A
    LD A,>MusicTitles
    ADC 0
    LD H,A
    ;Move it to the map
    LD DE,MapTemp+32*13+5
    LD C,10
-
    LDI A,(HL)
    LD (DE),A
    INC DE
    DEC C
    JR nz,-
    LD DE,MapTemp+32*14+5
    LD C,10
-
    LDI A,(HL)
    LD (DE),A
    INC DE
    DEC C
    JR nz,-
    ;Inform vBlank to do the thing
    LD HL,MapTemp+32*13
    LD DE,$99A0
    LD A,4
    CALL AddTransfer
  POP DE
  POP BC
  POP AF
  RET
MusicTestEnter:
  LD A,BankSound
  RST $08
;Update the text
  LD HL,MapTemp+32*12+5
  LD DE,MusicTitles
  LD C,10
-
  LD A,(DE)
  INC E
  LDI (HL),A
  DEC C
  JR nz,-
;Register setup
  LD B,$FF
  LD D,1
  LD E,1
  CALL MusicUpdateText
MusicTestLoop:
  HALT
  ;Check for buttons
  ;Freshly pressed?
  LDH A,(Buttons)
  LD C,A
  XOR B
  LD B,C
  AND C
  RRA     ;Right
  JR nc,+
  ;Select next song
  INC D
  LD A,16
  CP D
  CALL nz,MusicUpdateText
  JR nz,MusicTestLoop
  LD D,1
  CALL MusicUpdateText
  JR MusicTestLoop
+
  RRA     ;Left
  JR nc,+
  ;Select previous song
  DEC D
  CALL nz,MusicUpdateText
  JR nz,MusicTestLoop
  LD D,16
  CALL MusicUpdateText
  JR MusicTestLoop
+
  RRA     ;Up
  RRA     ;Down
  JR c,MTQuitEnter  ;Move to quit
  RRA     ;A
  JR nc,+
  ;Play selected song
  PUSH BC
    LD A,D
    DEC A
    ADD A
    LD HL,Songs
    ADD L
    LD L,A
    LD A,0
    ADC H
    LD H,A
    LDI A,(HL)
    LD B,(HL)
    LD C,A
    CALL MusicLoad
  POP BC
  JR MusicTestLoop
+
  RRA     ;B
  JR nc,MusicTestLoop
MTQuitEnter:
  ;Palette updates
  ;...
MTQuitLoop:
  HALT
  ;Check for buttons
  ;Freshly pressed?
  LDH A,(Buttons)
  LD C,A
  XOR B
  LD B,C
  LD C,A
  RRA     ;A
  JP c,OptionsEnter  ;Quit
  RRA     ;B
  JP c,OptionsEnter  ;Quit
  RRA     ;Select
  RRA     ;Start
  RRA     ;Right
  RRA     ;Left
  RRA     ;Up
  JR nc,MTQuitLoop
  ;Go back to the Music Test Loop
  JR MusicTestEnter
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
