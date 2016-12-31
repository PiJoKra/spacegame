updateScore:
	ldx #$3
	inc score, x
	
	sec
	handleScoreDigits:
		cpx #$FF
		beq .rts
		
		lda score, x
		cmp #$0A
		bcc .rts
		
		sbc #$0A
		sta score, x
		dex
		inc score, x
		
		jmp handleScoreDigits
		
	.rts:
		RTS
		
updateScoreHUD:
	lda PPU_STATUS_REGISTER
	
	lda #$20
	sta PPU_ADDRESS_REGISTER
	lda #$49
	sta PPU_ADDRESS_REGISTER
	
	ldx #$00
	loopUpdateScoreHUD:
		lda score, x
		sta PPU_DATA
		
		inx
		cpx #$4
		bne loopUpdateScoreHUD
		
	rts