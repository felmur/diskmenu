; --------------------------------------------------------
; FM DISK MENU for C64
; (c) 2024 by Felice Murolo, Salerno, Italia
; Licensed under LGPL license
; --------------------------------------------------------


; --------------------------------------------------------
; BASIC line
; --------------------------------------------------------
*= $0801
.word (+), 10
.null $9e, "2061"
+ .word 0
; --------------------------------------------------------
; Main routine
; --------------------------------------------------------
			ldy #$00
			ldx #$00
			lda #<main
			sta $fb				; $fb-$fc-$fd-$fe are some zero page location that can be used
			lda #>main
			sta $fc
			lda #$00
			sta $fd
			lda #$c0
			sta $fe
load
			lda ($fb),y
			sta ($fd),y
			iny
			bne load
			inc $fc
			inc $fe
			inx
			cpx #5				; move 5x256 = 1280 byte from main location to $C000
			bne load
			jmp $c000			; execute the DISKMENU routine

; --------------------------------------------------------
; include "main.prg" binary file from offset 2
; --------------------------------------------------------
main		.binary "main.prg",2