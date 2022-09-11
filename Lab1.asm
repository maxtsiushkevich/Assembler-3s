; 1 variant
        .model tiny         ; memory model 
        .code               ; code segment
        org 100h            ; 256 byte
start:  mov ah, 9
        mov dx, offset message
        int 21h
        ret                 ; end 
message db "Hello World!", 0Dh, 0Ah, '$'    ; string
end start
