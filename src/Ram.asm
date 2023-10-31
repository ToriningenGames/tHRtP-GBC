;WLA-GB v10
; Principal RAM registers


;$C000 - $C0FF: Sound data
.DEFINE OAMData         $C100 EXPORT
.DEFINE XferQueue       $C1A0 EXPORT    ;18 of these 5 byte entries: $5A size
;$C1FA - $C1FF: Mode specific variables
.DEFINE PaletteUpdates  $C200 EXPORT    ;64 maximum, with overhead:  $80 size
.DEFINE InitTemp        $C280 EXPORT    ;\ These two blend together
.DEFINE StackTop        $CAFF EXPORT    ;/
.DEFINE MapTemp         $CB00 EXPORT    ;To end of bank

; Bank 0 RAM registers

; Cartridge RAM

; HRAM
.ENUM $80 EXPORT
OAMStart        DSB     12
LCDVec          DW
System          DB
Buttons         DB
CurrROMBank     DB
CurrRAMBank     DB
vBlankFree      DB
Seed            DW
ModeTimer       DB
ModeVar0        DB
.ENDE

.DEFINE BankSound       1 EXPORT
.DEFINE BankGraphic     2 EXPORT
