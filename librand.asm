.model small
.386
locals

public set_random_seed, get_random_number

randA equ 13
randB equ 5

data segment para public 'data' use16
    random_seed dw ?
data ends

code segment para public 'code' use16
assume cs: code, ds: data

set_random_seed proc pascal far xarg: word
uses ax, bx, cx, dx
    mov ah, 02Ch
    int 21h
    xor dx, xarg
    mov random_seed, dx
    ret
set_random_seed endp

get_random_number proc pascal far
    mov ax, randA
    mul random_seed
    add ax, randB
    mov random_seed, ax
    ret 
get_random_number endp

code ends
end
