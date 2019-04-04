org 0x7e00
jmp 0x0000:main

white equ 15
green equ 10
blue equ 53
black equ 0
brown equ 6
red equ 12
yellow equ 14
pink equ 85

getchar:
  mov ah, 0x00
  int 16h
  ret

initVideo:
  mov al, 13h
  mov ah, 0
  int 10h
  ret

writePixel:
  mov ah, 0Ch 
  int 10h
  ret

putchar:
  mov ah, 0xe
  int 0x10
  ret

delay1s:                 ;Delay - 1sec
  mov cx, 0fh
  mov dx, 4240h
  mov ah, 86h
  int 15h
  ret

randomNum:
  mov AH, 00h  ;Interrupts to get system time        
  int 1AH      ;CX:DX now hold number of clock ticks since midnight      

  mov  ax, dx
  xor  dx, dx
  mov  cx, 37
  inc cx    
  div  cx       ;Here dx contains the remainder of the division - from 1 to 37
  mov [palavra], dx
  ret

printString:    ;Printa strings
  lodsb
  mov cl, 0
  cmp cl, al
  je .done
  
  mov ah, 0xe
  int 0x10
  jmp printString
  
  .done:
  ret

getchar2:
  .comeco:
    mov ah, 0x00
    int 16h         ;Armazena caracter em al

    cmp al, 65
    jl .comeco      ;Caracteres antes de 'A'
    cmp al, 122
    jg .comeco      ;Caracteres depois de 'z'
    cmp al, 90
    jg .verificachar    ;Verifica se está entre 'Z' e 'a'
    jmp .continua

  .viramaiuscula:
    sub al, 32
    jmp .continua

  .verificachar:
    cmp al, 97
    jl .comeco
    cmp al, 97
    jge .viramaiuscula

  .continua:
  mov cl, al        ;Caracter armazenado em cl
  call wordIs
  .loop1:
    lodsb           ;Armazena byte da string em al
    cmp al, 0       ;Check EOF(NULL)
    je .NAOACHOU
    cmp al, cl
    je .ACHOU
    jmp .loop1

  .NAOACHOU:
    mov [char], cl
    mov al, 0
    mov [ACHOULETRA], al  ;Variavel = 0 se nao achou
    jmp .endloop1

  .ACHOU:
    mov [char], cl
    mov al, 1
    mov [ACHOULETRA], al  ;Variavel = 1 se achou
    jmp .endloop1

  .endloop1:
  ret

stringLen:            ;Tamanho da string
  mov di, si				
	mov cx, 0
    .loop1:						
		  lodsb
		  cmp al, 0
		  je .endloop1

      inc cx
		  stosb
      jmp .loop1
	.endloop1:
  mov [len], cx       ;Guarda o tamanho em len
  ret

tracinho:             ;Printa n = [len] tracinhos
  call stringLen
  mov ax, 0
  mov bx, 58
  mov [cont], ax      ;Contador para printar um por um
  mov [xt], bx        ;Guarda posx onde vai printar o tracinho
  .forT:
    cmp ax, [len]
    je .endT

    mov cx, 28
    mov [color], cx
    mov cx, 18
    mov [largura], cx
    mov cx, 1
    mov [altura], cx
    add [xt], bx    ;Atualiza X
    mov cx, [xt]    ;X
    mov dx, 195     ;Y
    call drawBlock

    mov ax, [cont]
    inc ax
    mov [cont], ax
    mov bx, 23
    jmp .forT
  .endT:
  ret

drawBlock:
  mov al, [color]   ;Cor
  mov bx, dx
  add bx, [altura]  ;Altura

  .for1:
    cmp dx, bx
    je .endFor1

    push bx
    mov bx, cx
    add bx, [largura] ;Largura

    .for2:
      cmp cx, bx
      je .endFor2

      call writePixel ;Desenha pixel
      inc cx

      jmp .for2

    .endFor2:

    sub cx, [largura] ;Largura
    pop bx

    inc dx
    jmp .for1

  .endFor1:
  sub dx, [altura]    ;Altura
ret

copiaPalavra:
  call wordIs       ;si aponta para a palavra sorteada
  mov di, palavraX  ;di aponta para a palavra-copia
  .loop:
    lodsb           ;Carrega em al caracter da palavra sorteada
    stosb           ;Armazena o caracter em al na palavra-copia
    cmp al, 0       ;Só compara depois para tambem copiar o EOF
    je .endloop
    jmp .loop

  .endloop:
ret

func1:
  xor cl, cl
  mov si, palavraX  ;Mover si para o comeco da copia da palavra "sorteada" (palavraX)
  .loop1:
    cmp cl, [len]
    je .end         ;Finaliza se chega ao final da string
    mov di, si      ;di aponta para a letra que esta sendo lida na palavraX
    lodsb
    cmp al, [char]
    je .printa
    .back:
    inc cl
    jmp .loop1

  .printa:
    mov al, 32                ;Substitui a letra encontrada por espaço
    stosb

    mov al, [letrasAcertadas] ;Atualiza a quantidade de letras acertadas
    add al, 1
    mov [letrasAcertadas], al

    mov al, 3
    mul cl
    add al, 15
    mov  dl, al
    mov  dh, 23
    mov  bh, 0
    mov  bl, green
    mov  ah, 02h
    int  10h
    mov al, [char]
    call putchar
    jmp .back

  .end:
    ret

func2:
  mov si, erross
  .procuraEspaco:
    mov di, si ;Salva si antes do comando (o lodsb incrementa automaticamente o si)
    lodsb
    cmp al, 0
    je .continuando
    cmp al, 32
    je .LetraNaString
    jmp .procuraEspaco
  .LetraNaString:
  mov al, [char]
  stosb
  .continuando:
  mov al, 3
  mov cl, [erros]
  mul cl
  add al, 16
  mov  dl, al ;eixo x
  mov  dh, 10 ;eixo y
  mov  bh, 0
  mov  bl, red
  mov  ah, 02h
  int  10h
  mov al, [char]
  call putchar

  mov ax, [erros]

  cmp ax, 1
  je .1
  cmp ax, 2
  je .2
  cmp ax, 3
  je .3
  cmp ax, 4
  je .4
  cmp ax, 5
  je .5
  cmp ax, 6
  je .6


  .1: call printHead
      jmp .end
  .2: call printBody
      jmp .end
  .3: call printLeftArm
      jmp .end
  .4: call printRightArm
      jmp .end
  .5: call printLeftLeg
      jmp .end
  .6: call printRightLeg
      jmp .end

  .end:
ret

printApoio:           ;Printar o mastro da forca
  mov cx, brown
  mov [color], cx
  mov cx, 10
  mov [largura], cx
  mov cx, 130
  mov [altura], cx
  mov cx, 10
  mov dx, 20
  call drawBlock

  ;Superior
  mov cx, brown
  mov [color], cx
  mov cx, 50
  mov [largura], cx
  mov cx, 10
  mov [altura], cx
  mov cx, 10
  mov dx, 20
  call drawBlock

  ;Minor
  mov cx, brown
  mov [color], cx
  mov cx, 10
  mov [largura], cx
  mov cx, 10
  mov [altura], cx
  mov cx, 50
  mov dx, 30
  call drawBlock

  ;Corda
  mov cx, brown
  mov [color], cx
  mov cx, 2
  mov [largura], cx
  mov cx, 10
  mov [altura], cx
  mov cx, 54
  mov dx, 40
  call drawBlock
  ret


drawParalelogramR:
  mov al, [color]
  mov bx, dx
  add bx, [altura] ;Altura

  .for1:
    cmp dx, bx
    je .endFor1
    
    push bx

    inc cx

    mov bx, cx
    add bx, [largura] ;Largura

    .for2:

      cmp cx, bx
      je .endFor2

      call writePixel
      inc cx

      jmp .for2

    .endFor2:

    sub cx, [largura] ;Largura
    pop bx

    inc dx
    jmp .for1

  .endFor1:
  sub dx, [altura] ;Altura
ret


drawParalelogramL:
  mov al, [color]

  mov bx, dx
  sub bx, [altura] ;Altura

  .for1:

    cmp dx, bx
    jbe .endFor1
    
    push bx

    inc cx

    mov bx, cx
    add bx, [largura] ;Largura

    .for2:

      cmp cx, bx
      je .endFor2

      call writePixel
      inc cx

      jmp .for2

    .endFor2:

    sub cx, [largura] ;Largura
    pop bx

    dec dx
    jmp .for1

  .endFor1:
  sub dx, [altura] ;Altura
ret


;Funçoes de imprimir o boneco

printHead:
  ;Imprimir contorno
  mov cx, black
  mov [color], cx
  mov cx, 27
  mov [largura], cx
  mov cx, 22
  mov [altura], cx
  mov cx, 41
  mov dx, 49
  call drawBlock

  ;Cabeça
  mov cx, white
  mov [color], cx
  mov cx, 25
  mov [largura], cx
  mov cx, 20
  mov [altura], cx
  mov cx, 42
  mov dx, 50
  call drawBlock

  ;Olho esquerdo
  mov cx, black
  mov [color], cx
  mov cx, 2
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 49
  mov dx, 56
  call drawBlock

  ;Olho direito
  mov cx, black
  mov [color], cx
  mov cx, 2
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 58
  mov dx, 56
  call drawBlock

  ;Desenhar boca

  ;olho esquerdo
  mov cx, black
  mov [color], cx
  mov cx, 11
  mov [largura], cx
  mov cx, 3
  mov [altura], cx
  mov cx, 49
  mov dx, 62
  call drawBlock

  ret

printHeadBegin:
  ;Imprimir contorno
  mov cx, black
  mov [color], cx
  mov cx, 27
  mov [largura], cx
  mov cx, 22
  mov [altura], cx
  mov cx, 141
  mov dx, 77
  call drawBlock

  ;Cabeça
  mov cx, white
  mov [color], cx
  mov cx, 25
  mov [largura], cx
  mov cx, 20
  mov [altura], cx
  mov cx, 142
  mov dx, 78
  call drawBlock

  ;Olho esquerdo
  mov cx, black
  mov [color], cx
  mov cx, 2
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 149
  mov dx, 84
  call drawBlock

  ;Olho direito
  mov cx, black
  mov [color], cx
  mov cx, 2
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 158
  mov dx, 84
  call drawBlock

  ;desenhar boca

  ;Olho esquerdo
  mov cx, black
  mov [color], cx
  mov cx, 11
  mov [largura], cx
  mov cx, 3
  mov [altura], cx
  mov cx, 149
  mov dx, 90
  call drawBlock

  ret

printBody:
  ;Nó no pescoco
  mov cx, brown
  mov [color], cx
  mov cx, 7
  mov [largura], cx
  mov cx, 3
  mov [altura], cx
  mov cx, 51
  mov dx, 70
  call drawBlock

  ;Imprimir contorno
  mov cx, black
  mov [color], cx
  mov cx, 15
  mov [largura], cx
  mov cx, 42
  mov [altura], cx
  mov cx, 47
  mov dx, 73
  call drawBlock

  ;Tronco
  mov cx, pink
  mov [color], cx
  mov cx, 13
  mov [largura], cx
  mov cx, 40
  mov [altura], cx
  mov cx, 48
  mov dx, 74
  call drawBlock
  ret

printRightArm:
  ;Braço direito
  mov cx, pink
  mov [color], cx
  mov cx, 5
  mov [largura], cx
  mov cx, 16
  mov [altura], cx
  mov cx, 56
  mov dx, 74
  call drawParalelogramR

  mov cx, white
  mov [color], cx
  mov cx, 5
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 72
  mov dx, 90
  call drawBlock
  ret

printRightLeg:
  ;Perna direita
  mov cx, blue
  mov [color], cx
  mov cx, 5
  mov [largura], cx
  mov cx, 16
  mov [altura], cx
  mov cx, 53
  mov dx, 112
  call drawParalelogramR

  mov cx, brown
  mov [color], cx
  mov cx, 6
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 68
  mov dx, 126
  call drawBlock
  ret

printLeftArm:
  ;Braço esquerdo
  mov cx, pink
  mov [color], cx
  mov cx, 5
  mov [largura], cx
  mov cx, 16
  mov [altura], cx
  mov cx, 32
  mov dx, 89
  call drawParalelogramL

  mov cx, white
  mov [color], cx
  mov cx, 5
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 33
  mov dx, 90
  call drawBlock
  ret

printLeftLeg:
  ;Perna esquerda
  mov cx, blue
  mov [color], cx
  mov cx, 5
  mov [largura], cx
  mov cx, 16
  mov [altura], cx
  mov cx, 34
  mov dx, 126

  call drawParalelogramL

  ;Cintura da calca
  mov cx, blue
  mov [color], cx
  mov cx, 13
  mov [largura], cx
  mov cx, 5
  mov [altura], cx
  mov cx, 48
  mov dx, 109
  call drawBlock

  ;Sapato
  mov cx, brown
  mov [color], cx
  mov cx, 6
  mov [largura], cx
  mov cx, 2
  mov [altura], cx
  mov cx, 35
  mov dx, 125
  call drawBlock
  ret

screenBegin:
  ;Tela de inicio
  mov  dl, 10
	mov  dh, 3
	mov  bh, 0
	mov  bl, blue
	mov  ah, 02h
	int  10h

  mov si, title
  call printString
  call printHeadBegin

  mov  dl, 6
	mov  dh, 20
	mov  bh, 0
	mov  bl, blue
	mov  ah, 02h
	int  10h

  mov si, begin
  call printString

  .loopBegin:
    call getchar
    cmp al, 32
    je .endBegin

    jmp .loopBegin
  .endBegin:
ret


clear:            ;Limpa tela
    mov ah, 0x2
    mov dx, 0
    mov bh, 0
    int 10h

    mov al, 0x20
    mov ah, 0x9
    mov bh, 0
    mov cx, 1000
    int 10h

    mov bh, 0
    mov dx, 0
    mov ah, 0x2
    int 10h
ret


main:                       ;Incio do jogo
  mov ax, 0
  mov ds, ax
  mov es, ax
  mov [erros], ax           ;Zerar a quantidade de erros
  mov [letrasAcertadas], ax ;Zerar quantidade de letras acertadas
  call initVideo            ;Iniciar video
  call randomNum            ;Aleatorizar palavra
  mov al, [recomecou]
  cmp al, 1                 ;O jogo recomeçou?
  je .endnorestart

  ;Chamar tela de inicio
  .norestart:
    call screenBegin
    call clear
  .endnorestart:

  call wordIs               ;Mover palavra aleatoria para si
  call tracinho             ;Printar tracinhos
  call copiaPalavra         ;Copiar para palavraX


  ;Printar mastro
  call printApoio


  ;Printar string erros
  mov  dl, 24 ;eixo x
  mov  dh, 7 ;eixo y
  mov  bh, 0
  mov  bl, red
  mov  ah, 02h
  int  10h
  mov si, letrasErradas
  .loop1:
    lodsb
    cmp al, 0
    je .endloop1
    call putchar
    jmp .loop1
  .endloop1:

  ;Desenhar retangulo de letras erradas
  mov cx, red
  mov [color], cx
  mov cx, 150
  mov [largura], cx
  mov cx, 1
  mov [altura], cx
  mov cx, 140 ;eixo x
  mov dx, 70  ;eixo y
  call drawBlock

  mov cx, red
  mov [color], cx
  mov cx, 1
  mov [largura], cx
  mov cx, 30
  mov [altura], cx
  mov cx, 140 ;eixo x
  mov dx, 70  ;eixo y
  call drawBlock

  mov cx, red
  mov [color], cx
  mov cx, 150
  mov [largura], cx
  mov cx, 1
  mov [altura], cx
  mov cx, 140 ;eixo x
  mov dx, 99  ;eixo y
  call drawBlock

  mov cx, red
  mov [color], cx
  mov cx, 1
  mov [largura], cx
  mov cx, 30
  mov [altura], cx
  mov cx, 289 ;eixo x
  mov dx, 70  ;eixo y
  call drawBlock

  ;LOOP PARA LER CARACTERES E ATUALIZAR O JOGO
  .loop:
    call getchar2 ;Atualiza a variavel ACHOULETRA, a variavel [erros] e a variavel [char]
    mov al, [ACHOULETRA]
    cmp al, 1
    je .achou
    cmp al, 0
    je .naoachou

    .achou:
      call func1
      mov al, [letrasAcertadas]
      cmp al, [len] ;Todas as letras foram acertadas?
      je .endAchou
    jmp .loop

    .naoachou:
      ;CONFERE SE A LETRA JA FOI DIGITADA E CONTABILIZADA COMO ERRO ANTERIORMENTE
      mov si, erross  ;String com letras erradas
      .jaErrouEssaLetra:
        lodsb
        cmp al, 0
        je .continua
        cmp al, [char]
        je .loop
        jmp .jaErrouEssaLetra
      .continua:
      mov al, 1
      add [erros], al
      call func2
      mov al, [erros]
      cmp al, 6       ;Atingiu a quant. máxima de erros?
      je .endNaoachou
    jmp .loop

    .endAchou:
      call delay1s
      call clear
      mov  dl, 16 ;eixo x
      mov  dh, 7  ;eixo y
      mov  bh, 0
      mov  bl, green
      mov  ah, 02h
      int  10h
      mov si, ganhou
      call printString

      mov  dl, 2  ;eixo x
      mov  dh, 10 ;eixo y
      mov  bh, 0
      mov  bl, white
      mov  ah, 02h
      int  10h
      mov si, playagain
      call printString
      .leEspaco:
        call getchar
        cmp al, 32
        je .restart
        jmp .leEspaco
      jmp .end
      .restart:
        mov al, 1
        mov [recomecou], al
        call clear
        ;PREENCHER STRING ERROSS COM ESPACOS ANTES DA PROXIMA PARTIDA 
        mov si, erross
        .zeraErross:
          mov di, si
          lodsb
          cmp al, 0
          je .fim
          mov al, 32
          stosb
          jmp .zeraErross
        .fim:
        jmp main

    .endNaoachou:
      call delay1s
      call clear
      mov  dl, 10 ;eixo x
      mov  dh, 7  ;eixo y
      mov  bh, 0
      mov  bl, red
      mov  ah, 02h
      int  10h
      mov si, perdeu
      call printString

      mov  dl, 16 ;eixo x
      mov  dh, 9  ;eixo y
      mov  bh, 0
      mov  bl, yellow
      mov  ah, 02h
      int  10h
      call wordIs
      call printString

      mov  dl, 2  ;eixo x
      mov  dh, 22 ;eixo y
      mov  bh, 0
      mov  bl, white
      mov  ah, 02h
      int  10h
      mov si, playagain
      call printString

      .leEspaco2:
        call getchar
        cmp al, 32
        je .restart
        jmp .leEspaco2
      jmp .end
      .restart2:
        mov al, 1
        mov [recomecou], al
        call clear
        ;PREENCHER STRING ERROSS COM ESPACOS ANTES DA PROXIMA PARTIDA 
        mov si, erross
        .zeraErross2:
          mov di, si
          lodsb
          cmp al, 0
          je .fim
          mov al, 32
          stosb
          jmp .zeraErross
        .fim2:
        jmp main
  .end:

  jmp $

wordIs:       ;Move a palavra aleatorizada para si
  mov ax, [palavra]

  cmp ax, 1
  je .1
  cmp ax, 2
  je .2
  cmp ax, 3
  je .3
   cmp ax, 4
  je .4
  cmp ax, 5
  je .5
  cmp ax, 6
  je .6
  cmp ax, 7
  je .7
   cmp ax, 8
  je .8
  cmp ax, 9
  je .9
  cmp ax, 10
  je .10
  cmp ax, 11
  je .11
   cmp ax, 12
  je .12
  cmp ax, 13
  je .13
  cmp ax, 14
  je .14
  cmp ax, 15
  je .15
   cmp ax, 16
  je .16
  cmp ax, 17
  je .17
  cmp ax, 18
  je .18
  cmp ax, 19
  je .19
   cmp ax, 20
  je .20
  cmp ax, 21
  je .21
  cmp ax, 22
  je .22
  cmp ax, 23
  je .23
   cmp ax, 24
  je .24
  cmp ax, 25
  je .25
  cmp ax, 26
  je .26
  cmp ax, 27
  je .27
   cmp ax, 28
  je .28
  cmp ax, 29
  je .29
  cmp ax, 30
  je .30
  cmp ax, 31
  je .31
  cmp ax, 32
  je .32
  cmp ax, 33
  je .33
  cmp ax, 34
  je .34
  cmp ax, 35
  je .35
  cmp ax, 36
  je .36
  cmp ax, 37
  je .37

  .1: mov si, palavra1
      jmp .endword
  .2: mov si, palavra2
      jmp .endword
  .3: mov si, palavra3
      jmp .endword
  .4: mov si, palavra4
      jmp .endword
  .5: mov si, palavra5
      jmp .endword
  .6: mov si, palavra6
      jmp .endword
  .7: mov si, palavra7
      jmp .endword
  .8: mov si, palavra8
      jmp .endword
  .9: mov si, palavra9
      jmp .endword
  .10: mov si, palavra10
      jmp .endword
  .11: mov si, palavra11
      jmp .endword
  .12: mov si, palavra12
      jmp .endword
  .13: mov si, palavra13
      jmp .endword
  .14: mov si, palavra14
      jmp .endword
  .15: mov si, palavra15
      jmp .endword
  .16: mov si, palavra16
      jmp .endword
  .17: mov si, palavra17
      jmp .endword
  .18: mov si, palavra18
      jmp .endword
  .19: mov si, palavra19
      jmp .endword
  .20: mov si, palavra20
      jmp .endword
  .21: mov si, palavra21
      jmp .endword
  .22: mov si, palavra22
      jmp .endword
  .23: mov si, palavra23
      jmp .endword
  .24: mov si, palavra24
      jmp .endword
  .25: mov si, palavra25
      jmp .endword
  .26: mov si, palavra26
      jmp .endword
  .27: mov si, palavra27
      jmp .endword
  .28: mov si, palavra28
      jmp .endword
  .29: mov si, palavra29
      jmp .endword
  .30: mov si, palavra30
      jmp .endword
  .31: mov si, palavra31
      jmp .endword
  .32: mov si, palavra32
      jmp .endword
  .33: mov si, palavra33
      jmp .endword
  .34: mov si, palavra34
      jmp .endword
  .35: mov si, palavra35
      jmp .endword
  .36: mov si, palavra36
      jmp .endword
  .37: mov si, palavra37
      jmp .endword

  .endword:
  ret

data:                   ;Guarda os dados necessarios para o jogo

  largura dw 0
  altura dw 0
  color dw 0
  ACHOULETRA dw 0
  palavra dw 0
  erros dw 0
  char dw 0
  len dw 0
  cont dw 0
  xt dw 0
  letrasAcertadas dw 0
  recomecou dw 0

  erross db '      ', 0 ;Guarda as letras ja erradas para nao contabilizar mais de uma vez
  letrasErradas db 'erros', 0
  title db 'WILL YOU SAVE SAM?', 0
  ganhou db 'Acertou!', 0
  perdeu db 'Errou! a palavra era:', 0
  playagain db 'Pressione espaco para jogar novamente', 0
  begin db 'Aperte [espaco] para jogar', 0
  
  ;Palavras do jogo:
  palavra1 db 'CARACOL', 0
  palavra2 db 'LARANJA', 0
  palavra3 db 'DEMONIO', 0
  palavra4 db 'ESQUERDA', 0
  palavra5 db 'ABDUZIR', 0
  palavra6 db 'MACHISMO', 0
  palavra7 db 'OBSERVAR', 0
  palavra8 db 'ANCORA', 0
  palavra9 db 'CONCAVO', 0
  palavra10 db 'IMPERIO', 0
  palavra11 db 'OVULOS', 0
  palavra12 db 'CAIPIRA', 0
  palavra13 db 'ABACAXI', 0
  palavra14 db 'FRASCO', 0
  palavra15 db 'GAIVOTA', 0
  palavra16 db 'CONJUGE', 0
  palavra17 db 'COBALTO', 0
  palavra18 db 'ARQUITETO', 0
  palavra19 db 'CAMPAINHA', 0
  palavra20 db 'TEOCRACIA', 0
  palavra21 db 'CRUSTACEO', 0
  palavra22 db 'SACO', 0
  palavra23 db 'TREM', 0
  palavra24 db 'ISCA', 0
  palavra25 db 'CARDUME', 0
  palavra26 db 'ACNE', 0
  palavra27 db 'ESMALTE', 0
  palavra28 db 'COENTRO', 0
  palavra29 db 'GARFO', 0
  palavra30 db 'GURU', 0
  palavra31 db 'VIGIADA', 0
  palavra32 db 'ABAFAR', 0
  palavra33 db 'MEDULA', 0
  palavra34 db 'QUIABO', 0
  palavra35 db 'PARADOXO', 0
  palavra36 db 'TRAJETO', 0
  palavra37 db 'CARNAVAL', 0

  palavraX db 'AAAAAAAAA', 0
