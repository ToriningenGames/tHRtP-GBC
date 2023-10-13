; Principal RAM registers
.ENUM $C000 EXPORT
LCDVecTab       DSW     $08
System          DB
Buttons         DB
CurrROMBank     DB
.ENDE

.DEFINE OAMData $C100 EXPORT
.DEFINE XferQueue $C1A0 EXPORT

.DEFINE PaletteUpdates $C200 EXPORT

; Bank 0 RAM registers

; Cartridge RAM

; HRAM
.DEFINE OAMStart $80 EXPORT
