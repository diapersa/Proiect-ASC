assume cs:code, ds:data

; SEGMENTUL DE DATE
data segment
    ; STUDENT 1

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
    ; Maxim 16 octeti conform cerintei
    sirOcteti db 16 dup(?)

    ; Variabila in care memoram lungimea reala a sirului
    ; (numarul de octeti introdusi)
    l db 0

    ; STUDENT 2
    ; pentru cuvantul C
    C dw ?

    mesajAfisBinar db 'Cuvantul C in binar: $'
    mesajAfisHex db 'Cuvantul C in hex: $'

    LinieNoua db 13, 10, '$'
    tabela db '0123456789ABCDEF'

    ; pentru sir rotit
    sum dw ?
    sirRotire db 16 dup(?)
    N db ?
    
    mesajAfisBinarSir db 'Sirul rotit in binar: $'
    mesajAfisHexSir db 'Sirul rotit in hex: $'

    ; STUDENT 3
    lungime dw ?
    zece dw 10
    pozitie_octet db ?
    randNou db 13,10,'$'
    mesajSortat db 13,10,'Sirul sortat este : ',13,10,'$'
    nrMaxim_octetii1 db 0
    pozitie_numar_maxim_octetii1 dw ?
    mesajOctetBiti1Maxim db 13,10,'Octetul cu numar maxim de biti 1 este : ', 13,10,'$'
    mesajPozitieMaxim db 13,10,'Pozitia acestuia in sir este : ',13,10,'$'


data ends

; SEGMENTUL DE COD
code segment

; PUNCTUL DE INTRARE AL PROGRAMULUI
start:  

    ; functionalitati student 1 - Bianca

    ; Initializam registrul DS cu adresa segmentului de date
    ; Fara asta, nu putem accesa variabilele declarate in data segment
    mov ax, data
    mov ds, ax

    ; AFISAREA MESAJULUI DE INTRODUCERE
    mov ah, 09h               ; functia DOS pentru afisare sir
    mov dx, OFFSET mesajInput ; DX = adresa mesajului
    int 21h                   ; apel intrerupere DOS


    ; CITIREA DE LA TASTATURA
    ; Utilizatorul introduce valori HEX separate prin spatiu
    mov ah, 0Ah               ; functia DOS pentru citire cu buffer
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

    ; Mutam valoarea pe bitii superiori (bitii 7..4)
    shl al, 4

    ; Salvam temporar rezultatul in AH
    mov ah, al

    ; Trecem la urmatorul caracter
    inc si
    dec cl


    ; CONVERSIE AL DOILEA CARACTER HEX 

    mov al, [si]              ; citim al doilea caracter
    call hexToNibble          ; il convertim in 0..15

    ; Combinam bitii superiori cu cei inferiori
    or ah, al


    ; SALVAREA OCTETULUI FINAL

    mov [di], ah              ; salvam octetul in sirOcteti
    inc di                    ; trecem la urmatoarea pozitie
    inc bx                    ; incrementam contorul de octeti
    ; jmp convert


; SARIM PESTE SPATII SI CONTINUAM

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

    call calculateWord
    call printWord
    call rotateByte
    call printBinary
    call printHex

    call sortare_sir
    call afisare_sir_sortat
    call calculare_numar_maxim_octetii1
    call afisare_octet_bit_1_maxim


    ; TERMINAREA PROGRAMULUI

    mov ax, 4C00h
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

; functionalitati student2 - Diana

calculateWord PROC
    ; in data segment in main
    ; si - inceputul sirului
    ; l - nr de bytes

    mov C, 0    ; stocam rezultatul final

    push ax
    push bx
    push dx

    xor ax, ax
    xor bx, bx
    xor dx, dx

    push cx ; salvam contorul original
    push si ; salvam offset ul sirului original
    push di
    
    ; Pas 1: XOR intre primii 4 biti ai primului octet si ultimii 4 biti ai ultimului octet

    mov al, [si]    ; primul octet din sir
    and al, 00001111b   ; izolam bitii 0-3 
    mov bl, al  ; stocam bitii 0-3 

    mov di, si          ; dx = offset ul sirului 
    add di, cx            ; di = adresa finala
    dec di              ; di = l-1
    mov al, [di]   ; ultimul byte

    ; mov al, [si + l - 1]    ; ultimul byte

    and al, 11110000b   ; bitii 4-7 
    shr al, 4   ; mutam in bitii 0-3

    xor al, bl  ; xor -> bitii 0-3 in al

    ; Pas 2 + Pas 3: OR intre bitii 2-5 din fiecare octet

    xor bx, bx
    xor dx, dx

    mov bl, [si]   ; primul octet 
    and bl, 00111100b   ; izolam bitii 2-5 
    
    mov sum, 0
    mov dh, 0
    mov dl, [si]    ; primul octet
    add sum, dx  

    inc si

    sub cx, 1   ; primul octet a fost parcurs

repeta:
    mov dh, 0
    mov dl, [si]    ; octet curent
    add sum, dx 

    mov bh, dl    ; octet curent
    and bh, 00111100b   ; bitii 2-5
    or bl, bh

    inc si      ; trecem la urm octet
    loop repeta


    shl bl, 2   ; deplasare spre stg pt a ajunge la bitii 4-7 ai lui C
    or al, bl   ; al = pas1 + pas2

    ; Pas 3: suma octetilor modulo 256 -> ah
    
    mov ah, byte ptr sum     ; pastram 8 biti
    ; ax = ah:al -> C
    mov C, ax   ; salvam rez final

    pop di
    pop si  ; restauram si original
    pop cx  ; restauram cx original

    ; restauram toti registrii 
    pop dx
    pop bx
    pop ax

    ret
calculateWord ENDP

;print word C
printWord PROC
    ; afisare in binar a lui C + hexa

    push cx     ; pastram contorul initial
    push ax
    push bx
    push dx

    ; linie noua
    mov ah, 09h
    mov dx, offset LinieNoua
    int 21h

    ; 1) afisare in binar
    ; afisare mesaj
    mov ah, 09h
    mov dx, offset mesajAfisBinar
    int 21h

    ; linie noua
    mov ah, 09h
    mov dx, offset LinieNoua
    int 21h

    mov bx, C
    mov cx, 16  ; 16 deplasari spre stanga

    repeatAfisC:
        shl bx, 1
        jc unu

        mov ah, 02h
        mov dl, '0'
        int 21h

        loop repeatAfisC
        jmp endPrint1

    unu:
        mov ah, 02h
        mov dl, '1'
        int 21h
        loop repeatAfisC

    endPrint1:
        mov ah, 09h
        mov dx, offset LinieNoua
        int 21h


    ; 2) afisare in hex a lui C

    ; linie noua
    mov ah, 09h
    mov dx, offset LinieNoua
    int 21h

    ; afisare mesaj
    mov ah, 09h
    mov dx, offset mesajAfisHex
    int 21h

    ; linie noua
    mov ah, 09h
    mov dx, offset LinieNoua
    int 21h

    mov ax, C
    mov cx, 4   ; numarul de grupri de cate 4 biti ale cuv C

    repeat16:
        mov dx, 0
        push cx

        mov cx, 4   ; numar de biti care formeaza o cifra hexa

        repeat4:
            rol ax, 1
            rcl dx, 1
            loop repeat4
        
        pop cx
        push ax

        mov al, dl
        mov bx, offset tabela
        xlat tabela

        mov dl, al
        mov ah, 02h
        int 21h

        pop ax  ; restaurare valoare ax
        loop repeat16
        
    ; linie noua
    mov ah, 09h
    mov dx, offset LinieNoua
    int 21h

    pop dx
    pop bx
    pop ax
    pop cx      ; restauram valoarea contorului original

    ret
printWord ENDP

rotateByte PROC
    ; cx deja contine lungimea sirului
    push di
    push ax
    push bx

    mov di, offset sirRotire
    push cx     ; salvam contorul original
    push si     ; offset-ul adresei sirului 

    repeta3:
        mov N, 0  

        mov al, [si]    ; octet curent
        mov bl, al
        and bl, 00000001b   ; primul bit
        shr al, 1
        and al, 00000001b   ; al doilea bit
        add al, bl

        mov N, al   

        mov al, [si]

        push cx     ; salvam contorul
        mov cl, N
        rol al, cl   ; rotire spre stanga cu N pozitii
        pop cx      ; restauram cx

        mov [di], al

        inc di
        inc si

        loop repeta3

    pop si
    pop cx
    pop bx
    pop ax
    pop di

    ret
rotateByte ENDP


printBinary PROC
    push si        ; salvam offset ul sirului 
    push cx        ; salvam contorul original
    push ax
    push bx
    push dx

    mov si, offset sirRotire

    ; linie noua
    mov ah, 09h ; functie afisare sir
    mov dx, offset LinieNoua
    int 21h

    ; afisare mesaj
    mov ah, 09h
    mov dx, offset mesajAfisBinarSir
    int 21h

    ; linie noua
    mov ah, 09h ; functie afisare sir
    mov dx, offset LinieNoua
    int 21h

    repeat:
        mov bl, [si]    ; octet curent
        push cx
        mov cl, 8       ; pt configuratia binara a unui octet - 8 biti

    repeat2:
        shl bl, 1
        jc one  ; CF = 1 -> sare la eticheta one
                ; CF = 0 -> afisam '0'
        mov ah, 02h ; functie pt afisarea caracterelor
        mov dl, '0' ; codul ascii al car. de afisat
        int 21h     ; declanseaza afisarea car. 

        loop repeat2
        jmp endPrint
    one:
        mov ah, 02h
        mov dl, '1'
        int 21h
        loop repeat2

    endPrint:
        mov ah, 02h ; functie afisare caracter
        mov dl, ' ' ; cod ASCII pentru spatiu
        int 21h     ; afiseaza caracterul

    pop cx
    inc si
    loop repeat

    pop dx
    pop bx
    pop ax
    pop cx
    pop si  ; restauram adresa originala a sirului

    ; linie noua
    mov ah, 09h ; functie afisare sir
    mov dx, offset LinieNoua
    int 21h

    ret
printBinary ENDP


printHex PROC
    push si         ; salvam offset ul sirului
    push cx         ; salvam contorul original
    push ax
    push bx
    push dx

    mov si, offset sirRotire

    ; linie noua
    mov ah, 09h ; functie afisare sir
    mov dx, offset LinieNoua
    int 21h

    ; afisare mesaj
    mov ah, 09h
    mov dx, offset mesajAfisHexSir
    int 21h

    ; linie noua
    mov ah, 09h ; functie afisare sir
    mov dx, offset LinieNoua
    int 21h

    repeatHex:
        mov ah, [si]    ; octet curent
        push cx
        mov cl, 2   ; numarul de grupuri de cate 4 biti ale byte-ului bl

        repeat16_2:
        mov dl, 0   ; folosim dl pt izolarea grupului de 4 biti
        push cx

        mov cx, 4   ; nr de biti ce formeaza o cifra hexa

        repeat4_2:
            rol ah, 1
            rcl dl, 1
            loop repeat4_2

        pop cx  ; restauram cx pt bucla repeat16_2

        push ax

        mov al, dl
        mov bx, offset tabela
        xlat tabela

        mov dl, al
        mov ah, 02h
        int 21h

        pop ax
        loop repeat16_2

        
        mov ah, 02h ; functie afisare caracter
        mov dl, ' ' ; cod ASCII pentru spatiu
        int 21h     ; afiseaza caracterul

        inc si
        pop cx
        loop repeatHex

    pop dx
    pop bx
    pop ax
    pop cx      ; restauram contorul original
    pop si      ; restauram offset ul sirului

    ; linie noua
    mov ah, 09h ; functie afisare sir
    mov dx, offset LinieNoua
    int 21h

    ret
printHex ENDP

; functionalitati student3 - Brigitte

sortare_sir Proc
;----- bubble sort -----
    mov lungime,cx
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov cx, lungime  ; salvam lungimea sirului
    dec cx ; facem n-1 parcurgeri
repeta1:
    mov si, offset sirOcteti
    mov ax,cx ; salvam pozitia curenta
repeta2:
    mov bl,[si]
    cmp bl,[si+1] ;comparam doua elemente 
    jnc next
    mov dl,[si+1]
    mov [si],dl
    mov [si+1],bl
next:
    inc si
    loop repeta2
    mov cx,ax
    loop repeta1

    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ret
sortare_sir ENDP

afisare_sir_sortat PROC
;----- afisarea sirului sortat -----
    ;mov lungime,cx;salvam lungimea sirului 
    mov lungime,cx
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah,09h
    mov dx,offset randNou
    int 21h

    mov ah,09h
    mov dx, offset mesajSortat
    int 21h
    
    mov cx,lungime
    mov si, offset sirOcteti    ; adresa de inceput a sirului
repeta_afisare:
    ;--afisare octet--
    push cx ;"inghetam" valoarea lui cx in stiva
 
   
pozitiv:
    mov al,[si]
    mov ah,0
    mov cx,0

Repeta10:
    mov dx,0
    div zece
    push dx 
    inc cx
    cmp ax,0
    jne Repeta10

RepetaAfis:
    pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop RepetaAfis

    ;--afisare spatiu--
    mov dl , ' '
    mov ah,02h
    int 21h
    pop cx ; recuperam valoarea initiala a lui cx
    inc si
    loop repeta_afisare

    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ret
afisare_sir_sortat ENDP

calculare_numar_maxim_octetii1 PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, offset sirOcteti
    mov cx, bx

repeta_octeti:

    mov dx,cx ; retin pozitia curenta
    mov ax,0 ;aici stochez numarul de bitii 1
    mov cx,8
    mov bl,[si] ; octetul curent , il stochez in bl pt a nu-i schimba valoarea

calculare1:
    rcl bl,1
    jnc bitul_nu_este_unu
    add al,1
    bitul_nu_este_unu:
    loop calculare1

    cmp al,3 
    jc next_
    cmp al,nrMaxim_octetii1 ; CF=1 inseamna ca ax este mai mic
    jc next_ ; trecem mai departe , altfel actualizam maximul
    mov al,[si]
    mov nrMaxim_octetii1,al
    ; Calculam indexul: Index = SI - Offset sirOcteti
    mov ax, si
    sub ax, offset sirOcteti
    mov pozitie_numar_maxim_octetii1, ax  
next_:
    inc si
    mov cx,dx
    loop  repeta_octeti

    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ret
calculare_numar_maxim_octetii1 ENDP

afisare_octet_bit_1_maxim PROC
    push ax
    push bx
    push cx
    push dx

    ;-- afisare rand nou --
    mov ah, 09h
    mov dx, offset randNou
    int 21h

    ;-- afisare mesaj valoare --
    mov dx, offset mesajOctetBiti1Maxim
    int 21h

    ;-- afisare octet (valoare) --
    mov al, nrMaxim_octetii1
    xor ah, ah
    call Afisare_Numar_AX

    ;-- afisare rand nou --
    mov ah, 09h
    mov dx, offset randNou
    int 21h

    ;-- afisare mesaj pozitie --
    mov dx, offset mesajPozitieMaxim
    int 21h

    ;-- afisare pozitie (offset-ul) --
    mov ax, pozitie_numar_maxim_octetii1
    call Afisare_Numar_AX

    pop dx
    pop cx
    pop bx
    pop ax
    ret
afisare_octet_bit_1_maxim ENDP

;--- Subrutina pentru a evita duplicarea codului de afisare ---
Afisare_Numar_AX PROC
    mov cx, 0
    mov bx, 10
RepetaImpartire:
    mov dx, 0
    div bx          ; AX / 10, rest in DX
    push dx
    inc cx
    cmp ax, 0
    jne RepetaImpartire

RepetaAfis3:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop RepetaAfis3
    ret
Afisare_Numar_AX ENDP

code ends
end start
