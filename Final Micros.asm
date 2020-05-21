
    ; Emiliano Aguirre Bayli	A01338896
    ; Marco Antonio Ortiz Hdz	A00823250 
    
    #include "p18f45k50.inc"
    
    org 0x00
    goto configura
    
    org 0x08 ; interrupciones de alta prioridad
    retfie ;goto tmr0int
    
    org 0x18 ; interrupciones de baja prioridad
    retfie ;goto IOCint
    
    org 0x30
configura movlb d'15'
    ;clrf ANSELB, BANKED ; configura el puerto B como digital
    ;clrf ANSELC, BANKED ; configura el puerto C como digital
    clrf ANSELD, BANKED ; configura el puerto D como digital
    clrf ANSELA, BANKED ; configura el puerto A como digital
    clrf ANSELE, BANKED ; configura el puerto E como digital
    clrf ANSELC, BANKED ; configura el puerto C como digital
    clrf TRISD, A   ; configura el puerto D como salida, este puerto se usa para el bus de Datos del LCD
    ;setf TRISB, A ; configura el puerto B como entrada
    ;setf TRISC, A ; configura el puerto C como entrada
    clrf TRISA, A   ; configura el puerto A como salida, este puerto se usara para el LCD
    clrf TRISC, A   ; configura el puerto C como salidad, C6 y C7 se usarán para los LEDs de Win/Lose
    setf TRISE, A   ; congfigura el puerto E como entrada, este puerto se usa para los botones de accion
    #define RS LATA, 1, A   ; RS del LCD
    #define E LATA, 2, A    ; Enable del LCD
    #define RW LATA, 3, A   ; Read/Write del LCD
    #define dataLCD LATD, A ; Bus de Datos para el LCD
    #define botonA PORTE, 0, A   ; este es el boton "principal" para pasar de la pantalla de Welcome a la de elegir modo y para elegir "Play Game"
    #define botonB PORTE, 1, A  ; este es el boton "secundario" para pasar elegir ver el marcador
    #define LEDWin LATC, 6, A   ; este es el LED que se enciende si se gana la partida
    #define LEDLose LATC, 7, A  ; este es el LED que se enciende si se pierde la partida
    
vidas EQU 0x34          ; este registro es en donde se almacenarán las vidas restantes
randomNumber EQU 0x35   ; este registro es en donde se almacenará el random number
numWins EQU 0x36        ; este registro es para mantener el puntaje de victorias
numDefeats EQU 0x37     ; este registro es para mantener el puntaje de derrotas

resultadoResta EQU 0x38 ;este registro es para guardar el resultado de la resta entre lo seleccionado con el potencimoetro y el random number

    movlw d'0'
    movwf numWins       ; se inicializa el marcador de victorias en 0
    movwf numDefeats    ; se inicializa el marcador de derrotas en 0

    
    ; Se define el valor inicial del registro para retardo para LCD 
    movlw .247
    movwf 0x32, A
    
    
start 
    ; configuracion de interrupciones 
    ;bcf INTCON, 7, A ; activa prioridades
    ;movlw b'11101000' ; configuracion de INTCON
    ;movwf INTCON, A
    ;movlw b'10000100' ; configuracion de INTCON2
    ;movwf INTCON2, A
    ;movlw b'00000111' ; configuracion de T0CON
    ;movwf T0CON, A
    ;movlw b'00010000' ; activacion del IOC en el pin RB4
    ;movwf IOCB, A
    ;movlw b'00000001' ; activacion del IOC en el pin RC0
    ;movwf IOCC, A
    
    ; retardo inicial para que la LCD se inicialice ------------------------------------------------------------------------
    call ret40
    movlw .247
    movwf 0x32, A
    
    ; Empieza la configuración de la LCD -----------------------------------------------------------------------------------
    
    bcf RS ; se pone en 0 el RS porque aun no se necesita
    movlw b'00111000' ; Modo de funcionamiento de 2 lineas 
    call enviaDatos
    movlw b'00001111' ; Encender el display, el cursor y el parpadeo 
    call enviaDatos
    movlw b'00010100' ; Configurar el incremento del cursor hacia la derecha
    call enviaDatos
    ; Limpiar el display y enviar al home (posicion 0)
    bcf RS
    bcf RW
    bsf E
    movlw b'00000001'
    movwf dataLCD
    nop
    bcf E
    call ret2ms
    nop
    
    ; Aqui empieza el menu (cartel) de Bienvenida --------------------------------------------------------------------------
    
    ; Moverse a la posicion 4 de la primera linea (0x04) 
    movlw b'10000100' ; se carga el 0x04 en binario, el b7 es 1 por sintaxis de Set DDRAM address
    call enviaDatos ; se envian los datos
    bsf RS			; ya se pone en 1 el RS para escribir el mensaje
    ; Se empieza a escribir el mensaje letra por letra 
    movlw 'W'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw 'L'
    call enviaDatos
    movlw 'C'
    call enviaDatos
    movlw 'O'
    call enviaDatos
    movlw 'M'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw '!'
    call enviaDatos
    bcf RS ; vuelve a poner el RS en 0 para mover la posicion del cursor
    ; Moverse a la posicion 0 de la segunda linea (0x40)
    movlw b'11000000' ; se carga el 0x40 en binario, el b7 es 1 por sintaxis de Set DDRAM address
    call enviaDatos ; se envian los datos
    bsf RS ; se pone el RS en 1 para escribir los nuevos valores
    ; Se escribe el mensaje letra por letra
    movlw 'C'
    call enviaDatos
    movlw 'h'
    call enviaDatos
    movlw 'o'
    call enviaDatos
    movlw 'o'
    call enviaDatos
    movlw 's'
    call enviaDatos
    movlw 'e'
    call enviaDatos
    movlw ' '
    call enviaDatos
    movlw 'a'
    call enviaDatos
    movlw 'n'
    call enviaDatos
    movlw ' '
    call enviaDatos
    movlw 'o'
    call enviaDatos
    movlw 'p'
    call enviaDatos
    movlw 't'
    call enviaDatos
    movlw 'i'
    call enviaDatos
    movlw 'o'
    call enviaDatos
    movlw 'n'
    call enviaDatos
    
checkBotonWelcome ; cambio de pantalla al presionar el boton RE0
    btfss botonA ; checa si se presiono el boton para pasar de pantalla
        goto checkBotonWelcome ; si no se presiono, se queda esperando
    ; si se presiona, cambia de pantalla

    ; Limpiar el display y enviar al home (posicion 0)
    bcf RS
    bcf RW
    bsf E
    movlw b'00000001'
    movwf dataLCD
    nop
    bcf E
    call ret2ms
    nop
    ; Moverse a la posicion 1 de la primera linea (0x01) 
    movlw b'10000001' ; se carga el 0x01 en binario, el b7 es 1 por sintaxis de Set DDRAM address
    call enviaDatos ; se envian los datos
    bsf RS			; ya se pone en 1 el RS para escribir el mensaje
    ; Se empieza a escribir el mensaje letra por letra 
    movlw 'P'
    call enviaDatos
    movlw 'L'
    call enviaDatos
    movlw 'A'
    call enviaDatos
    movlw 'Y'
    call enviaDatos
    movlw ' '
    call enviaDatos
    movlw 'G'
    call enviaDatos
    movlw 'A'
    call enviaDatos
    movlw 'M'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw ':'
    call enviaDatos
    movlw ' '
    call enviaDatos
    movlw 'R'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw '0'
    call enviaDatos
    bcf RS ; vuelve a poner el RS en 0 para mover la posicion del cursor
    ; Moverse a la posicion 0 de la segunda linea (0x40)
    movlw b'11000000' ; se carga el 0x40 en binario, el b7 es 1 por sintaxis de Set DDRAM address
    call enviaDatos ; se envian los datos
    bsf RS ; se pone el RS en 1 para escribir los nuevos valores
    ; Se escribe el mensaje letra por letra
    movlw 'S'
    call enviaDatos
    movlw 'C'
    call enviaDatos
    movlw 'O'
    call enviaDatos
    movlw 'R'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw 'S'
    call enviaDatos
    movlw 'T'
    call enviaDatos
    movlw 'R'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw 'A'
    call enviaDatos
    movlw 'K'
    call enviaDatos
    movlw ':'
    call enviaDatos
    movlw ' '
    call enviaDatos
    movlw 'R'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw '1'
    call enviaDatos
    
checkBotonMode                  ; cambia de pantalla el modo que se haya seleccionado con el boton
    incf randomNumber, F, A     ; se genera un numero "aleatorio"
    btfsc botonA                ; checa si se presiono el boton RE0 para iniciar el juego
        goto playGame           ; si se presiono, inicia el juego
        ; si no se presiono, checa el boton RE1 para ver el marcador
    btfsc botonB
        goto viewScore          ; si se presiono, va al marcador
    goto checkBotonMode         ; si no se presiono, vuelve a checar el otro boton

playGame                        ; se queda esperando el potenciometro y seleccion del numero (no implementado)    
    movlw d'6'                  ; se carga la cantidad de vidas
    movwf vidas  
selecNum
    movlw d'150'                ;[TODO]Supongamos que el usuarios escoge el num 150 con el potenciometro
                                ;momentareamente usaremos numeros hardcodeados para simular la seleccion de los numeros
                                ;Esto hasta desarrollar la parte del potenciometro


    subwf randomNumber,1, A ;Se hace la resta y se guarda el resultado
    btfsc STATUS,2,A            ;Se verifica si el bit dos del status es zero, de ser asÃ­ se gano el juego
        goto gameWon
    movf STATUS,W,A             ;Guardo lo que se genero en el STATUS despues de la operacion para despues checar si el resultado fue negativo
    movwf resultadoResta,A
    dcfsnz vidas, 1, A     ;Se quita una vida al jugador, de tener cero despues de esto, se acaba el juego -----MARCA MAL DECFSNZ
        goto gameOver
    
                                ;[TODO] Agregar logica para saber si el numero correcto es mayor o menor, tambien hace falta crear esos custom characters
    btfsc resultadoResta, 0, A  ;Validar esta logica, si es negativo salta linea
        goto arrowDown
    goto arrowUp                ;[TODO] goto o call Â¿?

;Seccion de codigo que indica si se gano o perdio----------------------------------------------------------------------------------------

gameWon                          ; [TODO] Implementar lÃ³gica para prender el led de ganador y para regresar al menu principal
    incf numWins, 1, A

    goto gameWon

gameOver                         ;[TODO] Implementar lÃ³gica para prender el led de perdedor y para regresar al menu principal
    incf numDefeats, 1, A


    goto gameOver

;Seccion de codigo para pinta los custom characters----------------------------------------------------------------------------------------
arrowUp                          ;[TODO] Implementar lógica para pintar el custom que indicará al jugador escojer un numero mayor




    goto selecNum                ;Se regresa para seleccionar el num

arrowDown                          ;[TODO] Implementar lógica para pintar el custom que indicará al jugador escojer un numero menor




    goto selecNum                ;Se regresa para seleccionar el num


viewScore ; se muestra el marcador en la pantalla del LCD (Falta lo de la memoria de la EEPROM)
    ; Limpiar el display y enviar al home (posicion 0)
    bcf RS
    bcf RW
    bsf E
    movlw b'00000001'
    movwf dataLCD
    nop
    bcf E
    call ret2ms
    nop
    ; Moverse a la posicion 3 de la primera linea (0x03) 
    movlw b'10000011' ; se carga el 0x03 en binario, el b7 es 1 por sintaxis de Set DDRAM address
    call enviaDatos ; se envian los datos
    bsf RS			; ya se pone en 1 el RS para escribir el mensaje
    ; Se empieza a escribir el mensaje letra por letra 
    movlw 'W'
    call enviaDatos
    movlw 'I'
    call enviaDatos
    movlw 'N'
    call enviaDatos
    movlw 'S'
    call enviaDatos
    movlw ':'
    call enviaDatos
    movlw ' '
    call enviaDatos
    bcf RS ; vuelve a poner el RS en 0 para mover la posicion del cursor
    ; Moverse a la posicion 2 de la segunda linea (0x42)
    movlw b'11000010' ; se carga el 0x42 en binario, el b7 es 1 por sintaxis de Set DDRAM address
    call enviaDatos ; se envian los datos
    bsf RS ; se pone el RS en 1 para escribir los nuevos valores
    ; Se escribe el mensaje letra por letra
    movlw 'D'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw 'F'
    call enviaDatos
    movlw 'E'
    call enviaDatos
    movlw 'A'
    call enviaDatos
    movlw 'T'
    call enviaDatos
    movlw 'S'
    call enviaDatos
    movlw ':'
    call enviaDatos
    movlw ' '
    call enviaDatos


loop        ; loop infinito para pausar el programa mientras debuggeo
    goto loop 

    
    

    ; Subrutina para protocolo de envio de datos al LCD --------------------------------------------------------------------
enviaDatos 
    bcf RW
    bsf E
    movwf dataLCD
    nop
    bcf E
    call ret40
    movlw .247
    movwf 0x32, A
    
    ; Retardos para LCD ----------------------------------------------------------------------------------------------------
ret40 incf 0x32, F, A
    btfss STATUS, 1
    goto ret40
    return
    
ret1ms movlw .8
    movwf 0x33, A
incRut incf 0x33, F, A
    btfss STATUS, 2
    goto incRut
    return
    
ret2ms call ret1ms
    call ret1ms
    return
    
    
    
    ; Rutinas de interrupciones --------------------------------------------------------------------------------------------
    ;org 0x100
;tmr0int 
    ;bcf LATD, 0, A ; apaga el LED en el pin RD0
    ;bcf INTCON, 2, A ; apaga la bandera del TMR0
    ;bcf T0CON, 7, A ; desactiva el TMR0
    ;retfie
    
;prendeUnSeg 
    ;movlw 0xF0 ; valor inicial del TMR0H para un ret de 1 segundo
    ;movwf TMR0H, A 
    ;movlw 0xBD ; valor inicial del TMR0L para un ret de 1 segundo
    ;movwf TMR0L, A
    ;bsf LATD, 0, A ; prende el LED en el pin RD0
    ;bsf T0CON, 7, A ; activa el TMR0
    ;retfie
    
;prendeMedioSeg
    ;movlw 0xF8 ; valor inicial del TMR0H para un ret de 1/2 segundo
    ;movwf TMR0H, A 
    ;movlw 0x5E ; valor inicial del TMR0L para un ret de 1/2 segundo
    ;movwf TMR0L, A
    ;bsf LATD, 0, A ; prende el LED en el pin RD0
    ;bsf T0CON, 7, A ; activa el TMR0
    ;retfie
    
;IOCint 
    ;btfsc PORTB, 4, A ; checa si se presiono RB4
	;goto prendeUnSeg
    ;btfsc PORTC, 0, A ; checa si se presiono RC0
	;goto prendeMedioSeg
    ;retfie
    
    end

