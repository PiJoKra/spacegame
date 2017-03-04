spawnEnemyCounter .rs 1
SPAWN_ENEMY_COUNTER = $15

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
	
	
	
	rts

enemySprite:
	.db $00, $00, %00000000, $00
	.db $00, $00, %01000000, $00
	.db $00, $10, %00000000, $00
	.db $00, $10, %01000000, $00