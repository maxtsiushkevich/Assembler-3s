; массив из 30 чисел, найти (max-min)/max
.model small
.stack 100h

.data
  
MaxArrayLength equ 30 
ArrayLength db ?
Array dw  MaxArrayLength dup (0)  

minus_flag db 0
minus_flag_max db 0
minus_flag_min db 0
tmp db ?  
accuracy dw 6 
            
num_10 dw 10   
b_num_10 db 10

enter db 0Ah, 0Dh, '$'             

MinEl dw ?
MaxEl dw ? 
CurEl1 db 48 
CurEl2 db 48

InputArrayLengthMsgStr db 0Dh,'Vvedite razmer massiva [2-30]: $'
div_0_str db 0Ah, 0Dh, 'Oshibka! Nelzya delit na 0!$'                              
Task db 0Ah,0Dh,'Rezultat ((Max-Min)/Max) = $'
ErrorInputMsgStr db 0Ah, 0Dh,'Oshibka! Nekorrektnyi vvod!' ,0Ah,'$'  
                                                             
InputMsgStr db 0Dh,'Element'   
InputMsgStr_2 db ' - $'     
                        
.code
 
mov ax, @data
mov ds, ax                          
                                                                                                     
;[Vvod dliny massiva]         
                 
input_array_length proc    
    
    call arr_length_mess 	
    call inp_length 		     
endp                                             

arr_length_mess proc         
    xor bx, bx 				
    mov ah, 09h 			 
    lea dx, InputArrayLengthMsgStr
    int 21h 		
    ret 
endp   

; vvodim razmer
inp_length proc
    
    mov ah, 01h 				
	int 21h 	    	
	cmp al, 0dh 	        ; esli '\r'		
	je  push_to_arr_len		 
	jmp isNum 		       	
  next: ; perevod v ascii-kod
	sub al,'0' ;		
	xor ah, ah					
	mov cx, ax				
	xor ax, ax				 
	mov ax, bx						 				
	mul num_10				
	add ax, cx				 
	mov bx, ax 				
	jmp check_arr_length 	
endp

; proveryaem simvol [0 - 9]
isNum proc
    cmp al, '0'				
    jae nx					
    jmp errorArrLength		
  nx:
    cmp al, '9'				
    jle next				
    jmp errorArrLength		
endp  

     
; check array length
check_arr_length:
    mov cx, MaxArrayLength 	
	cmp bx, cx				
 	jle inp_length ; esli <-	
 	jmp errorArrLength 		
                   
                  
push_to_arr_len:			
    cmp bx, 1 ; esli array <= 1					
    jle errorArrLength		
    mov ArrayLength, bl		
    mov tmp, bl				
    jmp inp_array_of_shorts	;
                              
       
       
;[vvod massiva]                                   
inp_array_of_shorts proc 
    xor si, si				
    call inp_num			
endp                                                                      
                
print_arr_index:  
    mov ah, 09h
    lea dx, enter				
    int 21h     
    
    mov ah,09h
    lea dx, InputMsgStr
    int 21h        
    
    add CurEl2, 1		
    cmp CurEl2, 58		
    je set_counter 
    	
    z:
     jmp exe
     		
set_counter:				
    add CurEl1, 1
    mov CurEl2, 48
    jmp z 
    				    
inp_num proc  
    jmp print_arr_index 	
  exe:                 
    xor bx, bx 				      
    xor dx, dx				
  loop2:               
    mov ah, 01h 				
	int 21h	; vvidim chislo v massiv	
	cmp al, 0dh 			
	je  mini_max ; kogda chislo uzhe vvedeno		
	cmp al, '-'	; proveryem minus			
	je minus_check			
	jmp isNm ; check num				 
  nxt: ; perevod v ascii-kod
	sub al,'0' ; chislo i simvol chisla otlichutsya ot koda '0'
	xor ah, ah	
	mov cx, ax
	xor ax, ax
	mov ax, bx	 		 				
	mul num_10 
	jo error ; esli OF = 1
	add ax, cx
	mov bx, ax
    jmp overflow_check 
endp     


; proverka na perepolnenie
overflow_check:				
    cmp bx, 32768
    ja error				
    jmp loop2

; proverka na minus
minus_check proc  
   test bx, bx 
   jnz error ; esli ZF != 0  
   call set_minus_flag
   mov minus_flag, 1
   jmp loop2
endp

; ustanavlivayem flag minusa
set_minus_flag proc
    push cx 				
    mov cl, minus_flag 		
    test cl, cl 			 												
    pop cx 					
    jnz error ; esli ZF != 0 				
    ret  
endp 

isNm proc 
    cmp al, '0'
    jae nex
    jmp error
  nex:
    cmp al, '9'
    jle nxt
    jmp error   
endp 
; vstavlyem element chisla v massiv
push_to_arr proc 			
    add si, 2
    sub tmp, 1
    cmp tmp, 0 ;sravnivayem esli ne imeem bolshe elementov
    ja inp_num ; esli imeem				
    jmp print_task ; inache - print resultat
endp
     
     
;[poisk min i max]  
mini_max proc 
                                                                                                        
    mov cl, minus_flag
    test cl, cl
    jz pos ; esli ZF = 0
    neg bx                                                                                          
    er:
    jns error ; esli SF = 0				
    jmp e_mm   
  pos:
    cmp bx, 32768
    je error ; esli perepolnenie  
  e_mm:
   cmp si, 0
   je setMinMaxEl ; esli ZF = 1
   
   cmp bx, MinEl
   jle setMinEl ; 1 < 2
 
   cmp bx, MaxEl
   jge setMaxEl ; 1 > 2
 
   call push_to_arr  ; vstavlyem element v massiv 
endp             

; ustanavlivaem min and max element
setMinMaxEl:
    mov cl, minus_flag
    mov minus_flag_max, cl
    mov minus_flag_min, cl
    mov MinEl, bx 
    mov MaxEl, bx
    mov minus_flag, 0
    call push_to_arr

; ustanavlivaem min element    
setMinEl:
    mov cl, minus_flag
    mov minus_flag_min, cl
    mov MinEl, bx
    mov minus_flag, 0
    call push_to_arr
 
; ustanavlivaem max element
setMaxEl:
    mov cl, minus_flag
    mov minus_flag_max, cl
    mov MaxEl, bx
    mov minus_flag, 0
    call push_to_arr
    
; print "Result ((Max-Min)/Max) = "       
print_task: 
    mov ah, 09h
    lea dx, Task
    int 21h        
    jmp calculate 

;[vyvod]
                           
push_num_to_stack proc
    push dx
    push bx
    mov bx, ax 
    mov bp, sp									
loop1:  .            
    cmp ax, 0
    je skip_actions
    div b_num_10
    xor bx, bx
    mov bl, ah
    xor ah, ah
skip_actions:
    push bx 
    cmp al, 0
    je print_num 
    jmp loop1
print_num:   ; vyvod     
loop3:
    xor dx, dx  
    pop bx
    add bx, '0'
    mov ah, 02h ; vyvod
    mov dl, bl
    int 21h
    cmp bp, sp
    jne loop3
    pop bx
    pop dx    
    ret
endp

;[vychesleniya]  

calculate:                 
    mov ax, MaxEl  ; max element
    cmp ax, 0
    je err_div_0 ; esli delim na 0
    sub ax, MinEl  ; max element - min element
    call pr_div
    jmp end  


pr_div proc 
    push ax 
    push dx 
    push bx  
    mov bx, MaxEl  
    mov dl, minus_flag 
    cmp dl, minus_flag_max 
    jl sign_div ; esli <             
    
; delenie bez znaka   
unsign_div: 
    div MaxEl 
    call push_num_to_stack 
    test dx, dx 
    jz pr_div_end ; esli ZF = 0
    mov ax, MaxEl 
    call ost_output 
    jmp pr_div_end 

; delenie so znakom   
sign_div: 
    push ax
    push dx
    
    mov ah, 02h ; vyvod
    mov dx, '-'
    int 21h
    
    pop dx
    pop ax
    
    neg bx
    idiv bx 
    call push_num_to_stack  
    test dx, dx 
    jz pr_div_end ; esli ZF = 0
    mov ax, MaxEl
    cmp minus_flag_max, 0h 
    jz pr_div_ost_unsign ; esli ZF = 0
    neg ax   
       
pr_div_ost_unsign: 
    call ost_output 
    jmp pr_div_end 

; konec deleniya   
pr_div_end: 
    pop bx 
    pop dx 
    pop ax 
    ret 
endp 

; vyvod '.'
ost_output proc 
    push ax 
    push dx 
    push cx 
    push dx 
    mov bx, ax 
    mov ah, 2h 
    mov dl, '.' 
    int 21h 
    pop dx 					
    mov cx, accuracy    
;  vyvod chisel posle tochki    
ost_cycle:             
    mov ax, dx 				
    mul num_10 				
    div bx 
    push dx 
    mov dx, ax 
    mov ah, 2h 
    add dx, '0' 
    int 21h 
    sub dx, '0' 
    pop dx 
    cmp dx, dx 
    loopz ost_cycle     
ost_end: 
    pop cx 
    pop dx 
    pop ax 
    ret 
endp   

;[oshibki]  

errorArrLength: ; nekorrektnaya rezmernost
    mov ah, 09h
    lea dx, ErrorInputMsgStr
    int 21h
    jmp input_array_length 
 
error: ; nekorrektniy vvod
    mov ah, 09h
    lea dx, ErrorInputMsgStr
    int 21h
    sub CurEl2, 1 
    mov minus_flag, 0
    jmp inp_num
    
err_div_0:  ; delenie na 0
    mov ah, 09h
    lea dx, div_0_str
    int 21h
    jmp end 
    
end: 
    mov ax, 4c00h
    int 21h
