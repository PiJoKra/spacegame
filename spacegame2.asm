	.inesprg 1
	.ineschr 1
	.inesmap 0
	.inesmir 1
	
	.rsset $0000
	
	.bank 1
	.org $FFFA
	.dw	NMI
	.dw reset
	.dw 0
	
	;NES games MUST have their main code in bank 0,
	; and on address $8000 or $C000 (you can choose)
	.bank 0
	.org $8000
	
PPU_STATUS_REGISTER = $2002

CPU_JOYSTICK_1 = $4016
CPU_JOYSTICK_2 = $4017

APU_FRAMECOUNTER_CONTROL = $4017
	
reset:
	
	;clear decimal mode, as it is not supported by NES anyway
	cld
	
	;7th bit of framecounter control is the interupt inhibit flag
	;Setting it to 1 puts it into a 5-step sequence
	;TODO:...
	lda %01000000
	sta APU_FRAMECOUNTER_CONTROL
	
	;Initialize the stack
	ldx #$FF
	txs
	
	lda #$00
	sta $2000
	sta $2001
	sta $4010
	
	jsr waitVBlank
	
	ldx #$00
	lda #$00
	ldy #$00
clearMemory:
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	
	inx
	bne clearMemory
	
	;.waitVBlank:
	;	bit PPU_STATUS_REGISTER
	;	bpl .waitVBlank
	
	;TODO: fields $01FD-01FF are set in waitVBlank...
	jsr waitVBlank
	
enableNMI:
	lda #%10000000
	sta $2000
	
enableSprites:
	lda #%00010000
	sta $2001
	
endReset:
	jmp endReset
	
waitVBlank:
	bit PPU_STATUS_REGISTER
	bpl waitVBlank
	rts
	
;==================================================;

NMI:
	
	
	;End execution of NMI
	rti
	
;=================================================;
	
	.bank 2
	.org $0000
	.incbin "spacegame/spacegame.chr"