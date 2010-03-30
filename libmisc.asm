.model small
.386
locals

public wait_key_press

code segment para public 'code' use16
assume cs: code

wait_key_press proc pascal far
uses ax
    mov ah, 007h
    int 21h
    ret
wait_key_press endp

code ends
end
