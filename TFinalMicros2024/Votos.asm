; multi-segment executable file template.
data segment
    
    TOPF db 5 dup ("              ", 0aH),00h ;14 espacos (4 pontos + 10 nome)
    dataFile db "dados.bin", 00h
    fp dw ?
    
    voter_s         db 11 dup (20h)  
    menu_s1         db 'Votar',       00h
    menu_s2         db "Gerir",       00h
    menu_s3         db "Creditos",    00h
    menu_s4         db "Sair",        00h
    askNumber_s     db "Introduza o seu numero de eleitor:", 00h
    candidate_s1    db "Manuel Maria du Bocage", 00h
    candidate_s2    db "Paula Rego", 00h
    candidate_s3    db "Luiz Vaz de Camoes", 00h
    candidate_s4    db "Natalia Correia", 00h
    candidate_s5    db "Amadeo de Souza-Cardoso", 00h
    showVoter_s     db "Eleitor: ", 00h
    continue_s      db "CONTINUAR", 00h
   
    TMP      dw   00
    author_s db "Guilherme Silva 64937",  00h
 
ends
                       
stack segment
    dw   128  dup(0)
ends

code segment
start:
    MOV     Ax, data
    MOV     ds, Ax
    MOV     es, Ax
    
    CALL    setTextMode
    
    LEA     Dx, dataFile
    CALL fopen
    JC ErrorOpen
    MOV fp, AX
    ;LEA DX, TOPF
    ;MOV CX, 75
    ;CALL fread
    error_open:
    
    main_loop:
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
    	    CALL    frontOffice
    	    CALL    clearScreen
    	    JMP     main_loop
    	
    	manage:  
            CALL    backOffice
            JMP     main_loop
    	    
    	credits:	    
    	    CALL    clearScreen
            JMP     main_loop
            
        exit_program:
            CALL    clearScreen
            ;CALL SAVEPONTUACAO
            ;CALL fclose
           
    MOV     Ax, 4c00h ; terminate program
    INT     21h
;*********************************************
;   printStr    - prints a string pointed by     
;*********************************************
    PrintString proc  
    
    MOV     Ah, 0Eh    
    printLoop:
       
        MOV     Al, [Si]
        ;MOV     Bl, 0100_1111b
        INT     10h

    INC     Si
    Loop    printLoop 
           
    RET
    PrintString endp 
;*********************************************
;   printFirstMenu  -                   
;********************************************** 
    printFirstMenu proc 
    MOV     Dx, 0410h 
    CALL    setCursorPosition
    MOV     Cx, 05          ;verificar se é preciso printar NULL terminator 
    LEA     Si, menu_s1
    CALL    printString
    
    ADD     Dh, 04
    CALL    setCursorPosition
    MOV     Cx, 05 
    LEA     Si, menu_s2
    CALL    printString
    
    ADD     Dh, 04
    DEC     Dl
    CALL    setCursorPosition
    MOV     Cx, 08  
    LEA     Si, menu_s3
    CALL    printString
    
    ADD     Dx, 0402h
    CALL    setCursorPosition
    MOV     Cx, 04
    LEA     Si, menu_s4
    CALL    printString 
    
    RET
    printFirstMenu endp
;*********************************************
;   frontOffice     -                    
;********************************************** 
    frontOffice proc   
    CALL    setVideoMode
    PUSH    Dx
     
    MOV     Dx, 0000h 
    CALL    setCursorPosition
    MOV     Cx, 34
    LEA     Si, askNumber_s      ;ver LOOPNZ
    CALL    PrintString 
    CALL    getName     ;get number
    ; Validar o número contra a lista de eleitores
    ; Verificar que o eleitor ainda não votou 
    CALL    setVideoMode
    
    MOV     Dx, 0302h 
    CALL    setCursorPosition
    MOV     Cx, 22
    LEA     Si, candidate_s1
    CALL    PrintString  
    
    ADD     Dh, 03 
    CALL    setCursorPosition
    PUSH    Cx
    MOV     Cx, 10
    LEA     Si, candidate_s2
    CALL    PrintString
    
    ADD     Dh, 03 
    CALL    setCursorPosition
    MOV     Cx, 18
    LEA     Si, candidate_s3
    CALL    PrintString
    
    ADD     Dh, 03 
    CALL    setCursorPosition
    MOV     Cx, 15
    LEA     Si, candidate_s4              ;meter algo com o hover do rato
    CALL    PrintString
    
    ADD     Dh, 03 
    CALL    setCursorPosition
    MOV     Cx, 23
    LEA     Si, candidate_s5             ;mudar para vetor de pointers
    CALL    PrintString
    
    CALL    drawSquares 
    
    ADD     Dh, 05 
    CALL    setCursorPosition
    MOV     Cx, 09
    LEA     Si, showVoter_s
    CALL    PrintString
    ;MOV    Cx tamanho
    ;LEA     Si, voter_s
    ;CALL    PrintString
    
    MOV     Dx, 1618h 
    CALL    setCursorPosition
    MOV     Cx, 09
    LEA     Si, continue_s   ;meter a vermelho?
    CALL    PrintString
    
    vote_loop:
        CALL    getClick
        CMP     Dx, 20 
        JL      vote_loop 
        CMP     Dx, 130 
        JG      vote_loop
        CMP     Cx, 460 
        JL      vote_loop 
        CMP     Dx, 480 
        JG      vote_loop
        CMP     Dx, 30
        JL      change_square
    
    change_square:
        CALL    changeToRed        
    
    ;deve ser registado no ficheiro de logs a uma linha com a data e hora a que o voto foi sumetido, o número e nome do eleitor
                       
    POP     Dx                   
    RET
    frontOffice endp 
;*********************************************
;   drawSquares    -  Bh usado como counter     ;trocar com TMP e chamar COUNTER?              
;********************************************** 
    drawSquares proc    
    PUSH    Dx 
    PUSH    Bx
    PUSH    Ax
    
    MOV     Ah, 0Ch
    MOV     Al, 1111b
    MOV     Cx, 230
    MOV     Dx, 20
    MOV     Bh, 5
    square_right:
    	    INT     10h
            INC     Cx 
            CMP     Cx, 240
            JNE     square_right
            INT     10h
            ADD     Dx, 10
            
    square_left:
    	    INT     10h
            DEC     Cx
            CMP     Cx, 230
            JNE     square_left
            INT     10h
            ADD     Dx, 15  
            DEC     Bh
            OR      Bh, Bh
            JNZ     square_right
    MOV     Bh, 5
    SUB     Dx, 15      ;melhorar?         
    MOV     TMP, 120
    square_up:
            INT     10h
            DEC     Dx
            CMP     Dx, TMP
            JNE     square_up
            INT     10h
            SUB     DX, 15
            SUB     TMP, 25
            DEC     Bh
            OR      Bh, Bh
            JNZ     square_up
    MOV     Bh, 5
    ADD     Cx, 10
    ADD     Dx, 15              
    MOV     TMP, 30
    square_down:
            INT     10h
            INC     Dx
            CMP     Dx, TMP
            JNE     square_down
            INT     10h
            ADD     DX, 15
            ADD     TMP, 25
            DEC     Bh
            OR      Bh, Bh
            JNZ     square_down
            
    POP     Dx
    POP     Bx
    POP     Ax 
    RET
    drawSquares endp  
;*********************************************
;   changeToRed     -                    
;********************************************** 
    changeToRed proc     
   
    RET
    changeToRed endp
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
    PUSH    Ax
    
	MOV     Ah, 2 	
	INT     10h  
	
	POP     Ax
	RET
    setCursorPosition endp     
;*********************************************
;   setTextMode    -              
;**********************************************    
    setTextMode proc
    PUSH    Ax 
    
	MOV     Ax, 0000h
	INT     10h 
	
	POP     Ax
	RET
    setTextMode endp

;*********************************************
;   setVideoMode    -              
;**********************************************    
    setVideoMode proc
    PUSH    Ax 
    
	MOV     Ax, 0013h
	INT     10h 
	
	POP     Ax
	RET
    setVideoMode endp
;*********************************************
;   fOpen    -              
;**********************************************    
    fOpen proc
	MOV     Ah, 3Ch
	INT     21h 
	
	RET
    fOpen endp
;*********************************************
;   getClick -           
;**********************************************    
    getClick Proc         
    PUSH    AX
    PUSH    BX
        
    inic:
        MOV     AX,03h
    	INT     33h
        CMP     BX, 1 
        JNE     inic
        
    POP     AX
    POP     BX 
    RET
    getClick endp
;*********************************************
;   clearScreen - clears the screen           
;**********************************************    
    clearScreen proc
    PUSH    Ax
    ;PUSH    Bx 
    PUSH    Cx
    PUSH    Dx
    	
    MOV     Ah, 07h
    MOV     Al, 00h
    ;MOV     Bx, 0010_1111b      ; low 4 bits set fore color, high 4 bits set background color.
    MOV     Cx, 0000h
    MOV     Dx, 184Fh
    INT     10h 
    
    POP    Ax
    ;POP    Bx 
    POP    Cx
    POP    Dx	
    RET
    clearScreen endp
   ; clearScreen proc
	;push ax
	;mov ah,06
	;mov al,00
	;mov BH,07 ; attributes to be used on blanked lines
	;mov cx,0 ; CH,CL = row,column of upper left corner of window to scroll
	;mov DH,25 ;= row,column of lower right corner of window
	;mov DL,40
	;int 10h
	;pop ax
	;ret
;********************************
    fcreate PROC
    CLC     
    MOV CX, 0       ; cria um ficheiro normal
    MOV AH, 3CH     ; codigo para criar ficheiro
    INT 21H
    JC errcreating       ; se nao der -> CARRY = 1 -> faz jump
    RET
    errcreating:
    RET    ;mudar
    
    fcreate ENDP
;*********************************************
;   ReadStr     - reads a string                     
;**********************************************
    ReadStr proc
    PUSH    Ax        
        
       ; MOV CONTAGEM, 00h
    readLoop:                  
        MOV     Ah, 01h
        INT     21h
        MOV     [Di], Al
        INC     Di
           ; INC CONTAGEM
           ; CMP CONTAGEM, 11
        ;JE      endReadLoop
        CMP     Al, 0dh
        JE      endReadLoop
        JMP     readLoop
    endReadLoop: 
        DEC     Di
        MOV     [Di], 0dh 
            
    POP     AX     
    RET            
    ReadStr endp                 
;*****************************************************
;   getName   - prints an int                  
;*****************************************************                   
   getName proc 
        MOV DH, 14
        MOV DL, 10 
        MOV CX, 13
        ADD DH, 1
        MOV BH, 0
        CALL setCursorPosition
        
        LEA di, voter_s
        CALL readStr
        
    RET
    getName endp
;*****************************************************
;   getNumber   - prints an int                  
;***************************************************** 
    getNumber proc
    MOV AH, 2Ch
    INT 21h
    MOV AX, DX
    MOV AH, 00
    MOV BL, 7
    DIV BL 

    RET
    getNumber endp

                  
ends
end start ; set entry point and stop the assembler.