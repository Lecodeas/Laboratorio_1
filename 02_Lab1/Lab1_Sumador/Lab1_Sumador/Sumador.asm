;-----------------------------------------------
; Universidad del Valle de Guatemala
; IE2023: Programacion de Microcontroladores
; Sumador.asm
; Autor: Ian Anleu Rivera
; Proyecto: Laboratorio 1
; Hardware: ATMEGA328P
; Creado: 29/01/2024
; Ultima modificacion: 29/01/2024
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

	; Entradas (PORTD a Botones) y Salidas (PORTB a LEDs)
	LDI R16, 0xFF
	OUT DDRB, R16 ; Configura todo PORTB a Salida
	
	CLR R17
	OUT DDRD, R17 ; Configura todo PORTD a Entradas
	OUT PORTD, R16 ; Configurar todos Pull-Up

	; Salidas (PORTC a LEDs)
	OUT DDRC, R16 ; Configura todo PORTC a Salida

	; Registro para Contador1 y 2
	LDI R19, 0x00
	LDI R20, 0x00

;-----------------------------------------------
; LOOP de flash memory

Loop:
	RJMP Contador1 ; Contador de PORTB
	RJMP Contador2 ; Contador de PORTC
	RJMP Loop ; Vuelve a Loop

;-----------------------------------------------
; Subrutinas
;-----------------------------------------------

Contador1:
	; Antirrebote de Pin D0
	IN R16, PIND
	SBRS R16, PD0 ; Salto si PD0 es 1 (Logica inversa)
	RJMP AumentarB; Antirrebote y hacia Operaciones de Aumentar

	; Antirrebote de Pin D1
	SBRS R16, PD1 ; Salto si PD1 es 1 	
	RJMP DecrementarB; Antirrebote y hacia Operaciones de Decrementar

;-----------------------------------------------

Contador2:
	; Antirrebote de Pin D2
	IN R16, PIND
	SBRS R16, PD2 ; Salto si PD2 es 1 
	RJMP AumentarC; Antirrebote y hacia Operaciones de Aumentar

	; Antirrebote de Pin D1
	SBRS R16, PD1 ; Salto si PD1 es 1 	
	RJMP DecrementarC; Antirrebote y hacia Operaciones de Decrementar

;-----------------------------------------------

AumentarB:
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

DecrementarB:
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