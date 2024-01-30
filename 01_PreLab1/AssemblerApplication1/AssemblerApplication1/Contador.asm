;-----------------------------------------------
; Universidad del Valle de Guatemala
; IE2023: Programacion de Microcontroladores
; Contador.asm
; Autor: Ian Anleu Rivera
; Proyecto: Prelab 1
; Hardware: ATMEGA328P
; Creado: 27/01/2024
; Ultima modificacion: 28/01/2024
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
	LDI R16, 0xFF
	OUT DDRB, R16 ; Configura todo PORTB a Salida
	
	CLR R17
	OUT DDRD, R17 ; Configura todo PORTD a Entradas
	OUT PORTD, R16 ; Configurar todos Pull-Up

	; Registro para Contador
	LDI R19, 0x00

;-----------------------------------------------
; LOOP de flash memory

Loop:
	; Antirrebote de Pin D0
	IN R16, PIND
	SBRS R16, PD0 ; Salto si PD0 es 1 (Logica inversa)
	RJMP Aumentar; Antirrebote y hacia Operaciones de Aumentar

	; Antirrebote de Pin D1
	SBRS R16, PD1 ; Salto si PD1 es 1 	
	RJMP Decrementar; Antirrebote y hacia Operaciones de Decrementar

	RJMP Loop ; Vuelve a Loop

;-----------------------------------------------
; Subrutinas
;-----------------------------------------------

Aumentar:
	; Antirrebote ------------------------------
	LDI R17, 100 ; Esperara 100 ciclos
	Delay1:
		DEC R17
		BRNE Delay1 ; Disminuye cada ciclo hasta 0
	
	; Funcion de Aumentar ----------------------
	INC R19 ; Incrementa el Contador
	OUT PORTB, R19 ; Modifica la salida en PORTB 

	; Si despues del tiempo sigue en 0 vuelve a leer otro antirrebote
	SBIS PIND, PD0 ; Salto si PD0 es 1
	RJMP Aumentar;

	RJMP Loop
;-----------------------------------------------

Decrementar:
	; Antirrebote ------------------------------
	LDI R17, 100 ; Esperara 100 ciclos
	Delay2:
		DEC R17
		BRNE Delay2 ; Disminuye cada ciclo hasta 0

	; Funcion de Decrementar ----------------------
	DEC R19 ; Incrementa el Contador
	OUT PORTB, R19 ; Modifica la salida en PORTB 
	
	; Si despues del tiempo sigue en 0 vuelve a leer otro antirrebote
	SBIS PIND, PD1 ; Salto si PD1 es 1
	
	RJMP Decrementar;

	RJMP Loop

;-----------------------------------------------