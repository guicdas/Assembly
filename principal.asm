; multi-segment executable file template.

data segment
     
    ;***************************    Constantes  *******************************************
        num_eleitores   EQU 08
        PASS            EQU 'morangos'
        
        ; cores
        BRANCO      EQU 15
        VERMELHO    EQU 04
        PRETO       EQU 00
        
        ; teclas
        ENTER       EQU 13
        BACKSPACE   EQU 08
        ESC         EQU 27
        
        ; FD TYPE
        READ        EQU 00
        WR          EQU 01
        READWR      EQU 02
        
        ; caracteres
        CR          EQU 0dh
        LF          EQU 0Ah
        Tab         EQU 09
        HIFEN       EQU 45
        
        ; tamanhos
        squareSize  EQU 10
        maxNum      EQU 12               
        maxString   EQU 30
        lineSize    EQU 190                

        ; figuras desenhadas: o ecra tem 200 rows | 320 colunas, cada pixel esta em ordem na memoria a primeira linha 
        ; do ecra é entao de 1 a 320, dai em diante se quero meter o meu quadrado no row 20 e coluna 230 fica 20 * 320 + 230
        ; depois o mesmo espaçamento é usado para todos => 8000 (25 rows)
        square1     EQU 6660
        square2     EQU square1 + 8000
        square3     EQU square2 + 8000  
        square4     EQU square3 + 8000  
        square5     EQU square4 + 8000  
        rect        EQU 54587 
        line1       EQU 23100
        line2       EQU 31100
               
        
    ;***************************    Menu        *******************************************
        ; as strings sao null terminated e fazem parte do mesmo bloco podem ou nao ter nome, mas dependendo do caso, vamos (ou nao) ter que reutiliza-las
        ; individualmente , o int 21h vai fazer printate ao $ portanto podemos printar tudo de uma vez                
        
        str_menu      	db "Votar",                 "$"
        str_menu2       db " Carregar eleitores",   "$"
	    restoMenu:
	        db "Gerir",             CR,LF,LF,LF,LF,Tab
	        db "       Creditos",   CR,LF,LF,LF,LF,Tab,Tab
	        db " Sair", 	        "$"   
        restoMenu2:
            db "Grafico de Resultados",CR,LF,LF,LF,Tab,Tab
            db "  Sair",                 "$"       
                                      
    ;***************************    Input       *******************************************                                    
        num_eleitor     dw  1 dup (00)
        
        pass_input      db  maxString+1 dup (00)
        passwd          db  PASS, 00
         
        input_s:
            db "Introduza o seu numero de eleitor",CR,LF,"  (max: 65535):","$"
            db "Introduza a palavra chave ",CR,LF,"  da administracao:",   "$"    ; 51
        
        ; candidatos
        c1  db "Manuel Maria du Bocage:", Tab,"$" 
        c2  db "Paula Rego:",     Tab,Tab,Tab,"$"
        c3  db "Luiz Vaz de Camoes:", Tab,Tab,"$"
        c4  db "Natalia Correia: ",   Tab,Tab,"$"
        c5  db "Amadeo de Souza-Cardoso:",Tab,"$"
        
        ; contadores de votos
        v1  db 1 dup (00)
        v2  db 1 dup (00)
        v3  db 1 dup (00)
        v4  db 1 dup (00)
        v5  db 1 dup (00)
        
        voto1  db 1 dup (00)
        voto2  db 1 dup (00)
        voto3  db 1 dup (00)
        voto4  db 1 dup (00)
        voto5  db 1 dup (00)   
        
        s_votos_brancos db "VOTOS EM BRANCO:",Tab,Tab,"$"
        votos_brancos   db 1 dup (00) 
        s_votos_nulos   db "VOTOS NULOS:",Tab,Tab,Tab,"$"
        votos_nulos     db 1 dup (00)
            
    ;***************************    Misc       *******************************************       
        quantos_votos               db  1 dup (06)      ; comeca a 5 porque vai ser decrementado 6 vezes antes da votaçao
        bool_eleitoresCarregados    db  1 dup (00)       
        
        rectLength  dw  1 dup (squareSize)
        rectHeight  dw  1 dup (squareSize)
        
        s_aux       db "Eleitor: ",       "$"," - ","$"   
        s_continue  db "CONTINUAR",                 "$"     
        s_saving    db "Saving...",              LF,"$"     
        s_loading   db "Loading file...",        LF,"$"
        s_loaded    db "eleitores carregados!",     "$"    
        s_click     db "Click to continue",         "$"
        s_key       db "Press any key to continue", "$"
        s_indisp    db "Acao indisponivel",         "$"
        s_cabecalho db "Numero",Tab,"Nome",Tab,Tab,"Data/Hora",CR,LF 
                                    
        authors:
            db " Tiago leal 66181",         CR,LF,LF,LF,Tab
            db "    Sidi brahim 63452",     CR,LF,LF,LF,Tab
            db "  Guilherme Silva 64937",   "$"         
                                                                                         
                                        
    ;***************************  Ficheiros ***********************************************
        dataFile        db "C:\dados.bin",     00  
        logFile         db "C:\logs.txt",      00
        csvFile         db "C:\Eleitores.csv", 00
        
        buffer          db 01 dup(00)      ; Buffer para leitura de dados 
        
        lista_eleitores db (02 + 30 + 01) * num_eleitores  dup(00)

    ;***************************  error     ***********************************************                                                                                              
        serr_path    db "error: path not found"       ,LF,"$"     
        serr_access  db "error: access denied"        ,LF,"$"
        serr_invhand db "error: invalid handler"      ,LF,"$"
        serr_wpass   db "error: wrong password"       ,LF,"$"
        serr_failed  db "error: loading failed"       ,LF,"$"    
        serr_nan     db "error: input a number"       ,LF,"$"  
        serr_empty   db "error: empty argument"       ,LF,"$"
        serr_open    db "error: could not open file"  ,LF,"$"
        serr_close   db "error: could not close file" ,LF,"$" 
        serr_create  db "error: could not create file",LF,"$" 
        serr_read    db "error: could not read file"  ,LF,"$"
        serr_write   db "error: could not write file" ,LF,"$"
        serr_max     db "error: exceeded max value"   ,LF,"$"
        serr_inv     db "eleitor nao existente"       ,LF,"$"
        serr_rep     db "eleitor ja votou!"           ,LF,"$"
        serr_num     db "je chega de numeros!"        ,LF,"$" 
                   
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:      
    include emu8086.inc
    mov     Ax, data
    mov     ds, Ax
    mov     es, Ax
    
    call    init_mouse
    call    cleanPixels     
     
    call    loadDataFile
        
    call    selectMenu                              ; loop infinito ate sair
                   
    call    loadMemoryToBin
                   
    mov     Ax, 4c00h                               ; exit to operating system.
    int     21h 
        
    ;*************************************************************************************************
    ; Nome:      printMenu
    ; Descrição: Exibe o menu principal na tela, verificando se os dados de eleitores foram carregados. 
    ;
    ; Input:     N/A.
    ; Output:    N/A.
    ; Destroi:   N/A.
    ;*************************************************************************************************
    printMenu proc 
        cmp     bool_eleitoresCarregados, 00     ; do enunciado: não pode entrar aqui se não estiverem carregados os dados dos eleitores
        je      print_menu
        
        mov     Dx, 0410h 
        call    setCursorPosition        
        lea     Dx, str_menu
        call    printStr$
        jmp     print_rest     
        
        print_menu:
            mov     Dx, 040Bh 
            call    setCursorPosition        
            lea     Dx, s_indisp
            call    printStr$  
        
        print_rest:    
    	    mov     Dx, 0810h 
            call    setCursorPosition        
            lea     Dx, restoMenu
            call    printStr$  
        
        ret
    printMenu endp     
    
    ;*************************************************************************************************
    ; Nome:      selectMenu
    ; Descrição: Detecta cliques no menu principal e chama a função correspondente à opção escolhida,
    ;            votar, gerir, créditos ou sair.  
    ;
    ; Input:     bool_eleitoresCarregados - 01 | 00 
    ; Output:    N/A.
    ; Destroi:   N/A.
    ;*************************************************************************************************    
    selectMenu proc               
        
        main_loop:
            call    setTextMode
            call    printMenu 
                                  
        click_loop:
            call    getClick       ; loop infinito que sai e retorna posicao do rato QUANDO o rato for premido  => Cx row | Dx coluna
            cmp     Cx, 115
    	    jl      click_loop
    	    cmp     Cx, 185
    	    jg      click_loop
    	    cmp     Dx, 28
    	    jl      click_loop
    	    cmp     Dx, 137
    	    jg      click_loop
    	    cmp     Dx, 40
            jl      vote 
            cmp     Dx, 60
            jl      click_loop
            cmp     Dx, 72
            jl      manage
            cmp     Dx, 93
            jl      click_loop 
            cmp     Dx, 105
            jl      credits 
            cmp     Dx, 126
            jl      click_loop
            jmp     exit_program
                       
        vote:
            cmp     bool_eleitoresCarregados, 00
            je      click_loop                 
        	call    frontOffice
        	jmp     main_loop
    	
    	manage:
            call    backOffice
            jmp     main_loop
    	    
    	credits:
    	    call    setTextMode   
    	                                  
    	    mov     Dx, 070Bh 
            call    setCursorPosition   
            lea     Dx, authors
            call    printStr$
            
            call    keyToContinue        
            jmp     main_loop
            
        exit_program:
            call    setTextMode
           
        ret 
    selectMenu endp
                        
             
;************************************************************** Votar   ****************************************************************             
             
    ;*************************************************************************************************
    ; Nome:      frontOffice
    ; Descrição: Gerencia a interface de votação e incrementa os votos que foram feitos, 
    ;            nulo, branco ou valido.
    ;
    ; Input:     N/A.
    ; Output:    N/A.
    ; Destroi:   N/A.
    ;*************************************************************************************************         
    frontOffice proc
        call    setTextMode
        ; pede numero eleitor
        GOTOXY  2, 2
        lea     Dx, input_s   
        call    PrintStr$ 
        call    getNumeroEleitor
        cmp     Bx, 10
        jg      fim_front_office 
        call    validaNumeroEleitor 
        cmp     Bx, 01
        je      fim_front_office 
        
        call    setVideoMode
        call    showCandidates
        call    voteLoop     
        
        cmp     quantos_votos, 00
        je      voto_branco   
        cmp     quantos_votos, 01
        jg      voto_nulo
        
        ; voto valido
        call    addVotesToCounters
        jmp     fim_front_office
        
        voto_branco:
            inc     votos_brancos
            jmp     fim_front_office
        
        voto_nulo:
            inc     votos_nulos
        
        fim_front_office:     
            mov     num_eleitor,    00   
            mov     quantos_votos,  06 
            call    cleanPixels
            mov     voto1, 00 
            mov     voto2, 00
            mov     voto3, 00
            mov     voto4, 00
            mov     voto5, 00                                                                       
                                                                              
        ret
    frontOffice endp
    
    ;*************************************************************************************************
    ; Nome:      validaNumeroEleitor
    ; Descrição: Valida se o número de eleitor fornecido se encontra , se sim, verifica se já votou.
    ;
    ; Input:     Nenhum.
    ; Output:    Bx = 01 (nao encontrou eleitor/eleitor ja votou) | Bx = 00 (eleitor valido) 
    ; Destroi:   N/A.
    ;*************************************************************************************************
    validaNumeroEleitor proc
        lea     Di, lista_eleitores
        mov     Ax, num_eleitor
        mov     Cx, num_eleitores
        valida_loop:
            cmp     [Di], Ax
            je      eleitor_encontrado
            add     Di, 33
            loop    valida_loop
        
        lea     Dx, serr_inv   
        call    printError
        mov     Bx, 01    
        sai_erro:
        
        ret    
        eleitor_encontrado:
            cmp     [Di + 32], 00            ; nulo se nao votou
            je      sair_validacao
            
            lea     Dx, serr_rep   
            call    printError
            mov     Bx, 01 
            jmp     sai_erro    
            
        sair_validacao:
            mov     Bx, 00
        
        ret
    validaNumeroEleitor endp
           
    ;*************************************************************************************************
    ; Nome:      showCandidates
    ; Descrição: Exibe o menu de votacao nos candidatos, com o numero e nome do eleitor encontrado.
    ;
    ; Input:     Di - endereço do primeiro byte do eleitor a selecionado
    ; Output:    N/A. 
    ; Destroi:   N/A.
    ;*************************************************************************************************       
    showCandidates proc         
        
        ; print candidatos
        mov     Dx, 0301h
        call    setCursorPosition
        lea     Dx, c1
        call    printStr$
        mov     Dx, 0601h
        call    setCursorPosition
        lea     Dx, c2
        call    printStr$
        mov     Dx, 0901h
        call    setCursorPosition
        lea     Dx, c3
        call    printStr$
        mov     Dx, 0C01h
        call    setCursorPosition
        lea     Dx, c4
        call    printStr$
        mov     Dx, 0F01h
        call    setCursorPosition
        lea     Dx, c5
        call    printStr$
        
        call    printCandidatesRect   
        
        ; print da linha "Eleitor: (num) - (name)"
        mov     Dx, 1402h 
        call    setCursorPosition
        lea     Dx, s_aux
        call    PrintStr$
           
        mov     Ax, [Di] 
        mov     Dx, 10000
        call    divideInt
        call    printByte           ; primeiro digito
        
        mov     Dx, 1000
        call    divideInt
        call    printByte           ; segundo digito
        
        mov     Dx, 100
        call    divideInt
        call    printByte           ; terceiro digito
        
        mov     Dx, 10
        call    divideInt
        call    printByte           ; quarto digito
        call    printByte           ; quinto digito
        add     Di, 2  
        
        ; " - "
        lea     Dx, s_aux+10       
        call    PrintStr$
        
        mov     Ah, 0Eh
        mov     Cx, 30
        print_nome_eleitor:
            mov     Al, [Di]                    
            cmp     Al, 00                 ; quando chegar a um char null
            je      fim_nome
            int     10h
            inc     Di
            loop     print_nome_eleitor  
        
        fim_nome:
            inc     Di     
            loop    fim_nome                      ; avanca o resto dos nulos
        
        sub     Di, 32
            
        ; print CONTINUAR
        mov     Dx, 1618h 
        call    setCursorPosition
        lea     Dx, s_continue                  
        call    PrintStr$   
        call    printContinueRect   
        
        ret
    showCandidates endp  
    
    ;*************************************************************************************************
    ; Nome:      printByte
    ; Descrição: Imprime um único byte (valor numérico) na tela no formato ASCII.
    ;
    ; Input:     Al - valor a imprimir na tela
    ;            Dx - resto da divisao anterior
    ; Output:    Ax - valor a ser imprimido da proxima vez que chamarmos a rotina  
    ; Destroi:   N/A.
    ;*************************************************************************************************       
    printByte proc 
        push    Dx
        
        mov     Ah, 0Eh
        add     Al, '0' 
        int     10h    
        
        pop     Ax
        
        ret
    printByte endp 
        
    ;*************************************************************************************************
    ; Nome:      voteLoop
    ; Descrição: Gerencia o loop de votação, detectando cliques e atualizando os votos selecionados
    ;            retorna ao menu principal.
    ;
    ; Input:     N/A.
    ; Output:    N/A.  
    ; Destroi:   N/A.
    ;*************************************************************************************************       
    voteLoop proc
        push    Di  
        vote_loop:
            call    getClick                     ; Dx => colunas | Cx => linhas
            cmp     Dx, 20 
            jl      vote_loop 
            cmp     Dx, 130 
            jg      continue
            cmp     Cx, 520 
            jl      vote_loop 
            cmp     Cx, 540 
            jg      vote_loop
            cmp     Dx, 30
            jl      square_1
            cmp     Dx, 45
            jl      vote_loop
            cmp     Dx, 55
            jl      square_2
            cmp     Dx, 70
            jl      vote_loop
            cmp     Dx, 80
            jl      square_3
            cmp     Dx, 95
            jl      vote_loop
            cmp     Dx, 105
            jl      square_4
            cmp     Dx, 120
            jl      vote_loop
            cmp     Dx, 130
            jl      square_5
            jmp     vote_loop
    
        square_1:
            not     voto1
            lea     Di, [square1]
            jmp     draw
        square_2:
            not     voto2    
            lea     Di, [square2]
            jmp     draw
        square_3:
            not     voto3    
            lea     Di, [square3]
            jmp     draw
        square_4:
            not     voto4    
            lea     Di, [square4]
            jmp     draw
        square_5:
            not     voto5    
            lea     Di, [square5]
        draw:
            call    drawSquare
            jmp     vote_loop
        
        continue:
            cmp     Dx, 167
            jl      vote_loop
            cmp     Cx, 370
            jl      vote_loop
            cmp     Cx, 530
            jg      vote_loop
            cmp     Dx, 190
            jg      vote_loop    
        
        pop     Di    
        call    saveVotesToLog
            
        ret    
    voteLoop endp  
    
    ;*************************************************************************************************
    ; Nome:      addVotesToCounters
    ; Descrição: Adiciona os votos válidos aos contadores de cada candidato. Os votos estarao
    ;            negativos se tiverem selecionados
    ;
    ; Input:     voto1 a voto5 - 00 (candidato nao selecionado) | -1 (selecionado)
    ; Output:    N/A.  
    ; Destroi:   N/A.
    ;************************************************************************************************* 
    addVotesToCounters proc
        cmp     voto1, 00
        je      add_voto2
        neg     voto1
        mov     Al, voto1
        add     v1, Al
        
        add_voto2:
            cmp     voto2, 00
            je      add_voto3
            neg     voto2
            mov     Al, voto2
            add     v2, Al
        add_voto3:
            cmp     voto3, 00
            je      add_voto4
            neg     voto3
            mov     Al, voto3
            add     v3, Al
        add_voto4:
            cmp     voto4, 00
            je      add_voto5
            neg     voto4
            mov     Al, voto4
            add     v4, Al
        add_voto5:
            cmp     voto5, 00
            je      fim_add_votos
            neg     voto5
            mov     Al, voto5
            add     v5, Al
        fim_add_votos:
        
        ret
    addVotesToCounters endp  
    
    ;*************************************************************************************************
    ; Nome:      saveVotesToLog
    ; Descrição: Salva as informações de votos nos logs com a formatação
    ;            número eleitor TAB nome eleitor TAB data (com '-') ESPAÇO horário (com ':').
    ;
    ; Input:     Nenhum.
    ; Output:    Nenhum.  
    ; Destroi:   N/A.
    ;************************************************************************************************* 
    saveVotesToLog proc
        call    setTextMode   
        
        lea     Dx, s_saving
        call    printStr$      
        
        lea     Dx, logFile
        mov     Al, READWR                         
        call    openFile                        
        jnc     log_file_exists    
        
        mov     Al, READWR
        call    createFile
        
        mov     Bx, Ax          
        mov     Cx, 24                          ; testar
        lea     Dx, s_cabecalho        
        call    writeToFile 
        jmp     seek
        
        log_file_exists:
            mov     Bx, Ax
        
        seek:
            mov     al, 02                          ; mete o file pointer no fim do ficheiro 
            call    fSeek                           
        
        ; numero eleitor
        mov     Cx, 01
        mov     Ax, [Di] 
        mov     Dx, 10000
        call    divideInt
        call    printByteToFile                 ; primeiro digito
        
        mov     Dx, 1000
        call    divideInt
        call    printByteToFile 
            
        mov     Dx, 100
        call    divideInt
        call    printByteToFile  
        
        mov     Dx, 10
        call    divideInt
        call    printByteToFile   
        call    printByteToFile              
        
        add     Di, 2  

        mov     [buffer], Tab
        call    writeToFile  
        
        ; nome eleitor
        mov     Cx, 30
        save_nome_eleitor:
            mov     Al, [Di]                
            cmp     Al, 00                  ; quando chegar a um char null
            je      fim_nome_log
            push    Cx
            mov     Cx, 01
            mov     [buffer], Al 
            call    writeToFile
            pop     Cx
            inc     Di
            loop    save_nome_eleitor  
        
        fim_nome_log:
            inc     Di
            loop     fim_nome_log 
        
        mov     Cx, 01
        mov     [buffer], Tab
        call    writeToFile
        
        call    writeDateTimeTolog   
        
        mov     Cx, 01
        mov     [buffer], CR
        call    writeToFile
        mov     [buffer], LF   
        call    writeToFile         
        
        call    closeFile  
         
        ; muda byte voto
        mov     [Di], 01
        
        call    keyToContinue 
       
        leave_log:
          
        ret
    saveVotesToLog endp         
                       
    ;*************************************************************************************************
    ; Nome:      printByteToFile
    ; Descrição: Escreve um único byte convertido para ASCII no ficheiro.
    ;
    ; Input:     Al - byte a escrever
    ;            Bx - handler ficheiro
    ;            Dx - resto da divisao anterior
    ; Output:    Ax - o proximo valor a escrever quando a rotina for utilizada outra vez  
    ; Destroi:   N/A.
    ;**************************************************************************************************       
    printByteToFile proc
        push    Dx
          
        add     Ax, '0'
        mov     [buffer], Al 
        call    writeToFile  
        
        pop     Ax
        
        ret
    printByteToFile endp
                        
                                               
;***************************************************************** Gerir    ************************************************************  
                                       
    ;*************************************************************************************************
    ; Nome:      backOffice
    ; Descrição: Gera o menu de administração após validação da palavra-passe. Apenas prossegue se a 
    ;            passe for correta, senao podemos sair com ESC
    ;
    ; Input:     Nenhum.
    ; Output:    Nenhum.  
    ; Destroi:   N/A.
    ;************************************************************************************************** 
    backOffice proc
        call    setTextMode
        
        ; pergunta pela password    
        mov     Dx, 0202h
        call    setCursorPosition
        lea     Dx, input_s+51
        call    printStr$
        
        passwd_loop:
            lea     Si, passwd
            lea     Di, pass_input
            call    getName
            cmp     Bx, 01
            je      return_to_menu
            mov     Cx, 09
            repe    cmpsb 
            jnz     not_equal                                 ; Flag zero metida a 0 se algum charactere n for igual
            jmp     valid_user                                ; se for igual apresenta o próximo menu
        
        not_equal: 
            lea     Di, pass_input 
            mov     Cx, maxString+1                           ; verificar que a string ta limpa
            call    clearString
            lea     Dx, serr_wpass
            call    printError
            jmp     passwd_loop
        
        valid_user:
            call    menuGerente
        
        return_to_menu:
            lea     Di, pass_input
            mov     Cx, maxString+1
            call    clearString    
            
        ret
    backOffice endp
    
    ;***************************************************************************************************
    ; Nome:      menuGerente
    ; Descrição: Exibe o menu de gerenciamento, permitindo carregar eleitores apenas se ja nao tiverem 
    ;            sido carregados.
    ;
    ; Input:     bool_eleitoresCarregados
    ; Output:    Nenhum.  
    ; Destroi:   N/A.
    ;***************************************************************************************************   
    menuGerente proc
        call    setVideoMode
        
        cmp     bool_eleitoresCarregados, 00
        jg      carregar_eleitores_indisponivel 
        
        mov     Dx, 070Ah
        call    setCursorPosition
        lea     Dx, str_menu2
        call    printStr$
        jmp     resto_menu
        
        carregar_eleitores_indisponivel:
            mov     Dx, 070Bh
            call    setCursorPosition
            lea     Dx, s_indisp
            call    printStr$   
            
        resto_menu:    
            mov     Dx, 0A09h
            call    setCursorPosition
            lea     Dx, restoMenu2
            call    printStr$
        
        call    printGerirLines
                       
        gerir_loop:               
            call    getClick
            cmp     Cx, 116
            jl      gerir_loop
            cmp     Cx, 510
            jg      gerir_loop
            cmp     Dx, 115
            jg      gerir_loop
            cmp     Dx, 50
            jl      gerir_loop
            cmp     Dx, 72
            jl      carregar_eleitores 
            cmp     Dx, 97
            jl      grafico_resultados
            jmp     sair_menu_gerir
           
        carregar_eleitores:
            cmp     bool_eleitoresCarregados, 00
            jg      gerir_loop
            
            call    setTextMode
            mov     Dx, 0A03h
            call    setCursorPosition
            lea     Dx, s_loading
            call    printStr$ 
            
            call    carregarEleitoresMemoria
            
            call    setTextMode
            mov     Dx, 0C03h
            call    setCursorPosition
            lea     Dx, s_loaded
            call    printStr$
            call    wait1s 
            
            jmp     sair_menu_gerir 
        
        grafico_resultados:
            call    mostrarResultados
                      
        sair_menu_gerir:
            call    cleanPixels
                       
        ret  
    menuGerente endp
     
    ;***************************************************************************************************
    ; Nome:      carregarEleitoresMemoria
    ; Descrição: Carrega os dados dos eleitores a partir de um ficheiro CSV para a estrutura lista_eleitores.
    ;
    ; Input:     Nenhum
    ; Output:    bool_eleitoresCarregados - 01   
    ; Destroi:   N/A.
    ;***************************************************************************************************    
    carregarEleitoresMemoria proc
        lea     Dx, csvFile   
        mov     Al, READ                        
        call    openFile     
        jnc     csvFileExists
        
        call    createFile                          ; completar em caso de erro de criacao  
        jc      fim_read_csv
        csvFileExists:
            mov     Bx, Ax
        
        mov     Cx, num_eleitores  
        lea     Di, lista_eleitores  
        carregar_loop:
            push    Cx
            lea     Dx, buffer
            xor     Ax, Ax    
            read_number_loop: 
                mov     Cx, 01                      ; vamos querer sempre ler só 1 byte   
                call    readFromFile                ; as strings teram sempre ',' portanto nao e necessario proteger com jc
                cmp     [buffer], ','               ; Verificar se encontrou a virgula
                je      read_number_fim             ; Finalizar ao encontrar a virgula
                
                push    Dx
                mov     Cx, 10                      ; multiplicar digito anterior por 10
                mul     Cx    
                pop     Dx      
                         
                sub     [buffer], '0'         
                add     Al, [buffer]        
                jmp     read_number_loop  
                
            read_number_fim:
             
            mov     [Di], Ax
            add     Di, 2
            
            mov     Cx, 30 
            xor     Ax, Ax
            read_name_loop:
                push    Cx                     
                mov     Cx, 01
                call    readFromFile                      ; quando nao ha carry e Ax ta a 00 é porque atingiu EOF, mas havera sempre CR LF
                pop     Cx
                
                cmp     [buffer], CR                      ; Encontrar o Carriage Return
                je      read_name_fim 
                mov     Al, [buffer]                  
                stosb                               ; Armazenar byte no endereco apontado por DI
                loop     read_name_loop          
            
            read_name_fim:
                mov     Al, 00
                stosb 
                loop     read_name_fim              ; preenche os espaços restantes com nulos (até 30)
                stosb                               ; bit de voto inicializado a nulo
                
                mov     Cx, 01
                call    readFromFile                ; ler o LF (e desperdicar)
                                  
            pop     Cx                             
            loop    carregar_loop
                
        fim_read_csv:
            call    closeFile  
            
        inc     bool_eleitoresCarregados
        
        ret
    carregarEleitoresMemoria endp   
                                  
    ;***************************************************************************************************
    ; Nome:      mostrarResultados
    ; Descrição: Exibe os resultados da votação obtidas até ao momento.
    ;
    ; Input:     Nenhum
    ; Output:    Nenhum   
    ; Destroi:   N/A.
    ;*************************************************************************************************** 
    mostrarResultados proc
        call    setVideoMode 
        
        mov     Bx, 0101h
        lea     Dx, c1
        mov     Cl, v1
        call    printCandidato
        
        mov     Bx, 0301h
        lea     Dx, c2
        mov     Cl, v2
        call    printCandidato
        
        mov     Bx, 0501h
        lea     Dx, c3
        mov     Cl, v3
        call    printCandidato
        
        mov     Bx, 0701h
        lea     Dx, c4
        mov     Cl, v4
        call    printCandidato
        
        mov     Bx, 0901h
        lea     Dx, c5
        mov     Cl, v5
        call    printCandidato       
        
        mov     Bx, 0B01h
        lea     Dx, s_votos_brancos
    	mov     Cl, votos_brancos
        call    printCandidato
        
        mov     Bx, 0D01h
        lea     Dx, s_votos_nulos
    	mov     Cl, votos_nulos
    	call    printCandidato
        
        ; graficos
        call    keyToContinue
        call    setVideoMode  
        
        mov     Dx, 0101h
        call    setCursorPosition
        lea     Dx, c1
        call    printStr$
        mov     Dx, 0301h
        call    setCursorPosition
        lea     Dx, c2
        call    printStr$
        mov     Dx, 0501h
        call    setCursorPosition
        lea     Dx, c3
        call    printStr$
        mov     Dx, 0701h
        call    setCursorPosition
        lea     Dx, c4
        call    printStr$
        mov     Dx, 0901h
        call    setCursorPosition
        lea     Dx, c5
        call    printStr$          
        
        mov     Dx, 0B01h
        call    setCursorPosition
        lea     Dx, s_votos_brancos
        call    printStr$
        
        mov     Dx, 0D01h
        call    setCursorPosition
        lea     Dx, s_votos_nulos
        call    printStr$     
        
        call    printResults
        call    keyToContinue  
        
        ret
    mostrarResultados endp                               
        
    ;***************************************************************************************************
    ; Nome:      printCandidato
    ; Descrição: Imprime o nome de um candidato e o seu número de votos.
    ;
    ; Input:     BX - posição do cursor, DX - nome candidato, CL - número de votos do candidato
    ; Output:    Nenhum.   
    ; Destroi:   N/A.
    ;*************************************************************************************************** 
    printCandidato proc
        push    Dx 
        mov     Dx, Bx
        call    setCursorPosition   
        pop     Dx
        call    printStr$
        mov     Dl, Cl
        call    printAscii
        
        ret
    printCandidato endp   
                                  
;*************************************************************  prints   ********************************************************* 

        ;***************************************************************************************************
        ; Nome:      printCandidatesRect
        ; Descrição: Desenha os retângulos correspondentes aos candidatos no modo gráfico.
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;*************************************************************************************************** 
        printCandidatesRect proc
            push    Di
            
            mov     Cx, 0005h 
            lea     Di, [square1]             
            print_squares:
                call    drawSquare
                add     Di, 8000              ; tecnicamente é 8000 menos rectLen mas foi metido push/pop Di
                loop    print_squares
            
            pop     Di
            
            ret
        printCandidatesRect endp  
        
        ;***************************************************************************************************
        ; Nome:      printContinueRect
        ; Descrição: Desenha o retângulo associado ao botão "CONTINUAR".
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        printContinueRect proc
            push    Di
            
            mov     rectLength, 80
            mov     rectHeight, 20
            lea     Di, [rect]
            call    drawSquare
                    
            mov     rectLength, squareSize
            mov     rectHeight, squareSize     
                                        
            pop     Di
                                        
            ret                                   
        printContinueRect endp 
        
        ;***************************************************************************************************
        ; Nome:      printGerirLines
        ; Descrição: Desenha linhas separadoras no menu de gerenciamento.
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        printGerirLines proc
            push    es
            
            mov     Ax, 0A000h
            mov     es, Ax
            
            mov     Al, BRANCO 
            cld
                           
            lea     Di, [line1]                             ; apenas para nos certificarmos que o stosb faz inc Di
            mov     Cx, lineSize 
            rep     stosb
            
            lea     Di, [line2]
            mov     Cx, lineSize 
            rep     stosb
                           
            pop     es  
                        
            ret                                   
        printGerirLines endp  

        ;***************************************************************************************************
        ; Nome:      printResults
        ; Descrição: Exibe gráficos representando os votos de cada candidato.
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************            
        printResults proc
            push    rectLength
            add     quantos_votos, 07
               
            xor     Dh, Dh
            mov     Dl, v1 
            shl     Dl, 1
            mov     rectLength, Dx         
            lea     Di, [2450]
            call    drawSquare
            
            mov     Dl, v2
            call    printRectResult  
            
            mov     Dl, v3
            call    printRectResult  
            
            mov     Dl, v4
            call    printRectResult  
            
            mov     Dl, v5
            call    printRectResult    
            
            mov     Dl, votos_brancos
            call    printRectResult    
                                 
            mov     Dl, votos_nulos                     
            call    printRectResult
                                    
            pop     rectLength
                                    
            ret
        printResults endp    
        
        ;***************************************************************************************************
        ; Nome:      printRectResult
        ; Descrição: Desenha um retângulo gráfico proporcional ao número de votos (x2 para melhor visualizacao).
        ;
        ; Input:     DL - número de votos, Di - pixel inicial do retângulo
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        printRectResult proc 
            shl     Dl, 1
            mov     rectLength, Dx
            add     Di, 5120
            call    drawSquare
            
            ret
        printRectResult endp
        
        ;***************************************************************************************************
        ; Nome:      cleanPixels
        ; Descrição: Mete a preto os primeiros pixeis de todos os rectangulos desenhados.
        ;
        ; Input:     DL - número de votos, Di - pixel inicial do retângulo
        ; Output:    N/A.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        cleanPixels proc
            push    es
            
            mov     Ax, 0A000h
            mov     es, Ax
            
            cld
            mov     Al, PRETO                
            lea     Di, [square1]
            mov     Cx, 0005h
            clean_squares:
                stosb          
                add     Di, 7999
                loop    clean_squares
                
            lea     Di, [rect]
            stosb                
            
            lea     Di, [2450]
            mov     Cx, 0007h
            clean_result_rects:
                stosb          
                add     Di, 5119
                loop    clean_result_rects
                           
            pop     es  
        cleanPixels endp                                   
                                            
;***********************************************************    Funcoes auxiliares  ********************************************************* 
            
        ;***************************************************************************************************
        ; Nome:      init_mouse
        ; Descrição: inicializa o rato.
        ;
        ; Input:     Nenhum.
        ; Output:    ax = 0FFFFH (successo) | 0 (falhou), Bx = number of mouse buttons.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        init_mouse proc 
            mov ax, 0           ;initialize mouse
            int 33h     
            
            ret
        init_mouse endp
    
        ;***************************************************************************************************
        ; Nome:      getClick
        ; Descrição: Loop infinito ate rato ser premido (tecla esquerda).
        ;
        ; Input:     Nenhum.
        ; Output:    Cx = Linha (coord y), DX = Coluna (coord x)   
        ; Destroi:   N/A.
        ;***************************************************************************************************    
        getClick Proc
            push    Bx
            
            mov     Ax,03h    
            inic:
                int     33h
                cmp     Bx, 1 
                jne     inic
                
            pop     Bx
            
            ret
        getClick endp 
        
        ;***************************************************************************************************
        ; Nome:      getKey
        ; Descrição: Captura a tecla pressionada pelo utilizador.
        ;
        ; Input:     Nenhum.
        ; Output:    AX = Código da tecla pressionada   
        ; Destroi:   N/A.
        ;***************************************************************************************************   
        getKey Proc
            mov     Ah,00h
            int     16h
            
            ret
        getKey endp 
                              
        ;***************************************************************************************************
        ; Nome:      setCursorPosition
        ; Descrição: Rotina que poe o cursor em Dx.
        ;
        ; Input:     Dh = linha (coord y), Dl = coluna (coord x)
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        setCursorPosition proc
            push    Bx
            
            mov     Ah, 2
            xor     Bh, Bh  	
            int     10h  
            
            pop     Bx
            
            ret
        setCursorPosition endp
        
        ;***************************************************************************************************
        ; Nome:      setCursorWithSpace
        ; Descrição: Rotina que poe o cursor em Dx e printa um espaco nesse sitio 
        ;            (para limpar o que la estava antes).
        ;
        ; Input:     Dh = linha (coord y), Dl = coluna (coord x)
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        setCursorWithSpace proc
            push    Bx 
            push    Dx            
            
            mov     Ah, 02
            xor     Bh, Bh  	
            int     10h    
            mov     Dx, ' '  
            int     21h
            
            pop     Dx        
            
            xor     Bh, Bh        
            int     10h
            pop     Bx 
                             
            ret
        setCursorWithSpace endp 
        
        ;***************************************************************************************************
        ; Nome:      printStr$
        ; Descrição: Rotina que imprime uma string ate ao $ onde o cursor estiver.
        ;
        ; Input:     Dx - string a imprimir
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        printStr$ proc  
            mov     Ah, 09h
            int     21h
                   
            ret
        printStr$ endp 
  
        ;***************************************************************************************************
        ; Nome:      setVideoMode
        ; Descrição: Inicializa o modo de vídeo, usado para limpar ecra (apenas visual).
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        setVideoMode proc
            mov    Ax, 0013h
        	int    10h 
        	
        	ret
        setVideoMode endp 
        
        ;***************************************************************************************************
        ; Nome:      setTextMode
        ; Descrição: Inicializa o modo de texto, usado para limpar ecra (apenas visual).
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        setTextMode proc
        	mov     Ax, 0000h
        	int     10h 
        	
        	ret
        setTextMode endp
        
        ;***************************************************************************************************
        ; Nome:      printAscii
        ; Descrição: printa o valor ascii dum byte no ecra.
        ;
        ; Input:     Dl = valor numerico do byte.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        printAscii proc                 
            mov     Ah, 2
        	add     Dl, '0'
        	int     21h
        	
        	ret
        printAscii endp                 
                         
        ;***************************************************************************************************
        ; Nome:      clearLine
        ; Descrição: Limpa uma linha de texto no modo de texto do vídeo, a linha é preenchida com espaços
        ;
        ; Input:     DX = primeiro pixel da linha a ser limpa. (pixel = linha * 320)
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************    
        clearLine proc
            push    es
            push    Cx
            push    Di
            push    Ax
            
            mov     Ax, 0B800h
            mov     es, Ax
        
            mov     Di, Dx
            shl     Di, 1
            mov     Cx, 40
        
            mov     Ax, 0720h            
            rep     stosw
        	
        	pop     Ax
        	pop     Di
        	pop     Cx
        	pop     es
            
            ret
        clearLine endp                                                                                                                         
        
        ;***************************************************************************************************
        ; Nome:      writeDateTimeToLog
        ; Descrição: Escreve a data e hora do voto (atuais) no ficheiro de log.
        ;
        ; Input:     Nenhum.
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;*************************************************************************************************** 
        writeDateTimeToLog proc
            mov    Ah, 2Ah                       ; CX = year (1980-2099). DH = month. DL = day.
            int    21h   
            
            push    Dx                           ; guarda mes para se usar depois
            push    Dx                           ; guarda dia para se usar depois
            ; 2 
            mov     Ax, Cx 
            mov     Dx, 1000
            call    divideInt 
            
            push    Dx 
            add     Ax, '0'
            mov     [buffer], Al
            mov     Cx, 01  
            call    writeToFile
            
            ; 0
            pop     Dx 
            mov     Ax, Dx 
            mov     Dx, 100 
            call    divideInt
            
            push    Dx
            add     Ax, '0'
            mov     [buffer], Al  
            call    writeToFile 
            
            ; 04
            pop     Dx
            mov     Ax, Dx 
            call    saveTwoValuesTolog
                        
            ; - 
            mov     [buffer], HIFEN
            call    writeToFile 
            
            ; mes e dia 
            pop     Dx 
            xor     Ah, Ah
            mov     Al, Dh 
            call    saveTwoValuesTolog   
            
            mov     [buffer], HIFEN  
            call    writeToFile
            
            pop     Dx 
            xor     Ah, Ah
            mov     Al, Dl  
            call    saveTwoValuesTolog    
            
            ; espaco
            mov     [buffer], ' '
            call    writeToFile  
            
            ; hora + minutos
            mov    Ah, 2Ch                      ; return: CH = hour. CL = minute
            int    21h                          ; get system time
            
            mov     Dx, Cx  
            mov     Cx, 01    
            
            push    Dx
            xor     Ah, Ah
            mov     Al, Dh   
            call    saveTwoValuesTolog   
            
            mov     [buffer], ':'      
            call    writeToFile
            
            pop     Dx 
            xor     Ah, Ah
            mov     Al, Dl  
            call    saveTwoValuesTolog
            
            ret
        writeDateTimeToLog endp 
        
        ;***************************************************************************************************
        ; Nome:      divideInt
        ; Descrição: divide um inteiro em Ax, por Bx. (Dx é metido a 0)
        ;
        ; Input:     Ax = numerador, Bx = denominador.
        ; Output:    Ax = quociente, Dx = resto (remainder).   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        divideInt proc
            push    Bx
            
            mov     Bx, Dx 
            xor     Dx, Dx
            div     Bx
            
            pop     Bx
              
            ret 
        divideInt endp 
        
        ;***************************************************************************************************
        ; Nome:      saveTwoValuesTolog
        ; Descrição: Escreve dois valores (dígitos) no arquivo de log.
        ;            Converte cada dígito em ASCII e grava-os sequencialmente (Dx usado como buffer)
        ;
        ; Input:     AL = Valor para dividir em dois dígitos
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;*************************************************************************************************** 
        saveTwoValuesTolog proc
            mov     Dx, 10
            call    divideInt
            
            push    Dx
            add     Ax, '0'  
            mov     [buffer], Al   
            call    writeToFile 
            
            pop     Dx
            add     Dx, '0'
            mov     [buffer], Dl
            call    writeToFile
              
            ret 
        saveTwoValuesTolog endp 
        
        ;***************************************************************************************************
        ; Nome:      keyToContinue
        ; Descrição: Exibe uma mensagem no ecrã para pressionar qualquer tecla e aguarda ate qualquer tecla
        ;            ser clicada.
        ;
        ; Input:     N/A.
        ; Output:    N/A.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        keyToContinue proc           
            mov     Dx, 1307h 
            call    setCursorPosition   
            lea     Dx, s_key
            call    printStr$    
            
            call    getKey       
            
            ret
        keyToContinue endp 
        
        ;***************************************************************************************************
        ; Nome:      clickToContinue
        ; Descrição: Exibe uma mensagem no ecrã para clicar e aguarda ate o rato ser clicado.
        ;
        ; Input:     N/A.
        ; Output:    N/A.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        clickToContinue proc           
            mov     Dx, 1307h 
            call    setCursorPosition   
            lea     Dx, s_click
            call    printStr$    
            
            call    getClick       
            
            ret
        clickToContinue endp
                                                                                                                                         
;************************************************************** draw **************************************************************     
        
        ;aqui nos  mudamos diretamente o valor dos pixeis na memoria, ->mais rapido e menos confusao com registers
        
        ;***************************************************************************************************
        ; Nome:      drawSquare
        ; Descrição: Rotina que desenha um retangulo definido por rectHeight e rectLength
        ;            verifica se o primeiro pixel está branco, nesse caso muda a cor para vermelho,
        ;            controla o numero de votos escolhidos pelo user ao adicionar/subtrair
        ; Input:
        ;   Si         - pixel superior esquerdo
        ;   rectHeight - eixo x do retangulo
        ;   rectLength - eixo y do retangulo
        ; Output  - N/A
        ; Destrói - N/A
        ;***************************************************************************************************
        drawSquare proc
            push    es
            push    Bx
            push    Cx
            push    Di
            
            push    rectHeight
            push    rectLength  
            push    Bp
            mov     Bp, Sp
            
            mov     Ax, 0A000h         ; documentaçao ->    A0000 - B1000	Video memory for vga, monochrome, and other adapters.
            mov     es, Ax             ; It is used by video mode 13h of INT 10h
            
            call    getPixelValue      ; Al fica com a cor do pixel
            
            cmp     Al, BRANCO
            je      change_color       ; se o primeiro pixel tiver branco, muda para vermelho
            mov     Al, BRANCO         ; se o pixel for qualquer outra cor mete branco 
            jmp     no_change
                     
            change_color:
                mov     Al, VERMELHO
                inc     quantos_votos
                jmp     desenha_quadrado
                
            no_change:
                dec     quantos_votos 
            
            desenha_quadrado:    
            ; aresta de cima 
            cld
            mov     Bx, [Bp + 2]                        ; height + 4
            mov     Cx, Bx                              ; len    + 2  
            rep     stosb
            
            mov     Bx, [Bp + 4]
            push    Ax       
            mov     Ax, 320 
            mul     Bx   
            add     Di, Ax                              ; n sei pq     add  Di, Bx * 320
            pop     Ax  
            
            ; baixo      
            std
            mov     Cx, [Bp + 2]
            rep     stosb
            
            mov     Bx, [Bp + 4]                        ; Cx <--  rectLength  
            
            ; esquerda
            MOV     Cx, Bx                    
            down_square:
                stosb      
                SUB     Di, 319             
                LOOP    down_square   
                
            add     Di, [Bp + 2]
             
            ;direita
            cld               
            mov     Cx, [Bp + 4]                  
            left_square:
                stosb                              
                add     Di, 319
                loop    left_square
            
            pop     Bp                                 ; 2 pops inuteis
            pop     Bp
            pop     Bp
            xor     Bp, Bp
            
            pop     Di       
            pop     Cx       
            pop     Bx    
            pop     es
                                               
            ret
        drawSquare endp

        ;***************************************************************************************************
        ; Nome:      getPixelValue
        ; Descrição: Obtém a cor do pixel na posição especificada.
        ;
        ; Input:     DI - pixel cuja cor será lida.
        ; Output:    AL - Cor do pixel na posição Di.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        getPixelValue proc
            ; esta parte calcula, a partir do valor do pixel  =>    pixel * 320 + coluna 
            ; mas ao contrario, de forma a termos em Al, a cor do pixel
            xor     Dx, Dx          ; Dx = 0
            mov     Ax, Di
            mov     Bx, 320
            div     Bx              ; DIV faz AX*DX / BX  Dx tem o resultado, Ax tem o resto
            mov     Cx, Dx          ; Si % 320 => 230
            mov     Dx, Ax          ; Si / 320 => 20 
            
             mov     Ah, 0Dh          ;get pixel color
            int     10h 
            
            ret
        getPixelValue endp        
        
        ;***************************************************************************************************
        ; Nome:      getNumeroEleitor
        ; Descrição: Recebe o número do eleitor como entrada do utilizador, 
        ;            validando e exibindo erros se necessário.
        ;
        ; Input:     Nenhum.
        ; Output:    num_eleitor - Número do eleitor convertido para dois bytes.   
        ; Destroi:   N/A.
        ;***************************************************************************************************
        getNumeroEleitor proc
            mov     DX, 0501h
            mov     Cx, maxNum                  
            mov     Bx, 10                  
            cld                  
            getNum_loop:
                inc     Dx
                call    setCursorWithSpace
                mov     Ah, 01h
                int     21h
                cmp     Al, ENTER                       ; quando o enter e premido, verificamos se esta vazio  
                je      err_emptyNumber 
                cmp     Al, BACKSPACE                 
                je      backspace_num
                cmp     Al, ESC
                je      esc_numero             
                cmp     Al, '0'           
                jl      err_nan
                cmp     Al, '9'
                jg      err_nan
                call    addDigit                
                loop    getNum_loop
                
                lea     Dx, serr_num
                call    printError
                jmp     num_end
            
            backspace_num:
                dec     Dx
                cmp     Cx, maxNum
                je      getNum_loop
                dec     Dx
                inc     Cx
                call    eraseLastDigit                  
                jmp     getNum_loop
               
            err_nan:                 
                push    Dx
                lea     Dx, serr_nan
                call    printError
                pop     Dx
                dec     Dx
                jmp     getNum_loop
                
            err_emptyNumber:
                cmp     Cx, 12
                jl      err_numero_invalido    
                
                push    Dx
                lea     Dx, serr_empty
                call    printError
                pop     Dx
                dec     Dx
                jmp     getNum_loop
                
            err_numero_invalido:
                cmp     Bx, 10 
                jle     num_end
                
                lea     Dx, serr_max
                call    printError
                jmp     num_end
            
            esc_numero:
                mov     Bx, 11
            
            num_end: 
                
            ret
        getNumeroEleitor endp  
                              
        ;***************************************************************************************************
        ; Nome:      printError
        ; Descrição: Exibe uma mensagem de erro no ecrã e aguarda 
        ;            1 segundo antes de limpar a mensagem.
        ;
        ; Input:     DX - Mensagem de erro a ser exibida (endereço)
        ; Output:    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************                   
        printError proc 
            push    Dx
            mov     Dx, 0702h
            call    setCursorPosition
            pop     Dx
            call    printStr$
            call    wait1s
            mov     Dx, 280
            call    clearLine 
            mov     Dx, 200
            call    clearLine 
            
            ret
        printError endp                                 
                              
        ;***************************************************************************************************
        ; Nome:      addDigit
        ; Descrição: Adiciona um dígito a num_eleitor. Bx sera incrementado a cada digito que o numero 
        ;            passar o maximo valor de word
        ;
        ; Input:     Bx = 10 (para multiplicar) | >10 (numero introduzido é maior que word) 
        ; Output:    num_eleitor - Atualizado com o novo dígito.
        ;            BX - Incrementado em caso de overflow.   
        ; Destroi:   N/A.
        ;***************************************************************************************************                   
        addDigit proc
            push    Dx
            
            cmp     Bx, 10
            jg      adiciona_erro
            cmp     num_eleitor, 6553
            ja      adiciona_erro   
            
            push    Ax  
            xor     Dx, Dx
            mov     Ax, num_eleitor
            mul     Bx 
            ;cmp     Ax, 00
;            jl      adiciona_erro 
            
            mov     num_eleitor, Ax
            pop     Ax       
            
            xor     Ah, Ah                              
            sub     Al, '0'   
            add     num_eleitor, Ax
            jmp     fim_convert
            
            adiciona_erro:                          ; bx tem de estar a 10 para ser feito o calculo, bx vai ter "a mais", os erros introduzidos
                inc     Bx                                ; se bx tem 12, quer dizer que temos de apagr 2 vezes para voltar a ter num valido
            
            fim_convert:
                pop     Dx
             
            ret
        addDigit endp     
        
        ;***************************************************************************************************
        ; Nome:      addDigit
        ; Descrição: Adiciona um dígito a num_eleitor. Bx sera decrementado a cada digito que o numero, no caso
        ;            de ter overflow, for apagado.
        ;
        ; Input:     Bx = 10 (para dividir) | >10 (numero introduzido é maior que word) 
        ; Output:    num_eleitor - Atualizado com menos um dígito.
        ;            BX - Decrementado em caso de overflow.   
        ; Destroi:   N/A.
        ;***************************************************************************************************                    
        eraseLastDigit proc
            push    Dx
            
            dec     Bx
            cmp     Bx, 10
            je      fim_erase
            cmp     Bx, 10
            jg      fim_erase
            
            inc     Bx
                
            divide:
            xor     Dx, Dx
            mov     Ax, num_eleitor
            div     Bx
            mov     num_eleitor, Ax
            
            fim_erase:
                pop     Dx
             
            ret
        eraseLastDigit endp
        
        ;***************************************************************************************************
        ; Nome:      getName
        ; Descrição: Captura uma string de entrada do utilizador, nao deixa que o argumento seja vazio.
        ;
        ; Input:     DI - Endereço onde a string será armazenada 
        ; Output:    BX - 01 (erro) | 00 (valido).   
        ; Destroi:   N/A.
        ;***************************************************************************************************                    
        getName proc 
            push    Di
            
            cld 
            mov     Bx, 00
            mov     Dx, 0501h
            mov     Cx, maxString
            getName_loop:
                inc     Dx
                call    setCursorWithSpace                  
                mov     Ah, 01h
                int     21h
                cmp     Al, ENTER
                je      err_emptyName
                cmp     Al, BACKSPACE
                je      backspace_name 
                cmp     Al, ESC
                je      esc_name
                stosb   
                loop    getName_loop       
                jmp     name_end
            
            backspace_name:
                dec     Dx
                cmp     Cx, maxString
                je      getName_loop
                dec     Dx
                inc     Cx
                dec     Di
                mov     [Di], 00    
                jmp     getName_loop
                
            err_emptyName:
                cmp     Cx, maxString  
                jl      name_end                    
                push    Dx
                lea     Dx, serr_empty
                call    printError
                pop     Dx
                dec     Dx
                jmp     getName_loop
                
            name_end: 
            mov     [Di], 0                   ; null terminated para a comparacao
            jmp     fim_get_name
            
            esc_name:
                mov     Bx, 01
            
            fim_get_name:     
                pop     Di    
                
            ret
        getName endp        
        
        ;***************************************************************************************************
        ; Nome:      clearString
        ; Descrição: Limpa uma string, preenchendo-a com caracteres nulos (`0x00`).
        ;
        ; Input:     DI - Endereço inicial da string.
        ;            CX - Tamanho da string.
        ; Output;    Nenhum.   
        ; Destroi:   N/A.
        ;***************************************************************************************************                    
        clearString proc                                      ; pode ser melhorado, comparar com o NULL e se tiver null supostamente e o fim da string
            push    Di
            
            mov     Al, 00                                    ; null character
            rep     stosb     
            
            pop     Di    
                
            ret
        clearString endp
        
        ;***************************************************************************************************
        ; Nome:      wait1s
        ; Descrição: espera 1 segundo, para podermos ver erros antes de serem apagados.
        ;
        ; Input:     Nenhum.
        ; Output;    Nenhum.   
        ; Destroi:   N/A.
        ;****************************************************************************************************
        wait1s proc      
            push    Dx
            push    Cx
            
            mov     Cx, 0Fh
            mov     Dx, 4240h
            mov     Ah, 86h
            int     15h
            
            pop     Cx
            pop     Dx
                    
            ret
        wait1s endp   
        
        
;**************************************************************     Files     **************************************************************      
        
        ;***************************************************************************************************
        ; Nome:      openFile
        ; Descrição: Tenta Abrir um ficheiro no modo especificado.
        ;
        ; Input:     DX - Endereço do nome do ficheiro.
        ;            AL - Modo de abertura (ex.: READ, WR, READWR)
        ; Output;    AX - Handler ficheiro (sucesso) | codigo erro (falha).
        ;            CF - Flag de erro em caso de falha..   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************    
        openFile proc
            clc
        	mov     Ah, 3Dh 
        	int     21h
        	
        	ret
        openFile endp
       
        ;***************************************************************************************************
        ; Nome:      createFile
        ; Descrição: Tenta criar um ficheiro..
        ;
        ; Input:     DX - Endereço do nome do ficheiro.
        ; Output;    AX - Handler ficheiro (sucesso) | codigo erro (falha).
        ;            CF - Flag de erro em caso de falha..   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************
        createFile proc
            clc
            mov     Ah, 3ch                 ; create file      
            int     21h 
                
            ret       
        createFile endp  

        ;***************************************************************************************************
        ; Nome:      closeFile
        ; Descrição: Tenta fechar um ficheiro.
        ;
        ; Input:     Bx - Handler ficheiro .
        ; Output;    Nenhum.   
        ; Destroi:   AX (sucesso).
        ;****************************************************************************************************                                            
        closeFile proc
            clc
            mov     Ah, 3eh                 ; close file
            int     21h
               
            ret 
        closeFile endp   
        
        ;***************************************************************************************************
        ; Nome:      writeToFile
        ; Descrição: Escreve para dentro de um ficheiro. 
        ;
        ; Input:     Cx = 01 (printa 1 byte, buffer usado como argumento), senao printa Cx caracteres.
        ; Output;    Nenhum.   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************
        writeToFile proc
            push    Ax
            
            cmp     Cx, 01
            jg      writeString
            lea     Dx, buffer                  ; if Cx, 01 then the byte to write is in buffer
            
            writeString:
                clc
                mov     Ah, 40h             
                int     21h
                
            pop  Ax     
            
            ret 
        writeToFile endp  
                  
        
        ;***************************************************************************************************
        ; Nome:      readFromFile
        ; Descrição: Lê de um ficheiro. 
        ;
        ; Input:     BX - Handler do ficheiro.
        ;            CX - Número de bytes a ler.
        ;            DX - Endereço do buffer de destino.
        ; Output;    AX - Número de bytes lidos.   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************
        readFromFile proc
            push    Ax     
            
            clc
            mov     Ah, 3fh          
            int     21h
            
            pop     Ax     
            
            ret  
        readFromFile endp
        
        ;***************************************************************************************************
        ; Nome:      fSeek
        ; Descrição: mete o ponteiro dum ficheiro onde receber como argumento. (Dx metido a 0 = offset) 
        ;
        ; Input:     BX - Handler do ficheiro.
        ;            AL - Posição do ponteiro (00: início,02: fim).
        ; Output;    Nenhum.   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************
        fSeek proc                                                                                                                                                                                
            clc
            mov     ah, 42h             ; set file pointer (seek)  
            xor     Dx, Dx              ; no offset         
            xor     Cx, Cx
            int     21h                  
            
            jnc     seek_success        ; salta se fechar o ficheiro com sucesso      
            
            lea     Dx, serr_read               ; AX tem error equivalente se quisermos usar
            call    printStr$
            
            seek_success:  
                    
            ret
        fSeek endp
        
        ;***************************************************************************************************
        ; Nome:      loadMemoryToBin
        ; Descrição: Salva a estrutura no ficheiro binario. 
        ;
        ; Input:     Nenhum.
        ; Output;    Nenhum.   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************
        loadMemoryToBin proc
            lea     Dx, s_saving
            call    printStr$ 
            
            lea     Dx, dataFile
            mov     Al, WR
            call    openFile                        
            jnc     bin_file_exists    
            
            ;msg erro                             
            bin_file_exists:
                mov     Bx, Ax                
    
            mov     al, 0                 ; Reposiciona a partir do inicio
            call    fSeek
        
            lea     Di, lista_eleitores   ; Aponta para o inicio da estrutura na memoria
            mov     Cx, num_eleitores     ; Numero de eleitores a processar
            write_loop:
                push    Cx
                ; numero eleitor (2 bytes)
                mov     Cx, 01   
                mov     Dl, [Di]
                mov     [buffer], Dl 
                call    writeToFile  
                inc     Di       
                                    
                mov     Dl, [Di]                    
                mov     [buffer], Dl                          
                call    writeToFile
                inc     Di
                
                mov     Cx, 30
                save_nome_eleitor_bin:  
                    mov     Dl, [Di]                
                    cmp     Dl, 00                  ; quando chegar a um char null
                    je      fim_nome_bin
                    push    Cx
                    mov     Cx, 01
                    mov     [buffer], Dl 
                    call    writeToFile
                    pop     Cx
                    inc     Di
                    loop    save_nome_eleitor_bin  
                
                fim_nome_bin:
                    inc     Di
                    loop    fim_nome_bin
                
                ; status de voto (1 byte) 
                mov     Cx, 01  
                mov     Dl, [Di]
                mov     [buffer], Dl
                call    writeToFile           ; Escreve no ficheiro
                
                pop     Cx
                inc     Di                    ; Avanca para o proximo eleitor
            loop    write_loop
            
            ret
        loadMemoryToBin endp
        
        ;***************************************************************************************************
        ; Nome:      LoadDataFile
        ; Descrição: abre o ficheiro binario e preenche a estrutura com o que tiver la
        ;            cria se nao existir. 
        ;
        ; Input:     Nenhum.
        ; Output;    Nenhum.   
        ; Destroi:   Nenhum.
        ;****************************************************************************************************
        LoadDataFile proc 
            mov     Dx, 0202h            
            call    setCursorPosition        
            lea     Dx, s_loading
            call    printStr$ 
            
            lea     Dx, dataFile
            mov     Al, READWR
            call    openFile                        
            jnc     data_file_exists    
            
            mov     Dx, 0402h
            call    setCursorPosition 
            lea     Dx, serr_open
            call    printStr$  
            
            lea     Dx, dataFile
            mov     Al, READWR
            call    createFile
            jmp     data_file_created
            
            data_file_exists:
                mov     Bx, Ax                
                call    loadBinToMemory  
            
            data_file_created:    
                call    closeFile 
            
            ret
        LoadDataFile endp
         
        ;***************************************************************************************************
        ; Nome:      loadBinToMemory
        ; Descrição: preenche a estrutura com o que tiver dentro do ficheiro binario
        ;
        ; Input:     Nenhum.
        ; Output;    bool_eleitoresCarregados incrementado.   
        ; Destroi:   Nenhum.
        ;**************************************************************************************************** 
        loadBinToMemory proc
            mov     al, 0                 ; Reposiciona a partir do inicio
            call    fSeek
        
            lea     Di, lista_eleitores   ; Aponta para o inicio da estrutura na memoria
            mov     Cx, num_eleitores     ; Numero de eleitores a processar 
            lea     Dx, buffer
            read_loop:
                push    Cx
                
                mov     Cx, 01 
                call    readFromFile
                mov     Al, [buffer]                  
                stosb
                
                call    readFromFile
                mov     Al, [buffer]                  
                stosb
                
                mov     Cx, 30 
                xor     Ax, Ax
                read_name_from_mem:
                    push    Cx                     
                    mov     Cx, 01
                    call    readFromFile                      ; quando nao ha carry e Ax ta a 00 é porque atingiu EOF, mas havera sempre CR LF
                    pop     Cx
                    
                    cmp     [buffer], 00                      ; Encontrar o byte voto
                    je      fim_name_mem
                    cmp     [buffer], 01                      ; Encontrar o byte voto
                    je      fim_name_mem 
                    mov     Al, [buffer]                  
                    stosb                               ; Armazenar byte no endereco apontado por DI
                    loop     read_name_from_mem          
                
                fim_name_mem:
                    mov     Al, 00
                    rep     stosb  
                                    
                mov     Al, [buffer]                  
                stosb
                
                pop     Cx         
            loop    read_loop
            
            inc    bool_eleitoresCarregados
            
            ret
        loadBinToMemory endp
    
    ends
    
   
    end start ; set entry point and stop the assembler.
