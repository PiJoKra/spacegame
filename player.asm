PLAYER_MIN_X = $0A
PLAYER_MIN_Y = $0A
PLAYER_MAX_X = $F5
PLAYER_MAX_Y = $EB

playerSprite:
	.db $08, $00, $01, $08
	.db $08, $01, $01, $10
	.db $10, $10, $01, $08
	.db $10, $11, $01, $10


resetPlayerVariables:
	lda #$4
	sta playerSpeed
	
	lda #$80
	sta playerX
	sta playerY

repositionPlayer:

restrictPlayerPositionY:
	lda playerY
	cmp #PLAYER_MIN_Y
	bcc .restrictYLowerBound
	cmp #PLAYER_MAX_Y
	bcs .restrictYHigherBound
	
	jmp restrictPlayerPositionX
	
	.restrictYLowerBound:
		lda #PLAYER_MIN_Y
		sta playerY
		
		jmp restrictPlayerPositionX
	
	.restrictYHigherBound:
		lda #PLAYER_MAX_Y
		sta playerY
		
		jmp restrictPlayerPositionX
		
restrictPlayerPositionX:
	lda playerX
	cmp #PLAYER_MIN_X
	bcc .restrictXLowerBound
	cmp #PLAYER_MAX_X
	bcs .restrictXHigherBound
	
	jmp allignPlayerSprites
	
	.restrictXLowerBound:
		lda #PLAYER_MIN_X
		sta playerX
		
		jmp allignPlayerSprites
	
	.restrictXHigherBound:
		lda #PLAYER_MAX_X
		sta playerX
		
		jmp allignPlayerSprites

allignPlayerSprites:
	clc

	lda playerY
	sta $200
	sta $204
	adc #$8
	sta $208
	sta $20C
	
	lda playerX
	sta $203
	sta $20B
	adc #$8
	sta $207
	sta $20F
	
	rts