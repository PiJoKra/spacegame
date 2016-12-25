	.inesprg 1   ; 1x 16KB PRG code
	.ineschr 1   ; 1x  8KB CHR data
	.inesmap 0   ; mapper 0 = NROM, no bank swapping
	.inesmir 1   ; background mirroring

	.rsset $0000 ;Game related stuff

gamestate .rs 1	;$0000
GAME_STATE_MENU = $00
GAME_STATE_PLAYING = $01
GAME_STATE_DEAD = $02

buttons .rs 1 ;$0001
BUTTON_A		= %10000000
BUTTON_B		= %01000000
BUTTON_SELECT	= %00100000
BUTTON_START	= %00010000
BUTTON_UP		= %00001000
BUTTON_DOWN		= %00000100
BUTTON_LEFT		= %00000010
BUTTON_RIGHT	= %00000001

score .rs 4

	.rsset $0010 ;Player related stuff

playerSpeed .rs 1 ;$0010
playerX .rs 1 ;$0011
playerY .rs 1 ;$0012
PLAYER_MIN_X = $0A
PLAYER_MIN_Y = $0A
PLAYER_MAX_X = $A0
PLAYER_MAX_Y = $A0

canShoot .rs 1 ;$0013
CAN_SHOOT_COUNTER = $70

	;Bullets are stored as $xx $yy | $xx $yy | ... from $0020 until $0040
	;This means that 16 bullets can be stored at the same time
	;Instead of destroying bullets when they get out of the screen,
		;they get overwritten once the game runs out of space for new bullets
	;This means there can be a bullet overflow, but that should be solved by
		;the canShoot counter



	.bank 0
	.org $C000	
	
RESET:
	SEI          ; disable IRQs
	CLD          ; disable decimal mode
	LDX #$40
	STX $4017    ; disable APU frame IRQ
	LDX #$FF
	TXS          ; Set up stack
	INX          ; now X = $FF + 1 => 0
	STX $2000    ; disable NMI
	STX $2001    ; disable rendering
	STX $4010    ; disable DMC IRQs

	JSR vBlankWait

clrmem:
	LDA #$00
	STA $0000, x
	STA $0100, x
	STA $0300, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x

	LDA #$FE
	STA $0200, x

	INX
	BNE clrmem

	JSR vBlankWait

LoadPalettes:
	LDA $2002 ;Reset high/low latch
	
	;Write #$3F00 as first (background) palette address
	LDA #$3F
	STA $2006
	LDA #$00
	STA $2006

	;$3F00-$3F0F are for background colors
	;$3F10-$3F1F are for sprite colors
	LDX #$00
	LoadPalettesLoop:
		LDA Palette, x
		STA $2007
		INX
		CPX #$20
		BNE LoadPalettesLoop

LoadSpaceShipSprite:
	;$0200-$02FF is sprite data where every 4 bytes is a sprite
	;First sprite will be the spaceship
	LDX #$00
	LoadSpaceShipSpriteLoop:
		LDA SpaceShipSprite, x
		STA $0200, x
		INX
		CPX #$10
		BNE LoadSpaceShipSpriteLoop


EnableNMIAndSprites:
	LDA #%10000000 ;Enable NMI
	STA $2000

	LDA #%00010000 ;Enable sprites
	STA $2001
	
InitializeGame:
	LDA #$80
	STA playerX
	STA playerY
	LDA #$02
	STA playerSpeed
	
	LDA #CAN_SHOOT_COUNTER
	STA canShoot

StopResetAndClearMemory: ;Prevent code from reset and clearing of memory to leak through
	JMP StopResetAndClearMemory

vBlankWait:
	BIT $2002
	BPL vBlankWait ;If not ready, repeat
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadInput:
	LDA #$01
	STA $4016
	LDA #$00
	STA $4016

	LDX #$08
	ReadControllerLoop:
		LDA $4016
		LSR A
		ROL buttons
		DEX
		BNE ReadControllerLoop

	RTS

HandleButtonUp:
	LDA buttons
	AND #BUTTON_UP
	BEQ .rts
	
	LDA playerY
	SEC
	SBC playerSpeed
	STA playerY
	
	.rts:
		RTS

HandleButtonRight:
	LDA buttons
	AND #BUTTON_RIGHT
	BEQ .rts
	
	LDA playerX
	CLC
	ADC playerSpeed
	STA playerX
	
	.rts:
		RTS

HandleButtonDown:
	LDA buttons
	AND #BUTTON_DOWN
	BEQ .rts
	
	LDA playerY
	CLC
	ADC playerSpeed
	STA playerY
	
	.rts:
		RTS

HandleButtonLeft:
	LDA buttons
	AND #BUTTON_LEFT
	BEQ .rts
	
	LDA playerX
	SEC
	SBC playerSpeed
	STA playerX
	
	.rts:
		RTS
		
HandleButtonShoot:

	LDA canShoot
	BEQ .shoot
	SEC
	SBC #$1
	STA canShoot
	RTS
	
	.shoot:
		LDA buttons
		AND #BUTTON_A
		BEQ .rts
		
		LDA #CAN_SHOOT_COUNTER
		STA canShoot
		
	.rts:
		RTS

RestrictSpaceShipPositionY:
	LDA playerY
	CMP #PLAYER_MIN_Y
	BCC .restrictYLowerBound
	CMP #PLAYER_MAX_Y
	BCS .restrictYHigherBound
	RTS
	
	.restrictYLowerBound:
		LDA #PLAYER_MIN_Y
		STA playerY
		RTS
	
	.restrictYHigherBound:
		LDA #PLAYER_MAX_Y
		STA playerY
		RTS
	
RestrictSpaceShipPositionX:
	LDA playerX
	CMP #PLAYER_MIN_X
	BCC .restrictXLowerBound
	CMP #PLAYER_MAX_X
	BCS .restrictXHigherBound
	RTS
	
	.restrictXLowerBound:
		LDA #PLAYER_MIN_X
		STA playerX
		RTS
	
	.restrictXHigherBound:
		LDA #PLAYER_MAX_X
		STA playerX
		RTS
	
AllignSpaceShipSprites:

	;Sprites of the spaceship: 
	;200 x x 203 | 204 x x 207 | 208 x x 20B | 20C x x 20F
	;First number is y, forth is x

	LDA playerY
	STA $200
	STA $204
	CLC
	ADC #$8
	STA $208
	STA $20C
	
	LDA playerX
	STA $203
	STA $20B
	CLC
	ADC #$8
	STA $207
	STA $20F
	RTS
	
UpdateScore:
	LDX #$3 ;Start with the lowest digit of the score

	LDA score, x ;Load the lowest digit of the score
	CLC
	ADC #$1 ;Add 1 to the score
	STA score, x
	
	;Since every digit of the score is saved seperately, we have to check that
		;not a single digit is over 9, but instead overflows to the next digit
	
	SEC ;Set clear bit since we will only subtract here anyway
	HandleScoreDigits:
		CPX #$FF ;If we handled the highest digit of the score (score + 0), X will now be $FF ($0 - $1)
		BEQ .rts
		
		LDA score, x
		CMP #$0A ;If this digit is lower than $A, so $0-$9, we do not have to look any further 
		BCC .rts
		
		SBC #$0A ;If the digit is $A, set it back at $0
		STA score, x ;Store the new digit
		DEX ;Decrease X, so the next digit will be updated
		INC score, x ;Increase that next digit, since the previous one overflowed
		
		JMP HandleScoreDigits ;Repeat until no more digits
		
	.rts:
		RTS
ShowScore:
	RTS

NMI:
	LDA #$00
	STA $2003       ; set the low byte (00) of the RAM address
	LDA #$02
	STA $4014       ; set the high byte (02) of the RAM address, start the transfer
	LDA #$00        ;;tell the ppu there is no background scrolling
	STA $2005
	STA $2005
	
	JSR ReadInput
	
	JSR HandleButtonUp
	JSR HandleButtonRight
	JSR HandleButtonDown
	JSR HandleButtonLeft
	
	JSR RestrictSpaceShipPositionY
	JSR RestrictSpaceShipPositionX
	
	JSR AllignSpaceShipSprites
	
	JSR HandleButtonShoot
	
	JSR UpdateScore
	JSR ShowScore

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bank 1
    .org $E000

Palette:
	;Background colors
	.db $0F, $0F, $0F, $0F 
	.db $0F, $0F, $0F, $0F
	.db $0F, $0F, $0F, $0F
	.db $0F, $0F, $0F, $0F

	;Sprite colors
	;First color is always used for transparancy and 
	;needs to be the same color (last one I am not 100% sure of tho...)
	.db $00, $0F, $16, $30 ;Black, Red, White
	.db $00, $11, $21, $30 ;Blue, Light blue, White
	.db $00, $0F, $0F, $0F
	.db $00, $0F, $0F, $0F 

SpaceShipSprite:
	.db $08, $00, $01, $08
	.db $08, $01, $01, $10
	.db $10, $10, $01, $08
	.db $10, $11, $01, $10





    .org $FFFA     ;first of the three vectors starts here
    .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                     ;processor will jump to the label NMI:
    .dw RESET      ;when the processor first turns on or is reset, it will jump
                     ;to the label RESET:
    .dw 0          ;external interrupt IRQ is not used in this tutorial


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    .bank 2
    .org $0000
    .incbin "spacegame/spacegame.chr"



