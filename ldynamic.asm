.model small
.386
locals

include common.inc

extrn wait_key_press: far
extrn get_display_mode: far, set_display_mode: far

pause_coef equ 7
pause macro
local @@os, @@is
    mov cx, pause_coef
@@os:
    push cx
    mov cx, 0
@@is: 
    loop @@is
    pop cx
    loop @@os
endm

LLEN equ 120
XC equ 160
YC equ 100

draw macro coords
    ccall draw_line coords
    inc al
    inc bh
endm

stk segment stack use16
    db 256 dup (0)
stk ends

data segment para public 'data' use16
    old_mode db ?
    buff dw ?
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

switch_page proc pascal number: byte
uses ax
    mov ah, 005h ; choose page
    mov al, number
    int 10h    
    ret
switch_page endp

; get equiation of the line
get_equation proc pascal x1, y1, x2, y2
    ; (x - x1) / (x2 - x1) = (y - y1) / (y2 - y1) =>
    ; => y = ((x - x1) / (x2 - x1)) * (y2 - y1) + y1 =>
    ; => y = k * x + b
    ; k = (y2 - y1) / (x2 - x1)
    ; b = -k * x1 + y1
    finit
    ; calc k
    fild y2
    fisub y1
    fild x2
    fisub x1
    fdiv
    ; calc b
    fld st(0)
    fchs
    fimul x1
    fiadd y1
    ret
get_equation endp

; dx := y = k * x + b
calc_ordinate proc pascal x
    ; st(1) = k, st(0) = b
    fild x
    fmul st(0), st(2)
    fadd st(0), st(1)
    fistp buff
    mov dx, buff
    ret
calc_ordinate endp

; draw line from (x1, y1) to (x2, y2)
draw_line proc pascal x1, y1, x2, y2, color: byte, pagenum: byte
uses ax, bx, cx, dx
    mov al, color
    mov bh, pagenum

    ccall get_equation, <x1, y1, x2, y2>
    mov dx, y1
    mov cx, x1
    cmp cx, x2
    je short @@vertical
@@left_to_right:
    ccall calc_ordinate, cx
    int 10h
    inc cx
    cmp cx, x2
    jle short @@left_to_right
    jmp short @@exit

@@vertical:
    int 10h
    inc dx
    cmp dx, y2
    jle short @@vertical
@@exit:
    ret
draw_line endp

main proc
    call get_display_mode
    mov old_mode, al ; save display mode
    ccall set_display_mode, 00Dh

    mov ah, 00Ch ; draw pixel
    ccall draw_line <XC, YC - LLEN / 2, XC, YC + LLEN / 2, 007h, 000h> ; |
    ccall draw_line <XC - LLEN / 4, YC + LLEN / 2, XC + LLEN / 4, YC - LLEN / 2, 008h, 001h>
    ccall draw_line <XC - LLEN / 2, YC + LLEN / 2, XC + LLEN / 2, YC - LLEN / 2, 009h, 002h> ; /
    ccall draw_line <XC - LLEN / 2, YC + LLEN / 4, XC + LLEN / 2, YC - LLEN / 4, 00Ah, 003h>
    ccall draw_line <XC - LLEN / 2, YC, XC + LLEN / 2, YC, 00Bh, 004h> ; -
    ccall draw_line <XC - LLEN / 2, YC - LLEN / 4, XC + LLEN / 2, YC + LLEN / 4, 00Ch, 005h>
    ccall draw_line <XC - LLEN / 2, YC - LLEN / 2, XC + LLEN / 2, YC + LLEN / 2, 00Dh, 006h> ; \
    ccall draw_line <XC - LLEN / 4, YC - LLEN / 2, XC + LLEN / 4, YC + LLEN / 2, 00Eh, 007h>

    xor bx, bx
@@display:
    ccall switch_page, bx
    pause
    cmp bx, 7
    je short @@restart
    inc bx
    jmp short @@display
@@restart:
    xor bx, bx
    jmp short @@display

exit:
    call wait_key_press
    ccall set_display_mode, old_mode
    mov ax, 04C00h
    int 21h
main endp

code ends
end main
