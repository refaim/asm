ccall macro func, params
    irp param, <params>
        push word ptr param
    endm
    call func
endm
