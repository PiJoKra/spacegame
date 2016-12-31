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