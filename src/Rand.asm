.INCLUDE "map.i"

.BANK 0 SLOT 0

.SECTION "Random Numbers" FREE

;Lehmer RNG on 16 bits
;Picked 65537 for m... I think
;Picked 159 for a for no particular reason
Rand:
  PUSH BC
  PUSH DE
  PUSH HL
  LDH A,(Seed)
  LD L,A
  LDH A,(Seed+1)
  LD H,A
  XOR A
  LD B,A
  LD D,H
  LD E,L
  LD C,3
-
  ADD HL,HL
  ADC B
  DEC C
  JR nz,-
  LD C,4
-
  ADD HL,DE
  ADC B
  ADD HL,HL
  ADC B
  DEC C
  JR nz,-
  LD C,A
  ADD HL,BC
  LD A,L
  LDH (Seed),A
  LD A,H
  LDH (Seed+1),A
  POP HL
  POP DE
  POP BC
  RET

.ENDS
