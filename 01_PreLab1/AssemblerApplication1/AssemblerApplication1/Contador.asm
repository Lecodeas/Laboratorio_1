;-----------------------------------------------
; Universidad del Valle de Guatemala
; IE2023: Programacion de Microcontroladores
; Contador.asm
; Autor: Ian Anleu Rivera
; Proyecto: Prelab 1
; Hardware: ATMEGA328P
; Creado: 27/01/2024
; Ultima modificacion: 30/01/2024
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
	; Clock en 2MHz
	LDI R16, 0b1000_0000 
	STS CLKPR, R16 ; Habilitar prescaler (STS por la memoria en donde esta CLKPR)
	LDI R16, 0b0000_0011
	STS CLKPR, R16  ; 0011 es Divisor entre 8

	; Entradas (PORTD a Button 1 y 2) y Salidas (PORTB a LEDs)
	LDI R16, 0x0F
	OUT DDRB, R16 ; Configura Primeros 4 de PORTB a Salida
	
	CLR R17
	LDI R16, 0xFF
	OUT DDRD, R17 ; Configura todos de PORTD a Entradas
	OUT PORTD, R16 ; Configurar todos Pull-Up

	; Registro para monitoreo de estados previos
	LDI R18, 0xFF
	
	; Registro para Contador
	LDI R19, 0x00
	

;-----------------------------------------------
; LOOP de flash memory

Loop:
	; Antirrebote de PinD
	IN R16, PIND
	; Ya tengo estados previos en R19
	CP R16, R18 ; Comparo los estados actual y previo por algun cambio
	BREQ Loop ; Si no han cambiado, mantengo el loop
	CALL Antirrebote
	IN R16, PIND
	CP R16, R18 ; Comparo los estados actual y previo por algun cambio
	BREQ Loop ; Si no han cambiado, mantengo el loop
	; Si cambiaron
	MOV R18, R16 ; Modifico el estado actual y

Aumentar:
	SBRC R16, PD0 ; Determino si el boton de aumentar esta presionado 
	RJMP Decrementar ; De no estar presionado, vuelvo al loop
	INC R19 ; De estar presionado, aumento contador R19
	OUT PINB, R19 ; Y lo transporto a PINB

Decrementar:
	SBRC R16, PD1 ; Determino si el boton de decrementar esta presionado 
	RJMP Loop ; De no estar presionado, vuelvo al loop
	DEC R19 ; De estar presionado, disminuyo contador R19
	OUT PINB, R19 ; Y lo transporto a PINB

	RJMP Loop ; Al terminar, hago el loop

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