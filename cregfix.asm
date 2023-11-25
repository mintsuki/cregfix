org 0x8000
bits 16

jmp skip_bpb
nop

times 3-($-$$) db 0
bpb:
  .oem_id:            db "CREGFIX "
  .sector_size:       dw 512
  .sects_per_cluster: db 1
  .reserved_sects:    dw 1
  .fat_count:         db 2
  .root_dir_entries:  dw 224
  .sector_count:      dw 2880
  .media_type:        db 0xf8
  .sects_per_fat:     dw 9
  .sects_per_track:   dw 18
  .heads_count:       dw 2
  .hidden_sects:      dd 0
  .sector_count_big:  dd 0
  .drive_num:         db 0
  .reserved:          db 0
  .signature:         db 0x29
  .volume_id:         dd 0x12345678
  .volume_label:      db "CREGFIX    "
  .filesystem_type:   db "FAT12   "

skip_bpb:
    ; Relocate to 0x8000
    cld
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov si, 0x7c00
    mov di, 0x8000
    mov cx, 512
    rep movsb

    ; Init segments and sp
    jmp 0:.init_cs
  .init_cs:
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Load next HDD bootsector at 0x7c00
    mov si, .dap
    mov ah, 0x42
    mov dl, 0x80
    clc
    int 0x13
    jc $

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

    ; Chainload next HDD bootsector
    mov eax, 0xaa55
    xor ebx, ebx
    xor ecx, ecx
    mov edx, 0x80
    xor edi, edi
    xor esi, esi
    xor ebp, ebp
    push dword 0x202
    popfd
    jmp 0x7c00

times 0xda-($-$$) db 0
times 6 db 0

  .dap:
    db 0x10
    db 0
    dw 1
    dw 0x7c00
    dw 0
    dq 0

times 510-($-$$) db 0
dw 0xaa55

times 2879*512 db 0
