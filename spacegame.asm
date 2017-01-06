	.inesprg 1
	.ineschr 1
	.inesmap 0
	.inesmir 1
	
	;Start variables at location $0000
	.rsset $0000
	
	;Important: the stack of NES uses addresses $0100-$01FF, 
	;so those 256 addresses cannot be used for variables
	;The stack starts filling up at address $01FF, so you *can* store a few
	;variables in the lowest addresses of the stack as long as the stack does 
	;not get to filled, but to be safe I will not do that 
	
	;Another note is that a lot of NES game developers use addresses $0200-$02FF
	;to store the sprites the OAM can send to the PPU, this will be done in this game too
	
gamestate .rs 1

;Score will be a 8 digit number
score .rs 8
SCORE_DIGITS = $08

buttons .rs 1
	
	.bank 1
	
	.org $E000
	.include "spacegame/palette.asm"
	.include "spacegame/backgroundGame.asm"
	.include "spacegame/player.asm"
	
	.org $FFFA
	.dw NMI
	.dw reset
	.dw 0
	
;==================================================;
	
	;NES games MUST have their main code in bank 0,
	; and on address $8000 or $C000 (you can choose)
	.bank 0
	.org $8000
	.include "spacegame/strings.asm"
	.include "spacegame/updateScore.asm"
	.include "spacegame/handleButtons.asm"

;Picture Processing Unit ports
PPU_CONTROLLER = $2000
PPU_MASK = $2001
PPU_STATUS_REGISTER = $2002
	;after setting PPU_ADDRESS_REGISTER you need to set PPU_SCROLL again as they have a shared internal register. That is why it is best to change PPU_SCROLL at the end. (http://wiki.nesdev.com/w/index.php/PPU_scrolling#Frequent_pitfalls)
PPU_SCROLL = $2005
PPU_ADDRESS_REGISTER = $2006
PPU_DATA = $2007

;PPU Object Attribute Memory
PPU_OAM_ADDRESS = $2003
	;PPU_OAM_DATA is not used, as it can cause some weird behavior that I do not fully understand myself.
	;Instead, data is written to $0200, and than automatically transferred to the PPU. For this last thing to work PPU_OAM_DMA has to be set to $02
PPU_OAM_DATA = $2004
	;High bit of OAM. When PPU_OAM_DMA has a value of $XX, the data at addresses $XX00-$XXFF will be read and transferred to the PPU to draw as sprites
PPU_OAM_DMA = $4014

;Central Processing Unit ports
CPU_JOYSTICK_1 = $4016
CPU_JOYSTICK_2 = $4017 ;Shares address with APU FC

;Audio Processing Unit ports
APU_DELTA_MODULATION_CHANNEL = $4010
APU_FRAMECOUNTER_CONTROL = $4017 ;Shares address with CPU J2
	
reset:
	
	;clear decimal mode, as it is not supported by NES anyway
	cld
	
	;7th bit of framecounter control is the interupt inhibit flag
	;Setting it to 1 puts it into a 5-step sequence
	;TODO:... more information
	lda %01000000
	sta APU_FRAMECOUNTER_CONTROL
	
	;Initialize the stack
	ldx #$FF
	txs
	
	inx
	stx PPU_CONTROLLER
	stx PPU_MASK
	stx PPU_SCROLL
	stx PPU_SCROLL
	stx APU_DELTA_MODULATION_CHANNEL
	
	jsr waitVBlank
	
	ldx #$00
	lda #$00
clearMemory:
	sta $0000, x
	sta $0100, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne clearMemory
	
	inx ;Overflow x back from FF to 0
	lda #$FF ;Sprites are hidden if they have a y-value of $EF or $FF
clearSpriteData:
	sta $0200, x
	
	inx
	bne clearSpriteData
	
	jsr waitVBlank
	
loadPalette:
	lda PPU_STATUS_REGISTER
	
	;The palettes are stored on addresses $3F00-$3F1F
	lda #$3F
	sta PPU_ADDRESS_REGISTER
	lda #$00
	sta PPU_ADDRESS_REGISTER
	
	ldx #$00
	loopLoadPalette:
		lda palette, x
		sta PPU_DATA
		
		inx
		cpx #$20
		bne loopLoadPalette
	
		
background:
	jsr loadBackgroundGame	
	
	
initialisePlayer:
	jsr resetPlayerVariables
	
enableNMI:
	;First bit enables NMI on every vertical blanking interval
	;4th bit says that the background tiles should be read from $1000 instead of $0000
	;http://wiki.nesdev.com/w/index.php/PPU_registers#Controller_.28.242000.29_.3E_write
	lda #%10010000
	sta PPU_CONTROLLER
	
enableSprites:
	;First three bits are to emphasise Blue, Green or Red (not used)
	;4th bit enables sprites
	;5th bit enables backgrounds
	;6th bit enables sprites to be shown in the first 8 columns
	;7th bit enables background to be shown in the first 8 columns
	;8th bit enables grayscale mode (not used)
	;http://wiki.nesdev.com/w/index.php/PPU_registers#Mask_.28.242001.29_.3E_write
	lda #%00011110
	sta PPU_MASK

	
endReset:
	jmp endReset
	
waitVBlank:
	bit PPU_STATUS_REGISTER
	bpl waitVBlank
	rts
	
;==================================================;

NMI:
	;Sprites are stored from $0200-$02FF
	lda #$00
	sta PPU_OAM_ADDRESS
	lda #$02
	sta PPU_OAM_DMA
	
	jsr readInput
	jsr repositionPlayer
	
	jsr updateScore
	jsr updateScoreHUD
	
	;Set PPU_SCROLL to 0000 as it gets reset every time PPU_ADDRESS_REGISTER is read
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	
	;End execution of NMI
	rti

;=================================================;
	
	.bank 2
	.org $0000
	.incbin "spacegame/spacegame.chr"