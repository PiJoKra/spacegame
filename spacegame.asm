;A space game

;/!\ Important /!\
;Before working on this I had zero knowledge of programming in NESASM (or any other assembly language)
;I tried to comment as much of the code as possible, that does not mean everything
;written is correct. Since I am a beginner, I could have made some mistakes here
;and there, so read with caution.
;I read the following tutorial, and than started on the project:
;http://nintendoage.com/forum/messageview.cfm?StartRow=1&catid=22&threadid=7155


;I also used these helpful resources
;This might be the first project I have ever worked on where I did not 
;get any help from StackOverflow.com

;6502.org - http://www.6502.org/
;	http://www.6502.org/tutorials/compare_instructions.html
;NESDev - http://nesdev.com/
;	wiki.nesdev.com 
;	forum.nesdev.com 
;easy6502 - https://skilldrick.github.io/easy6502/ (Only used for quick tests)
;Source code of NESASM - http://www.nespowerpak.com/nesasm/


;General information I found about NESASM

;All memory spaces are 8-bit. Sometimes a 16-bit integer is needed, and that is solved
;by allowing to write to the memory space two times. Since NESASM is little endian, the

;lowest bit needs to be written first. (TODO: Somehow does not apply to $2007 and $2006)
;NESASM uses hexadecimal and binary numbers, not decimal numbers. On some places however
;(TODO: check if this is correct) It seems that this is not the case for zero, which can also be written in de decimal format


	.inesprg 1 ;1 16kb prg bank
	.ineschr 1 ;1 8kg chr bank
	.inesmap 0 ;Do not use a mapper
	.inesmir 1 ;Mirror vertical
	
	;Start variables at location $0000
	.rsset $0000
	
	;Important: the stack of NES uses addresses $0100-$01FF, 
	;so those 256 addresses cannot be used for variables
	;The stack starts filling up at address $01FF, so you *can* store a few
	;variables in the lowest addresses of the stack as long as the stack does 
	;not get too filled, but to be safe I will not do that 
	
	;Another note is that a lot of NES game developers use addresses $0200-$02FF
	;to store the OAM, this will be done in this game too
	
gamestate .rs 1
GAME_STATE_MENU = 1
GAME_STATE_GAME = 2
GAME_STATE_OVER = 3

;Since nametables cannot be fully loaded in one frame, we have to do it over multiple frames
nameTableLoader .rs 1
NAME_TABLE_LOADING_PARTS = 4 ;load 64 tiles each frame

;Score will be a 8 digit number
score .rs 8
SCORE_DIGITS = $08

buttons .rs 1

backgroundAddressLow .rs 1
backgroundAddressHigh .rs 1

	
	.bank 1
	
	.org $E000
	.include "spacegame/palette.asm"
	.include "spacegame/backgroundGame.asm"
    .include "spacegame/backgroundMenu.asm"
	.include "spacegame/backgroundOver.asm"
    .include "spacegame/menu.asm"
	.include "spacegame/player.asm"
	.include "spacegame/prng.asm"
	.include "spacegame/enemies.asm"
	
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
PPU_OAM_SPRITE_SIZE = $8

;Central Processing Unit ports
CPU_JOYSTICK_1 = $4016
CPU_JOYSTICK_2 = $4017 ;Shares address with APU FC

;Audio Processing Unit ports
APU_DELTA_MODULATION_CHANNEL = $4010
APU_FRAMECOUNTER_CONTROL = $4017 ;Shares address with CPU J2
	
reset:
	
	;clear decimal mode, as it is not supported by NES anyway
	cld
	
	;Disable IRQ (Setting the interupt flag only allows NMI to be executed, 
	;	http://wiki.nesdev.com/w/index.php/CPU_status_flag_behavior)
	;I normally already did this by pushing 0 to $FFFE (as seen in bank 1),
	;but some emulators don't run without this instruction (e.g. VirtualNES)
	sei
	
	;7th bit of framecounter control is the interupt inhibit flag
	;Setting it to 1 puts it into a 5-step sequence
	;TODO:... more information
	lda %01000000
	sta APU_FRAMECOUNTER_CONTROL
	
	;Initialize the stack by setting the stack pointer to $FF, the last position of the stack
	;The stack in NES is descending, that is why the highest value is assigned
	ldx #$FF
	txs
	
	inx ;$FF + 1 = $0, so x is now 0
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
	sta $0100, x ;The stack
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
	
		
menu:
    lda #GAME_STATE_MENU
    sta gamestate
	jsr loadBackgroundMenu
	
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
    
    lda gamestate
    
    cmp #GAME_STATE_MENU
    beq gameStateMenu
    
    cmp #GAME_STATE_GAME
    beq gameStateGame
    
    ;Otherwise go to game-over screen
    jmp gameStateOver
	
gameStateMenu:
    jsr gameStartButtonShowHide
    jsr readInputMenu
    jsr updateSeedRoller
    
    jmp endNMI

gameStateGame:
    lda nameTableLoader
    cmp #NAME_TABLE_LOADING_PARTS
    bne .keepLoading
    
	jsr spawnEnemyEveryXFrames
	jsr updateEnemy
	
	jsr updateScoreHUD
	jsr updateHealthHUD
	
	jsr isPlayerAlive
	cmp #$00
	beq endGame
	
	jsr updatePlayerBullets
	
	jsr readInputPlayer
	jsr repositionPlayer
	jsr showBullets
    
    jmp endNMI
    
    .keepLoading:
        jsr loadBackgroundGame
        jmp endNMI
    
gameStateOver:
	lda nameTableLoader
	cmp #$04
	bne .keepLoading
	
    jsr countDownGameOver
	
	jmp endNMI
	
	.keepLoading:
		lda nameTableLoader
		sta $64
		jsr loadBackgroundOver
		jmp endNMI
	
    
endNMI:
	;Set PPU_SCROLL to 0000 as it gets reset every time PPU_ADDRESS_REGISTER is read
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	
	;End execution of NMI
	rti
	
endGame:
	lda #GAME_STATE_OVER
	sta gamestate
	
	lda #$FE
	sta PLAYER_SPRITE+$00
	sta PLAYER_SPRITE+$04
	sta PLAYER_SPRITE+$08
	sta PLAYER_SPRITE+$0C
	
	lda #$00
	sta nameTableLoader
	
	lda #GAME_OVER_COUNTER_MAX
	sta gameOverCounter
	
	;jsr drawYouLost
	
	jmp gameStateOver

;=================================================;
	
	.bank 2
	.org $0000
	.incbin "spacegame/spacegame.chr"