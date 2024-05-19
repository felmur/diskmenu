*= $c000
; ----------------------------------------------------
; Routine principale
; ----------------------------------------------------
init
				jsr $E544	; pulizia schermo
				lda #0
				sta $d020
				sta $d021
				lda #1
				sta $0286
				
				; inizializzazione variabili programma
				ldx #0
				lda #0
				sta numchar
				sta numvoci
				sta temp
				sta addr
				sta addr+1
				sta iflg
init2				
				sta voci,x
				inx
				bne init2

				;	print title
				ldy #12
				ldx #0
				clc
				jsr $E50A		; cursore a X,Y
				lda #<title0 	; load pointer of string
				ldy #>title0
				JSR $AB1E   	; print string

				ldy #12
				ldx #1
				clc
				jsr $E50A		; cursore a X,Y
				lda #<title1 	; load pointer of string
				ldy #>title1
				JSR $AB1E   	; print string

				ldy #12
				ldx #2
				clc
				jsr $E50A		; cursore a X,Y
				lda #<title2 	; load pointer of string
				ldy #>title2
				JSR $AB1E   	; print string
				;	fine print title
				
				jsr dollar		; carica la directory del disco

; stampa voci di menu e nome disco
stampa
				lda numvoci
				bne stampa3
				jmp uscita
stampa3
				sta temp
				lda #<voci
				sta addr
				lda #>voci
				sta addr+1
				dec temp

				LDA #$0D
				JSR $FFD2      ; print RETURN

				lda #0
				sta numchar
				
nomedisco				
				lda #<label1				
				ldy #>label1				
				jsr $ab1e				
				lda addr
				ldy addr+1
				jsr $ab1e
				LDA #$0D
				dec temp				
				JSR $FFD2      ; print RETURN
				JSR $FFD2      ; print RETURN
				clc
				lda addr
				adc #17
				sta addr
				bcc stampa1
				lda addr+1				
				clc				
				adc #1				
				sta addr+1				
stampa1			

				lda #129
				JSR $FFD2      ; print orange
				ldx numchar
				inc numchar
				lda hex,x
				JSR $FFD2      ; print char of hex
				lda #41
				JSR $FFD2      ; print ')'
				lda #32
				JSR $FFD2      ; print space
				lda #158
				JSR $FFD2      ; print yellow
				lda addr
				ldy addr+1
				jsr $ab1e
				LDA #$0D
				JSR $FFD2      ; print RETURN
				clc
				lda addr
				adc #17
				sta addr
				bcc stampa2
				lda addr+1				
				clc				
				adc #1				
				sta addr+1				
stampa2
				dec temp
				beq istruzioni
		        JSR $FFE1      	; RUN/STOP pressed?
        		BNE stampa1     ; no RUN/STOP -> continue
        		
istruzioni        
				ldy #0
				ldx #22
				clc
				jsr $E50A		; cursore a X,Y
				lda #<label2
				ldy #>label2
				jsr $ab1e		; print istruzioni
				
input
				ldx #0
				stx numchar
				lda numvoci
				sta temp
				dec temp
				dec temp
				ldy #28
				ldx #22
				clc
				jsr $E50A		; cursore a X,Y
				lda #158		; giallo
				JSR $FFD2		
				ldx iflg
				bne inp3
				lda #18			; reverse on se iflg=0
				JSR $FFD2
				lda #191		; stampa carattere in reverse
				JSR $FFD2
				lda #1			; setta iflg=1
				sta iflg
				jsr wait		; attesa
				jmp inp5
inp3			
				lda #146		; reverse off se iflg=1
				JSR $FFD2
				lda #191		; stampa carattere normale
				JSR $FFD2
				lda #0			; setta iflg=0
				sta iflg			
				jsr wait		; attesa
inp5				
		        JSR $FFE1		; RUN/STOP pressed?
        		BEQ uscita      ; no RUN/STOP -> continue
				jsr $ffe4			
				sta val			
				beq input		
						
inp1			lda val
				cmp #81			; Q - QUIT
				bne inp2
				jmp uscita
inp2							; cerca il carattere digitato nella stringa 'hex'
				ldx numchar
				inc numchar
				cpx temp
				beq input
				lda hex,x
				cmp val
				bne inp2
				jsr runcmd		; la posizione del carattere è in X
				
uscita				
				jsr resetscreen
				lda #<label4
				ldy #>label4
				jsr $ab1e
				rts

; ----------------------------------------------------
; esegue un comando
; ----------------------------------------------------
runcmd
.block
				stx tmp1		
				lda #<voci				
				sta $fb				
				lda #>voci				
				sta $fc				
run1
				lda $fb				
				clc				
				adc #17				
				sta $fb				
				bcc run2				
				lda $fc				
				clc				
				adc #1				
				sta $fc				
run2								
				lda tmp1
				beq run3
				dec tmp1
				jmp run1
run3								
				jsr resetscreen				
				lda #<label3				
				ldy #>label3				
				jsr $ab1e				
				lda $fb
				ldy $fc
				jsr $ab1e

				ldy #0
run5
				lda ($fb),y
				beq run4
				iny
				jmp run5
run4
				tya
				ldx $fb
				ldy $fc
				jsr $ffbd		; set filename
				lda #$01
				ldx #$08
				ldy #$01
				jsr $ffba		; set parameter (open 1,8,1)
				lda #$00		; acc = 0 -> load, acc = 1 -> verify
;				sta $9d		    ; flag progam mode (to suppress 'searching for...' msg)
				jsr $ffd5		; load file
				
				lda #0		   ; clean input buffer 
				sta $0200
				sta $0201
				sta $0202
				
				jsr resetscreen
				
				JSR $A659		; run
				Jmp $A7AE
				
tmp1			.byte 0
addr			.word 0

.endblock

; ----------------------------------------------------
; pulisce lo schermo e lo resetta ai colori di default
; ----------------------------------------------------
resetscreen
				jsr $E544	; pulizia schermo
				lda #146	; reset reverse
				jsr $ffd2
				lda #14
				sta $d020
				sta $0286
				lda #6
				sta $d021
				rts		

; ----------------------------------------------------
; attende per un certo periodo di tempo
; ----------------------------------------------------
wait
.block
				lda #60
				sta temp
w1
				ldx #0
w2
				ldy #0
				nop
				iny
				beq w2
				inx
				bne w2
				dec temp
				bne w1
				rts

temp			.byte 0
.endblock
			
; ------------------------------------------------------------------
; Carica la directory del disco
; ------------------------------------------------------------------
dollar
.block
				lda #$00
				sta flg
				LDA #(dirname_end-dirname)
				LDX #<dirname
				LDY #>dirname
				JSR $FFBD      ; call SETNAM
				
				LDA #$02       ; filenumber 2
				LDX $BA
				BNE skip
				LDX #$08       ; default to device number 8
skip   
				LDY #$00       ; secondary address 0 (required for dir reading!)
				JSR $FFBA      ; call SETLFS
		
				JSR $FFC0      ; call OPEN (open the directory)
				BCS error      ; quit if OPEN failed
		
				LDX #$02       ; filenumber 2
				JSR $FFC6      ; call CHKIN
		
				LDY #$04       ; skip 4 bytes on the first dir line
				BNE skip2
next
				LDY #$02       ; skip 2 bytes on all other lines
skip2  
				JSR getbyte    ; get a byte from dir and ignore it
				DEY
				BNE skip2
		
				JSR getbyte    ; get low byte of basic line number
				TAY
				JSR getbyte    ; get high byte of basic line number
				PHA
				TYA            ; transfer Y to X without changing Akku
				TAX
				PLA
		;        JSR $BDCD      ; print basic line number
		;        LDA #$20       ; print a space first
char
		;        JSR $FFD2      ; call CHROUT (print character)
		
				JSR getbyte
				sta temp
				cmp #$22
				beq char2

char5
				ldx flg
				beq char2
				ldx numchar	
				sta voci,x
				inc numchar
char2
				lda temp
				cmp #$22
				bne char3
				lda flg
				beq char4
				lda #0
				sta flg
				jmp char3
char4
				lda #1
				sta flg
char3        
				lda temp	        
				BNE char       ; continue until end of line
		
				lda #0
				ldx numchar	
				sta voci,x
				inc numvoci
				lda numvoci
				sta $2000
				cmp #15
				beq exit
char7        
				lda #0
				sta numchar
				ldx numvoci
char6        
				lda numchar
				adc #17
				sta numchar
				dex
				bne char6
		
				;LDA #$0D
				;JSR $FFD2      ; print RETURN
				JSR $FFE1      ; RUN/STOP pressed?
				BNE next       ; no RUN/STOP -> continue
error
				; Akkumulator contains BASIC error code
		
				; most likely error:
				; A = $05 (DEVICE NOT PRESENT)
exit
				LDA #2         ; filenumber 2
				JSR $FFC3      ; call CLOSE
				JSR $FFCC      ; call CLRCHN
				rts

getbyte
				JSR $FFB7      ; call READST (read status byte)
				BNE end       ; read error or end of file
				JMP $FFCF      ; call CHRIN (read byte from directory)
end
				PLA            ; don't return to dir reading loop
				PLA
				JMP exit

flg				.byte 0

dirname
				.TEXT "$"      ; filename used to access directory
dirname_end
.endblock


; ----------------------------------------------------
; Variabili globali
; ----------------------------------------------------
title0			.text 129,117,x"63" x 14,105,13,0
title1 			.text 129,98,158," FM DISK MENU ",129,98,0		
title2			.text 129,106,x"63" x 14,107,13,0
label1			.text 129,"DISK NAME: ",158,0
label2			.text 129,"TYPE ID TO RUN, 'Q' TO QUIT",0
label3			.text "LOADING ",0
label4			.text 13,18,158,"FM DISK MENU EXITING...",146,154,13,0
hex				.text "0123456789ABC",0

numchar			.byte 0
numvoci			.byte 0
voci			.text x"00" x 256		; spazio per nome disco + 14 nomi di file (nome = 16 char + 0 finale)
temp			.byte 0
val				.byte 0
addr			.word 0
iflg			.byte 0

		