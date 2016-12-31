palette:
	;Background colors
	.db $00, $30, $2D, $1F ;White, Gray, Black
	.db $00, $11, $11, $11
	.db $00, $11, $11, $11
	.db $00, $11, $11, $11

	;Sprite colors
	;First color is always used for transparancy and 
	;needs to be the same color (last one I am not 100% sure of tho...)
	.db $00, $0F, $16, $30 ;Black, Red, White
	.db $00, $11, $21, $30 ;Blue, Light blue, White
	.db $00, $0F, $0F, $0F
	.db $00, $0F, $0F, $0F 