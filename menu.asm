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
	lda #$0
	sta score
    jsr loadBackgroundGame
    jsr resetPlayerVariables
    
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
        stx seedRoller
        stx seed
        stx seed+1
        jmp .initialiseEnemies
    
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