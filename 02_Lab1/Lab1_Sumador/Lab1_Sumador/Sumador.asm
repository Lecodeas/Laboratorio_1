;-----------------------------------------------
; Universidad del Valle de Guatemala
; IE2023: Programacion de Microcontroladores
; Sumador.asm
; Autor: Ian Anleu Rivera
; Proyecto: Laboratorio 1
; Hardware: ATMEGA328P
; Creado: 29/01/2024
; Ultima modificacion: 31/01/2024
;-----------------------------------------------

.include "M328PDEF.INC" ; Nombres de Registros
.cseg

.org 0x00 ; Vector Reset

;-----------------------------------------------
; Stack Pointer

	LDI R16, LOW(RAMEND) ; Funcion LOW da la parte baja
	OUT SPL, R16
	LDI R16, HIGH(RAMEND) ; Funcion HIGH da la parte alta
	OUT SPH, R16

;-----------------------------------------------
; Configuracion

Setup:
	; Clock en 1MHz
	LDI R16, 0b1000_0000 
	STS CLKPR, R16 ; Habilitar prescaler (STS por la memoria en donde esta CLKPR)
	LDI R16, 0b0000_0100
	STS CLKPR, R16  ; 0100 es Divisor entre 16

	; Salidas (PORTD y PORTC a LEDs)
	LDI R16, 0xFF
	OUT DDRD, R16 ; Configura PORTD a Salida
	OUT DDRC, R16 ; Configura PORTC a Salida
	
	; Entradas (PORTB a Buttons)
	LDI R17, 0x00
	OUT DDRB, R17 ; Configura todos de PORTD a Entradas
	OUT PORTB, R16 ; Configurar todos Pull-Up

	; Registro para monitoreo de estados previos
	LDI R18, 0xFF
	
	; Registros para Contadores
	LDI R19, 0x00 ; Contador 1
	LDI R20, 0x00 ; Contador 2
	LDI R21, 0x00 ; OR de 1 y 2
	LDI R22, 0x00 ; Suma de 1 y 2
	

;-----------------------------------------------
; LOOP de flash memory

Loop:
	; Antirrebote de PinB
	IN R16, PINB
	; Ya tengo estados previos en R19
	CP R16, R18 ; Comparo los estados actual y previo por algun cambio
	BREQ Loop ; Si no han cambiado, mantengo el loop
	CALL Antirrebote
	IN R16, PINB
	CP R16, R18 ; Comparo los estados actual y previo por algun cambio
	BREQ Loop ; Si no han cambiado, mantengo el loop
	; Si cambiaron
	MOV R18, R16 ; Modifico el estado actual y
	
	CALL Contadores ; Verifico ambos contadores
	
	CALL Combinacion ; Combina los contadores para ponerlos en PIND

	CALL Sumas ; Verifico el boton de Suma

	RJMP Loop ; Al terminar vuelve al loop

;-----------------------------------------------
; Subrutinas
;-----------------------------------------------

Antirrebote:
	LDI R17, 100 ; 100 Ciclos entre lecturas
Delay:
	DEC R17 ; Disminuye el contador
	CPI R17, 0x00 ; Compara Contador con 0
	BRNE Delay ; Vuelve a Delay si no son iguales
	RET

;-----------------------------------------------

Contadores:
; CONTADOR 1 R19
Aumentar1:
	SBRC R16, PB0 ; Determino si el boton de aumentar esta presionado 
	RJMP Decrementar1 ; De no estar presionado, verifico el otro botón
	INC R19 ; De estar presionado, aumento contador R19

Decrementar1:
	SBRC R16, PB1 ; Determino si el boton de decrementar esta presionado 
	RJMP Aumentar2 ; De no estar presionado, vuelvo al CALL
	DEC R19 ; De estar presionado, disminuyo contador R19

; CONTADOR 2 R20
Aumentar2:
	SBRC R16, PB2 ; Determino si el boton de aumentar esta presionado 
	RJMP Decrementar2 ; De no estar presionado, verifico el otro botón
	INC R20 ; De estar presionado, aumento contador R20

Decrementar2:
	SBRC R16, PB3 ; Determino si el boton de decrementar esta presionado 
	RET ; De no estar presionado, vuelvo al CALL
	DEC R20 ; De estar presionado, disminuyo contador R20

	RET ; Al terminar, vuelvo al CALL

;-----------------------------------------------

Combinacion:
	ANDI R19, 0X0F ; Modificar ambos contadores a solo 4 bits
	ANDI R20, 0X0F
	SWAP R20 ; Cambiar de lugar Nibbles de R20
	MOV R21, R19 ; Copiar R19 a R21
	OR R21, R20 ; Combinar el R19 con R20 en R21
	SWAP R20 ; Regreso R20 a su forma original
	OUT PORTD, R21 ; Despliego R21 en todo el PIND
	RET ; Regreso al CALL

;-----------------------------------------------


Sumas:
	SBRC R16, PB4; Determino si el boton de suma esta presionado
	RET ; De no estar presionado, vuelvo al CALL
	MOV R22, R19 ; De estar presionado copio R19 a R22
	ADD R22, R20 ; Realizo la suma de R19 y R20 en R22
	ANDI R22, 0X1F; Verifico que sean solo 5 bits (4 mas carry)
	OUT PORTC, R22; Despliego el resultado en PORTC
	RET ; Al terminar, vuelvo al CALL

;-----------------------------------------------