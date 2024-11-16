; multi-segment executable file template.
data segment
    
    dataFile dw "dados.bin", 00h
    
    voter_s         db 31 dup (20h)
    voterNumber_s   db 7 dup (20h)
    numLen  EQU $ - voterNumber_s
    error:
        db "warning: path not found",              "$"
        db "warning: access denied",               "$"     ;24
        db "error: invalid handler/file not open", "$"     ;47
        db "error: please input a number",         "$"     ;46
        db "error: empty argument",                "$"     ;113 
        db "error: couldn't write to file",        "$"     ;135
    menu:
        db 'Votar',         "$"
        db "Gerir",         "$"
        db "Creditos",      "$"
        db "Sair",          "$"
    numInput_s    db  "Introduza o seu numero de eleitor:", "$"
    nameInput_s   db  "Introduza o seu nome:",              "$"
    candidates:
        db "Manuel Maria du Bocage",    "$"
        db "Paula Rego",                "$"
        db "Luiz Vaz de Camoes",        "$"
        db "Natalia Correia",           "$"
        db "Amadeo de Souza-Cardoso",   "$"
    other_s:
       db "Eleitor: ",    "$" 
       db " - ",          "$"           ;10
       db "CONTINUAR",    "$"           ;14
       db "Saving...",    "$"           ;24 
       
    author_s db "Guilherme Silva 64937",  "$"
ends
                       
stack segment
    dw   128  dup(0)
ends

code segment
start:
    MOV     Ax, data
    MOV     ds, Ax
    MOV     es, Ax
    
    CALL    fOpen
    ;CALL    fCreate 
    main_loop:
        CALL    setTextMode     
        CALL    printFirstMenu      
  
    click_loop:
        CALL    getClick
	    CMP     Cx, 120
	    JL      click_loop
	    CMP     Cx, 420
	    JG      click_loop
	    CMP     Dx, 15
	    JL      click_loop
	    CMP     Dx, 135
	    JG      click_loop
	    CMP     Dx, 45
        JL      vote
        CMP     Dx, 75
        JL      manage
        CMP     Dx, 105
        JL      credits
        JMP     exit_program
  
    	vote:
    	    CALL    clearMenu 
    	    CALL    frontOffice
    	    JMP     main_loop
    	
    	manage:  
            CALL    backOffice
            JMP     main_loop
    	    
    	credits:
    	    CALL    clearMenu
    	    MOV     Dx, 0B08h 
            CALL    setCursorPosition   
            LEA     Dx, author_s
            CALL    printStr$   
            
    	    CALL    getClick
    	    ;MOV     Dx, 440
    	    ;CALL    clearLine
            JMP     main_loop
            
        exit_program:
            CALL    clearMenu
            ;CALL   SAVE
            CALL    fclose
           
    MOV     Ax, 4c00h
    INT     21h
;*****************************************************
;   printStr$    - prints a string terminated by $    
;*****************************************************
    printStr$ proc  
    MOV     Ah, 09h
    INT     21h
           
    RET
    printStr$ endp 
;*********************************************
;   printFirstMenu  -                   
;********************************************** 
    printFirstMenu proc 
    MOV     Dx, 0411h 
    CALL    setCursorPosition
    LEA     Dx, menu
    CALL    printStr$
    
    MOV     Dx, 0811h
    CALL    setCursorPosition
    LEA     Dx, menu+6
    CALL    printStr$
    
    MOV     Dx, 0C10h
    CALL    setCursorPosition
    LEA     Dx, menu+12
    CALL    printStr$
    
    MOV     Dx, 1012h
    CALL    setCursorPosition
    LEA     Dx, menu+21
    CALL    printStr$ 
    
    RET
    printFirstMenu endp
;*********************************************
;   clearMenu  -                   
;********************************************** 
    clearMenu proc 
    MOV     Dx, 160
    CALL    clearLine
    ADD     Dx, 160
    CALL    clearLine
    ADD     Dx, 160
    CALL    clearLine
    ADD     Dx, 160
    CALL    clearLine
    
    RET
    clearMenu endp
;*********************************************
;   frontOffice     -                    
;********************************************** 
    frontOffice proc       
    MOV     Dx, 0000h 
    CALL    setCursorPosition
    LEA     Dx, numInput_s   
    CALL    PrintStr$  
    CALL    getNumber      
    
    MOV     Dx, 0600h 
    CALL    setCursorPosition
    LEA     Dx, nameInput_s   
    CALL    PrintStr$  
    CALL    getName 
    ; Validar o número contra a lista de eleitores      SCASW
    ; Verificar que o eleitor ainda não votou           SCASB
    CALL    setVideoMode
    
    MOV     Dx, 0302h 
    CALL    setCursorPosition
    LEA     Dx, candidates
    CALL    PrintStr$  
    
    MOV     Dx, 0602h 
    CALL    setCursorPosition
    LEA     Dx, candidates+23
    CALL    PrintStr$
    
    MOV     Dx, 0902h 
    CALL    setCursorPosition
    LEA     Dx, candidates+34
    CALL    PrintStr$
    
    MOV     Dx, 0C02h 
    CALL    setCursorPosition
    LEA     Dx, candidates+53              
    CALL    PrintStr$
    
    MOV     Dx,0F02h 
    CALL    setCursorPosition
    LEA     Dx, candidates+69             ;mudar para vetor de pointers
    CALL    PrintStr$
   
    LEA     Si, [6630]
    CALL    printSquare 
    LEA     Si, [14630]         ;meter em variaveis
    CALL    printSquare
    LEA     Si, [22630]
    CALL    printSquare
    LEA     Si, [30630]
    CALL    printSquare
    LEA     Si, [38630]
    CALL    printSquare             
   
    MOV     Dx, 1402h 
    CALL    setCursorPosition
    LEA     Dx, other_s
    CALL    PrintStr$
    
    LEA     Dx, voterNumber_s       
    CALL    PrintStr$
    LEA     Dx, other_s+10
    CALL    PrintStr$     
    LEA     Dx, voter_s   
    CALL    PrintStr$
    
    MOV     Dx, 1618h 
    CALL    setCursorPosition
    LEA     Dx, other_s+14                  ;meter a vermelho?
    CALL    PrintStr$
    
    vote_loop:
        CALL    getClick
        JMP     continue
        CMP     Dx, 20 
        JL      vote_loop 
        CMP     Dx, 130 
        JG      vote_loop
        CMP     Cx, 460 
        JL      vote_loop 
        CMP     Dx, 480 
        JG      vote_loop
        CMP     Dx, 30
        JL      square_1
        CMP     Dx, 45
        JL      vote_loop
        CMP     Dx, 55
        JL      square_2
        CMP     Dx, 70
        JL      vote_loop
        CMP     Dx, 80
        JL      square_3
        CMP     Dx, 95
        JL      vote_loop
        CMP     Dx, 105
        JL      square_4
        CMP     Dx, 120
        JL      vote_loop
        JMP     square_5
    
    square_1:
        LEA     Si, [6630]
        CALL    printSquare
        JMP     vote_loop
    square_2:    
        LEA     Si, [14630]
        CALL    printSquare
        JMP     vote_loop
    square_3:    
        LEA     Si, [22630]
        CALL    printSquare
        JMP     vote_loop
    square_4:    
        LEA     Si, [30630]
        CALL    printSquare
        JMP     vote_loop
    square_5:    
        LEA     Si, [38630]
        CALL    printSquare
        JMP     vote_loop        
    
    continue:    
        CALL    saveVotes
                  
    RET
    frontOffice endp 
;*********************************************
;   printSquare     -    args: si, al                
;********************************************** 
    printSquare proc
    PUSH    ds
    PUSH    Bx
    
    MOV     Ax, 0A000h   
    MOV     ds, Ax
    
    XOR     Dx, Dx           
    MOV     Ax, Si
    MOV     Bx, 320
    DIV     Bx
    MOV     Cx, Dx          ; Si % 320
    MOV     Dx, Ax          ; Si / 320        
    MOV     Ah, 0Dh
    INT     10h     
    
    CMP     Al, 0Fh
    JE      change_color
    MOV     Al, 0Fh
    JMP     no_change  
    
    change_color:
        MOV     Al, 0Ch  
        
    no_change:
    MOV     Cx, 10
    right_square:
        MOV     [Si], Al     
        INC     Si           
        LOOP    right_square
                   
    MOV     Cx, 10
    left_square:
        MOV     [Si], Al     
        ADD     Si, 320          
        LOOP    left_square
   
    MOV     Cx, 10
    up_square:
        MOV     [Si], Al    
        DEC     Si           
        LOOP    up_square
          
    MOV     Cx, 10
    down_square:
        MOV     [Si], Al      
        SUB     Si, 320             
        LOOP    down_square
    
    POP     Bx    
    POP     ds
    RET
    printSquare endp
;*********************************************
;   saveVotes     -                    
;********************************************** 
    saveVotes proc
    CLC
    CALL    setTextMode
    MOV     Ah, 40h
    MOV     Cx, numLen
    LEA     Dx, error
    INT     21h
    JC      error_write
    LEA     Dx, other_s+24
    CALL    printStr$
    CALL    getClick 
    RET
    
    error_write: 
        LEA     Dx, error+113
        CALL    printStr$  
   
    RET
    saveVotes endp
;*********************************************
;   backOffice     -                    
;********************************************** 
    backOffice proc    
    CALL    clearScreen  
   
    RET
    backOffice endp
;*********************************************
;   setCursorPosition     -                    
;**********************************************   
    setCursorPosition proc
    MOV     Ah, 2
    XOR     Bh, Bh  	
	INT     10h  
	
	RET
    setCursorPosition endp     
;*********************************************
;   setTextMode    -              
;**********************************************    
    setTextMode proc    
	MOV     Ax, 0000h
	INT     10h 
	
	RET
    setTextMode endp

;*********************************************
;   setVideoMode    -              
;**********************************************    
    setVideoMode proc
    MOV     Ax, 0013h
	INT     10h 
	
	RET
    setVideoMode endp
;*********************************************
;   fOpen    -              
;**********************************************    
    fOpen proc
    CLC
	MOV     Ah, 3Dh 
	MOV     Al, 02
	LEA     Dx, dataFile
	INT     21h
	JC      err_open
	MOV     Bx, Ax    
    RET
    err_open:
        CMP     Ax, 03
        JE      no_path
        LEA     Dx, error
        CALL    printStr$
        RET
        
    no_path:
        LEA     Dx, error+24        ;testar
        CALL    printStr$ 
	
	RET
    fOpen endp
;*********************************************
;   getClick -           
;**********************************************    
    getClick Proc 
    PUSH    BX
        
    inic:
        MOV     AX,03h
    	INT     33h
        CMP     BX, 1 
        JNE     inic
        
    POP     BX
    RET
    getClick endp  
;*********************************************
;   clearLine - clears a line              
;**********************************************    
    clearLine proc
    PUSH    Cx
    PUSH    Di
    PUSH    Ax
    
    MOV     Ax, 0B800h       
    MOV     es, Ax            

    MOV     Di, Dx           
    SHL     Di, 1
    MOV     Cx, 40            

    MOV     Ax, 0720h               ;cool bug -> tirar push/pop
    REP     STOSW            
	
	POP     Ax
	POP     Di
	POP     Cx
    RET
    clearLine endp
;*********************************************
;   clearScreen - clears the screen           
;**********************************************    
    clearScreen proc
    PUSH    Ax
    MOV     Ax, 0B800h        
    MOV     es, Ax            

    XOR     Di, Di            
    MOV     Cx, 1000          

    MOV     Ax, 0720h           
    fill_screen:
        STOSW 
        LOOP fill_screen    
	
	POP     Ax
    RET
    clearScreen endp
;*********************************************
;   fCreate -       
;**********************************************
    fCreate PROC
    CLC             
    MOV     Cx, 00h
    MOV     Dx, offset dataFile       
    MOV     Ah, 3Ch     
    INT     21h
    JC      err_create
    MOV     Bx, Ax    
    RET
    err_create:
        MOV     Dx, 0000h
        CALL    setCursorPosition
        LEA     Dx, error+47
        CALL    printStr$  
        
    RET
    fCreate ENDP
;*********************************************
;   fclose - close a file           
;**********************************************
    fclose PROC
    CLC          
    MOV     AH, 3EH     
    INT     21H
    JC      err_closing    
    RET
    err_closing:
        MOV     Dx, 0000h
        CALL    setCursorPosition
        LEA     Dx, error+47
        CALL    printStr$
    
    RET 
    fclose ENDP
;*****************************************************
;   getNumber   -                   
;*****************************************************                   
    getNumber proc                       ;input:t6 da merda
    MOV     DX, 0301h
    LEA     Di, voterNumber_s
    MOV     Cx, 6                  
    readNum_loop:
        INC     Dx
        CALL    setCursorPosition
        MOV     Ah, 01h
        INT     21h
        CMP     Al, 13
        JE      num_end              
        CMP     AL, '0'
        JL      err_read
        CMP     AL, '9'
        JG      err_read
        MOV     [Di], Al
        INC     Di                  
        LOOP    readNum_loop
        JMP     num_end    
       
    err_read:                 ;METER UM ESPACO
        PUSH    Dx
        MOV     Dx, 0400h
        CALL    setCursorPosition
        LEA     Dx, error+84
        CALL    printStr$ 
        CALL    wait_1s
        MOV     Dx, 160
        CALL    clearLine
        POP     Dx
        DEC     Dx
        JMP     readNum_loop
        
    err_emptyNumber:
        PUSH    Dx
        MOV     Dx, 0400h
        CALL    setCursorPosition
        LEA     Dx, error+113
        CALL    printStr$
        CALL    wait_1s
        MOV     Dx, 160
        CALL    clearLine
        POP     Dx
        DEC     Dx
        JMP     readNum_loop
        
    num_end:
    CMP     Cx, 6
    JE      err_emptyNumber
    MOV     [Di], 36
        
    RET
    getNumber endp
;*****************************************************
;   getName   - prints an int                  
;*****************************************************                   
    getName proc                     ;implementar backspace
    MOV     Dx, 0901h 
    LEA     Di, voter_s
    MOV     Cx, 30
    readName_loop:
        INC     Dx
        CALL    setCursorPosition                  
        MOV     Ah, 01h
        INT     21h
        MOV     [Di], Al
        INC     Di
        CMP     Al, 13
        JE      name_end
        LOOP    readName_loop
        JMP     name_end
        
    err_emptyName:                     ;codigo repetido
        PUSH    Dx
        MOV     Dx, 0D00h
        CALL    setCursorPosition
        LEA     Dx, error+113
        CALL    printStr$
        CALL    wait_1s
        MOV     Dx, 520
        CALL    clearLine
        POP     Dx
        DEC     Dx
        CALL    readName_loop
        
    name_end:
    CMP     Cx, 30
    JE      err_emptyName
    MOV     [Di], 36 
        
    RET
    getName endp
;*****************************************************
;   getSystemTime   -    push bx               
;***************************************************** 
getSystemTime proc
MOV    AH, 2Ch
INT    21h
MOV    AX, DX
MOV    AH, 00
MOV    BL, 7
DIV    BL 

RET
getSystemTime endp 
;*****************************************************
;   wait_1s   -            
;*****************************************************
wait_1s PROC      
    PUSH    Dx

    MOV     Cx, 0Fh
    MOV     Dx, 4240h
    MOV     Ah, 86h
    INT     15h

    POP DX        
    RET
wait_1s ENDP
                  
ends
end start ; set entry point and stop the assembler.