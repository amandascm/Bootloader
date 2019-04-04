org 0x500
jmp 0x0000:start

start:
    mov bl, 14
    call clear

    call initVideo    ;Iniciar modo de video

    mov si, loading1
    mov  dl, 13        ;Eixo x
    mov  dh, 7        ;Eixo y
    mov  bh, 0
    mov  bl, 14
    mov  ah, 02h
    int  10h
    call delay100ms  ;Espera
    call printString ;Printar carregamento

    mov ax, 0
    mov [cont], ax

    .loop1:            ;Carregar kernel
      cmp ax, 3
      je .end1
      inc ax
      mov [cont], ax
      call printDots  ;Carregando
      mov ax, [cont]
      jmp .loop1
    .end1:


    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ax, 0x7e0 ;0x7e0<<1 = 0x7e00 (início de kernel.asm)
    mov es, ax
    xor bx, bx    ;Posição es<<1+bx

    jmp reset

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

      call writePixel ;Desenhar pixel
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

writePixel:           ;Desenhar pixel
  mov ah, 0Ch 
  int 10h
  ret

printDots:            ;Printar pontos de carregamento
    mov cx, 14
    mov [color], cx
    mov cx, 15
    mov [largura], cx
    mov cx, 15
    mov [altura], cx
    mov cx, 120    ;X
    mov dx, 85     ;Y
    call drawBlock
    call delay100ms
    call delay100ms
    call delay100ms
    

    mov cx, 0
    mov [color], cx
    mov cx, 15
    mov [largura], cx
    mov cx, 15
    mov [altura], cx
    mov cx, 120    ;X
    mov dx, 85     ;Y
    call drawBlock
    call delay100ms
    call delay100ms
    call delay100ms

    mov cx, 14
    mov [color], cx
    mov cx, 15
    mov [largura], cx
    mov cx, 15
    mov [altura], cx
    mov cx, 150    ;X
    mov dx, 85     ;Y
    call drawBlock
    call delay100ms
    call delay100ms
    call delay100ms


    mov cx, 0
    mov [color], cx
    mov cx, 15
    mov [largura], cx
    mov cx, 15
    mov [altura], cx
    mov cx, 150    ;X
    mov dx, 85     ;Y
    call drawBlock
    call delay100ms
    call delay100ms
    call delay100ms


    mov cx, 14
    mov [color], cx
    mov cx, 15
    mov [largura], cx
    mov cx, 15
    mov [altura], cx
    mov cx, 180    ;X
    mov dx, 85     ;Y
    call drawBlock
    call delay100ms
    call delay100ms
    call delay100ms


    mov cx, 0
    mov [color], cx
    mov cx, 15
    mov [largura], cx
    mov cx, 15
    mov [altura], cx
    mov cx, 180    ;X
    mov dx, 85     ;Y
    call drawBlock
    call delay100ms
    call delay100ms
    call delay100ms

ret

initVideo:          ;Iniciar modo video
  mov al, 13h
  mov ah, 0
  int 10h
  ret

delay100ms:         ;Delay de 0.1sec
  mov cx, 01h
  mov dx, 86a0h
  mov ah, 86h
  int 15h
  ret

printString:        ;Printar string
  lodsb
  cmp al, 0
  je .done

  mov ah, 0xe
  int 0x10
  jmp printString
  
  .done:
ret

clear:              ;Limpar tela
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

reset:
    mov ah, 00h   ;Reseta o controlador de disco
    mov dl, 0     ;Floppy disk
    int 13h

    jc reset      ;Se o acesso falhar, tenta novamente

    jmp load

load:
    mov ah, 02h   ;Lê um setor do disco
    mov al, 20    ;Quantidade de setores ocupados pelo kernel
    mov ch, 0     ;Track 0
    mov cl, 3     ;Sector 3
    mov dh, 0     ;Head 0
    mov dl, 0     ;Drive 0
    int 13h

    jc load       ;Se o acesso falhar, tenta novamente

    jmp 0x7e00    ;Pula para o setor de endereco 0x7e00 (inicio do kernel)

data: 

loading1 db 'LOADING KERNEL', 0
largura dw 0
altura dw 0
color dw 0
cont dw 0