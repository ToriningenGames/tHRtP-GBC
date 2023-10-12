.INCLUDE regs.i
.INCLUDE map.i

.BANK 0 SLOT 0
.SECTION "vBlank" FREE
;vBlank
vBlank:
;OAM First
;Tile Check
;Palette Check
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
