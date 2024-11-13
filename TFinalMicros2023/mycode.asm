; multi-segment executable file template.
data segment
    
    TOPF db 5 dup ("              ", 0aH),00h ;14 espacos (4 pontos + 10 nome)
    
    strfile db "top5.bin", 00h
    fp dw ?
      
    strj db "Jogar", 00H
    strtop db "Top 5", 00H
    strcred db "Creditos", 00H
    strsair db "Sair", 00h
    strocar db "Trocar", 00h
    sContinuar db "Continuar", 00h
    sCalculando db "Calculando", 00h
    sTOP db "top 5", 00h
    SPONTOS db "PONTOS", 00h
    sErro db "ERRO", 00h
    sResultado db "Resultado:", 00h
    sGame db "Press: - ENTER to keep cards", 00h
    sCredits db "Press: - ENTER to leave", 00h
    sGame2 db "- any other key to select", 00h 
    sAUX db "AUX", 00h
    
    sRF db "150 pontos (Royal Flush)", 00h
    sSF db "100 pontos (Straight Flush)", 00h
    sFK db "80 pontos (Four Of A Kind)", 00h
    sFH db "60 pontos (Full House)", 00h
    sF db "40 pontos (Flush)", 00h
    sSt db "30 pontos (Straight)", 00h
    sSet db "25 pontos (Set - Three Of A Kind)", 00h
    sTP db "20 pontos (Two Pair)", 00h
    sOP db "15 pontos (One Pair)", 00h
    sHC db "1 ponto (High Card)", 00h
    
    nomeJ db "nome Jogador:", 00H
    JOGADOR db 11 dup (20h)   ;definir tamanho string?? 
    
    CONTAGEM db 00h          ;conta tamanho do nome do jogador   
    COUNTER db 00h           ;conta o valor das cartas
    COUNTER2 db 00h          ;conta o simbolo das cartas
    PairCounter db 00h
    PONTOS db 00h            ;guarda a pontuação
    
    valC1 db 00h             ;valor da 1a carta
    symC1 db 00h             ;simbolo da 1a carta
    C1escolhida db 00h       ;escolha da 1a carta
    valC2 db 00h             ;valor da 2a....
    symC2 db 00h 
    C2escolhida db 00h
    valC3 db 00h
    symC3 db 00h   
    C3escolhida db 00h
    valC4 db 00h
    symC4 db 00h  
    C4escolhida db 00h
    valC5 db 00h 
    symC5 db 00h  
    C5escolhida db 00h
                             ;variavel temp para printar 10's
    TMPCursorL db 00h
    TMPCursorH db 00h
    
    credits db "//   Creditos   //", 00H
    credit db "Guilherme Silva 64937",00H
    
    strex db "Sair",00H

ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    MOV ax, data
    MOV ds, ax
    MOV es, ax
    
    LEA DX, strfile
    MOV AL, 2
    CALL fopen
    JC ErrorOpen
    MOV fp, AX
    MOV BX, AX
    LEA DX, TOPF
    MOV CX, 75
    CALL fread
    JMP textmode
    
    ErrorOpen:
        CALL fcreate
        Mov  fp, AX
    
    textmode:
        MOV Al, 13h ; modo vídeo
	    INT 10h
        
    gameloop:
        CALL putFirstW 
    clickloop:
        CALL getClick
	    CMP Cx, 236
	    JL clickloop
	    CMP Cx, 420
	    JG clickloop
	    CMP Dx, 15
	    JL clickloop
	    CMP Dx, 135
	    JG clickloop
	    CMP Dx, 45
        JL jogar
        CMP Dx, 75
        JL top
        CMP Dx, 105
        JL cred
        JMP sair
  
    	jogar: 
    	    CALL clearScreen  
    	    CALL getPlayerName
    	    
    	    CALL clearScreen
    	    CALL printButtons
    	    
    	    ;CALL printCards
    	    
    	repete:    
    	    CALL putNumbers
    	    CALL game    
    	    
    	click3:    
    	    CALL getClick
    	   
    	    CMP CX, 60      
    	    JL click3
    	    CMP DX, 190 
    	    JG click3
    	    CMP CX, 600
    	    JG click3    	    
    	    CMP DX, 170
    	    JL click3
    	    
    	    CMP CX, 160
    	    JL acabaJogo
    	    CMP CX, 460
    	    JL click3
    	    CMP CX, 600
    	    JL continua
    	    JMP click3
    	    
        	continua:
        	    CALL subP
                CALL resetCards
        	    JMP repete
    	       
    	    acabaJogo:
                CALL clearScreen
               ;CALL SAVEPONTUACAO
                JMP gameloop
    	
    	top:     
    
            MOV CONTAGEM, 00h 
    
            CALL clearScreen
            MOV DX, 0404h ; define as coordenadas (X,Y) em que vai comecar a escrever a string
            MOV CX, 5
            LEA BP, sTOP
            CALL printStr 
        
            MOV DX, 070Dh ; define as coordenadas (X,Y) em que vai comecar a escrever a string
            MOV CX, 0Eh 
            LEA BP, TOPF
            
            topLoop:
                CMP CONTAGEM, 5
                JE Fim
                 
                CALL printStr
                ADD DH, 2
                INC CONTAGEM
                ADD BP, 0Fh
                jmp topLoop
            Fim:
                MOV DL, 02
                MOV DH, 19
                CALL setCursorPosition
                MOV CX, 23
                LEA BP, sCredits
                CALL printStr
                MOV AH, 01h        
                INT 21h    
                CMP AL, 0Dh    ; Compara a tecla premida com o codigo 
                JE acabaTop      ; ASCII da tecla (Enter)
            acabaTop:
                CALL clearScreen
                JMP gameloop
    	    
    	cred:	    
    	    CALL creditos
    	    CALL clearScreen
            JMP gameloop
        sair:
            CALL clearScreen
            CALL fclose
             
          
    MOV AX,4c00h ; terminate program
    INT 21h
;***********************                   
    creditos proc 
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH BP
        
        CALL clearScreen 
        MOV DH, 1
        MOV DL, 10
        MOV CX, 18   
        LEA BP, credits
        CALL printStr
        MOV DH, 04
        MOV DL, 9
        MOV CX, 21
        LEA BP, credit  
        CALL printStr
        MOV DL, 02
        MOV DH, 21
        CALL setCursorPosition
        MOV CX, 23
        LEA BP, sCredits
        CALL printStr
        
        MOV AH, 01h        
        INT 21h    
        Enter:
            CMP AL, 0Dh    ; Compara a tecla premida com o codigo 
            JNE Enter       ; ASCII da tecla (Enter)               
        
        POP AX
        POP CX
        POP DX
        POP BP
        RET            
    creditos endp
  
  ;  *************************   
    getClick Proc         
        PUSH AX
        PUSH BX
        
        inic:
            MOV AX,03h
    	    INT 33h
            CMP BX, 1 
        	JNE inic
        
        POP AX
        POP BX
    	RET
    getClick endp 
;******************************  
    fread PROC
       
        CLC
        MOV AH, 3FH     ; codigo para ler de ficheiros
        INT 21H
      
        RET
    fread ENDP
;********************************
    fwrite PROC
    
    CLC
    MOV AH, 40H     ; codigo para escrever em ficheiros
    INT 21H
 
    RET

    fwrite ENDP
;********************************
    fcreate PROC
    
    CLC     
    MOV CX, 0       ; cria um ficheiro normal
    MOV AH, 3CH     ; codigo para criar ficheiro
    INT 21H
    JC errcreating       ; se nao der -> CARRY = 1 -> faz jump
    RET
    errcreating:
    ret    ;mudar
    
    fcreate ENDP
;*******************************
    fopen PROC
    
    CLC
    MOV AH, 3DH     ; codigo para abrir ficheiros
    INT 21H
    RET

    fopen ENDP
;******************************* 
    fclose PROC
    
    CLC
    MOV AH, 3EH     ; codigo para abrir ficheiros
    INT 21H
    RET

    fclose ENDP
;*********************************************
;   printStr    - prints a string            
;   input       - BP <- string to print      
;   ouput       -                            
;   infos       - white with red backround     
;*********************************************
    PrintStr proc
        PUSH AX
        PUSH BX
    
        MOV AL, 01h  
        MOV BL, 0100_1111b
        MOV AH, 13h
        INT 10h
    
        POP BX 
        POP AX
        ret
    PrintStr endp
;*********************************************
;   printChar    - prints a character
;   input       - AL <- character to print    
;   ouput       -                     
;   infos       -                     
;**********************************************
    PrintChar proc
        PUSH AX    
        PUSH CX
        
        MOV AH, 09h ;AH,02H 
        MOV CX, 1 ;DL, AL
        INT 10h ;21h 
        
        POP CX
        POP AX
        RET
    PrintChar endp
;*********************************************
;   ReadStr     - reads a string
;   input       -     
;   ouput       -                     
;   infos       - reads 11 characters                    
;**********************************************
    ReadStr proc
        PUSH AX        
        
        MOV CONTAGEM, 00h
        Read:                  
            MOV AH, 01h
            INT 21h
            MOV [DI], AL
            INC DI
            INC CONTAGEM
            CMP CONTAGEM, 11
            JE EndRead
            cmp AL, 0dh
            je EndRead
            jmp Read
        EndRead: 
            DEC DI
            MOV [DI], 0dh 
            
        POP AX     
        ret            
    ReadStr endp 
;*********************************************
;   clearScreen - clears the screen
;   input       -    
;   ouput       -                     
;   infos       -                     
;**********************************************    
    clearScreen proc
    	push ax
    	
    	mov ah, 00h
    	mov al, 13h
    	int 10h 
    	
    	pop ax
    	ret
    clearScreen endp
;*********************************************
;   clearCalc   - prints over sCalculando 
;   input       -    
;   ouput       -                     
;   infos       - prints in black to "erase" it                  
;***********************************************
    clearCalc proc
       
        MOV DL, 12
        MOV DH, 16
        CALL setCursorPosition
        MOV CX, 10
        LEA BP, sCalculando
        MOV AL, 01h  
        MOV BL, 0000_0000b
        MOV AH, 13h
        INT 10h
        MOV DL, 23
        MOV DH, 16
        CALL setCursorPosition
        MOV AL, 2Eh
        MOV BL, 0
        CALL printChar
        MOV DL, 25
        MOV DH, 16
        CALL setCursorPosition
        MOV AL, 2Eh
        MOV BL, 0 
        CALL printChar
        
        RET
    clearCalc endp    
;*****************************************************
;   printInt   - prints an int 
;   input       - al <- it to print   
;   ouput       -                     
;   infos       - can be upgraded to print with colors                  
;*****************************************************
    printInt proc

        intLoop:
            MOV AH, 00
            MOV BL, 10
            DIV BL
            
            MOV CH, AL          ;CH E UM TEMP
            CMP CH, 0
            JE fimInt
            DEC DL   
            MOV AL, AH
            ADD AL, 48
            MOV BL, 15
            CALL printChar 
            
            MOV AL, CH
           
            CALL setCursorPosition
            JMP intLoop
        
        fimInt:
            MOV AL, AH
            CALL setCursorPosition
            ADD AL, 48
            MOV BL, 15
            CALL printChar
        
        RET
    printInt endp
;*************************    
    addP proc
        MOV DL, 29
        MOV DH, 2
        CALL setCursorPosition

        MOV AL, COUNTER
        ADD PONTOS, AL
        MOV AL, PONTOS
         
        CALL printInt
        
        RET
    addP endp
;***********************************
    subP proc
        
        MOV DL, 29
        MOV DH, 2
        CALL setCursorPosition

        SUB PONTOS, 10
        MOV AL, PONTOS
        CALL printInt
        
        RET
    subP endp    
;*************************    
    setVideoMode proc
	push ax
	mov ah,00 ; modo vídeo
	Int 10h
	pop ax
	ret
    setVideoMode endp                 
   ;*********************************  
    getMousePos proc
	push ax
	mov ax,03h
	int 33h
	pop ax
	ret
    getMousePos Endp
   ;*********************************
    HideBlinkingCursor proc
	push cx
	mov ch, 32  ;(0001 0000B)
	mov ah, 1 
	int 10h 
	pop cx
       ret
    HideBlinkingCursor endp
  ;*********************************   
    setCursorPosition proc
	mov ah,2 	
	Int 10h
	ret
    setCursorPosition endp
 ;**********************************   
    putFirstW proc 
        push bp
        
        ;call putLines         ;;;;;;;;;;;;;;;;;;;;;;;;;
        MOV DX, 0310h 
        MOV CX, 5h
        lea bp, strj 
        call PrintStr
        add dh, 04h
        lea bp, strtop
        call PrintStr
        add dh, 04h 
        MOV CX, 8h
        lea bp, strcred
        call PrintStr
        add dh, 04h 
        MOV CX, 4h
        lea bp, strex
        call PrintStr
        
        pop bp
        ret
    putFirstW endp
;*************************************                  
    putLines proc
        MOV Al, 15
        MOV Cx, 120
        MOV Dx, 15
        put1:
            mov ah,0ch
    	    int 10h
            inc Cx
            cmp Cx, 210
            jne put1
        mov Cx, 120
        mov Dx, 45    
        put2:
            mov ah,0ch
    	    int 10h
            inc Cx
            cmp Cx, 210
            jne put2
        mov Cx, 120
        mov Dx, 15    
        put3:
            mov ah,0ch
    	    int 10h
            inc Dx
            cmp Dx, 135
            jne put3
        mov Cx, 210
        mov Dx, 15    
        put4:
            mov ah,0ch
    	    int 10h
            inc Dx
            cmp Dx, 135
            jne put4
        mov Cx, 120
        mov Dx, 75
        put5:
            mov ah,0ch
    	    int 10h
            inc Cx
            cmp Cx, 210
            jne put5
        mov Cx, 120
        mov Dx, 105    
        put6:
            mov ah,0ch
    	    int 10h
            inc Cx
            cmp Cx, 210
            jne put6
        mov Cx, 120
        mov Dx, 135
        put7:
            mov ah,0ch
    	    int 10h
            inc Cx
            cmp Cx, 210
            jne put7  
        ret
    putLines endp
  ;*****************
   getPlayerName proc 
        CALL hideBlinkingCursor
        MOV DH, 14
        MOV DL, 10 
        MOV CX, 13
        LEA BP, nomeJ 
        CALL PrintStr
        ADD DH, 1
        MOV BH, 0
        CALL setCursorPosition
        
        LEA di, JOGADOR
        CALL readStr
        
        RET
    getPlayerName endp
;********************************
    resetCards proc
        
        MOV valC1, 00
        MOV symC1, 00
        MOV C1escolhida, 00
        MOV valC2, 00
        MOV symC2, 00
        MOV C2escolhida, 00
        MOV valC3, 00
        MOV symC3, 00
        MOV C3escolhida, 00
        MOV valC4, 00
        MOV symC4, 00
        MOV C4escolhida, 00
        MOV valC5, 00
        MOV symC5, 00
        MOV C5escolhida, 00
        
        MOV DL, 5
        MOV DH, 10
        CALL setCursorPosition
        MOV CL, 3
        LEA BP, sAUX
        MOV AL, 01h  
        MOV BL, 0000_0000b
        MOV AH, 13h
        INT 10h
                    
        MOV DL, 12
        MOV DH, 10
        CALL setCursorPosition
        MOV CL, 3
        LEA BP, sAUX
        MOV AL, 01h  
        MOV BL, 0000_0000b
        MOV AH, 13h
        INT 10h
             
        MOV DL, 19
        MOV DH, 10
        CALL setCursorPosition
        MOV CL, 3
        LEA BP, sAUX
        MOV AL, 01h  
        MOV BL, 0000_0000b
        MOV AH, 13h
        INT 10h
            
        
        MOV DL, 27
        MOV DH, 10 
        CALL setCursorPosition
        MOV CL, 3
        LEA BP, sAUX
        MOV AL, 01h  
        MOV BL, 0000_0000b
        MOV AH, 13h
        INT 10h 

        MOV DL, 34
        MOV DH, 10  
        CALL setCursorPosition
        MOV CL, 3
        LEA BP, sAUX
        MOV AL, 01h  
        MOV BL, 0000_0000b
        MOV AH, 13h
        INT 10h
            
        RET
    resetCards endp   
   ;**********************
    putNumbers proc
        meteC1:
            MOV DL, 5
            MOV DH, 10
            CALL NumberPut   ;ver se da merda
            CALL addP
            MOV DL, COUNTER
            MOV valC1, DL 
            MOV COUNTER, 00   ;COUNTER É METIDO A 0
            MOV DL, 6
            MOV DH, 10
            CALL SymbolPut
            MOV symC1, DL
            MOV COUNTER2, 00 
            
        meteC2:
            MOV AL, valC2
            SUB PONTOS, AL
        
            MOV DL, 12
            MOV DH, 10
            CALL NumberPut
            CALL addP
            MOV DL, COUNTER
            MOV valC2, DL
            MOV COUNTER, 00    ;COUNTER É METIDO A 0 
            MOV DL, 13
            MOV DH, 10
            CALL SymbolPut
            MOV symC2, DL 
            MOV COUNTER2, 00 
            
            MOV BL, valC1       ;verifica se a carta ja existe
            CMP valC2, BL
            JNE meteC3
            MOV BL, symC1
            CMP symC2, BL
            JE meteC2
             
        meteC3:
            MOV AL, valC3
            SUB PONTOS, AL
        
            MOV DL, 19
            MOV DH, 10
            CALL NumberPut
            CALL addP
            MOV DL, COUNTER
            MOV valC3, DL
            MOV COUNTER, 00  ;COUNTER É METIDO A 0 
            MOV DL, 20
            MOV DH, 10
            CALL SymbolPut
            MOV symC3, DL 
            MOV COUNTER2, 00

            MOV BL, valC1       ;verifica se a carta ja existe
            CMP valC3, BL
            JNE verifC3_C2
            MOV BL, symC1
            CMP symC3, BL
            JE meteC3
            
        verifC3_C2:    
            MOV BL, valC2
            CMP valC3, BL
            JNE meteC4
            MOV BL, symC2
            CMP symC3, BL
            JE meteC3
            
            
        meteC4:
            MOV AL, valC4
            SUB PONTOS, AL
        
            MOV DL, 27
            MOV DH, 10
            CALL NumberPut ;ver se n da merda
            CALL addP
            MOV DL, COUNTER
            MOV valC4, DL
            MOV COUNTER, 00   ;COUNTER É METIDO A 0 
            MOV DL, 28
            MOV DH, 10
            CALL SymbolPut
            MOV symC4, DL
            MOV COUNTER2, 00  
            
            MOV BL, valC1       ;verifica se a carta ja existe
            CMP valC4, BL
            JNE verifC4_C2
            MOV BL, symC1
            CMP symC4, BL
            JE meteC4
            
        verifC4_C2:    
            MOV BL, valC2
            CMP valC4, BL
            JNE verifC4_C3
            MOV BL, symC2
            CMP symC4, BL
            JE meteC4
                     
        verifC4_C3:
            MOV BL, valC3
            CMP valC4, BL
            JNE meteC5
            MOV BL, symC3
            CMP symC4, BL
            JE meteC4
                     
        meteC5:
            MOV AL, valC5
            SUB PONTOS, AL
        
            MOV DL, 34
            MOV DH, 10
            CALL NumberPut
            CALL addP
            MOV DL, COUNTER        
            MOV valC5, DL
            MOV COUNTER, 00   ;COUNTER É METIDO A 0 
            MOV DL, 35
            MOV DH, 10
            CALL SymbolPut
            MOV symC5, DL 
            MOV COUNTER2, 00
            
            MOV BL, valC1       ;verifica se a carta ja existe
            CMP valC5, BL
            JNE verifC5_C2
            MOV BL, symC1
            CMP symC5, BL
            JE meteC5
            
        verifC5_C2:    
            MOV BL, valC2
            CMP valC5, BL
            JNE verifC5_C3
            MOV BL, symC2
            CMP symC5, BL
            JE meteC5
                     
        verifC5_C3:
            MOV BL, valC3
            CMP valC5, BL
            JNE verifC5_C4
            MOV BL, symC3
            CMP symC5, BL
            JE meteC5
            
        verifC5_C4:
            MOV BL, valC4
            CMP valC5, BL
            JNE allCardsDif
            MOV BL, valC4
            CMP symC5, BL
            JE meteC5
            
        allCardsDif:        
            
        RET
    putNumbers endp

  ;************************
    getNumber proc
        MOV AH, 2Ch
        INT 21h
        MOV AX, DX
        MOV AH, 00
        MOV BL, 7
        DIV BL 
        CALL printNumbers

        RET
    getNumber endp
   ;********************** 
    getSymbol proc
        MOV AH, 2Ch
        INT 21h
        
        MOV AX, DX
        MOV AH, 00
        MOV BL, 25
        DIV BL 
        CALL printSymbols
        
        ret
    getSymbol endp
   ;*********************
    printSymbols proc
        MOV COUNTER2, 3
        CMP AL, 0
        JE meteCopas
        INC COUNTER2
        CMP AL, 1
        JE meteOuros
        INC COUNTER2
        CMP AL, 2
        JE metePaus
        INC COUNTER2
        CMP AL, 3
        JGE meteEspadas
        
        meteCopas:  
            MOV AL, 3 
            MOV BL, 15
            CALL printChar
            JMP segue
             
        meteOuros:
            MOV AL, 4  
            MOV BL, 15
            CALL printChar
            JMP segue
            
        metePaus:
            MOV AL, 5 
            MOV BL, 15
            CALL printChar
            JMP segue
        
        meteEspadas:
            MOV AL, 6
            MOV BL, 15 
            CALL printChar
        
        segue:
            
        ret
    printSymbols endp 
    
   ;************************
    printNumbers proc
              
        INC COUNTER      ;1
        CMP AL, 0
        JE meteNum
        INC COUNTER      ;2
        CMP AL, 1
        JE meteNum
        INC COUNTER      ;3
        CMP AL, 2
        JE meteNum
        INC COUNTER      ;4
        CMP AL, 3
        JE meteNum
        INC COUNTER      ;5
        CMP AL, 4
        JE meteNum
        INC COUNTER      ;6
        CMP AL, 5
        JE meteNum
        INC COUNTER      ;7
        CMP AL, 6
        JE meteNum
        INC COUNTER      ;8
        CMP AL, 7
        JE meteNum
        INC COUNTER      ;9
        CMP AL, 8
        JE meteNum
        INC COUNTER      ;10
        CMP AL, 9
        JE meteExcep
        INC COUNTER      ;11 - J(74)
        CMP AL, 10
        JE meteValete
        INC COUNTER      ;12 - Q(81)
        CMP AL, 11
        JE meteQueen
        inc COUNTER      ;13 - K(75)
        CMP AL, 12
        JE meteRei
        INC COUNTER      ;14 - A(65)
        JMP meteAs
        
        
        meteNum:
            MOV AL, COUNTER 
            ADD AL, 48
            MOV BL, 15
            CALL printChar
            JMP cont
            
        meteExcep:
            MOV DL, TMPCursorL
            MOV DH, TMPCursorH
            MOV AL, COUNTER
            CALL printInt
            JMP cont
            
        meteValete:
            MOV AL, 4Ah
            MOV BL, 15
            CALL printChar
            JMP cont
            
        meteQueen:
            MOV AL, 51h
            MOV BL, 15
            CALL printChar
            JMP cont
            
        meteRei:
            MOV AL, 4Bh
            MOV BL, 15
            CALL printChar 
            JMP cont
            
        meteAs:
            MOV AL, 41h
            MOV BL, 15
            CALL printChar       
            
        cont:     
        ret
    printNumbers endp 
    
  ;**************************
    printButtons proc
        MOV DL, 4
        MOV DH, 2
        CALL setCursorPosition
	    MOV CH, 00
	    MOV CL, CONTAGEM        
        LEA BP, JOGADOR
        CALL printStr
        ADD DL, 23
        CALL setCursorPosition
        MOV AL, PONTOS
        ADD AL, 48
        MOV BL, 15
        CALL printChar
        INC DL
        CALL setCursorPosition
        CALL printChar
        INC DL
        CALL setCursorPosition
        CALL printChar
        MOV DL, 31
        MOV DH, 2
        CALL setCursorPosition
	    MOV CH, 00
	    MOV CL, 6        
        LEA BP, SPONTOS
        CALL printStr
        
        ;CALL putButtons   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        MOV DL, 5
        MOV DH, 22
        CALL setCursorPosition
	    MOV CH, 00
	    MOV CL, 4        
        LEA BP, strsair
        CALL printStr
        ADD DL, 24
        CALL setCursorPosition
	    MOV CL, 6        
        LEA BP, strocar
        CALL printStr    
        ret
    printButtons endp              
  ;**********************
    putButtons proc
        MOV AL, 15    ;cor branca
        MOV CX, 30
        MOV DX, 170
        putButton1:
            MOV AH,0ch
    	    INT 10h
            INC CX
            CMP CX, 80
            JNE putButton1
        putButton2:
            MOV AH,0ch
    	    INT 10h
            INC DX
            CMP DX, 190
            JNE putButton2
        putButton3:
            MOV AH,0ch
    	    INT 10h
            DEC CX
            CMP CX, 30
            JNE putButton3
        putButton4:
            MOV AH,0ch
    	    INT 10h
            DEC DX
            CMP DX, 170
            JNE putButton4
        ADD CX, 190
        putButton5:
            MOV AH,0ch
    	    INT 10h
            INC CX
            CMP CX, 305
            JNE putButton5
        putButton6:
            MOV AH, 0ch
    	    INT 10h
            INC DX
            CMP DX, 190
            JNE putButton6
        putButton7:
            MOV AH,0ch
    	    INT 10h
            DEC CX
            CMP CX, 220
            JNE putButton7
        putButton8:
            MOV AH,0ch
    	    INT 10h
            DEC DX
            CMP DX, 170
            JNE putButton8
        ret
    putButtons endp
  ;***********************  
    printCards proc
        MOV AL, 15
        MOV CX, 27
        MOV DX, 55
    putcard1_1:
        MOV AH,0ch
	    INT 10h
        INC CX
        CMP CX, 70
        JNE putcard1_1
    putcard1_2:
        MOV AH, 0Ch
        INT 10h
        INC DX
        CMP DX, 120
        JNE putcard1_2
    putcard1_3:
        MOV AH, 0Ch
        INT 10h
        DEC CX
        CMP CX, 27
        JNE putcard1_3
    putcard1_4:
        MOV AH, 0Ch
        INT 10h
        DEC DX
        CMP DX, 55
        JNE putcard1_4
        
        MOV CX, 80
    putcard2_1:
        MOV AH,0ch
	    INT 10h
        INC CX
        CMP CX, 125
        JNE putcard2_1
    putcard2_2:
        MOV AH, 0Ch
        INT 10h
        INC DX
        CMP DX, 120
        JNE putcard2_2
    putcard2_3:
        MOV AH, 0Ch
        INT 10h
        DEC CX
        CMP CX, 80
        JNE putcard2_3
    putcard2_4:
        MOV AH, 0Ch
        INT 10h
        DEC DX
        CMP DX, 55
        JNE putcard2_4
        
        MOV CX, 137
    putcard3_1:
        MOV AH,0ch
	    INT 10h
        INC CX
        CMP CX, 183
        JNE putcard3_1
    putcard3_2:
        MOV AH, 0Ch
        INT 10h
        INC DX
        CMP DX, 120
        JNE putcard3_2
    putcard3_3:
        MOV AH, 0Ch
        INT 10h
        DEC CX
        CMP CX, 137
        JNE putcard3_3
    putcard3_4:
        MOV AH, 0Ch
        INT 10h
        DEC DX
        CMP DX, 55
        JNE putcard3_4
        
        MOV CX, 195
    putcard4_1:
        MOV AH,0ch
	    INT 10h
        INC CX
        CMP CX, 240
        JNE putcard4_1
    putcard4_2:
        MOV AH, 0Ch
        INT 10h
        INC DX
        CMP DX, 120
        JNE putcard4_2
    putcard4_3:
        MOV AH, 0Ch
        INT 10h
        DEC CX
        CMP CX, 195
        JNE putcard4_3
    putcard4_4:
        MOV AH, 0Ch
        INT 10h
        DEC DX
        CMP DX, 55
        JNE putcard4_4
        
        MOV CX, 253
    putcard5_1:
        MOV AH,0ch
	    INT 10h
        INC CX
        CMP CX, 300
        JNE putcard5_1
    putcard5_2:
        MOV AH, 0Ch
        INT 10h
        INC DX
        CMP DX, 120
        JNE putcard5_2
    putcard5_3:
        MOV AH, 0Ch
        INT 10h
        DEC CX
        CMP CX, 253
        JNE putcard5_3
    putcard5_4:
        MOV AH, 0Ch
        INT 10h
        DEC DX
        CMP DX, 55
        JNE putcard5_4   
    ret    
    printCards endp 
;*******************************
    NumberPut proc    
        CALL setCursorPosition
        MOV TMPCursorL, DL
        MOV TMPCursorH, DH
        CALL getNumber
        RET
    NumberPut endp
;*******************************
    SymbolPut proc
        CALL setCursorPosition
        CALL getSymbol 
        MOV DL, COUNTER2 
        RET
    SymbolPut endp   
;******************************
    trocarCartas proc
        C1:
            CMP C1escolhida, 1
            JE trocarC1 
        C2:
            CMP C2escolhida, 1
            JE trocarC2
        C3:
            CMP C3escolhida, 1
            JE trocarC3 
        C4:
            CMP C4escolhida, 1
            JE trocarC4
        C5:
            CMP C5escolhida, 1
            JE trocarC5
            JMP continuacao
            
        trocarC1:
            MOV DL, 5
            MOV DH, 10
            CALL NumberPut
            MOV valC1, DL
            MOV COUNTER, 00   ;COUNTER É METIDO A 0
            MOV DL, 6
            MOV DH, 10
            CALL SymbolPut
            MOV symC1, DL 
            MOV COUNTER2, 00 
            
            JMP C2
        trocarC2:
            MOV DL, 12
            MOV DH, 10
            CALL NumberPut
            MOV valC2, DL
            MOV COUNTER, 00    ;COUNTER É METIDO A 0 
            MOV DL, 13
            MOV DH, 10
            CALL SymbolPut
            MOV symC2, DL 
            MOV COUNTER2, 00
             
            JMP C3
        trocarC3:
            MOV DL, 19
            MOV DH, 10
            CALL NumberPut
            
            MOV valC3, DL
            MOV COUNTER, 00  ;COUNTER É METIDO A 0 
            MOV DL, 20
            MOV DH, 10
            CALL SymbolPut
            MOV symC3, DL 
            MOV COUNTER2, 00
            JMP C4
            
        trocarC4:
            MOV DL, 27
            MOV DH, 10
            CALL NumberPut
            
            MOV valC4, DL
            MOV COUNTER, 00   ;COUNTER É METIDO A 0 
            MOV DL, 28
            MOV DH, 10
            CALL SymbolPut
            MOV symC4, DL
            MOV COUNTER2, 00  
            JMP C5
                
        trocarC5:
            MOV DL, 34
            MOV DH, 10
            CALL NumberPut
              
            MOV valC5, DL
            MOV COUNTER, 00   ;COUNTER É METIDO A 0 
            MOV DL, 35
            MOV DH, 10
            CALL setCursorPosition
            CALL getSymbol  
            MOV DL, COUNTER2
            MOV symC5, DL 
            MOV COUNTER2, 00
                
        continuacao:
              
           
        RET
    trocarCartas endp
  ;**********************
    RoyalFlush proc
        
        CMP valC1, 10
        JE segueRF1
        CMP valC1, 11
        JE segueRF1
        CMP valC1, 12
        JE segueRF1
        CMP valC2, 13
        JE segueRF1
        CMP valC1, 14
        JE segueRF1
        JMP sairRF
            
        segueRF1:
            CMP valC2, 10
            JE segueRF2
            CMP valC2, 11
            JE segueRF2
            CMP valC2, 12
            JE segueRF2
            CMP valC2, 13
            JE segueRF2
            CMP valC2, 14
            JE segueRF2
            JMP sairRF
        
        segueRF2:
            MOV BL, valC1
            CMP valC2, BL
            JE sairRF
            CMP valC3, 10
            JE segueRF3
            CMP valC3, 11
            JE segueRF3
            CMP valC3, 12
            JE segueRF3
            CMP valC3, 13
            JE segueRF3
            CMP valC3, 14
            JE segueRF3
            JMP sairRF
            
         segueRF3:
            MOV BL, valC3
            CMP valC2, BL
            JE sairRF
            CMP valC1, BL
            JE sairRF
            CMP valC4, 10
            JE segueRF4
            CMP valC4, 11
            JE segueRF4
            CMP valC4, 12
            JE segueRF4
            CMP valC4, 13
            JE segueRF4
            CMP valC4, 14
            JE segueRF4
            JMP sairRF
         
         segueRF4:
            MOV BL, valC4
            CMP valC3, BL
            JE sairRF 
            CMP valC2, BL
            JE sairRF 
            CMP valC1, BL
            JE sairRF
            CMP valC5, 10
            JE segueRF5
            CMP valC5, 11
            JE segueRF5
            CMP valC5, 12
            JE segueRF5
            CMP valC5, 13
            JE segueRF5
            CMP valC5, 14
            JE segueRF5
            JMP sairRF
         
         segueRF5: 
            MOV BL, valC5
            CMP valC4, BL
            JE sairRF  
            CMP valC3, BL
            JE sairRF   
            CMP valC2, BL
            JE sairRF   
            CMP valC1, BL
            JE sairRF   
            MOV DL, 3
            MOV DH, 17
            CALL setCursorPosition
    	    MOV CL, 10
    	    LEA BP, sResultado
    	    CALL printStr
    	    ADD DL, 12
            CALL setCursorPosition
    	    MOV CL, 24        
            LEA BP, sRF
            CALL printStr
        
        sairRF:
              
        RET
    RoyalFlush endp  
  ;*********************
    StraightFlush proc
        
        RET
    StraightFlush endp
  ;********************
    FourOfAKind proc
        
        RET
    FourOfAKind endp
  ;***********************
    FullHouse proc
        
        RET
    FullHouse endp  
  ;*********************
    Flush proc
        
        RET
    Flush endp
  ;************************
    Straight proc
        
        RET
    Straight endp
  ;***********************
    Set proc
        
        RET
    Set endp
  ;*********************
    TwoPair proc
        
        RET
    TwoPair endp
  ;**********************
    OnePair proc
        MOV BL, valC1
        CMP valC2, BL
        JE oneP  
        CMP valC3, BL
        JE oneP
        CMP valC4, BL
        JE oneP
        CMP valC5, BL
        JE oneP
        MOV BL, valC2 
        CMP valC3, BL
        JE oneP         
        CMP valC4, BL
        JE oneP
        CMP valC5, BL
        JE oneP 
        MOV BL, valC3  
        CMP valC4, BL
        JE oneP
        CMP valC5, BL
        JE oneP 
        MOV BL, valC4
        CMP valC5, BL
        JE oneP
        JMP sairOP
        
        oneP:
            CALL clearCalc
            MOV DL, 3
            MOV DH, 17
            CALL setCursorPosition
    	    MOV CL, 10
    	    LEA BP, sResultado
    	    CALL printStr
    	    ADD DL, 12
            CALL setCursorPosition
    	    MOV CL, 20     
            LEA BP, sOP
            CALL printStr
        
        sairOP:
        
        RET
    OnePair endp
;**************************
    HighCard proc
        
        CALL clearCalc
        MOV DL, 3
        MOV DH, 17
        CALL setCursorPosition
	    MOV CL, 10
	    LEA BP, sResultado
	    CALL printStr
	    ADD DL, 12
        CALL setCursorPosition
	    MOV CL, 19     
        LEA BP, sHC
        CALL printStr
        MOV DL, 29
        MOV DH, 22
        CALL setCursorPosition
	    MOV CX, 9               ;separar ch cl        
        LEA BP, sContinuar
        CALL printStr  
        
        RET
    HighCard endp    
  ;************************
    calculaCombo proc
        MOV DL, 12
        MOV DH, 16
        CALL setCursorPosition
        MOV CX, 10
        LEA BP, sCalculando
        CALL printStr
        
        CALL RoyalFlush
        CALL StraightFlush
        CALL FourOfAKind
        CALL FullHouse
        
        MOV DL, 23
        MOV DH, 16
        CALL setCursorPosition
        MOV AL, 2Eh
        MOV BL, 15
        CALL printChar
        
        CALL Flush
        CALL Straight
        CALL Set
        CALL TwoPair   
        
        MOV DL, 25
        MOV DH, 16
        CALL setCursorPosition
        MOV AL, 2Eh
        MOV BL, 15 
        CALL printChar 
        
        CALL OnePair
        CALL HighCard
        CALL clearResult
        
        RET
    calculaCombo endp
;****************************
    clearSGame proc
        MOV DL, 02
        MOV DH, 16
        CALL setCursorPosition
        MOV CX, 28
        LEA BP, sGame
        MOV AL, 01h
        MOV BL, 0000_0000b
        MOV AH, 13h
        int 10h
        INC DH
        ADD DL, 7
        CALL setCursorPosition
        MOV CX, 25
        LEA BP, sGame2
        MOV AL, 01h
        MOV BL, 0000_0000b
        MOV AH, 13h
        int 10h
         
        RET
    clearSGame endp
;*************************
    clearResult proc
        CALL clearCalc
        MOV DL, 3
        MOV DH, 17
        CALL setCursorPosition
	    MOV CL, 10
	    LEA BP, sResultado
	    MOV AL, 01h
        MOV BL, 0000_0000b
        MOV AH, 13h
        int 10h
	    ADD DL, 12
        CALL setCursorPosition
	    MOV CL, 19     
        LEA BP, sSet
        MOV AL, 01h
        MOV BL, 0000_0000b
        MOV AH, 13h
        int 10h
        
        RET
    clearResult endp
    
;**************************
    meteNumero proc
        CMP AL, 10
        JL mete_num        
        CMP AL, 10
	    JE mete_10
	    CMP AL, 11
	    JE mete_J
	    CMP AL, 12
	    JE mete_Q
	    CMP AL, 13
	    JE mete_K
	    CMP al, 14
	    JE mete_A
	    JMP normal
        
        mete_num:
            ADD AL, 48
            CALL printChar
            JMP normal
        
        mete_10:
    	    DEC DL
    	    CALL setCursorPosition
    	    MOV AL, 49
    	    CALL printChar
    	    INC DL 
    	    CALL setCursorPosition
    	    MOV AL, 48 
    	    CALL printChar
    	    JMP normal
    	    
    	mete_J:
    	    MOV AL, 4AH
    	    CALL printChar 
    	    JMP normal
    	    
    	mete_Q:
    	    MOV AL, 51h
    	    CALL printChar 
    	    JMP normal
    	    
    	mete_K:
    	    MOV AL, 4BH
    	    CALL printChar 
    	    JMP normal
    	    
    	mete_A:
    	    MOV AL, 41H
    	    CALL printChar 
        
        normal:
        
        RET
    meteNumero endp
;*****************************
    mudaParaBranco proc
        MOV BL, 15
    	CALL meteNumero   ;
	    INC DL
	    CALL setCursorPosition
        RET
    mudaParaBranco endp
;*****************************
    mudaParaRed proc
        MOV BL, 12
    	CALL meteNumero   ;
	    INC DL
	    CALL setCursorPosition
        RET
    mudaParaRed endp    
   ;********************* 
    game proc
                 
        MOV DL, 02
        MOV DH, 16
        CALL setCursorPosition
        MOV CX, 28
        LEA BP, sGame
        CALL printStr
        ADD DL, 7
        INC DH
        CALL setCursorPosition
        MOV CX, 25
        LEA BP, sGame2
        CALL printStr
        MOV AH, 08h        
        INT 21h    
        CMP AL, 0Dh    ; Compara a tecla premida com o codigo 
        JE troca
        CALL clearSGame
        click2:
            
            CALL getClick 
    	    CMP CX, 60       ;adicionar botao pontos que mostra cada carta?
    	    JL click2
    	    CMP DX, 55 ;190 
    	    JL click2
    	    CMP DX, 190 
    	    JG click2
    	    CMP CX, 600
    	    JG click2
    	    
    	    CMP DX, 120
    	    JG escolha
    	    CMP CX, 140
    	    JL carta1
    	    CMP CX, 180
    	    JL click2
    	    CMP CX, 260
    	    JL carta2
    	    CMP CX, 300
    	    JL click2
    	    CMP CX, 380
    	    JL carta3
    	    CMP CX, 420
    	    JL click2
    	    CMP CX, 500
    	    JL carta4
    	    CMP CX, 540
    	    JL click2
    	    JMP carta5
    	     
    	escolha:
    	    CMP DX, 170
    	    JL click2
    	    CMP CX, 160
    	    JL leave
    	    CMP CX, 460
    	    JL click2
    	    CMP CX, 600
    	    JL troca
    	    JMP click2
    	                                                     
    	carta1:
    	    MOV DX, 83
	        MOV CX, 52
	        MOV AH, 0Dh
	        INT 10h
	        MOV DL, 5
    	    MOV DH, 10
    	    CALL setCursorPosition        ;GET PIXEL
	        CMP AL, 12
	        JE meteC1white         
	        
	        MOV C1escolhida, 1
	        MOV AL, valC1
	        CALL mudaParaRed
	        MOV AL, symC1
    	    CALL printChar
    	    
    	    JMP click2
    	    
    	meteC1white:
    	    MOV C1escolhida, 0
    	    MOV AL, valC1
    	    CALL mudaParaBranco
    	    MOV AL, symC1
    	    CALL printChar
    	    JMP click2    
    
    	    
    	carta2:
    	    MOV DX, 83
	        MOV CX, 107
	        MOV AH, 0Dh             ;GET PIXEL
	        INT 10h    
	        MOV DL, 12
    	    MOV DH, 10
    	    CALL setCursorPosition            
	        CMP AL, 12
	        JE meteC2white 
	        
	        MOV C2escolhida, 1    
    	    MOV AL, valC2
    	    CALL mudaParaRed
    	    MOV AL, symC2
    	    CALL printChar
    	    JMP click2
    	    
    	meteC2white:
    	    MOV C2escolhida, 0
    	    MOV AL, valC2
    	    CALL mudaParaBranco
    	    MOV AL, symC2
    	    CALL printChar
    	    JMP click2 
    	    
    	carta3:
    	    MOV DX, 83
	        MOV CX, 163
	        MOV AH, 0Dh                 ;GET PIXEL
	        INT 10h
	        MOV DL, 19
    	    MOV DH, 10
    	    CALL setCursorPosition               
	        CMP AL, 12
	        JE meteC3white
	        
	        MOV C3escolhida, 1 
    	    MOV AL, valC3  
    	    CALL mudaParaRed
    	    MOV AL, symC3
    	    CALL printChar
    	    
    	    JMP click2
    	    
    	meteC3white:
    	    MOV C3escolhida, 0
    	    MOV AL, valC3  
    	    CALL mudaParaBranco
    	    MOV AL, symC3
    	    CALL printChar
    	    JMP click2
    	   
    	    
    	carta4:
    	    MOV DX, 83
	        MOV CX, 228
	     
	        MOV AH, 0Dh                    ;GET PIXEL
	        INT 10h         
	        MOV DL, 27
    	    MOV DH, 10
    	    CALL setCursorPosition       
	        CMP AL, 12
	        JE meteC4white
	            
	        MOV C4escolhida, 1 
    	    MOV AL, valC4
    	    CALL mudaParaRed
    	    MOV AL, symC4 
    	    CALL printChar
    	    JMP click2
    	    
    	meteC4white:
    	    MOV C4escolhida, 0 
    	    MOV AL, valC4
    	    CALL mudaParaBranco
    	    MOV AL, symC4
    	    CALL printChar
    	    JMP click2
    	         
        carta5:
            MOV DX, 83
	        MOV CX, 284
	        MOV AH, 0Dh                ;GET PIXEL
	        INT 10h      
	        MOV DL, 34
    	    MOV DH, 10
    	    CALL setCursorPosition          
	        CMP AL, 12
	        JE meteC5white
	        
	        MOV C5escolhida, 1 
    	    MOV AL, valC5
    	    CALL mudaParaRed
    	    MOV AL, symC5
    	    CALL printChar
    	    JMP click2        
    	               
    	meteC5white:
    	    MOV C5escolhida, 0
    	    MOV AL, valC5
    	    CALL mudaParaBranco
    	    MOV AL, symC5 
    	    CALL printChar
    	    JMP click2
    	                  	    
        leave:
            CALL clearScreen
           ;CALL SAVEPONTUACAO  

            JMP gameloop
            
        troca:
            CALL clearSGame
            CALL trocarCartas
            CALL calculaCombo
            
        ret
    game endp
                  
ends
end start ; set entry point and stop the assembler.