.model small
.386
locals

include common.inc

extrn wait_key_press: far
extrn get_display_mode: far, set_display_mode: far
extrn get_offset_by_point_13h: far, get_point_by_offset_13h: far, fill_screen_13h: far
extrn set_random_seed: far, get_random_number: far

playerColor equ 10
winColor equ 10
mineColor equ 4
loseColor equ 4

minesCount equ 500
playerWidth equ 10
playerHeight equ 10

screenWidth equ 320
screenHeight equ 200
rightMaxPos equ screenWidth - (playerWidth + 1)
bottomMaxPos equ screenHeight - (playerHeight + 1)
maxPointOffset equ screenWidth * screenHeight

playerSeedXarg equ 52
mineSeedXarg equ 118

stk segment stack use16
    db 256 dup (0)
stk ends

data segment para public 'data' use16
    old_mode db ?
    result_color db ?
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

get_random_point proc pascal
uses ax, dx
    call get_random_number
    xor dx, dx
    mov si, maxPointOffset + 1
    div si
    mov si, dx
    ret
get_random_point endp

draw_rectangle proc pascal w: word, h: word, color: byte
uses cx
    mov cx, h
@@drawline:
    ccall draw_horz_line, <w, color>
    add si, screenWidth
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
    mov result_color, loseColor
    inc si
    loop @@draw
@@exit:
    ret
draw_horz_line endp

draw_player proc pascal
uses ax, bx
    ccall set_random_seed, playerSeedXarg
    call get_random_point
    ccall get_point_by_offset_13h, <si>
    cmp ax, rightMaxPos
    jle short @@check_height
    mov ax, rightMaxPos
@@check_height:
    cmp bx, bottomMaxPos
    jle short @@draw
    mov bx, bottomMaxPos
@@draw:
    ccall get_offset_by_point_13h, <ax, bx>
    ccall draw_rectangle, <playerWidth, playerHeight, playerColor>
@@exit:
    ret
draw_player endp

main proc
    call get_display_mode
    mov old_mode, al ; save display mode
    ccall set_display_mode, 013h

    mov ax, 0A000h ; video memory address
    mov es, ax

    call wait_key_press
    ccall set_random_seed, mineSeedXarg
    mov cx, minesCount
@@mines:
    call get_random_point
    mov byte ptr es:[si], mineColor
    loop @@mines

    call wait_key_press
    mov result_color, winColor
    call draw_player
    call wait_key_press
    ccall fill_screen_13h, result_color

@@exit:
    call wait_key_press
    ccall set_display_mode, old_mode
    mov ax, 04C00h
    int 21h
main endp

code ends
end main
