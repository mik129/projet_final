global _start

section .data
    msg_usage db "Usage: ./infector_bin <binaire_cible>", 10, 0
    len_usage equ $ - msg_usage
    msg_start db "[*] Lancement de l'infector ELF en assembleur pur", 10, 0
    len_start equ $ - msg_start

section .text
_start:
    ; 1. Vérifier le nombre d'arguments ( argc dans [rsp] )
    mov rdi, [rsp]        ; argc
    cmp rdi, 2
    jl print_usage        ; Si argc < 2, afficher l'aide

    ; Afficher le message de démarrage
    mov rax, 1            ; sys_write
    mov rdi, 1            ; stdout
    mov rsi, msg_start    ; pointeur vers le message
    mov rdx, len_start    ; taille
    syscall

    ; --- PROCHAINE ÉTAPE : Ouvrir le fichier cible (sys_open) ---
    ; argv[1] se trouve à l'adresse [rsp + 16]

    jmp exit_success

print_usage:
    mov rax, 1            ; sys_write
    mov rdi, 2            ; stderr
    mov rsi, msg_usage    ; pointeur vers l'aide
    mov rdx, len_usage    ; taille
    syscall
    mov rax, 60           ; sys_exit
    mov rdi, 1            ; code d'erreur 1
    syscall

exit_success:
    mov rax, 60           ; sys_exit
    xor rdi, rdi          ; code de sortie 0
    syscall
