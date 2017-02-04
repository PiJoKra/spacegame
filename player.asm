playerSpeed .rs 1
playerX .rs 1
playerY .rs 1
canShoot .rs 1
;A bullet will be two digits x and y. For the player 16 bullets will be remembered,
;meaning we need a space of 32 bytes
bulletCount .rs 1
bulletLastIndex .rs 1
bullets .rs 16

PLAYER_MIN_X = $0A
PLAYER_MIN_Y = $0A
PLAYER_MAX_X = $E5
PLAYER_MAX_Y = $DB

PLAYER_SPRITE = $0200
PLAYER_BULLET_SPRITES = $0210

CAN_SHOOT_COUNTER = $10
BULLET_SPEED = $6
MAX_PLAYER_BULLETS = $08

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
	
updatePlayerBullets:
	ldx #$00 ;cursor index bullet
	ldy #$00 ;new index of bullet
	
	lda bulletCount
	cmp #$0
	beq .rts
	
	;Making sure the bullets are at the start of the stack, and all the empty spots
	;are at the end
	;AX AY 00 00 BX BY 00 00 CX CY
	;AX AY BX BY CX CY 00 00 00 00
	.loopOverBullets:
		lda bullets, x
		
		sec
		sbc #BULLET_SPEED
		bcc .destroyBullet ;If the Y-position of the bullet <= 0

		sta bullets, y
		lda bullets+1, x
		sta bullets+1, y

		iny
		iny

		.continue:
			cpx bulletLastIndex
			inx
			inx
			bcc .loopOverBullets
	
	;Since the bullets are now copied one cell to the front when the previous bullet is destroyed,
	;the old bullet values are still present on the next cell. Here these cells will be cleared
	cpy #$00
	beq .noMoreBullets
	dey
	dey
	sty bulletLastIndex
	;iny
	;iny
	;.clearRedundantCells:
		;lda #$0
		;sta bullets, y
		
	;	dex
	;	cpx bulletLastIndex
	;	bne .clearRedundantCells

	.rts:
		lda bulletLastIndex
		sta $30
		rts
		
	.destroyBullet:
		dec bulletCount
		jmp .continue
		
	.noMoreBullets:
		lda #$00
		sta bulletLastIndex
		jmp .rts
	
playerShoot:
	
	lda bulletCount
	cmp #MAX_PLAYER_BULLETS
	beq .rts
		
	inc bulletCount
	
	clc
	adc bulletCount
	tax ;Store bulletCount * 2 in X
	dex ;Since counting starts from 0, so prevent the off-by-one-error
	
	stx bulletLastIndex
	
	lda playerY
	sta bullets, x
	lda playerX
	adc #$04
	sta bullets+1, x
	
	.rts:
		rts
		
showBullets:
	;Two different counters
	;Counter x is used for the bullets that are stored. It will make jumps of two since it contains 2 values (Y and X)
	;Counter y is used for the bullets on the screen. It will make jumps of four since it contains 4 values
	ldx #$FE ;$FE + 2 = 00, 0 first index
	ldy #$00
	
	.showBulletsLoop:
		inx
		inx

		lda bullets, x
		sta PLAYER_BULLET_SPRITES, y
		
		lda #$02
		sta PLAYER_BULLET_SPRITES+$1, y
		
		lda #$0
		sta PLAYER_BULLET_SPRITES+$2, y
		
		lda bullets+$1, x
		sta PLAYER_BULLET_SPRITES+$3, y
		
		iny
		iny
		iny
		iny
		
		cpx bulletLastIndex
		bne .showBulletsLoop
	rts
	

playerSprite:
	.db $00, $00, %00000000, $00
	.db $00, $00, %01000000, $00
	.db $00, $10, %00000000, $00
	.db $00, $10, %01000000, $00