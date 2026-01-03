assume cs:code, ds:data

public calculateWord
public rotateByte
public printBinary
public printHex

data segment
    C dw ?
    sum dw ?
    sirRotire db l dup(?)
    N db ?
data ends

code segment

calculateWord PROC
    ; in data segment in main
    ; si - inceputul sirului
    ; l - nr de bytes

    mov C, 0    ; stocam rezultatul final

    xor ax, ax
    xor bx, bx
    xor dx, dx
    
    ; Pas 1: XOR intre primii 4 biti ai primului octet si ultimii 4 biti ai ultimului octet

    mov al, [si]    ; primul octet din sir
    and al, 00001111b   ; izolam bitii 0-3 
    mov bl, al  ; stocam bitii 0-3 

    mov al, [si + l - 1]    ; ultimul byte
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

    push cx ; salvam contorul original

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

    pop cx  ; restauram cx original

    ret
calculateWord ENDP


rotateByte PROC
    ; cx deja contine lungimea sirului

    mov di, offset sirRotire
    push cx

    repeta:
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

        loop repeta

    pop cx
    ret
rotateByte ENDP


printBinary PROC
    push cx        ; salvam contorul original

    mov si, offset sirRotire

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
    loop printBinary

    pop cx
    ret
printBinary ENDP

code ends
end