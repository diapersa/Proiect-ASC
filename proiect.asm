
assume cs:code,ds:data

public sortare_sir
public afisare_sir_sortat

data segment
sir db 1,5,7,8,2,6,3,9,4
lungime equ $-offset sir
pozitie_octet db ?
randNou db 13,10,'$'
mesajSortat db 13,10,'Sirul sortat este : ',13,10,'$'
spatiu db  ' $'
data ends

code segment
start:

mov ax,data
mov ds,ax

call sortare_sir
call afisare_sir_sortat

mov ax,4c00h
int 21h


sortare_sir Proc
;----- bubble sort -----
mov cx,lungime
repeta1:
mov ax,cx ;salvam pozitia curenta din sir
mov cx,lungime ; folosim cx pt al doilea loop , iteram de n-1 ori
dec cx  ;n=n-1
mov si,0
repeta2:
mov bl,sir[si]
cmp bl,sir[si+1] ;comparam doua elemente 
jnc next
mov bl,sir[si]
mov dl,sir[si+1]
mov sir[si],dl
mov sir[si+1],bl
next:
inc si
loop repeta2
mov cx,ax
loop repeta1

ret
sortare_sir ENDP

afisare_sir_sortat PROC
;----- afisarea sirului sortat -----
mov ah,09h
mov dx,offset randNou
int 21h

mov ah,09h
mov dx, offset mesajSortat
int 21h

mov cx,lungime
mov si,0
repeta_afisare:
;--afisare octet--
mov dl,sir[si]
add dl,'0'
mov ah ,02h
int 21h
;--afisare spatiu--
mov dl , ' '
mov ah,02h
int 21h

inc si
loop repeta_afisare

ret
afisare_sir_sortat ENDP

code ends
end start