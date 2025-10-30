org 0

; Minimal device driver header
dd -1
dw 0x8000
dw strategy
dw interrupt
db 'CREGFIX '

strategy:
    mov [cs:req], bx
    mov [cs:req+2], es
    retf

interrupt:
    push eax
    push ebx
    push es

    les bx, [cs:req]
    cmp byte [es:bx+2], 0
    jne done

    ; Clear control registers
    mov eax, 0x10
    mov cr0, eax

    xor eax, eax
    mov cr2, eax
    mov cr3, eax
    mov cr4, eax

    xor edx, edx
    mov ecx, 0xc0000080
    wrmsr

    mov word [es:bx+14], 0 ; Set driver size to 0 (don't stay resident)
    mov word [es:bx+16], cs

done:
    mov word [es:bx+3], 0x0100 ; Status = done

    pop es
    pop ebx
    pop eax
    retf

req dd 0
