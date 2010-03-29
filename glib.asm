.model small
.386
locals

public get_display_mode, set_display_mode
public get_point_offset_13h, fill_screen_13h

code segment para public 'code' use16
assume cs: code

; out: ah -- chars in line, al -- display mode, bh -- current page number
get_display_mode proc pascal far
    mov ah, 00Fh ; get mode
    int 10h
    ret
get_display_mode endp

set_display_mode proc pascal far mode: byte
uses ax
    mov ah, 000h ; set mode
    mov al, mode
    int 10h
    ret
set_display_mode endp


; ATTENTION
; for next functions es must contain video memory offset

; out: si -- offset of point (x, y) in video memory (display mode 13h)
get_point_offset_13h proc pascal far x: word, y: word
uses ax
    mov ax, 320 ; width
    mul y
    add ax, x
    mov si, ax
    ret
get_point_offset_13h endp

fill_screen_13h proc pascal far color: byte
uses ax, si
    mov al, color
    mov si, 0FFFFh
@@draw:
    mov es:[si], al
    dec si
    test si, si
    jnz short @@draw
    mov es:0, al
    ret
fill_screen_13h endp

code ends
end
