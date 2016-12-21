	.inesprg 1   ; 1x 16KB PRG code
	.ineschr 1   ; 1x  8KB CHR data
	.inesmap 0   ; mapper 0 = NROM, no bank swapping
	.inesmir 1   ; background mirroring

	.rsset $0000

gamestate .rs 1
GAME_STATE_MENU = $00
GAME_STATE_PLAYING = $01
GAME_STATE_DEAD = $02

playerSpeed .rs 1
playerX .rs 1
playerY .rs 1
PLAYER_X_MEM = $0204
PLAYER_Y_MEM = $0200
PLAYER_MIN_X = $0
PLAYER_MIN_Y = $0
PLAYER_MAX_X = $F7
PLAYER_MAX_Y = $F7

buttons .rs 1

score .rs 1

	.bank 0
	.org $C000	
	
RESET:
	SEI          ; disable IRQs
	CLD          ; disable decimal mode
	LDX #$40
	STX $4017    ; disable APU frame IRQ
	LDX #$FF
	TXS          ; Set up stack
	INX          ; now X = 0
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
	
	LDX #$0
	
	;$3F00-$3F0F are for background colors
	;$3F10-$3F1F are for sprite colors
	LoadPalettesLoop:
		LDA Palette, x
		STA $2007
		INX
		CPX #$20
		BNE LoadPalettesLoop

LoadSpaceShipSprite:
	LDX #$0
	
	;$0200-$02FF is sprite data where every 4 bytes is a sprite
	;First sprite will be the spaceship
	LoadSpaceShipSpriteLoop:
		LDA SpaceShipSprite, x
		STA $0200, x
		INX
		CPX #$10
		BNE LoadSpritesLoop


EnableNMIAndSprites:
	LDA #%10000000 ;Enable NMI
	STA $2000

	LDA #%00010000 ;Enable sprites
	STA $2001

StopResetAndClearMemory: ;Prevent code from reset and clearing of memory to leak through
	JMP StopResetAndClearMemory

vBlankWait:
	BIT $2002
	BPL vBlankWait ;If not ready, repeat
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NMI:
	LDA #$00
	STA $2003       ; set the low byte (00) of the RAM address
	LDA #$02
	STA $4014       ; set the high byte (02) of the RAM address, start the transfer
	LDA #$00        ;;tell the ppu there is no background scrolling
	STA $2005
	STA $2005

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
	.db $22, $0F, $16, $30 ;Blue, Black, Red, White
	.db $0F, $0F, $0F, $0F
	.db $0F, $0F, $0F, $0F
	.db $0F, $0F, $0F, $0F 

SpaceShipSprite:
	.db $08, $00, $00, $08
	.db $08, $01, $00, $10
	.db $10, $10, $00, $08
	.db $10, $11, $00, $10





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



