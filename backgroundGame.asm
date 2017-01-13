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
		
	lda #$00
	ldx #$1A
	loopLoadBackgroundRest:
		ldy #$20
		loopLoadBackgroundRow:
		
			sta PPU_DATA
			dey
			cpy #$0
			bne loopLoadBackgroundRow
		
		dex
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
		cpx #$10
		bne loopLoadAttributes
		
	rts

backgroundGame:

	;Top row that is not shown on NTCS.
	;Because people using NTCS will not see the top row, lets just keep it empty
	.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	;Border top
	.db $00, $10, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $12, $00

	; | score: xxxx
	.db $00, $13
	.db "SCORE:"
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $18, $18, $18, $18, $18, $00, $19, $19, $19, $19, $19, $14, $00

	;Border bottom

	.db $00, $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $00
	
attributes:
	.db %00000100, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000