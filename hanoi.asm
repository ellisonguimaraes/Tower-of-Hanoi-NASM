;
;   By: Ellison William M. Guimarães - 201620215
;
;   $ nasm -f elf -F stabs hanoi.asm
;   $ ld -m elf_i386 -s -o ha hanoi.o
;   $ ./ha
;    
;    Variáveis usada para resolução de hanoi:
;        rod:        Quatidade de discos
;        from_rod:   Origem
;        to_rod:     Destino
;        aux_rod:    Auxiliar
;


section .data
    ;CONSTANTES DE ORIENTAÇÃO
    SYS_WRITE:  equ 4
    STD_OUT:    equ 1
    SYS_READ:  equ 3
    STD_IN:    equ 1


    ;VARIÁVEIS DA FUNÇÃO DE HANOI (N, de, para, aux) JÁ ATRIBUIDAS
    rod:        dd 0x33 ;Quantidade de discos
    from_rod:   dd 0x31 ;Vai da primeira estaca
    to_rod:     dd 0x33 ;Para o terceiro
    aux_rod:    dd 0x32 ;Usando o segundo como aux

    ;Auxilia na impressão dos dados na pilha
    auxiliar:   dd 0x0

    ;MENSAGENS
    msgpt1: db 0xa, "Mover disco ", 0
    msgpt1_len: equ $-msgpt1

    msgpt2: db " da estaca ", 0
    msgpt2_len: equ $-msgpt2

    msgpt3: db " para a ", 0
    msgpt3_len: equ $-msgpt3

    signal: db "*", 0
    signallen: equ $-signal

    linebreak: db 0xA
    linebreak_len: equ $-linebreak


section .text
    global _start
    %macro print 2
		mov		eax, SYS_WRITE
		mov		ebx, STD_OUT
		mov		ecx, %1
		mov		edx, %2
		syscall
	%endmacro


_start:
    ;Criando um novo quadro de pilha com 16 bytes
    push ebp
    mov ebp, esp
    sub esp, 0x10

    ;Atribuindo as variáveis ao quadro de pilhas
    mov eax, [rod]
    mov dword[ebp-0x4], eax
    mov eax, [from_rod]
    mov dword[ebp-0x8], eax
    mov eax, [to_rod]
    mov dword[ebp-0xC], eax
    mov eax, [aux_rod]
    mov dword[ebp-0x10], eax

    ;Primeira chamada
    call hanoi


    print linebreak, linebreak_len


    ;Remove a pilha e volta para o quadro de pilha anterior (sistema)
    mov esp, ebp
    pop ebp

    ;Termina o programa
    mov eax, 1
    mov ebx, 0
    int 0x80


hanoi:
    ;Verificando se o número de discos é = 1
    mov eax, 0x31
    cmp eax, dword[ebp-0x4]
    je printHanoi ;Se sim, printa na tela.

    ;Movendo variáveis da pilha para os registradores, para ser pegos dentro do novo quadro de pilha
    mov eax, dword[ebp-0x4]
    mov ebx, dword[ebp-0x8]
    mov ecx, dword[ebp-0xC]
    mov edx, dword[ebp-0x10]


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; CRIANDO NOVO QUADRO DE PILHA PARA A PRIMEIRA RECURSÃO ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push ebp
    mov ebp, esp
    sub esp, 0x10

    ;Decrementando N na pilha (n-1) e atribuindo os valores(invertido) para a nova pilha/CHAMADA
    dec eax
    mov dword[ebp-0x4], eax
    mov dword[ebp-0x8], ebx
    mov dword[ebp-0xC], edx
    mov dword[ebp-0x10], ecx
    
    ;Primeira recursão
    call hanoi

    ;Remove a pilha e volta para o quadro de pilha anterior
    mov esp, ebp
    pop ebp

    ;Printa na tela
    call printsignal
    call printHanoi


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; CRIANDO NOVO QUADRO DE PILHA PARA A SEGUNDA RECURSÃO ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push ebp
    mov ebp, esp
    sub esp, 0x10

    ;Decrementando N na pilha (n-1) e atribuindo os valores(invertido) para a nova pilha/CHAMADA
    dec eax
    mov dword[ebp-0x4], eax
    mov dword[ebp-0x8], edx
    mov dword[ebp-0xC], ecx
    mov dword[ebp-0x10], ebx
    
    ;Segunda recursão
    call hanoi

    ;Remove a pilha e volta para o quadro de pilha anterior
    mov esp, ebp
    pop ebp


    ret



printHanoi:
    print msgpt1, msgpt1_len    ;Imprime "Mover disco "

    mov eax, dword[ebp-0x4]     ;Acessa a qtd de disco (N)
    mov [auxiliar], eax         
    print auxiliar, 1           ;Imprime N

    print msgpt2, msgpt2_len    ;Imprime " da estaca "

    mov eax, dword[ebp-0x8]     ;Acessa o from_rod
    mov [auxiliar], eax
    print auxiliar, 1           ;Imprime from_rod

    print msgpt3, msgpt3_len    ;Imprime " para a "

    mov eax, dword[ebp-0xC]     ;Acessa o to_rod
    mov [auxiliar], eax
    print auxiliar, 1           ;Imprime o to_rod

    ;Restaurando registradores
    mov eax, dword[ebp-0x4]
    mov ebx, dword[ebp-0x8]
    mov ecx, dword[ebp-0xC]
    mov edx, dword[ebp-0x10]

    ret



;FUNÇÃO INDIFERENTE.
printsignal:
    mov eax, SYS_WRITE
    mov ebx, STD_OUT
    mov ecx, signal
    mov edx, signallen
    int 0x80

    ret


