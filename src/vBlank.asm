.INCLUDE regs.i
.INCLUDE map.i

.BANK 0 SLOT 0
.SECTION "vBlank" FREE
;vBlank
vBlank:
;Total vBlank time:  4560
;Constant cost:       912
;OAM additional cost:   0
;Transfer init cost:  156
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
  LDH (WBK),A   ;Set source bank
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
  ;Reset RAM bank
  LDH A,(CurrRAMBank)
  LDH (WBK),A
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
  LD A,228       ;vBlank free time, divided by 16
  LDH (vBlankFree),A
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
  LDH (Buttons),A
;Sound Check
  LD A,1
  LD ($2000),A
  CALL PlayTick
  LDH A,(CurrROMBank)
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
;HL = Source. Low bit selects wRAM bank
;Carry clear if transfer failed; registers unchanged
;Carry set if transfer queued; A, BC, HL destroyed
AddTransfer:
  ;Get requested transfer size
  PUSH HL
    PUSH AF
      ADD A   ;2 timespaces per 16 bytes
      ADD 10  ;Transfer init cost
    ;Compare for timespace
      LD HL,$FF00|vBlankFree
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
  SCF   ;Indicate success
  RET
+
  POP AF
  POP HL
  RET

;Add this palette change to the queue, if there's room
;A = Color count
;C = Palette index. Objects are index+64. USED RAW! MAKE SURE IT LINES UP!
;HL = Source
;Carry clear if transfer failed; B, DE destroyed
;Carry set if transfer queued; all destroyed
AddPalette:
  PUSH AF
  PUSH HL
    LD B,A  ;3 timespaces per color
    ADD A
    ADD B
    ADD 6   ;Color init cost
  ;Compare for timespace
    LD HL,$FF00|vBlankFree
    CPL
    INC A
    ADD (HL)
    JR nc,+
  ;Reserve timespace
    LD (HL),A
  ;Find a spot
    LD DE,PaletteUpdates
-
    LD A,(DE)
    INC A
    JR z,++
    INC E
    LD A,(DE)
    ADD A
    INC A
    ADD E
    LD E,A
    JR -
++
  ;Throw the transfer in
    LD A,$80
    OR C
    LD (DE),A
    INC E
  POP HL
  POP AF
  LD (DE),A
  INC E
  ADD A
  LD C,A
-
  LDI A,(HL)
  LD (DE),A
  INC E
  DEC C
  JR nz,-
;Indicate success
  SCF
  RET
+
  POP HL
  POP AF
  CCF
  RET
.ENDS
