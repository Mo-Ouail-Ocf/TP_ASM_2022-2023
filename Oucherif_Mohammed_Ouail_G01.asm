
data segment
    ; add your data here! 
    
    tp db 'TP ASSEMBLEUR -1CP-G01- Oucherif Mohammed Ouail $'
    year db 'Annee universitaire 2022/2023  $'
    ;afficher pkey
    pkey db "press any key...$" 
    ;afficher la phrase
    day db '  Date et Heure  :$' 
    
    ;la variable date
    date dw  3eb0h
    ;la varible heure
    heure dw 6bd5h
     
    ;data a extraire de date 
    jour db 0 ;contient le jour extrait 
    mois db 0 ;contient le mois extrait 
    nbre_decal db 0;contient nbre_decal extrait
    annee dw 0  ;l'annee 
    ;data  extraire de heure
    sec db 0;contient les secondes a extraire
    min db 0;contient les minutes a extraire
    hh db 0 ;contient l'heure a extraire
    
ends

code segment
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; les macros:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
print_chaine macro str  ;macro pour afficher une chaine
    lea dx,str
    mov ah,9
    int 21h
endm

print_letter macro chiff ;macro pour afficher une lettre
    mov dl,chiff
    mov ah,02
    int 21h
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;programme principale;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
main proc
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; le code de main:
    
    ;affichage symbolique;
    print_chaine tp 
    call new_line 
    call new_line
    print_chaine year
    call new_line 
    call new_line
    print_chaine day
  
    call new_line
    call new_line
    ;;;;;;;;;;;;;;;;;;;;;
       
    ;;;;;;;;;;;extraire_date;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;extraire jour;;;
    mov ax,date
    and ax,001fh
    mov jour,al
    ;;;;;;;;;;;;;;;;;;;;
    
    ;;;;extraire mois;;;
    mov ax,date
    shr al,5
    mov mois,al
    
    ;msb de mois (il se trouve dans l'octet fort de date,on teste si
    ;le premier bit est 1 (dans ce cas on rajoute 1000b ou 8h) ou 0
    mov ax,date
    shr ah,1
    jnc suiv
    add mois,8h
    ;;;;;;;;;;;;;;;;;;;;
    
    suiv:
    ;;;;extraire nb_dec et annee;
    mov ax,date
    shr ah,1
    mov nbre_decal ,ah
    shr ax,8
    mov  annee,ax
    add annee,2000 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;extraire heure;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;extaire sec;;;;
    mov ax,heure
    and ax,0001fh
    mov bl,2
    mul bl
    mov sec,al
    ;;;;;;;;;;;;;;;;;;;
    
    ;;;;extraire min;;;
    mov ax,heure
    and ax,007e0h
    shr ax,5
    mov min,al 
    ;;;;;;;;;;;;;;;;;;;
    
    ;;;;extraire hh;;;;
    mov ax,heure
    and ah,0f8h
    shr ah,3
    mov hh,ah
    ;;;;;;;;;;;;;;;;;;;; 
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;;;;;;;;;;;;;;;;;;;;;affichage;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
    ;;;;le jour;;;
    mov ax,0
    mov al,jour
    ;on empile la valeur a afficher vers la procedure d'affichage:
    push ax
    call affich_num
    
    print_letter '/'
    ;;;;;;;;;;;;;;
    
    ;;;;le mois;;;
    mov ax,0
    mov al,mois
    push ax
    call affich_num
    
    print_letter '/'
    ;;;;;;;;;;;;;;
    
    ;;;;the year;;;;
    mov ax,annee
    push ax
    call affich_num
     
    print_letter ':'
    ;;;;;;;;;;;;;;;;
    
    ;;;;l'heure:;;;;;
    mov ax,0
    mov al,hh
    push ax
    call affich_num
    print_letter 'H'
    ;;;;;;;;;;;;;;;;;
    
    ;;;;minutes;;;;;;
    mov ax,0
    mov al,min
    push ax
    call affich_num
    print_letter 'M'
    print_letter 'N'
    ;;;;;;;;;;;;;;;;;
    
    ;;;;secondes;;;;;
    mov ax,0
    mov al,sec
    push ax
    call affich_num
    print_letter 'S'
    ;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;press any key;;;;;;;;;;;;;
    call new_line 
    call new_line 
    print_chaine pkey
   ; wait for any key....    
    mov ah, 1
    int 21h
    
 
    mov ax, 4c00h ; exit to operating system.
    int 21h
main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;fin du programme principale;;;;;;;;;;;;;;;;;;;;;;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;;;les procedures utilisees;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;new line:affiche d'un saut de ligne;
new_line proc  
    mov dl,13
    mov ah,02
    int 21h
    mov dl,10
    mov ah,02
    int 21h
    ret
new_line endp
;;;;;;;;;;;;;
 

;;procedure d'affichage d'un nombre en decimal
affich_num proc
    
    mov cx , 0 ;cx continet le nbr de chiffre a afficher
    mov bp,sp  ;bp pour parcourir la pile
    mov ax,[bp+2];ranger dans ax la valeur a afficher ecrit en hexa
    mov bx,10  ; bx pour faire la division par 10 et obtenir le reste dans dx
     
    repeter:
    mov dx,0
    div bx 
    inc cx 
    add dx,48 
    ; dx contient le reste,qui est le nbr a afficher mais on ajoute 48 pour
    ; afficher le chiffre ( qui est de '0' a '9' en ascii) 
    ;parceque: ( 00-->NULL -- 4  48-->'0' ) 
    
    push dx  ;empiler le chiffre a afficher 
    cmp ax  ,0  ;on arrete quand ax devient 0 
    ;(le quotient dans ax est nul veut dire que le nbr a afficher se compose d'un seul chiffe )
    jne repeter
    
    ;tester si on affiche 0 ou non (si le nombre inferieur a 10 on affiche 0 avant afficher le nombre)
    cmp cx,1
    jne pour
    print_letter '0'
    
    ;dans la boucle suivante: 
    ; on va depiler pour afficher les nbrs en bon ordres
    ;i.e.,pour afficher 2023
    ;la pile contient:
    ; 2--0--2--3 
    ; |
    ; sp
    ; depiler ..afficher 2.. depiler ..afficher 0 ... cx fois 
    
    pour:
    pop dx
    mov ah,02h
    int 21h
    loop pour
    ret 2
    
affich_num endp    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ends

end main ; set entry point and stop the assembler.
