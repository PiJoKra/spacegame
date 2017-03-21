gameStartButtonShownCounter .rs 1
GAME_START_BUTTON_SHOWN_COUNTER_MAX = $30
gameStartButtonShown .rs 1
GAME_START_BUTTON_SHOWN = $00
GAME_START_BUTTON_HIDDEN = $01
gameOverCounter .rs 1
GAME_OVER_COUNTER_MAX = $50
seedRoller .rs 1

menuInit:
    lda #GAME_START_BUTTON_SHOWN_COUNTER_MAX
    sta gameStartButtonShownCounter
    lda #$01
    sta seedRoller
    rts
    
updateSeedRoller:
    inc seedRoller
    rts

gameStartButtonShowHide:
    ldx gameStartButtonShownCounter
    dex
    cpx #$00
    beq .toggleStartButton
    rts
    
    .toggleStartButton:
        lda gameStartButtonShown
        cmp #GAME_START_BUTTON_SHOWN
        beq .hideStartButton
        
        lda #GAME_START_BUTTON_SHOWN
        sta gameStartButtonShown
        
    .hideStartButton:
        lda #GAME_START_BUTTON_HIDDEN
        sta gameStartButtonShown

readInputMenu:
    jsr readInput
    
    lda buttons
    and #BUTTON_A
    bne startGame
    
    rts
    
startGame:
	jsr resetScore
    jsr loadBackgroundGame
    jsr resetPlayerVariables
	jsr clearYouLostText
    
    .setSeed:
        ldx seedRoller
        cpx #$00
        beq .seedCannotBeZero
        stx seed
        stx seed+1
        
    .initialiseEnemies:
        jsr initialiseEnemySprite
        jsr initialiseEnemyCounter

    .changeGameState:
        lda #GAME_STATE_GAME
        sta gamestate
        lda #$00
        sta nameTableLoader
        
	rts
    
    .seedCannotBeZero:
        inx ;So we change it to one
        stx seed
        stx seed+1
        jmp .initialiseEnemies

drawYouLost:
	;Draw "YOU LOST~!"
	lda PPU_STATUS_REGISTER
	lda #$21
	sta PPU_ADDRESS_REGISTER
	lda #$0C
	sta PPU_ADDRESS_REGISTER
	
	ldx #$00
	.loop:
		lda youLostString, x
		sta PPU_DATA
		
		inx
		cpx #$0A
		bne .loop
		
	txa
	clc
	adc #$24
	tax
	.loop2:
		lda pressAKey, x
		sta PPU_DATA
		
		inx
		cpx #$10
		bne .loop2
		
	rts
	
clearYouLostText:
	lda PPU_STATUS_REGISTER
	lda #$21
	sta PPU_ADDRESS_REGISTER
	lda #$0C
	sta PPU_ADDRESS_REGISTER

	ldx #$00
	.loop:
		lda #$00
		sta PPU_DATA
		
		inx
		cpx #$0A
		bne .loop
	rts
		

countDownGameOver:
	jsr updateSeedRoller
	
	ldx gameOverCounter
	cpx #$00
	beq .waitForInput
	dex
	stx gameOverCounter

    rts
	
	.waitForInput:
		jsr readInput
		lda buttons
		and #BUTTON_A
		bne .restart
		rts
		
	.restart:
		jsr startGame
		rts
		
youLostString:
	.db "YOU LOST~!"
	
pressAKey:
	.db "PRESS A TO START"