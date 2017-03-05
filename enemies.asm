spawnEnemyCounter .rs 1
enemy .rs 3 ;max 10 enemies. Attributes: y x speed
SPAWN_ENEMY_COUNTER = $60
ENEMY_SPRITE = $230

initialiseEnemySprite:
	ldx #$0
	.loop:
		lda enemySprite, x
		sta ENEMY_SPRITE, x
		
		inx
		cpx #$10
		bne .loop
	rts

initialiseEnemyCounter:
	lda #SPAWN_ENEMY_COUNTER
	sta spawnEnemyCounter
	rts
	
spawnEnemyEveryXFrames:
	ldx spawnEnemyCounter
	cpx #$00
	beq spawnEnemy
	dex
	stx spawnEnemyCounter
	rts

spawnEnemy:
	jsr initialiseEnemyCounter
	
	lda #$1
	sta enemy+0
	jsr prng
	sta enemy+1
	
	lda #$3
	sta enemy+2
	
	
	rts
	
updateEnemy:
	lda enemy
	;cmp #$00
	;beq .noEnemy
	clc
	adc enemy+2
	;bcc .destroyEnemy
	sta enemy
	jmp showEnemy
	
	.noEnemy:
		rts
	
	.destroyEnemy:
		lda #$00
		sta enemy
		sta enemy+1
		rts
	
showEnemy:
	lda enemy
	cmp #$00
	beq .dontShow
	
	sta ENEMY_SPRITE
	sta ENEMY_SPRITE+4
	clc
	adc #PPU_OAM_SPRITE_SIZE
	sta ENEMY_SPRITE+8
	sta ENEMY_SPRITE+12
	
	lda enemy+1
	sta ENEMY_SPRITE+3
	sta ENEMY_SPRITE+11
	adc #PPU_OAM_SPRITE_SIZE
	sta ENEMY_SPRITE+7
	sta ENEMY_SPRITE+15
	
	rts
	
	
	.dontShow:
		rts

enemySprite:
	.db $FE, $20, %00000000, $FE
	.db $FE, $21, %00000000, $FE
	.db $FE, $30, %00000000, $FE
	.db $FE, $31, %00000000, $FE