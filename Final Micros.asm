
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
    clrf ANSELB, BANKED ; configurando el puerto B como digital
    clrf ANSELC, BANKED ; configurando el puerto C como digital
    clrf ANSELD, BANKED ; configurando el puerto D como digital
    clrf TRISD, A ; configurando el puerto D como salida
    setf TRISB, A ; configurando el puerto B como entrada
    setf TRISC, A ; configurando el puerto C como entrada
    
start 
    ; configuracion de interrupciones
    bcf INTCON, 7, A ; activa prioridades
    movlw b'11101000' ; configuracion de INTCON
    movwf INTCON, A
    movlw b'10000100' ; configuracion de INTCON2
    movwf INTCON2, A
    movlw b'00000111' ; configuracion de T0CON
    movwf T0CON, A
    movlw b'00010000' ; activacion del IOC en el pin RB4
    movwf IOCB, A
    movlw b'00000001' ; activacion del IOC en el pin RC0
    movwf IOCC, A
    
loop goto loop ; loop infinito para esperar a que se presione RB4 o RC0
    
    
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
    