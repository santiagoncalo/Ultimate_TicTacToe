;------------------------------------------------------------------------
;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   Gonçalo Santiago 2022133003 e Mariana Maia 2022148315
;	ANO LETIVO 2022/2023
;--------------------------------------------------------------
.8086
.model small
.stack 2048

dseg	segment para public 'data'

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		
		;Váriaveis
		
		Menu			db 10,13,'			   ULTIMATE TIC TAC TOE   			',10,13
						db '  1.Jogar 1vs1',10,13
						db '  ',10,13
						db '  2.Sair',10,13
						db '  ',10,13
						db '  Trabalho realizado por: Goncalo Santiago e Mariana Maia','$',10,13
		
		NomeUm     db '     Nome do primeiro jogador:  $', 10,13
		NomeDois   db 'Nome do segundo jogador:  $',10,13 
		NomeJogadorUm   db 100 dup('$')
		NomeJogadorDois db 100 dup('$')
		
		num 			db 0
		jogadorvez      db 'Vez do Jogador $' 
		tab				db 1
		VenceMensagem db 'Venceu o tabuleiro $'
		VenceJogo		db 'Ganhou! Parabens Jogador $'
		RegraJogador    db 'Jogador $'
		EmpateMensagem db 'Empate!$'
		
		XO				dw 584Fh
		GuardaCaracter  db 'X'
		GuardaJogador   db 1
		GuardaX		dw 0058h
		GuardaO  		dw 004fh

		vazio           db '                                     $'
		Tabuleiro1      byte 3 dup(3 dup('_')) ;tabuleiro 3x3 para guardar o primeiro tabuleiro
		Tabuleiro2      byte 3 dup(3 dup('_'))
		Tabuleiro3      byte 3 dup(3 dup('_')) 
		Tabuleiro4      byte 3 dup(3 dup('_')) 
		Tabuleiro5      byte 3 dup(3 dup('_')) 
		Tabuleiro6      byte 3 dup(3 dup('_')) 
		Tabuleiro7      byte 3 dup(3 dup('_')) 
		Tabuleiro8      byte 3 dup(3 dup('_')) 
		Tabuleiro9      byte 3 dup(3 dup('_')) 
		TabAux			byte 3 dup(3 dup('_'))
		EstadoTabuleiro byte 9 dup('_') ;para guardar 1 se o jogador1 ganhou o tabuleiro, 2 se o jogador2 ganhou o tabuleiro, 0 se empate
		Px				db 3
		Py				db 3

		cores 			db 2f
		fim_jogo		db 01
		Flagjogo        db 01
		FlagEmpate      db 00
		
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;guarda no tabuleiro correspondente

Index_Array macro Px,Py
	
	LOCAL ComparaX,ComparaY,IncrementaX,IncrementaY,fim
	;limpar tudo
	xor si,si
	xor ax,ax
	xor bx,bx

	mov bl,POSx
	mov al,Px
	
	mov bh,POSy
	mov ah,PY
	
	jmp ComparaX

IncrementaY:	
	add si, 03h
	add ah, 01h
	jmp ComparaY
	
IncrementaX:
	inc si
	add al, 02h
	jmp ComparaX

ComparaX:
	cmp al,bl
	jne IncrementaX
	
ComparaY:
	cmp bh, ah
	jne IncrementaY
fim:
	
endm

;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp

; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		

; LE UMA TECLA	

LE_TECLA	PROC
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp

; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:			
			goto_xy	POSx,POSy		; Vai para nova posição
			mov 	ah, 08h
			mov		bh,0			; numero da página
			int		10h		
			mov		Car, al			; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah			; Guarda a cor que está na posição do Cursor 
			
			goto_xy	78,0			; Mostra o caractr que estava na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car	
			int		21H			
	
			goto_xy	POSx,POSy	; Vai para posição do cursor
		
LER_SETA:
			call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27		; ESCAPE
			JE		FIM
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
		
	cmp		cl, 5fh		; Só escreve se for _ ->5fh	
	JNE 	LER_SETA
	
	;if else -> verificar se é O ou X
	mov cx, GuardaX
	cmp ch,num
	je X
	jne O
X:
	cmp al, 58h ;comparar o X
	jne O
	je Continua
O:
    cmp al, 4fh ;comparar o O
	jne LER_SETA
	je Continua 

Continua:
	mov GuardaCaracter,al
	mov		ah, 02h		; coloca o caracter lido no ecra
	mov		dl, al
	int		21H	
	
	call TABULEIRO
	xor dl, dl
	
	cmp Flagjogo,00
	je fim
	goto_xy	POSx,POSy
	call VezJogador
	goto_xy 0,0
	jmp		LER_SETA

ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			jmp		CICLO

fim:				
			RET
AVATAR		endp

VezJogador proc
	goto_xy 33, 15
	lea dx,jogadorvez
	mov ah,09h
	int 21h

	mov ah,02h
	mov dl, num
	add dl, '0' ; adiciona 48, tabela ascii
	int 21h
	
	cmp num, 01h
	je JOGADOR1
	jne JOGADOR2
	
JOGADOR1:		
	goto_xy 33, 16
	inc num
	lea dx, NomeJogadorUm+2
	mov ah,09h
	int 21h
	jmp fim
	
JOGADOR2:		
	goto_xy 33, 16
	dec num
	lea dx, NomeJogadorDois+2
	mov ah,09h
	int 21h

fim:

	ret
VezJogador endp

;Mudar cor de fundo do ecrã
COR_ECRA proc
	
	mov ah,00
	mov al,03
	int 10h
	
	mov ah,09
	mov bh,00
	mov al,20h
	mov cx,800h
	mov bl,cores
	int 10h
	
	ret
COR_ECRA endp

LINHA proc
	;Para manter o estado de td
	PUSHF
	PUSH DI
	
	xor ax,ax

LINHA__1:
	cmp si,02h
	ja LINHA__3
	jbe IF_LIN
	
LINHA__2:
	add di,3
	jmp IF_LIN
	
LINHA__3:
	cmp si,06h
	jb LINHA__2
	add di,6
	jae IF_LIN
	
IF_LIN:
	mov al,[di];0
	mov ah,[di]+1;1
	
	cmp al, 5fh
	je FIM

	cmp ah, 5fh
	je FIM
	
	cmp ah,bl
	je IGUAL
	
	mov al,[di]+2;2
	cmp al,ah
	jne FIM
	je IGUAL
	
IGUAL:
	call MUDA_COR
	call ATUALIZA_ESTADO_JOGO
FIM:
	;POP DX,CX,BX,AX
	POP DI
	POPF
	ret
LINHA endp

;Verificar Coluna
COLUNA proc
	PUSHF
	PUSH DI
	
	xor ax,ax
	xor bx,bx

	cmp si,0
	je IF_COL
	cmp si,3
	je	IF_COL
	cmp si,6
	je IF_COL
	
	add di,01
	cmp si,1
	je	IF_COL
	cmp si,4
	je IF_COL
	cmp si,7
	je	IF_COL
	
	add di,01
	cmp si,2
	je IF_COL
	cmp si,5
	je	IF_COL
	cmp si,8
	
IF_COL:
	mov al,[di];0
	mov ah,[di]+3;3
	
	cmp al, 5fh
	je FIM
	
	cmp ah,5fh
	je FIM
	
	cmp al,ah
	jne FIM
	
	mov al,[di]+6;6
	cmp ah,al
	jne FIM
	je IGUAL
	
IGUAL:
	call MUDA_COR
	call ATUALIZA_ESTADO_JOGO
	
FIM:
	
	POP DI
	POPF
	ret

COLUNA endp

DIAGONAL proc
	PUSHF
	PUSH DI
	xor ax,ax
	
IF_DIAGON:
	mov al,[di];0
	mov ah,[di]+4;4
	
	cmp al, 5fh
	je ELSE_DIAGON

	cmp ah, 5fh
	je ELSE_DIAGON
	
	cmp al,ah
	jne ELSE_DIAGON
	
	mov ah,[di]+8;8
	
	cmp al,ah
	jne ELSE_DIAGON
	je IGUAL

ELSE_DIAGON:
	mov al,[di]+2;0
	mov ah,[di]+4;4
	
	cmp al, 5fh
	je FIM

	cmp ah, 5fh
	je FIM
	
	cmp al,ah
	jne FIM
	
	mov al,[di]+6;8
	
	cmp al,ah
	jne FIM
	je IGUAL

IGUAL:
	call MUDA_COR
	call ATUALIZA_ESTADO_JOGO
FIM:
	
	POP DI
	POPF
	ret
	
DIAGONAL endp


BLOQUEIA_TAB proc
	
	xor cx,cx
	xor ax,ax	
	xor bx,bx
	
TABULEIRO_:	
	cmp tab,01
	mov ch,02
	mov PX,02
	je FORI
	
	cmp tab,02
	mov ch,02
	mov PX, 11
	je FORI
	
	cmp tab,03
	mov ch,02
	mov PX,20
	je FORI
	
	cmp tab,04
	mov ch,06
	mov PX,02
	je FORI
	
	cmp tab,05
	mov ch,06
	mov PX,11
	je FORI
	
	cmp tab,06
	mov ch,06
	mov PX,20
	je FORI

	cmp tab,07
	mov ch,10
	mov PX,02
	je FORI
	
	cmp tab,08
	mov ch,10
	mov PX,11
	je FORI
	
	cmp tab,09
	mov ch,10
	mov PX,20
	je FORI
	
FORI:
	cmp cl,03
	je SAIR
	
	add PX,02
	inc cl
	
	mov PY, ch
	mov bx,00h
	
	jmp FORJ
	
FORJ:
	cmp bx,03
	je FORI
	
	goto_xy PX,PY
	mov ah,02h
	mov dl,GuardaCaracter
	int 21h

	inc PY
	inc bx
	jmp FORJ
	
SAIR:

	ret
BLOQUEIA_TAB endp

ATUALIZA_ESTADO_JOGO proc
	;array do estado
	;posição do array = num tab
	PUSHF
	PUSH SI
	PUSH AX
	xor si,si
	;xor ax,ax
	xor cL,cL
	
	mov ah,GuardaJogador
	MOV AL,TAB
	DEC AL
	;lea si, EstadoTabuleiro

	MOV CX,08
	MOV BL,0
CICLO:	
	cmp AL,BL
	JE MOVE
	inc si
	INC BL
	LOOP CICLO
	
MOVE:
	mov EstadoTabuleiro[si],ah
	
GUARDAR:
	
	goto_xy 04,17
	lea dx, RegraJogador
	mov ah,09h
	int 21h
	
	goto_xy 13,17
	mov ah,02h
	mov dl,GuardaJogador
	add dl, '0'
	int 21h
	
	goto_xy 04,18
	lea dx, VenceMensagem
	mov ah,09h
	int 21h
	
	goto_xy 23,18
	mov ah,02h
	mov dl,tab
	add dl, '0'
	int 21h
	
	call ESTADO_JOGO
	
	POP AX
	POP SI
	POPF
	ret
ATUALIZA_ESTADO_JOGO endp

VERIFICAR_EMP proc
	PUSHF 
	PUSH DI
	
	xor ax,ax
	xor cx,cx
	
	mov cx,09
CORRE:
	mov al, [di]
	cmp al,5fh
	je FIM
	inc di
	LOOP CORRE
	
MOV cx,09
mov si,08
INCSI:
	cmp tab,cl
	je EMPATE
	dec si
	LOOP INCSI

EMPATE:
	mov  ax,0B800h ;Memóra de Video
    mov  es,ax
    
	cmp tab,1
    mov di, 328
	je continua
	
	cmp tab,2
    mov di, 346
	je continua
	
	cmp tab,3
    mov di, 364
	je continua
	
	cmp tab,4
    mov di, 968
	je continua
	
	cmp tab,5
    mov di, 986
	je continua
	
	cmp tab,6
    mov di, 1004
	je continua
	
	cmp tab,7
    mov di, 1608
	je continua
	
	cmp tab,8
    mov di, 1626	
	je continua
	
	cmp tab,9
    mov di, 1644
	je continua

continua:
    mov     ax, 1003h
    mov     bx, 0   
    int     10h
	mov ch,2
	mov cl,3
	mov ah,11100000b
	
ciclo:
    cmp cl,00
	je ciclol
    mov byte ptr ES:[DI+1], ah 
    add di, 4
	dec cl
	jmp ciclo
	
ciclol:
	SUB DI,12
	cmp ch,00
	je fim_ciclo
    mov byte ptr ES:[DI+1], ah 
    add di, 160
	dec ch
	MOV cl,3
	jmp ciclo

fim_ciclo:

	goto_xy 04,17
	lea dx,vazio
	mov ah,09h
	int 21h
	
	goto_xy 04,18
	lea dx,vazio
	mov ah,09h
	int 21h
	
	goto_xy 04,17
	lea dx, EmpateMensagem
	mov ah,09h
	int 21h
	
	mov EstadoTabuleiro[si],0
	call ESTADO_JOGO
	
FIM:
	POP DI
	POPF 
	ret
VERIFICAR_EMP endp

ESTADO_JOGO proc
	xor si,si
	xor ax,ax
	xor cx,cx

	call VLINHA
	call VCOLUNA
	call VDIAGONAL
	
	xor ax,ax
	xor si,si
	mov cx,08
	
JOGOESPACO:
	cmp EstadoTabuleiro[si],5fh
	je FIM
	inc si
	LOOP JOGOESPACO
	
	xor si,si
	mov cx,08	
vzero:
	cmp EstadoTabuleiro[si],0
	je EMPT
	inc si
	LOOP vzero
	
	xor si,si
	mov cx,08
vum:
	cmp EstadoTabuleiro[si], 1
	je IGUAL
	inc si
	LOOP vum
IGUAL:
	inc al
	inc si
	jmp vum
	
	xor si,si
	mov cx,08
vdois:
    cmp EstadoTabuleiro[si], 2
	je IGUALDOIS
	inc si	
	LOOP vdois
IGUALDOIS:
    inc ah
	inc si
    jmp vdois 
	
	
    cmp al,ah
    jb JO2
    mov num,1
    ja GANHOU
    je EMPT

JO2:
    mov num,2
    jmp GANHOU

EMPT:
	mov Flagjogo, 00
	mov FlagEmpate,01
	
GANHOU:
	mov Flagjogo,00
FIM:
	
	ret
ESTADO_JOGO endp
	
	
VLINHA proc
	xor si,si
	xor ax,ax
	xor cx,cx
	mov cx,00
CICLO:
	cmp cx,03
	JE FIM
	mov al,EstadoTabuleiro[si]
	inc si
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je VELSELINHA
	
	cmp ah,0
	je VELSELINHA
	
	cmp al,5fh
	je VELSELINHA
	
	cmp ah,5fh
	je VELSELINHA
	
	cmp al,ah
	jne VELSELINHA
	
	inc si
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	inc si
	inc cx
	jne CICLO
	
VELSELINHA:
	add si,2
	jmp CICLO
GANHOU:
	mov Flagjogo,00
FIM:
	ret
VLINHA endp


VCOLUNA proc
	xor si,si
	xor ax,ax
	xor cx,cx
	mov cx,00
CICLO:
	cmp cx,03
	JE FIM
	mov al,EstadoTabuleiro[si]
	add si,03
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je VELSECOLUNA
	
	cmp ah,0
	je VELSECOLUNA
	
	cmp al,5fh
	je VELSECOLUNA
	
	cmp ah,5fh
	je VELSECOLUNA
	
	cmp al,ah
	jne VELSECOLUNA
	
	add si,03
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	sub si,05
	inc cx
	jne CICLO
	
VELSECOLUNA:
	sub si,02
	jmp CICLO
	
GANHOU:
	mov Flagjogo,00

FIM:
	ret
VCOLUNA endp

VDIAGONAL proc
	xor si,si
	xor ax,ax
	xor cx,cx

	mov al,EstadoTabuleiro[si]
	add si,04
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je VELSEDIAGONAL
	
	cmp ah,0
	je VELSEDIAGONAL
	
	cmp al,5fh
	je VELSEDIAGONAL
	
	cmp ah,5fh
	je VELSEDIAGONAL
	
	cmp al,ah
	jne VELSEDIAGONAL
	
	add si,04
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	
VELSEDIAGONAL:
	MOV SI,0
	add si,02
	mov al,EstadoTabuleiro[si]
	add si,02
	mov ah,EstadoTabuleiro[si]
	
	cmp al,0
	je FIM
	
	cmp ah,0
	je FIM
	
	cmp al,5fh
	je FIM
	
	cmp ah,5fh
	je FIM
	
	cmp al,ah
	jne FIM
	
	add si,02
	mov al,EstadoTabuleiro[si]
	
	cmp ah,al
	je GANHOU
	jne FIM
	
GANHOU:
	mov Flagjogo,00

FIM:
	ret

VDIAGONAL endp



FIMJOGO proc
	;mostra mensagem final de quem ganhou o jogo e sai do programa


	ret
FIMJOGO endp	
	

MUDA_COR proc
	PUSHF
    PUSH di
    xor di,di
    xor ax,ax
	xor bx,bx

    mov   ax,0B800h ;Memóra de Video
    mov   es,ax
    
    cmp tab,1
    mov di, 328
    je BLINK
	
	cmp tab,2
    mov di, 346
    je BLINK
	
	cmp tab,3
    mov di, 364
    je BLINK

	cmp tab,4
    mov di, 968
    je BLINK
	
	cmp tab,5
    mov di, 986
    je BLINK
	
	cmp tab,6
    mov di, 1004
    je BLINK
	
	cmp tab,7
    mov di, 1608
    je BLINK
	
	cmp tab,8
    mov di, 1626
    je BLINK	
	
	cmp tab,9
    mov di, 1644
    je BLINK
	
BLINK:	
    ; disable blinking
    mov     ax, 1003h
    mov     bx, 0   
    int     10h
    
	mov ah,01001111b
    mov al,GuardaCaracter
	cmp al, 58H
	je CONTINUA
	jne MUDACOR
	
MUDACOR:
	mov ah,00011111b 
CONTINUA:
	mov ch,2
	mov cl,3
	
ciclo:
    cmp cl,00
	je ciclol
    mov byte ptr ES:[DI],  AL;Letra em ASCII
    mov byte ptr ES:[DI+1], ah ;Atributos
    add di, 4
	dec cl
	jmp ciclo
	
ciclol:
	SUB DI,12
	cmp ch,00
	je fim_ciclo
	mov byte ptr ES:[DI],  AL;Letra em ASCII
    mov byte ptr ES:[DI+1], ah ;Atributos
    add di, 160
	dec ch
	MOV cl,3
	jmp ciclo

fim_ciclo:
    
    POP di
    POPF
    ret
MUDA_COR endp

PRINT_ARRAY proc
	goto_xy 2,19
    mov dl,Tabuleiro1[0]
    MOV AH, 02h
    INT 21h
goto_xy 3,19
    mov dl,Tabuleiro1[1]
    MOV AH, 02h
    INT 21h
goto_xy 4,19
   mov dl,Tabuleiro1[2]
    MOV AH, 02h
    INT 21h
goto_xy 5,19
 mov dl,Tabuleiro1[3]
    MOV AH, 02h
    INT 21h
goto_xy 6,19
    mov dl,Tabuleiro1[4]
    MOV AH, 02h
    INT 21h
goto_xy 7,19
  mov dl,Tabuleiro1[5]
    MOV AH, 02h
    INT 21h
		goto_xy 8,19
  mov dl,Tabuleiro1[6]
    MOV AH, 02h
    INT 21h
goto_xy 9,19
  mov dl,Tabuleiro1[7]
    MOV AH, 02h
    INT 21h
goto_xy 10,19
  mov dl,Tabuleiro1[8]
    MOV AH, 02h
    INT 21h
	ret
PRINT_ARRAY endp

;Dá o tabuleiro em q se encontra segundo as coordenadas
TABULEIRO proc
	
	xor si,si
	xor di,di
	mov al, num
	mov GuardaJogador,al
	
Coluna1:
	cmp POSx,08h
	jbe Linha1
	ja  Coluna2
	
Linha1:
	cmp POSy,04h
	ja Linha2
	Index_Array 04h,02h
	mov Tabuleiro1[si],dl
	mov tab, 01
	
	lea di, Tabuleiro1
	;call PRINT_ARRAY
	jmp CONTINUA

Linha2:
	cmp POSy,08h
	ja Linha3
	Index_Array 04h,06h
	mov Tabuleiro4[si],dl
	mov tab, 04
		
	lea di, Tabuleiro4
	jmp CONTINUA
	
Linha3:
	Index_Array 04h,0Ah ;10 decimal
	mov Tabuleiro7[si],dl
	mov tab, 07
	
	lea di, Tabuleiro7
	jmp CONTINUA
	
Coluna2:
	cmp POSx, 11h ;17 decimal
	ja Coluna3
	cmp POSy,04h
	ja Linha22
	
	Index_Array 0dh,02h ;13 decimal
	mov Tabuleiro2[si],dl
	mov tab, 02

	lea di, Tabuleiro2
	jmp CONTINUA

Coluna3:
	cmp POSy,04h
	ja  Linha23
	
	Index_Array 16h,02h ;22 decimal
	mov Tabuleiro3[si],dl
	mov tab,03
	
	lea di, Tabuleiro3
	jmp CONTINUA
	
Linha22:
	cmp POSy,08h
	ja Linha32
	
	Index_Array 0dh,06h
	mov Tabuleiro5[si],dl
	mov tab,05
	
	lea di, Tabuleiro5
	jmp CONTINUA

Linha32:
	Index_Array 0dh,0ah
	mov Tabuleiro8[si],dl
	mov tab,08
	
	lea di, Tabuleiro8
	jmp CONTINUA

Linha23:
	cmp POSy,08h
	ja Linha33
	
	Index_Array 16h,06h
	mov Tabuleiro6[si],dl
	mov tab,06
	
	lea di, Tabuleiro6
	jmp CONTINUA
Linha33:
	Index_Array 16h,0ah
	mov Tabuleiro9[si],dl
	mov tab,09
	
	lea di, Tabuleiro9
	jmp CONTINUA

CONTINUA:		
	call LINHA
	call COLUNA
	call DIAGONAL
	call VERIFICAR_EMP
	jmp sair
	
sair:	
	
	ret
TABULEIRO endp

;Gera número aleatório
RANDOM proc
	
	call ESPERA
	mov ah,0h
	int 1ah ;hora do sistema-> cx high part clock count;dx low part clock count
	mov ax,dx ;interessa dx
	mov dx,0
	mov bx, 2 ;pq queremos um número entre 0 e 1 (logo são 2 números)
	div bx ;divide AX(oq estava no relógio (low)) por BX(2)
	mov num,dl ;resto=num aleatório
	
	ret
RANDOM endp

;Para não dar sempre 1, espera algum tempo (delay)

ESPERA proc
	mov cx,1
inicio:
	cmp cx,30000
	je fim
	inc cx
	jmp inicio
fim:
	ret
ESPERA endp

RANDOMXO proc
	
	call ESPERA
	mov ah,0h
	int 1ah ;hora do sistema-> cx high part clock count;dx low part clock count
	mov ax,dx ;interessa dx
	mov dx,0
	mov bx, 2 ;pq queremos um número entre 0 e 1 (logo são 2 números)
	div bx ;divide AX(oq estava no relógio (low)) por BX(2)
	cmp dl, 01
	mov cx, XO
	je  MOSTRAX
	jne MOSTRAO
	
MOSTRAX:
	mov GuardaX, 0158h
	mov GuardaO,024fh
	goto_xy 35,10
	lea dx, RegraJogador+2
	mov ah,09h
	int 21h
	
	goto_xy 43,10
	mov ah,02h
	mov dl, num
	add dl, '0'
	int 21h
	
	cmp num,02
	je NUMERO2
	jne NUMERO1
	
NUMERO2:
	sub num,02
	
NUMERO1:
	
	goto_xy 47,10
	mov ah,02h
	mov dl,ch
	int 21h
	
	goto_xy 35,11
	lea dx, RegraJogador+2
	mov ah,09h
	int 21h
	
	goto_xy 43,11
	inc num
	mov ah,02h
	mov dl, num
	add dl, '0'
	int 21h
	
	goto_xy 47,11
	mov ah,02h
	mov dl,cl
	int 21h
	
MOSTRAO:
	mov GuardaX, 0258h
	mov GuardaO,014fh
	goto_xy 33,10
	lea dx, RegraJogador
	mov ah,09h
	int 21h

	goto_xy 43,10
	mov ah,02h
	mov dl, num
	add dl, '0'
	int 21h
	
	cmp num,02
	je NUMERO2O
	jne NUMERO1O
	
NUMERO2O:
	sub num,02
	
NUMERO1O:
	goto_xy 47,10
	mov ah,02h
	mov dl,cl
	int 21h
	
	goto_xy 33,11
	lea dx, RegraJogador
	mov ah,09h
	int 21h
	
	goto_xy 43,11
	inc num
	mov ah,02h
	mov dl, num
	add dl, '0'
	int 21h
	
	goto_xy 47,11
	mov ah,02h
	mov dl,ch
	int 21h
fim:	
	ret
RANDOMXO endp
;Receber nome e mostrar nome do jogador
INTRO_NOME proc
mov cores,3fh
call COR_ECRA
	;Mostra mensagem inicial
	lea dx, NomeUm
	mov ah,09h
	int 21h
	;Lê input
	mov ah,0ah
	lea dx,NomeJogadorUm
	int 21h	
	;Mostra mensagem inicial
	goto_xy 5,3
	lea dx, NomeDois
	mov ah,09h
	int 21h
	
	;Lê input
	mov ah,0ah
	lea dx,NomeJogadorDois
	int 21h
	
	ret	
INTRO_NOME endp

Main  proc
	mov			ax, dseg
	mov			ds,ax
	
	mov			ax,0B800h
	mov			es,ax

inicio:	
	call apaga_ecran
	goto_xy	5,1
	
	mov cores,3fh
	call COR_ECRA
	lea dx,Menu ;lê menu	
	mov ah,09h ;mostra menu
	int 21h
	
ValidacaoMenu:
	call LE_TECLA
	sub al,48 ;tabela ascii 49->1, 50->2...
	cmp al,01h 
	je 	JOGA_1VS1
	cmp al,02h
	je  BONUS
	cmp	al,03h
	je	fim
	jne ValidacaoMenu

JOGA_1VS1:
	call apaga_ecran
	goto_xy		5,1
	call INTRO_NOME
	call apaga_ecran
	goto_xy    0,0
	call IMP_FICH
	call RANDOM
	inc num 
	call VezJogador
	call RANDOMXO
	call AVATAR
	
	cmp FlagEmpate, 01
	je MENSAGEMEMPATE
	CMP Flagjogo,00
	JE MensagemFinal
	jne fim
	
MensagemFinal:
	call apaga_ecran
	mov cores,3fh
	call COR_ECRA
	goto_xy 28,12
	mov ah,09h
	lea dx, VenceJogo	
	int 21h
	
	goto_xy 54,12
	mov ah,02h
	mov dl,num
	add dl,'0'
	int 21h
	
	call LE_TECLA
	jmp inicio
	
MENSAGEMEMPATE:
	call apaga_ecran
	mov cores,3fh
	call COR_ECRA
	goto_xy 28,12
	mov ah,09h
	lea dx, EmpateMensagem
	int 21h
	call LE_TECLA
	jmp inicio
BONUS:

fim:
	call apaga_ecran
	mov			ah,4CH
	int			21H
Main	endp
Cseg	ends
end	Main