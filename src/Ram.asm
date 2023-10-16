; Principal RAM registers
.ENUM $C000 EXPORT
LCDVecTab       DSW     $08
System          DB
Buttons         DB
CurrROMBank     DB
CurrRAMBank     DB
vBlankFree      DB
.ENDE

.DEFINE OAMData         $C100 EXPORT
.DEFINE XferQueue       $C1A0 EXPORT    ;18 of these 5 byte entries: $5A size
;$C1FA - $C1FF
.DEFINE PaletteUpdates  $C200 EXPORT    ;64 maximum, with overhead:  $80 size
.DEFINE InitTemp        $C280 EXPORT
;$CE00 - $CEFF: Sound data

; Bank 0 RAM registers

; Cartridge RAM

; HRAM
.DEFINE OAMStart $80 EXPORT
