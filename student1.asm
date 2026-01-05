assume cs:code, ds:data

; SEGMENTUL DE DATE
data segment

    ; Mesaj afisat utilizatorului inainte de citire
    ; '$' este obligatoriu pentru afisarea cu INT 21h / AH=09h
    mesajInput db 'Introduceti octeti hex (8-16 valori): $'

    ; Buffer DOS folosit pentru citire cu INT 21h / AH=0Ah
    ; Structura bufferului:
    ; buffer[0] = numarul maxim de caractere acceptate
    ; buffer[1] = numarul efectiv de caractere citite
    ; buffer[2...] = caracterele introduse de utilizator
    buffer db 50          ; maxim 50 caractere
           db ?           ; aici DOS va pune nr. de caractere citite
           db 50 dup(?)   ; zona unde se vor stoca caracterele

    ; Vectorul unde vom stoca octetii convertiti din HEX in BINAR
    ; Maxim 16 octeti conform cerinței
    sirOcteti db 16 dup(?)

    ; Variabila in care memoram lungimea reala a sirului
    ; (numărul de octeti introdusi)
    l db 0

data ends

; PROCEDURI DEFINITE IN ALTE FISIERE 
extern functions:proc                   
extern sortare_sir:proc                 
extern afisare_sir_sortat:proc
extern calculare_numar_maxim_octetii1:proc
extern afisare_octet_bit_1_maxim:proc


; SEGMENTUL DE COD
code segment

; PUNCTUL DE INTRARE AL PROGRAMULUI
start:

    ; Initializăm registrul DS cu adresa segmentului de date
    ; Făra asta, nu putem accesa variabilele declarate in data segment
    mov ax, data
    mov ds, ax

    ; AFISAREA MESAJULUI DE INTRODUCERE
    mov ah, 09h               ; functia DOS pentru afisare sir
    mov dx, OFFSET mesajInput ; DX = adresa mesajului
    int 21h                   ; apel intrerupere DOS


    ; CITIREA DE LA TASTATURĂ
    ; Utilizatorul introduce valori HEX separate prin spatiu
    mov ah, 0Ah               ; funcția DOS pentru citire cu buffer
    mov dx, OFFSET buffer     ; DX = adresa bufferului
    int 21h                   ; DOS completeaza bufferul


    ; PREGATIREA CONVERSIEI HEX -> BINAR

    ; SI va indica pozitia curenta in buffer
    ; Sarim peste primele 2 pozitii (lungime max + nr caractere)
    mov si, OFFSET buffer
    add si, 2

    ; DI va indica pozitia unde salvam octetii convertiti
    mov di, OFFSET sirOcteti

    ; CL = numarul de caractere citite
    mov cl, buffer[1]

    ; BX va fi contorul de octeti convertiti
    xor bx, bx                ; BX = 0


; BUCLE DE CONVERSIE ASCII HEX -> OCTET BINAR
convert:

    ; Daca nu mai sunt caractere de procesat, iesim
    cmp cl, 0
    je done

    ; Citim caracterul curent din buffer
    mov al, [si]

    ; Daca este spatiu, il ignoram
    cmp al, ' '
    je skip

   
    ; CONVERSIE PRIMUL CARACTER HEX 

    ; Convertim caracterul ASCII intr-o valoare 0..15
    call hexToNibble

    ; Mutam valoarea pe bitii superiori (biții 7..4)
    shl al, 4

    ; Salvam temporar rezultatul în AH
    mov ah, al

    ; Trecem la urmatorul caracter
    inc si
    dec cl


    ; CONVERSIE AL DOILEA CARACTER HEX 

    mov al, [si]              ; citim al doilea caracter
    call hexToNibble          ; il convertim în 0..15

    ; Combinam bitii superiori cu cei inferiori
    or ah, al


    ; SALVAREA OCTETULUI FINAL

    mov [di], ah              ; salvam octetul în sirOcteti
    inc di                    ; trecem la următoarea pozitie
    inc bx                    ; incrementam contorul de octeti


; SARIM PESTE SPATII ȘI CONTINUAM

skip:
    inc si
    dec cl
    jmp convert


; FINAL CONVERSIE

done:

    ; Salvam lungimea sirului (numarul de octeti)
    mov l, bl

    ; Pregatim registrele
    ; SI = adresa sirului
    ; CX = lungimea sirului
    mov si, OFFSET sirOcteti
    mov cx, bx


    ; APELAREA PROCEDURILOR COLEGILOR

    call functions
    call sortare_sir
    call afisare_sir_sortat
    call calculare_numar_maxim_octetii1
    call afisare_octet_bit_1_maxim


    ; TERMINAREA PROGRAMULUI

    mov ah, 4Ch
    int 21h

; SUBRUTINA hexToNibble
; Converteste:
; '0'..'9' -> 0..9
; 'A'..'F' -> 10..15

hexToNibble proc

    ; Daca caracterul este mai mic sau egal cu '9'
    cmp al, '9'
    jle digit

    ; Altfel este litera hexazecimala
    sub al, 'A'
    add al, 10
    ret

digit:
    sub al, '0'
    ret

hexToNibble endp


code ends
end start
