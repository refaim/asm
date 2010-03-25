ccall macro func, params
    irp param, <params>
        push param
    endm
    call func
endm