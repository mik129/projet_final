global _start

section .data
    msg_usage db "Usage: ./infector_bin <binaire_cible>", 10, 0
    len_usage equ $ - msg_usage
    msg_start db "[*] Lancement de l'infector ELF en assembleur pur", 10, 0
    len_start equ $ - msg_start
    msg_success db "[+] Fichier ouvert et mappé en mémoire avec succès !", 10, 0
    len_success equ $ - msg_success

section .text
_start:
    ; 1. Vérifier le nombre d'arguments (argc dans [rsp])
    mov rdi, [rsp]
    cmp rdi, 2
    jl print_usage

    ; Afficher le message de démarrage
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_start
    mov rdx, len_start
    syscall

    ; 2. Ouvrir le fichier cible (argv[1] est à [rsp + 16])
    ; sys_open(filename, flags=O_RDWR(2), mode=0)
    mov rax, 2            ; sys_open
    mov rdi, [rsp + 16]   ; argv[1]
    mov rsi, 2            ; O_RDWR (Lecture / Écriture)
    xor rdx, rdx          ; mode = 0
    syscall

    test rax, rax
    js exit_error         ; Si rax < 0, erreur d'ouverture
    mov r8, rax           ; Sauvegarder le File Descriptor (fd) dans r8

    ; 3. Récupérer la taille du fichier avec sys_lseek
    ; sys_lseek(fd, offset=0, whence=SEEK_END(2))
    mov rax, 8            ; sys_lseek
    mov rdi, r8           ; fd
    xor rsi, rsi          ; offset = 0
    mov rdx, 2            ; SEEK_END
    syscall

    test rax, rax
    js exit_error
    mov r9, rax           ; Sauvegarder la taille du fichier dans r9

    ; Retourner au début du fichier (SEEK_SET = 0)
    mov rax, 8
    mov rdi, r8
    xor rsi, rsi
    xor rdx, rdx
    syscall

    ; 4. Mapper le fichier en mémoire avec sys_mmap
    ; void *mmap(void *addr=0, size_t length, int prot=PROT_READ|PROT_WRITE(3), int flags=MAP_SHARED(1), int fd, off_t offset=0)
    mov rax, 9            ; sys_mmap
    xor rdi, rdi          ; addr = NULL (le noyau choisit l'adresse)
    mov rsi, r9           ; length (taille du fichier récupérée par lève-tôt/lseek)
    mov rdx, 3            ; PROT_READ (1) | PROT_WRITE (2) = 3
    mov r10, 1            ; MAP_SHARED (1)
    mov r8, r8            ; fd (déjà dans r8)
    xor r9, r9            ; offset = 0
    syscall

    test rax, rax
    js exit_error
    
    ; Afficher le message de succès
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_success
    mov rdx, len_success
    syscall

    jmp exit_success

print_usage:
    mov rax, 1
    mov rdi, 2
    mov rsi, msg_usage
    mov rdx, len_usage
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

exit_error:
    mov rax, 60
    mov rdi, 2
    syscall

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall