	.inesprg 1
	.ineschr 1
	.inesmap 0
	.inesmir 1
	
	.rsset $0000
score .rs 4
	
	.bank 1
	
	.org $E000
	.include "spacegame/palette.asm"
	.include "spacegame/backgroundGame.asm"
	
	.org $FFFA
	.dw	NMI
	.dw reset
	.dw 0
	
;==================================================;
	
	;NES games MUST have their main code in bank 0,
	; and on address $8000 or $C000 (you can choose)
	.bank 0
	.org $8000
	.include "spacegame/updateScore.asm"

;Picture Processing Unit ports
PPU_CONTROLLER = $2000
PPU_MASK = $2001	
PPU_STATUS_REGISTER = $2002
PPU_SCROLL = $2005
PPU_ADDRESS_REGISTER = $2006
PPU_DATA = $2007

;Central Processing Unit ports
CPU_JOYSTICK_1 = $4016
CPU_JOYSTICK_2 = $4017

;Audio Processing Unit ports
APU_DELTA_MODULATION_CHANNEL = $4010
APU_FRAMECOUNTER_CONTROL = $4017
	
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
	
	lda #$00
	sta PPU_CONTROLLER
	sta PPU_MASK
	sta PPU_SCROLL
	sta PPU_SCROLL
	sta APU_DELTA_MODULATION_CHANNEL
	
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
	lda #$FF
clearSpriteData:
	sta $0200, x
	
	inx
	bne clearSpriteData
	
	;TODO: fields $01FD-01FF are set in waitVBlank...
	;That does not happen if the vblank code is put here...
	;But if you put both the previous waitVBlank and this one in its own container, than the same fields are written to...
	;Assembly6502... Y SO CONFUSING??...
	jsr waitVBlank
	
loadPalette:
	lda PPU_STATUS_REGISTER
	
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
	
enableNMI:
	lda #%10010000
	sta $2000
	
enableSprites:
	lda #%00011110
	sta $2001
	
endReset:
	jmp endReset
	
waitVBlank:
	bit PPU_STATUS_REGISTER
	bpl waitVBlank
	rts
	
;==================================================;

NMI:
	
	jsr updateScore
	
	;Set PPU_SCROLL to 0000 as it gets reset every time PPU_ADDRESS_REGISTER gets read
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	
	;End execution of NMI
	rti

;=================================================;
	
	.bank 2
	.org $0000
	.incbin "spacegame/spacegame.chr"