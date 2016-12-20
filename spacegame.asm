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
PLAYER_MIN_X = $0
PLAYER_MIN_Y = $0
PLAYER_MAX_X = $F7
PLAYER_MAX_Y = $F7

buttons .rs 1

score .rs 1

	.bank 0
	.org $C000	
	
vBlankWait:
	BIT $2002
	BPL vBlankWait ;If not ready, repeat
	RTS
	
	
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
	
StopResetAndClearMemory ;Prevent code from reset and clearing of memory to leak through
	JMP StopResetAndClearMemory

NMI:
	LDA #$00
	STA $2003       ; set the low byte (00) of the RAM address
	LDA #$02
	STA $4014       ; set the high byte (02) of the RAM address, start the transfer

	LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
	STA $2000
	LDA #%00011110   ; enable sprites, enable background, no clipping on left side
	STA $2001
	LDA #$00        ;;tell the ppu there is no background scrolling
	STA $2005
	STA $2005


;;;;;;
	.bank 1
    .org $E000
  palette:
    .db $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
    .db $22,$1C,$15,$14,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette
  
  sprites:
       ;vert tile attr horiz
    .db $80, $32, $00, $80   ;sprite 0
    .db $80, $33, $00, $88   ;sprite 1
    .db $88, $34, $00, $80   ;sprite 2
    .db $88, $35, $00, $88   ;sprite 3
  
  
  
    .org $FFFA     ;first of the three vectors starts here
    .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                     ;processor will jump to the label NMI:
    .dw RESET      ;when the processor first turns on or is reset, it will jump
                     ;to the label RESET:
    .dw 0          ;external interrupt IRQ is not used in this tutorial
    
    
  ;;;;;;;;;;;;;;  
    
    
    .bank 2
    .org $0000
    .incbin "mario.chr"   ;includes 8KB graphics file from SMB1



