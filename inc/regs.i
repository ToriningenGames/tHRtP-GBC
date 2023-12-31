; LCD control/status registers
.DEFINE LCDC    $40
.DEFINE STAT    $41
.DEFINE SCY     $42
.DEFINE SCX     $43
.DEFINE LY      $44
.DEFINE LYC     $45
.DEFINE DMA     $46
.DEFINE WY      $4A
.DEFINE WX      $4B
.DEFINE VBK     $4F
.DEFINE HDMA1   $51
.DEFINE HDMA2   $52
.DEFINE HDMA3   $53
.DEFINE HDMA4   $54
.DEFINE HDMA5   $55
.DEFINE OPRI    $6C
; Palette registers
.DEFINE BGPI    $68
.DEFINE BGPD    $69
.DEFINE OBPI    $6A
.DEFINE OBPD    $6B
; System registers
.DEFINE IE      $FF
.DEFINE IF      $0F
.DEFINE WBK     $70
.DEFINE RP      $56
.DEFINE SPEED   $4F
.DEFINE JOYP    $00
.DEFINE SB      $01
.DEFINE SC      $02
.DEFINE DIV     $04
.DEFINE TIMA    $05
.DEFINE TMA     $06
.DEFINE TAC     $07
; Sound registers
.DEFINE SC1S    $10
.DEFINE SC1L    $11
.DEFINE SC1V    $12
.DEFINE SC1F    $13
.DEFINE SC1C    $14
.DEFINE SC2L    $16
.DEFINE SC2V    $17
.DEFINE SC2F    $18
.DEFINE SC2C    $19
.DEFINE SC3E    $1A
.DEFINE SC3L    $1B
.DEFINE SC3V    $1C
.DEFINE SC3F    $1D
.DEFINE SC3C    $1F
.DEFINE SC4L    $20
.DEFINE SC4V    $21
.DEFINE SC4F    $22
.DEFINE SC4C    $23
.DEFINE SCCV    $24
.DEFINE SCCP    $25
.DEFINE SCCE    $26
.DEFINE WAVE    $30
