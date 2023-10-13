.INCLUDE regs.i
.INCLUDE map.i

.BANK 0 SLOT 0
.SECTION "vBlank" FREE
;vBlank
vBlank:
.DEFINE vbTime       4560
;Constant cost:       912
.DEFINE vbCost        912
;OAM additional cost:   0
;Transfer init cost:  168
.DEFINE vbTrICost     168
  ;Cost per byte:       2
.DEFINE vbTrBCost       2
;BkgPal change cost:   92
.DEFINE vbBPICost      92
  ;Cost per color:     48
.DEFINE vbBPBCost      48
;ObjPal change cost:   96
.DEFINE vbOPICost      96
  ;Cost per color:     48
.DEFINE vbOPBCost      48
;OAM First (Tail call)
OAMEnd:
;Tile Check
;Can we even perform a transfer?
  LD HL,$FF00|HDMA5
  BIT 7,(HL)
  JR z,++
  ;Is a transfer pending?
  LD HL,XferQueue
  JR +
-
  ;Valid transfer
  INC L
  LDI A,(HL)
  LD ($2000),A  ;Set source bank
  LDH (HDMA2),A
  LDI A,(HL)
  LDH (HDMA1),A
  LDI A,(HL)
  LDH (VBK),A   ;Set dest bank
  LDH (HDMA4),A
  LDI A,(HL)
  LDH (HDMA3),A
  LD A,B
  LDH (HDMA5),A
+
  LD B,(HL)
  LD (HL),$FF
  LD A,B
  INC A
  JR nz,-
  ;Reset ROM bank
  LD A,(CurrROMBank)
  LD ($2000),A
++
;Palette Check
  LD HL,PaletteUpdates
  JR +
--
  INC L
  LD C,BGPI
  BIT 6,A
  JR z,++
  INC C
  INC C
++
  LDH (C),A
  INC C
  LD B,(HL)
  INC L
-
  LDI A,(HL)
  LDH (C),A
  LDI A,(HL)
  LDH (C),A
  DEC B
  JR nz,-
+
  LD A,(HL)
  LD (HL),$FF
  BIT 0,A
  JR z,--
;CRITICAL PORTION END
;Button Check
  LD C,JOYP
  LD A,%00100000
  LDH (C),A
  LDH A,(C)
  LDH A,(C)
  LDH A,(C)
  AND $0F
  LD B,A
  LD A,%00010000
  LDH (C),A
  LDH A,(C)
  LDH A,(C)
  LDH A,(C)
  AND $0F
  SWAP A
  OR B
  LD (Buttons),A
;Sound Check
  CALL PlayTick
  POP AF
  POP BC
  POP DE
  POP HL
  RETI
.ENDS
