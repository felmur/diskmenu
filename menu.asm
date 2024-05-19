*= $0801
.word (+), 10
.null $9e, "2061"
+ .word 0

			ldy #$00
			ldx #$00
			lda #<main
			sta $fb
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
			cpx #5
			bne load
			jmp $c000

main		.binary "main.prg",2
