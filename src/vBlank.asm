.INCLUDE regs.i
.INCLUDE map.i

.BANK 0 SLOT 0
.SECTION "vBlank" FREE
;vBlank
vBlank:
;Total vBlank time:  4560
;Constant cost:       912
;OAM additional cost:   0
;Transfer init cost:  168
  ;Cost per 16 bytes:  32
;BkgPal change cost:   92
  ;Cost per color:     48
;ObjPal change cost:   96
  ;Cost per color:     48
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
  LD HL,vBlankFree
  LD (HL),228   ;vBlank free time, divided by 16
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
  LD A,1
  LD ($2000),A
  CALL PlayTick
  LD A,(CurrROMBank)
  LD ($2000),A
  POP AF
  POP BC
  POP DE
  POP HL
  RETI
.ENDS

.SECTION "vBlank Interface" FREE
;Add this transfer to the queue, if there's room
;A = Transfer size
;DE = Dest. Low bit selects vRAM bank
;HL = Source. Low bit selects ROM bank
;Carry clear if transfer failed; registers unchanged
;Carry set if transfer queued; A, BC, HL destroyed
AddTransfer:
  ;Get requested transfer size
  PUSH HL
    PUSH AF
      ADD A   ;2 timespaces per 16 bytes
      ADD 11  ;Transfer init cost
    ;Compare for timespace
      LD HL,vBlankFree
      CPL
      INC A
      ADD (HL)
      JR nc,+
    ;Reserve timespace
      LD (HL),A
    ;Add this transfer to tail
      LD HL,XferQueue-5
-
      INC L
      INC L
      INC L
      INC L
      INC L
      LD A,(HL)
      INC A
      JR nz,-
    POP AF
  POP BC
  LDI (HL),A
  LD (HL),C
  INC L
  LD (HL),B
  INC L
  LD (HL),E
  INC L
  LD (HL),D
  LD A,1
  AND L
  ;If this was an odd index transfer, return 1 timespace
  SCF   ;Indicate success
  RET z
  LD HL,vBlankFree
  INC (HL)
  RET
+
  POP AF
  POP HL
  RET
;Add this palette change to the queue, if there's room
  ;Overwrite overlaps
  ;Consolidate palette transfers if they're contiguous
.ENDS
