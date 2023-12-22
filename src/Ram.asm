;WLA-GB v10
; Principal RAM registers

.STRUCT HighScoreEntry
name  DSB 8
score DSB 3
stage DB
.ENDST
.EXPORT _sizeof_HighScoreEntry

.STRUCT SavedGame
score DL
stage db
lives db
bombs db
difficulty db
.ENDST
.EXPORT _sizeof_SavedGame

;$C000 - $C0FF: Sound data
.DEFINE OAMData         $C100 EXPORT
.DEFINE XferQueue       $C1A0 EXPORT    ;18 of these 5 byte entries: $5A size
.DEFINE PlayerState     $C1FA EXPORT
.DEFINE PlayerTimer     $C1FB EXPORT
.DEFINE PlayerNext      $C1FC EXPORT
.DEFINE PlayerCurrDir   $C1FD EXPORT
;$C1FE - $C1FF: Free
.DEFINE PaletteUpdates  $C200 EXPORT    ;64 maximum, with overhead:  $80 size
.DEFINE InitTemp        $C280 EXPORT    ;\ These two blend together
.DEFINE StackTop        $CAFF EXPORT    ;/
.DEFINE MapTemp         $CB00 EXPORT    ;To end of bank

; Bank 0 RAM registers
.DEFINE ExtractTemp     $D000 EXPORT

; Bank 1 RAM registers
.ENUM $D000 EXPORT
GameStateData     INSTANCEOF SavedGame
CardData          DSW 20*10
.ENDE 

; Cartridge RAM

.ENUM $A000 EXPORT
RAMGuard          DB
Difficulty        DB
Lives             DB
HighScoreGuard    DB
HighScoresEasy    INSTANCEOF HighScoreEntry 10
HighScoresNormal  INSTANCEOF HighScoreEntry 10
HighScoresHard    INSTANCEOF HighScoreEntry 10
HighScoresLunatic INSTANCEOF HighScoreEntry 10
SaveDataGuard     DB
SavedData         INSTANCEOF SavedGame
.ENDE


; HRAM
.ENUM $80 EXPORT
OAMStart          DSB   12
LCDVec            DW
System            DB
Buttons           DB
CurrROMBank       DB
CurrRAMBank       DB
vBlankFree        DB
Seed              DW
ModeTimer         DW
CurrScore         DL
CurrStage         DB
CurrLives         DB
CurrBombs         DB
CurrDifficulty    DB
ScreensaverTimer  DW
.ENDE

.DEFINE BankSound       1 EXPORT
.DEFINE BankGraphic     2 EXPORT
