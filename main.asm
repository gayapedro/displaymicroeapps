/*
* Unifacs - 2019.2
* Washington M Santos
* Engenharia de Computação
* Microcontroladores e Aplicações
* Prática - Iterrupção + Blink duplo
* Professor Euclério
*/
.equ RD = PC1
.equ WR = PC0


.ORG 0x0000
RJMP setup
setup:
	LDI r16, 0xFF
	OUT DDRC, r16
	NOP

loop:
	/***********************************************************************/
	RCALL setSaida
	RCALL delay

	LDI r16, 0b00001110
	OUT PORTB, r16
	
	SBI PORTC, WR
	SBI PORTC, RD
	RCALL delay
	CBI PORTC, WR
	RCALL delay
	SBI PORTC, WR
	CBI PORTC, RD
	
	RCALL delay
	/*Limpo a saída do registrador*/
	LDI r16, 0X00
	OUT PORTB, r16
	RCALL delay
	RCALL setEntrada
	RCALL delay
	IN r17, PINB
	Linha1:
	RCALL ligar_led1
	RCALL ligar_led2
	RCALL ligar_led3
	RCALL ligar_led4
	RCALL delay
	/***********************************************************************/

	/***********************************************************************/
	RCALL setSaida
	RCALL delay
	LDI r16, 0b00001101
	OUT PORTB, r16
	SBI PORTC, WR
	SBI PORTC, RD
	RCALL delay
	CBI PORTC, WR
	RCALL delay
	SBI PORTC, WR
	CBI PORTC, RD
	RCALL delay
	/*Limpo a saída do registrador*/
	LDI r16, 0X00
	OUT PORTB, r16
	RCALL delay
	RCALL setEntrada
	RCALL delay
	IN r17, PINB
	Linha2:
	RCALL ligar_led1
	RCALL ligar_led2
	RCALL ligar_led3
	RCALL ligar_led4
	RCALL delay
	/***********************************************************************/

	/***********************************************************************/
	RCALL setSaida
	RCALL delay
	LDI r16, 0b00001011
	OUT PORTB, r16
	SBI PORTC, WR
	SBI PORTC, RD
	RCALL delay
	CBI PORTC, WR
	RCALL delay
	SBI PORTC, WR
	CBI PORTC, RD
	RCALL delay
	/*Limpo a saída do registrador*/
	LDI r16, 0X00
	OUT PORTB, r16
	RCALL delay
	RCALL setEntrada
	RCALL delay
	IN r17, PINB
	Linha3:
	RCALL ligar_led1
	RCALL ligar_led2
	RCALL ligar_led3
	RCALL ligar_led4
	RCALL delay
	/***********************************************************************/

	/***********************************************************************/
	RCALL setSaida
	RCALL delay
	LDI r16, 0b00000111
	OUT PORTB, r16
	SBI PORTC, WR
	SBI PORTC, RD
	RCALL delay
	CBI PORTC, WR
	RCALL delay
	SBI PORTC, WR
	CBI PORTC, RD
	RCALL delay
	/*Limpo a saída do registrador*/
	LDI r16, 0X00
	OUT PORTB, r16
	RCALL delay
	RCALL setEntrada
	RCALL delay
	IN r17, PINB
	Linha4:
	RCALL ligar_led1
	RCALL ligar_led2
	RCALL ligar_led3
	RCALL ligar_led4
	RCALL delay
	/***********************************************************************/
RJMP loop


ligar_led1:
	SBIS PINB, PB0
	RJMP ligar_led1
	RET
ligar_led2:
	SBIS PINB, PB1
	RJMP ligar_led2
	RET
ligar_led3:
	SBIS PINB, PB2
	RJMP ligar_led3
	RET
ligar_led4:
	SBIS PINB, PB3
	RJMP ligar_led4
	RET


setSaida:
	LDI r16, 0xFF
	OUT DDRB, r16
	RET

setEntrada:
	LDI r16, 0x00
	OUT DDRB, r16
	RET

delay:
	LDI r16, 1 /*Escreve o valor 8 em Hexa no registrador r16*/

out_delay:
	LDI r24, low(3037)
	LDI r25, high(3037)

delay_loop:
	ADIW r24,1
	BRNE delay_loop
	DEC r16           /*Decrementa 1 do valor que o registrador r16 tem*/
	BRNE out_delay
	RET