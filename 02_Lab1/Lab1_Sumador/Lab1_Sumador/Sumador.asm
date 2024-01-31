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
	STS CLKPR, R16  ; 0011 es Divisor entre 16

	; Salidas (PORTB y PORTC a LEDs)
	LDI R16, 0x0F
	OUT DDRB, R16 ; Configura Primeros 4 de PORTB a Salida
	OUT DDRC, R16 ; Configura Primeros 4 de PORTC a Salida
	
	; Entradas (PORTD a Buttons) 
	CLR R17
	LDI R16, 0xFF
	OUT DDRD, R17 ; Configura todos de PORTD a Entradas
	OUT PORTD, R16 ; Configurar todos Pull-Up

	; Registro para monitoreo de estados previos
	LDI R18, 0xFF
	
	; Registros para Contadores
	LDI R19, 0x00 ; Contador B
	LDI R20, 0x00 ; Contador C
	

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
	
	CALL Contadores ; Verifico ambos contadores

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
; CONTADOR B R19
AumentarB:
	SBRC R16, PD0 ; Determino si el boton de aumentar esta presionado 
	RJMP DecrementarB ; De no estar presionado, verifico el otro botón
	INC R19 ; De estar presionado, aumento contador R19
	OUT PINB, R19 ; Y lo transporto a PINB

DecrementarB:
	SBRC R16, PD1 ; Determino si el boton de decrementar esta presionado 
	RJMP AumentarC ; De no estar presionado, vuelvo al CALL
	DEC R19 ; De estar presionado, disminuyo contador R19
	OUT PINB, R19 ; Y lo transporto a PINB

; CONTADOR C R20
AumentarC:
	SBRC R16, PD2 ; Determino si el boton de aumentar esta presionado 
	RJMP DecrementarC ; De no estar presionado, verifico el otro botón
	INC R20 ; De estar presionado, aumento contador R20
	OUT PINC, R20 ; Y lo transporto a PINC

DecrementarC:
	SBRC R16, PD3 ; Determino si el boton de decrementar esta presionado 
	RET ; De no estar presionado, vuelvo al CALL
	DEC R20 ; De estar presionado, disminuyo contador R20
	OUT PINC, R20 ; Y lo transporto a PINC

	RET ; Al terminar, vuelvo al CALL

;-----------------------------------------------