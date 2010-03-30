.model small
.386
locals

include common.inc

extrn wait_key_press: far
extrn get_display_mode: far, set_display_mode: far
extrn get_offset_by_point_13h: far

stk segment stack use16
    db 256 dup (0)
stk ends

data segment para public 'data' use16
    old_mode db ?
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

main proc
    call get_display_mode
    mov old_mode, al ; save display mode
    ccall set_display_mode, 013h

    mov ax, 0A000h ; video memory address
    mov es, ax

    ccall get_offset_by_point_13h <60, 100>
    mov cx, 200 ; line length
@@horizontal:
    mov es:[si], byte ptr 04h
    inc si
    loop @@horizontal

    ccall get_offset_by_point_13h <160, 25>
    mov cx, 150 ; line length
@@vertical:
    mov es:[si], byte ptr 04h
    add si, 320
    loop @@vertical

@@exit:
    call wait_key_press
    ccall set_display_mode, old_mode
    mov ax, 04C00h
    int 21h
main endp

code ends
end main
