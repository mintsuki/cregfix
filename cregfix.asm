bits 16
org 0

; Minimal device driver header
dd -1
dw 0x8000
dw strategy
dw interrupt
db 'CREGFIX '

strategy:
    ; Strategy is called right before interrupt; save request
    ; header address for later
    mov [cs:req], bx
    mov [cs:req+2], es
    retf

interrupt:
    push eax
    push ebx
    push ecx
    push edx
    push es
    pushf

    ; ES:BX = Request header
    les bx, [cs:req]

    ; If the command DOS requests is not INIT (0), do nothing
    cmp byte [es:bx+2], 0
    jne .done

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

    ; Set driver size to 0 (don't stay resident)
    mov word [es:bx+14], 0
    mov word [es:bx+16], cs

  .done:
    ; Status = done
    mov word [es:bx+3], 0x0100

    popf
    pop es
    pop edx
    pop ecx
    pop ebx
    pop eax
    retf

req dd 0
