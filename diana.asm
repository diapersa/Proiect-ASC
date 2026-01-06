assume cs:code
 
public calculateWord
public printWord
public rotateByte
public printBinary
public printHex
public functions


extrn C:word, mesajAfisBinar:byte, mesajAfisHex:byte
extrn LinieNoua:byte, tabela:byte
extrn sum:word, sirRotire:byte, N:byte
extrn mesajAfisBinarSir:byte, mesajAfisHexSir:byte

code segment

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
        mov ah, 09h ; functie afisare sir
        mov dx, offset LinieNoua
        int 21h

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

        newLine:
            mov ah, 09h
            mov dx, offset LinieNoua
            int 21h

        inc si
        pop cx
        loop repeatHex

    pop dx
    pop bx
    pop ax
    pop cx      ; restauram contorul original
    pop si      ; restauram offset ul sirului
    ret
printHex ENDP

;description
functions PROC
    ; apelam procedura pt calcularea cuvantului + afisarea lui in binar si hexa
    call calculateWord
    call printWord

    ; rotirea sirului cu proprietatile corespunzatoare
    call rotateByte

    ; afisarea sirului rotit in binar si hexa
    call printBinary
    call printHex

    ret
functions ENDP

code ends
end