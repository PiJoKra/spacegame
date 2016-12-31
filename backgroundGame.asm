loadBackgroundGame:
	lda PPU_STATUS_REGISTER
	
	lda #$20
	sta PPU_ADDRESS_REGISTER
	lda #$00
	sta PPU_ADDRESS_REGISTER

	ldx #$00
	loopLoadBackgroundHUD:
		lda backgroundGame, x
		sta PPU_DATA
		inx
		cpx #$80
		bne loopLoadBackgroundHUD
		
	lda #$18
	loopLoadBackgroundRest:
		sta PPU_DATA
		
		inx
		cpx #$0
		bne loopLoadBackgroundRest
		
	lda PPU_STATUS_REGISTER
	
	lda #$23
	sta PPU_ADDRESS_REGISTER
	lda #$C0
	sta PPU_ADDRESS_REGISTER
	
	ldx #$00
	loopLoadAttributes:
		lda attributes, x
		sta PPU_DATA
		
		inx
		cpx #$08
		bne loopLoadAttributes
		
	rts

backgroundGame:

	; Border top
	.db $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18
	.db $18, $10, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $12, $18

	; | score: xxxx
	.db $18, $13, $18, $32, $22, $2E, $31, $24, $18, $00, $00, $00, $00, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $14, $18

	;Border bottom

	.db $18, $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $18
	
attributes:
	.db 0, 0, 0, 0, 0, 0, 0, 0