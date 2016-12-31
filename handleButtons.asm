BUTTON_A		= %10000000
BUTTON_B		= %01000000
BUTTON_SELECT	= %00100000
BUTTON_START	= %00010000
BUTTON_UP		= %00001000
BUTTON_DOWN		= %00000100
BUTTON_LEFT		= %00000010
BUTTON_RIGHT	= %00000001

CAN_SHOOT_COUNTER = $70

readInput:
	lda #$01
	sta CPU_JOYSTICK_1
	lda #$00
	sta CPU_JOYSTICK_1
	
	ldx #$08
	loopReadInput:
		lda CPU_JOYSTICK_1
		lsr A
		rol buttons
		dex
		bne loopReadInput
		
handleButtonUp:
	lda buttons
	and #BUTTON_UP
	beq handleButtonRight
	
	lda playerY
	sec
	sbc playerSpeed
	sta playerY
	
handleButtonRight:
	lda buttons
	and #BUTTON_RIGHT
	beq handleButtonDown
	
	lda playerX
	clc
	adc playerSpeed
	sta playerX
	
handleButtonDown:
	lda buttons
	and #BUTTON_DOWN
	beq handleButtonLeft
	
	lda playerY
	clc
	adc playerSpeed
	sta playerY
	
handleButtonLeft:
	lda buttons
	and #BUTTON_LEFT
	beq handleButtonA
	
	lda playerX
	sec
	sbc playerSpeed
	sta playerX
	
handleButtonA:
	lda canShoot
	beq .shoot
	dec canShoot
	rts
	
	.shoot:
		lda buttons
		and #BUTTON_A
		beq returnFromHandleInput
		
		lda #CAN_SHOOT_COUNTER
		sta canShoot
		
returnFromHandleInput:
	rts