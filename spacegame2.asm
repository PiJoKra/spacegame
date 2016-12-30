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

;Picture Processing Unit ports
PPU_CONTROLLER = $2000
PPU_MASK = $2001	
PPU_STATUS_REGISTER = $2002

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
	sta APU_DELTA_MODULATION_CHANNEL
	
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
	
	;TODO: fields $01FD-01FF are set in waitVBlank...
	;That does not happen if the vblank code is put here...
	;But if you put both the previous waitVBlank and this one in its own container, than the same fields are written to
	;Assembly6502... Y SO CONFUSING??...
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
	inc $00
	
	;End execution of NMI
	rti
	
;=================================================;
	
	.bank 2
	.org $0000
	.incbin "spacegame/spacegame.chr"