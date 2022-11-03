.model small                  
.stack 100h                    
 
.data
msgEnterString       db "Vvedite stroky: $"
msgEnterSubstring    db 0Ah, 0Dh, "Vvedite podstroky: $"
msgResult            db 0Ah, 0Dh, "Itogovaya stroka: $" 
enterStr             db 0Ah, 0Dh, '$'
max_length           equ 200   ; len = 200
 
Strb db '$'                   
Strl db max_length               
String  db max_length dup('$')                       
                              
SubStrb db '$'                
SubStrl db max_length         
SubString  db max_length dup('$')     
                                                                                           
.code                          
start:                         
                               
    mov ax, @data             
    mov ds, ax                
                               
                 
    call enterString           ;vvod stroki
    call enterSubstring        ;vvod podstroki
      
    xor cx, cx                 ;obnul counter
    lea si, String             ;ustanavlivaem pointer na nachalo Str; == mov si, offset String
    dec si                     ;
    jmp skip_spaces            ;Jump na skip_spaces loop

    
    find:                      ;ustanavlivaem si na nachalo sled slova
        inc si                 ;
        push bx 
        mov bl, [si]               ;
        cmp bl, ' '          ;sravnivaem element Str s ' '
        pop bx
        je skip_spaces         ;esli ' ' - nachinaem noviy poisk 
        
        push bx 
        mov bl, [si]
        cmp bl, '$'          ; sravnivaem s '$'  
        pop bx
        je exit                ;esli konec - exit 
        
        jmp find               
        
        skip_spaces:           ;propuskaem probely pered sled slovom
            inc si   
            push bx 
            mov bl, [si]
            cmp bl, ' '
            pop bx
           je skip_spaces      
           
        lea di, SubString      ;ustanavlivaem pointer na nachalo SubString
        call searchSubString   ;poisk podstroki
       jmp find                
          
    error_exit:
        call outputErrorResult ;      
          
    exit:  
        call outputResult      ;vyvod resultata  
                 
inputString proc               ;Vvod stroki procedure
    push ax                    ;sohranyaem ax    
    mov ah, 0Ah                
    int 21h                     
    pop ax                     ;vostanavlivayem ax
    ret                        ;return
inputString endp           
 
outputString proc              ;vyvod stroki
    push ax                
    mov ah, 09h                
    int 21h                    
    pop ax                    
    ret                        
outputString endp              
 
enterString proc               
    lea dx, msgEnterString     
    call outputString         
    lea dx, Strb              
    mov Strb[0], max_length
    call inputString           
    ret                        
enterString endp               
                            
enterSubstring proc            
    lea dx, msgEnterSubstring 
    call outputString          
    lea dx, SubStrb           
    mov SubStrb[0], max_length
    call inputString          
    ret                       
enterSubstring endp            

outputResult proc              
    lea dx, msgResult          ; vyvod resultata
    call outputString          
    lea dx, String            
    call outputString          
           
    lea dx, enterStr
    call outputString       
           
    xor ax, ax    
    mov ah,4ch              
    int 21h  
    ret                  
outputResult endp   

outputErrorResult proc              
         
    call outputString                  
    mov ax, 4ch               
    int 21h  
    ret                  
outputErrorResult endp         
                                              
    
searchSubString proc             ; poisk podstroki
    push ax                      
    push cx                      
    push di                      
    push si                      ;sohranyaem ax, cx, di, si 
                                
    xor cx, cx                   ;reset cx
    mov cl, [SubStrl]            ;v cx kladem dlinu podstroki
    comparestr:                  
        mov ah,[si]              ;v ah [si] simvol stroki
        dec cx                   ;dekrimentiruem cx
        cmp ah,[di]              ;sravnivaem simvoly stroki i podstroki
        je  compare              ;esli == perehodim k compare
        jne NotEqual             ;esli != perehodim k NotEqual
        compare:                 
            inc si               ; peremeschaemsya k sled simvoly
            inc di               
            cmp cx,0             ;sravnivayem cx s 0
            je check             ;esli cx = 0 -> konec podstroki -> perehod k check 
          jne comparestr         ;       != vozvrat v nachalo 
                                 
        check:      
            push bx 
            mov bl, [si]                
            cmp bl, ' '         
            pop bx
            je Equal            
            jne NotEqual        
                                
        Equal:                   
            call lengthProc      ;poluchaem dliny slova
            call shift           ;sdvigaem vlevo  
            call searchSubString ;povtoryaem
                                 
        NotEqual:                
            pop si              
            pop di               
            pop cx               
            pop ax               
            ret                  ;vosstanavlivayem ax, cx, di, si                           ;
searchSubString endp             
                                 
                                 
shift proc                       
    push cx                     
    push di                      
    push bx                      
                                
    lea ax, String               ;Str v ax
    add al, [Strl]               ;dobavlyaem dliny Str to al 
    sub ax,si                    ;vychitaem si iz ax
    mov cx,ax                    ;ax v cx; cx soderzhit dliny ostatka stroki
    add cx,2                    
                                 
    ;sdvig slova         
    shift_left:                  
        mov ah,[si]              ;sohranyaem tekuschiy element
        sub si, bx               ;sdvig vlevo
        mov [si], ah             ;sdvigaem element na poziciu bx vlevo 
        add si, bx               ;vosstanavlivaem si 
        inc si                   ;sled simvol
    loop shift_left              
                                 
                                 
    pop bx                       
    pop di                       
    pop cx                       ;vostanavlivayem
    ret                         
shift endp                      
                                
lengthProc proc                      
    push ax                      
    skip:                        
    inc si  
    push bx 
    mov bl, [si]                     
    cmp bl, ' '
    pop bx               
    je skip                   
    mov ax,si                    ;sravnivayem element  Str s ' '  
                                
    wordMarker:                        
    mov dh,[si]                  
    inc si    
    push bx 
    mov bl, [si]                   
    cmp bl, ' '                  ;sravnivyaem s koncom Str
    pop bx
    je continue                 
    push bx 
    mov bl, [si]
    cmp bl, '$'                  
    pop bx
    je continue                  
    jmp wordMarker                    
    continue:                    
    push si                     
    sub si,ax                    
    mov bx,si                  
                                
    pop si                      
    pop ax                      
    ret                          
lengthProc endp                      
                                 
end start                        