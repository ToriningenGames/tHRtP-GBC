.DEFINE WalkSpeed 1
.DEFINE SlideSpeed 2
.DEFINE Leniency 5
.DEFINE SwingTime 60

;Actions
.ENUM 0
ActStand  DB
ActMove   DB
ActShoot  DB
ActSwing  DB
ActSlide  DB
ActPower  DB
ActKickM  DB
ActKickS  DB
ActMulti  DB
.ENDE

.SECTION "Player" FREE

;High nibble: Current action
;Low nibble: Next action
ActionsFree:
 .db $00
ActionsEnd:
 .db $00

PlayerInit:
  LD HL,PlayerState
  XOR A
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  LDI (HL),A
  LD ($C103),A
  LD A,$20
  LD ($C102),A
  LD A,$54
  LD ($C101),A
  LD A,$98
  LD ($C100),A
  RET
PlayerFrame:
  ;Have the timer handy
  LD HL,PlayerTimer
  DEC (HL)
  LD C,(HL)
  ;What are we doing?
  LD A,(PlayerState)
  ADD A
  ADD <PlayerActions
  LD L,A
  LD A,0
  ADC >PlayerActions
  LD H,A
  LDI A,(HL)
  LD H,(HL)
  LD L,A
  PUSH HL   ;Tail call return
;Converts the raw button input into player short form
;%BAdD
; |||+--- Directional button
; ||+--- Opposite Directional button
; |+--- A button
; +--- B button
PlayerGetActions:
  LDH A,(Buttons)
  CPL
  AND $33
  LD L,A
  RRA
  RRA
  OR L
  AND $0F
  LD L,A
  AND $03
  LD A,L
  RET z   ;Don't check direction if there's none pressed
  LD HL,PlayerCurrDir
  BIT 7,(HL)
  JR z,+
  ;Invert
  XOR $03
+
  BIT 0,(HL)
  RET nz
  ;Collapse
  LD L,A
  SRA L
  AND $03
  ADD $FF   ;Set carry flag iff any direction is pressed
  RL L
  LD A,$0D
  AND L
+
  RET

;On call:
;A= current player input short form
;C= Timer value
PlayerActions:
 .dw PlayerStand,PlayerMove,PlayerShoot,PlayerSwing
 .dw PlayerSlide,PlayerPower,PlayerKickM,PlayerKickS,PlayerMulti
PlayerStand:
  OR A
  RET z  ;Continue standing
  ;Asked to do something. We can always abide
  LD B,A
  AND %00001001
  XOR %00001001
  JR z,PlayerBeginSlide
  RR B
  JR c,PlayerBeginMove
  RR B
  RR B
  JR c,PlayerBeginShoot
  RR B
  JR c,PlayerBeginSwing
  RET   ;???
PlayerMove:
  BIT 3,A
  JR nz,PlayerBeginSlide
  AND $03
  JR z,PlayerBeginStand
  AND $02
  JR nz,PlayerBeginMove
  ;Beta move
  LD A,(PlayerCurrDir)
  BIT 7,A
  LD HL,$C101
  LD A,WalkSpeed
  JR z,+
  LD A,-WalkSpeed
+
  ADD (HL)
  LD (HL),A
  ;...
  RET
PlayerShoot:
  DEC C
  JR z,PlayerBeginStand
  RET
PlayerSwing:
  ;Give some leniency in the beginning, in case player didn't hit both buttons on-frame
  AND $03
  JR z,+
  LD A,SwingTime
  SUB C
  SUB Leniency
  JR c,PlayerBeginSlide
+
  ;Cannot be interrupted; continue swinging
  ;...
  DEC C
  JR z,PlayerBeginStand
  RET
PlayerSlide:
  AND $03
  JR z,PlayerBeginStand
  ;Beta slide
  LD A,(PlayerCurrDir)
  BIT 7,A
  LD HL,$C101
  LD A,SlideSpeed
  JR z,+
  LD A,-SlideSpeed
+
  ADD (HL)
  LD (HL),A
  ;...
  RET
PlayerPower:
  RET
PlayerKickM:
  RET
PlayerKickS:
  RET
PlayerMulti:
  RET

PlayerBeginStand:
  LD HL,PlayerCurrDir
  LD (HL),0
  LD BC,ActStand*256
  JR PlayerBeginCommon
PlayerBeginMove:
  LDH A,(Buttons)
  BIT 0,A
  LD A,$FF
  JR nz,+
  LD A,$01
+
  LD (PlayerCurrDir),A
  LD BC,ActMove*256
  JR PlayerBeginCommon
PlayerBeginShoot:
  LD BC,ActShoot*256+2
  JR PlayerBeginCommon
PlayerBeginSwing:
  LD BC,ActSwing*256+60
  JR PlayerBeginCommon
PlayerBeginSlide:
  LDH A,(Buttons)
  BIT 0,A
  LD A,$FF
  JR nz,+
  LD A,$01
+
  LD (PlayerCurrDir),A
  LD BC,ActSlide*256+SwingTime
  JR PlayerBeginCommon
PlayerBeginPower:
  RET
PlayerBeginKickM:
  RET
PlayerBeginKickS:
  RET
PlayerBeginMulti:
  RET
PlayerBeginCommon:
  LD HL,PlayerState
  LD (HL),B
  INC L
  LD (HL),C
  RET

.ENDS
