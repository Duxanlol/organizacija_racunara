data segment      
    msg_unesiteString db "Unesite broj: $"                    
    msg_unesiteUmnozilac db "Unesite umozilac: $"
    string db '                      '     
    msg_superDigitJe db "Super digit je: $"
    length dw 0   
    integer dw 0
ends
; Deficija stek segmenta
stek segment stack
    dw 128 dup(0)
ends
; Ucitavanje znaka bez prikaza i cuvanja     
keypress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm
; Isis stringa na ekran
writeString macro s
    push ax
    push dx  
    mov dx, offset s
    mov ah, 09
    int 21h
    pop dx
    pop ax
endm
; Kraj programa           
krajPrograma macro
    mov ax, 4c02h
    int 21h
endm   
           
code segment
; Novi red
novired proc
    push ax
    push bx
    push cx
    push dx
    mov ah,03
    mov bh,0
    int 10h
    inc dh
    mov dl,0
    mov ah,02
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
novired endp
; Ucitavanje stringa sa tastature
; Adresa stringa je parametar na steku
readString proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov dx, [bp+12]
    mov bx, dx
    mov ax, [bp+14]
    mov byte [bx] ,al
    mov ah, 0Ah
    int 21h
    mov si, dx     
    mov cl, [si+1] 
    mov ch, 0
kopiraj:
    mov al, [si+2]
    mov [si], al
    inc si
    loop kopiraj     
    mov [si], '$'
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
readString endp
; Konvertuje string u broj           

; String length proc
getLength macro source, destination
    push ax
    push dx 
    push cx              
    LOCAL duzina
    mov dx, offset source 
    mov si, dx
    mov cx, 0
    duzina:            
        mov al, [si] 
        add cx, 1  
        inc si 
        cmp al, '$' 
        jne duzina
    dec cx
    mov destination, cx  
    pop cx
    pop dx
    pop ax   
endm     
              
              
strtoint proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov bx, [bp+14]
    mov ax, 0
    mov cx, 0
    mov si, 10
petlja1:
    mov cl, [bx]
    cmp cl, '$'
    je kraj1
    mul si
    sub cx, 48
    add ax, cx
    inc bx  
    jmp petlja1
kraj1:
    mov bx, [bp+12] 
    mov [bx], ax 
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
strtoint endp
; Konvertuje broj u string
inttostr proc
   push ax
   push bx
   push cx
   push dx
   push si
   mov bp, sp
   mov ax, [bp+14] 
   mov dl, '$'
   push dx
   mov si, 10
petlja2:
   mov dx, 0
   div si
   add dx, 48
   push dx
   cmp ax, 0
   jne petlja2
   
   mov bx, [bp+12]
petlja2a:      
   pop dx
   mov [bx], dl
   inc bx
   cmp dl, '$'
   jne petlja2a
   pop si  
   pop dx
   pop cx
   pop bx
   pop ax 
   ret 4
inttostr endp  


saberiCifre macro source, dest  
    push ax
    push dx
    push cx                 
    LOCAL cifre          
    LOCAL exit
    mov dx, offset source 
    mov si, dx
    mov cx, 0 
    xor ax,ax
    cifre:
        mov al, [si]
        cmp al, '$'
        je exit
        sub al, 48
        add cx, ax
        inc si        
        jmp cifre  
    exit:
    mov dest, cx
    pop cx
    pop dx
    pop ax          
endm

superDigit proc         
    push cx     
    push bx 
    push si
    ;getLength string, integer
    ;mov cx, integer
    ;cmp cx, 1
    mov si, offset string
    inc si
    cmp [si], '$'
    je return  
    saberiCifre string, bx  
    push bx
    push offset string
    call inttostr                
    call superDigit
              
               
                  
    return:  
    pop si
    pop bx
    pop cx    
    ret             
superDigit endp


start:
    ; postavljanje segmentnih registara       
    ASSUME cs: code, ss:stek
    mov ax, data
    mov ds, ax
    call novired
    writeString msg_unesiteString   
    push 20
    push offset string
    call readString   
    saberiCifre string, bx   ;sabrane cifre su u bx
    
    call novired      
    writeString msg_unesiteUmnozilac
    push 20
    push offset string 
    call readString   
    push offset string
    push offset integer
    call strtoint  
    mov ax, bx
    mov cx, integer
    mul cx                ; pomnozi sabrane cifre sa umnoziocem
    push ax
    push offset string
    call inttostr              
    call superDigit       ; zovi rekurziju
    call novired        
    writeString msg_superDigitJe
    writeString string       
    keyPress                      
    krajPrograma 
ends
end start