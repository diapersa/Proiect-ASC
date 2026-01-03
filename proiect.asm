
assume cs:code,ds:data

public sortare_sir
public afisare_sir_sortat
public calculare_numar_maxim_octetii1
public afisare_octet_bit_1_maxim

data segment
sir db 7,8,16,15,3
lungime equ $-offset sir
pozitie_octet db ?
randNou db 13,10,'$'
mesajSortat db 13,10,'Sirul sortat este : ',13,10,'$'
nrMaxim_octetii1 db 0
pozitie_numar_maxim_octetii1 dw ?
mesajOctetBiti1Maxim db 13,10,'Octetul cu numar maxim de biti 1 este : ', 13,10,'$'
mesajPozitieMaxim db 13,10,'Pozitia acestuia in sir este : ',13,10,'$'
data ends

code segment
start:

mov ax,data
mov ds,ax

call sortare_sir
call afisare_sir_sortat
call calculare_numar_maxim_octetii1
call afisare_octet_bit_1_maxim

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

calculare_numar_maxim_octetii1 PROC

mov si,0
mov cx,lungime

repeta_octeti:

mov dx,cx ; retin pozitia curenta
mov ax,0 ;aici stochez numarul de bitii 1
mov cx,16
mov bl,sir[si] ; octetul curent , il stochez in bl pt a nu-i schimba valoarea

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
mov al,sir[si]
mov nrMaxim_octetii1,al
mov pozitie_numar_maxim_octetii1,si

next_:
inc si
mov cx,dx
loop  repeta_octeti

ret
calculare_numar_maxim_octetii1 ENDP


afisare_octet_bit_1_maxim PROC
;--afisam rand nou--
mov ah,09h
mov dx,offset randNou
int 21h
;--afisam mesaj sugestiv--
mov ah,09h
mov dx, offset mesajOctetBiti1Maxim
int 21h
;--afisam rezulatul--
mov dl,nrMaxim_octetii1
add dl,'0'
mov ah ,02h
int 21h
;--afisam rand nou--
mov ah,09h
mov dx,offset randNou
int 21h
;--afisam mesaj sugestiv--
mov ah,09h
mov dx, offset mesajPozitieMaxim
int 21h
;--afisam rezulatul--
mov dx,pozitie_numar_maxim_octetii1
add dx,'0'
mov ah ,02h
int 21h



ret 
afisare_octet_bit_1_maxim ENDP

code ends
end start