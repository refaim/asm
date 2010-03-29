.model small
.386
locals

include common.inc

extrn get_display_mode: far, set_display_mode: far
extrn fill_screen_13h: far

minesCount equ 500
playerSize equ 10

randA equ 13
randB equ 5

bgColor equ 0
winColor equ 10
loseColor equ 4

playerColor equ 10
mineColor equ 4

maxOffset equ 320 * 200 + 1

stk segment stack use16
    db 256 dup (0)
stk ends

data segment para public 'data' use16
    old_mode db ?
    random_seed dw ?
    lose_flag db 0
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

pause proc pascal
uses ax
    mov ah, 007h
    int 21h
    ret
pause endp

set_random_seed proc pascal
uses ax, bx, cx, dx
    mov ah, 02Ch
    int 21h
    mov random_seed, dx
    ret
set_random_seed endp

get_random_number proc pascal
    mov ax, randA
    mul random_seed
    add ax, randB
    mov random_seed, ax
    ret 
get_random_number endp

get_random_point proc pascal
uses ax, dx
    call get_random_number
    xor dx, dx
    mov si, maxOffset
    div si
    mov si, dx
    ret
get_random_point endp

draw_rectangle proc pascal w: word, h: word, color: byte
uses cx
    mov cx, h
@@drawline:
    ccall draw_horz_line, <w, word ptr color>
    add si, 320
    sub si, w
    loop @@drawline
    ret
draw_rectangle endp

draw_horz_line proc pascal len: word, color: byte
uses ax, cx
    mov cx, len
    mov al, color
@@draw:
    cmp byte ptr es:[si], mineColor
    je short @@found
    mov es:[si], al
    inc si
    loop @@draw
    jmp short @@exit    
@@found:
    mov lose_flag, 1
    inc si
    loop @@draw
@@exit:
    ret
draw_horz_line endp

draw_player proc pascal
    call set_random_seed
    call get_random_point
    ccall draw_rectangle, <playerSize, playerSize, playerColor>
@@exit:
    ret
draw_player endp

main proc
    call get_display_mode
    mov old_mode, al ; save display mode
    ccall set_display_mode, 013h

    mov ax, 0A000h ; video memory address
    mov es, ax

    ccall fill_screen_13h, bgColor

    call pause
    call set_random_seed
    mov cx, minesCount
@@mines:
    call get_random_point
    mov byte ptr es:[si], mineColor
    loop @@mines

    call pause
    call draw_player
    cmp lose_flag, 1
    je short @@lose

    call pause
    ccall fill_screen_13h, winColor
    jmp short @@exit

@@lose:
    call pause
    ccall fill_screen_13h, loseColor
    jmp short @@exit

@@exit:
    call pause
    ccall set_display_mode, word ptr old_mode
    mov ax, 04C00h
    int 21h
main endp

code ends
end main
