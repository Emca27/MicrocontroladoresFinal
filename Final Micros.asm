
    ; Emiliano Aguirre Bayli	A01338896
    ; Marco Antonio Ortiz Hdz	A00823250 
    
    #include "p18f45k50.inc"
    
    org 0x00
    goto configura
    
    org 0x08 ; interrupciones de alta prioridad
    goto tmr0int
    
    org 0x18 ; interrupciones de baja prioridad
    goto IOCint
    
    org 0x30
configura movlb d'15'
    ;clrf ANSELB, BANKED ; configurando el puerto B como digital
    ;clrf ANSELC, BANKED ; configurando el puerto C como digital
    clrf ANSELD, BANKED ; configurando el puerto D como digital
    clrf ANSELA, BANKED	; configura como digital
    clrf TRISD, A ; configurando el puerto D como salida
    ;setf TRISB, A ; configurando el puerto B como entrada
    ;setf TRISC, A ; configurando el puerto C como entrada
    clrf TRISA, A ; configurando el puerto A como salida
    #define RS LATA, 1, A
    #define E LATA, 2, A
    #define RW LATA, 3, A
    #define dataLCD LATD, A
    
    ; Se define el valor inicial del registro para retardo para LCD ------------
    movlw .247
    movwf 0x32, A
    
    
start 
    ; configuracion de interrupciones ------------------------------------------
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
    
    ; retardo inicial para que la LCD se inicialice ----------------------------
    call ret40
    movlw .247
    movwf 0x32, A
    
    ; Empieza a escribir en la LCD ---------------------------------------------
    bcf RS			; se pone en 0 el RS porque aun no se necesita
    ; Modo de funcionamiento de 2 lineas 
    movlw b'00111000'
    call enviaDatos
    ; Encender el display, el cursor y el parpadeo 
    movlw b'00001111'
    call enviaDatos
    ; Configurar el incremento del cursor hacia la derecha
    movlw b'00010100'
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
    
    ; Aqui va a empezar la bienvenida
    
    ; Moverse a la posici�n 5 de la segunda l�nea (0x45) -----------------------
    movlw b'11000101'	; se carga el 0x45 en binario
			; el bit 7 se pone en 1 por sintaxis de Set DDRAM address
    call enviaDatos
    bsf RS			; ya se pone en 1 el RS para escribir los c y 4
    ; Escribir la letra 'c' ----------------------------------------------------
    movlw 'c'
    call enviaDatos
    ; Escribir el numero '4' ---------------------------------------------------
    movlw '4'
    call enviaDatos
    
 ;Aqui empieza el Menu de Puntajes 
 ;Quedara mamalon
 ;SuperMamalon
loop goto loop ; loop infinito para esperar a que se presione RB4 o RC0
    ; still waiting for el mamalon
    
    
    ; Subrutina para protocolo de envio de datos al LCD ------------------------
enviaDatos 
    bcf RW
    bsf E
    movwf dataLCD
    nop
    bcf E
    call ret40
    movlw .247
    movwf 0x32, A
    
    ; Retardos para LCD --------------------------------------------------------
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
    
    
    
    ; Rutinas de interrupciones ------------------------------------------------
    org 0x100
tmr0int 
    bcf LATD, 0, A ; apaga el LED en el pin RD0
    bcf INTCON, 2, A ; apaga la bandera del TMR0
    bcf T0CON, 7, A ; desactiva el TMR0
    retfie
    
prendeUnSeg 
    movlw 0xF0 ; valor inicial del TMR0H para un ret de 1 segundo
    movwf TMR0H, A 
    movlw 0xBD ; valor inicial del TMR0L para un ret de 1 segundo
    movwf TMR0L, A
    bsf LATD, 0, A ; prende el LED en el pin RD0
    bsf T0CON, 7, A ; activa el TMR0
    retfie
    
prendeMedioSeg
    movlw 0xF8 ; valor inicial del TMR0H para un ret de 1/2 segundo
    movwf TMR0H, A 
    movlw 0x5E ; valor inicial del TMR0L para un ret de 1/2 segundo
    movwf TMR0L, A
    bsf LATD, 0, A ; prende el LED en el pin RD0
    bsf T0CON, 7, A ; activa el TMR0
    retfie
    
IOCint 
    btfsc PORTB, 4, A ; checa si se presiono RB4
	goto prendeUnSeg
    btfsc PORTC, 0, A ; checa si se presiono RC0
	goto prendeMedioSeg
    retfie
    
    end

