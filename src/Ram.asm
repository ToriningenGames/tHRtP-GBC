; Principal RAM registers
.ENUM $C000 EXPORT
LCDVecTab       DSW     $08
System          DB
Buttons         DB
.ENDE

; Bank 0 RAM registers
.ENUM $D000 EXPORT
.ENDE

; Cartridge RAM
.ENUM $A000 EXPORT
.ENDE

;HRAM
.ENUM $80 EXPORT
.ENDE
