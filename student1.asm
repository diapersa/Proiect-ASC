assume cs:code, ds:data

data segment

    ; mesaj afisat utilizatorului
    mesajInput db 'Introduceti octeti hex (8-16 valori): $'

    ; buffer DOS pentru citire cu INT 21h / AH = 0Ah
    ; buffer[0] = numar maxim caractere
    ; buffer[1] = numar caractere citite
    ; buffer[2...] = caracterele introduse
    buffer db 50
           db ?
           db 50 dup(?)

    ; sirul in care stocam octetii convertiti (max 16)
    sirOcteti db 16 dup(?)

    ; lungimea sirului (numarul de octeti cititi)
    l db 0

data ends


; PROCEDURI DEFINITE IN ALTE FISIERE 

extern functions:proc                   
extern sortare_sir:proc                 
extern afisare_sir_sortat:proc
extern calculare_numar_maxim_octetii1:proc
extern afisare_octet_bit_1_maxim:proc


; SEGMENTUL DE COD – MAIN

code segment

start:
    ; initializam segmentul de date
    mov ax, data
    mov ds, ax

    ; Afisam mesajul de introducere
    mov ah, 09h
    mov dx, OFFSET mesajInput
    int 21h

    ; Citim sirul de caractere de la tastatura
    ; folosind INT 21h / AH = 0Ah
    mov ah, 0Ah
    mov dx, OFFSET buffer
    int 21h

    ; Pregatire conversie HEX -> BINAR
    ; SI -> primul caracter din buffer
    ; DI -> unde salvam octetii convertiti
    ; CL -> numar caractere citite
    ; BX -> contor octeti
    
    mov si, OFFSET buffer
    add si, 2                 ; sarim peste primele 2 pozitii din buffer

    mov di, OFFSET sirOcteti
    mov cl, buffer[1]
    xor bx, bx                ; bx = 0

; BUCLE DE CONVERSIE ASCII HEX -> OCTET BINAR

convert:
    ; daca nu mai avem caractere, iesim
    cmp cl, 0
    je done

    ; luam caracterul curent
    mov al, [si]

    ; daca este spatiu, il sarim
    cmp al, ' '
    je skip

    ; conversie primul caracter hex (HIGH nibble)

    call hexToNibble          ; AL = valoare 0..15
    shl al, 4                 ; mutam pe nibble-ul superior
    mov ah, al                ; salvam temporar in AH

    inc si                    ; trecem la urmatorul caracter
    dec cl

  
    ; conversie al doilea caracter hex (LOW nibble)
   
    mov al, [si]
    call hexToNibble
    or ah, al                 ; combinam cei doi nibble

   
    ; salvam octetul rezultat in sir
   
    mov [di], ah
    inc di                    ; urmatoarea pozitie in sir
    inc bx                    ; incrementam numarul de octeti


; Sarim peste spatii

skip:
    inc si
    dec cl
    jmp convert

; FINAL CONVERSIE

done:
    ; salvam lungimea sirului
    mov l, bl

    ; pregatim registrele 
    ; SI = adresa sirului
    ; CX = lungimea sirului
    mov si, OFFSET sirOcteti
    mov cx, bx

    ; Apel proceduri 
    
    call functions
    call sortare_sir
    call afisare_sir_sortat
    call calculare_numar_maxim_octetii1
    call afisare_octet_bit_1_maxim

    ; Terminarea programului
    mov ah, 4Ch
    int 21h


; SUBRUTINA: conversie caracter HEX -> valoare 0..15

hexToNibble proc
    ; daca este cifra '0'..'9'
    cmp al, '9'
    jle digit

    ; daca este litera 'A'..'F'
    sub al, 'A'
    add al, 10
    ret

digit:
    sub al, '0'
    ret
hexToNibble endp


code ends
end start
