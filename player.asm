playerSpeed .rs 1
playerX .rs 1
playerY .rs 1
canShoot .rs 1

PLAYER_MIN_X = $0A
PLAYER_MIN_Y = $0A
PLAYER_MAX_X = $E5
PLAYER_MAX_Y = $DB

CAN_SHOOT_COUNTER = $70

resetPlayerVariables:
	lda #$4
	sta playerSpeed
	
	lda #$80
	sta playerX
	sta playerY
	
loadPlayerSprite:
	ldx #$00
	loopLoadPlayerSprite:
		lda playerSprite, x
		sta $0200, x
		
		inx
		cpx #$10
		bne loopLoadPlayerSprite
	rts

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
	

playerSprite:
	.db $00, $00, %00000000, $00
	.db $00, $00, %01000000, $00
	.db $00, $10, %00000000, $00
	.db $00, $10, %01000000, $00