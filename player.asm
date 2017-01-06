playerSpeed .rs 1
playerX .rs 1
playerY .rs 1
canShoot .rs 1
;A bullet will be two digits x and y. For the player 16 bullets will be remembered,
;meaning we need a space of 32 bytes
bullets .rs 32

PLAYER_MIN_X = $0A
PLAYER_MIN_Y = $0A
PLAYER_MAX_X = $E5
PLAYER_MAX_Y = $DB

PLAYER_SPRITE = $0200

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
		sta PLAYER_SPRITE, x
		
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
	sta PLAYER_SPRITE
	sta PLAYER_SPRITE+$4
	adc #PPU_OAM_SPRITE_SIZE
	sta PLAYER_SPRITE+$8
	sta PLAYER_SPRITE+$C
	
	lda playerX
	sta PLAYER_SPRITE+$3
	sta PLAYER_SPRITE+$B
	adc #PPU_OAM_SPRITE_SIZE
	sta PLAYER_SPRITE+$7
	sta PLAYER_SPRITE+$F
	
	rts
	
shoot:
	ldx #$00
	
	
	
	rts
	

playerSprite:
	.db $00, $00, %00000000, $00
	.db $00, $00, %01000000, $00
	.db $00, $10, %00000000, $00
	.db $00, $10, %01000000, $00