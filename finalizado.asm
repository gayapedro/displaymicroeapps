.def aux = R18
.def delayaux = R19
.def incremento = R20
;pinos do display lcd
.equ pinoe = PD3
.equ pinors = PD2
.equ pino4 = PD4
.equ pino5 = PD5
.equ pino6 = PD6
.equ pino7 = PD7
.equ RD = PC1
.equ WR = PC0
;comandos do lcd
.equ limpar = 0b00000001
.equ modoentrada = 0b00000110
.equ desligardisplay = 0b00001000
.equ ligardisplay = 0b00001100
.equ resetardisplay = 0b00110000
.equ modo4bits = 0b00101000
.equ posicaocursor = 0b10000000

.org 0x0000
rjmp configuracao
;letras
letra_w: .db 0b01010111,0
letra_a: .db 0b01000001,0
letra_s: .db 0b01010011,0
letra_h: .db 0b01001000,0
letra_i: .db 0b01001001,0
letra_n: .db 0b01001110,0
letra_g: .db 0b01000111,0
letra_t: .db 0b01010100,0
letra_o: .db 0b01001111,0
letra_p: .db 0b01010000,0
letra_e: .db 0b01000101,0
letra_d: .db 0b01000100,0
letra_r: .db 0b01010010,0
letra_espaco: .db 0b00100000,0
letra_infinito: .db 0b11110011,0

configuracao:
    ;inicializa topo da pilha
    ldi aux,low(RAMEND)
    out SPL,aux
    ldi aux,high(RAMEND)
    out SPH,aux
    ;configura portd e portb como output
    LDI aux,0xFF
    OUT DDRD,aux
	OUT DDRC,aux
    ;inicializa o lcd
    rcall inicializar
    ldi incremento,0x00

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
	LDI r16, 0x00
	OUT PORTB, r16
	RCALL delay
	RCALL setEntrada
	RCALL delay
	SBIS PINB,0
	RCALL Escreve_W
	SBIS PINB,1
	RCALL Escreve_A
	SBIS PINB,2
	RCALL Escreve_S
	SBIS PINB,3
	RCALL Escreve_H
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
	SBIS PINB,0
	RCALL Escreve_I
	SBIS PINB,1
	RCALL Escreve_N
	SBIS PINB,2
	RCALL Escreve_G
	SBIS PINB,3
	RCALL Escreve_T
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
	SBIS PINB,0
	RCALL Escreve_O
	SBIS PINB,1
	RCALL Escreve_SPC
	SBIS PINB,2
	RCALL Escreve_E
	SBIS PINB,3
	RCALL Escreve_P
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
	SBIS PINB,0
	RCALL Escreve_D
	SBIS PINB,1
	RCALL Escreve_R
	SBIS PINB,2
	RCALL Escreve_CLS
	SBIS PINB,3
	RCALL Escreve_ESPECIAL
	RCALL delay
	RJMP loop
	/***********************************************************************/

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

inicializar:
;delay de inicialização do display
    ldi delayaux, 100              
    rcall delay1mili
;configura pinos E e RS
    cbi PORTD, pinors
    cbi PORTD, pinoe
;configura o lcd para o uso: 3 instruções de reset, duas de modo 4 bits, uma de desligar, uma de limpar, uma de enviar dados e uma de ligar
    ldi aux, resetardisplay  
    rcall enviardados
    ldi delayaux, 10                 
    rcall delay1mili

    ldi aux, resetardisplay  
    rcall enviardados
    ldi delayaux,200 
    rcall delay1micro 

    ldi aux, resetardisplay 
    rcall enviardados
    ldi delayaux, 200   
    rcall delay1micro 

    ldi aux, modo4bits   
    rcall enviardados
    ldi delayaux, 80        
    rcall delay1micro 

    ldi aux, modo4bits     
    rcall escreverinstrucao
    ldi delayaux, 80        
    rcall delay1micro 

    ldi aux, desligardisplay       
    rcall escreverinstrucao
    ldi delayaux, 80         
    rcall delay1micro 

    ldi aux, limpar                
    rcall escreverinstrucao
    ldi delayaux, 4            
    rcall delay1mili

    ldi aux, modoentrada         
    rcall escreverinstrucao
    ldi delayaux, 80       
    rcall delay1micro 

    ldi aux, ligardisplay       
    rcall escreverinstrucao
    ldi delayaux, 80     
    rcall delay1micro 
    ret

escrever:
    cpi incremento, 16
    breq trocalinha
    rjmp continua
    trocalinha:
    ldi incremento,0x40
    continua:
    mov aux,incremento
    push ZH
    push ZL
    lsl ZL                         
    rol ZH
    ori aux, posicaocursor
    rcall escreverinstrucao
    ldi delayaux, 80  
    rcall delay1micro
    lpm aux,Z+
    sbi PORTD, pinors 
    cbi PORTD, pinoe     
    rcall enviardados                 
    swap aux                         
    rcall enviardados
    ldi delayaux, 80 
    rcall delay1micro
    pop ZL
    pop ZH
    ret

escreverinstrucao:
    cbi PORTD, pinors     
    cbi PORTD, pinoe 
    rcall enviardados
    swap aux
    rcall enviardados 
    ret

enviardados:
    sbi PORTD,pino7
    sbrs aux,7
    cbi PORTD,pino7
    sbi PORTD,pino6
    sbrs aux,6
    cbi PORTD,pino6
    sbi PORTD,pino5
    sbrs aux,5
    cbi PORTD,pino5
    sbi PORTD,pino4
    sbrs aux,4
    cbi PORTD,pino4
    sbi PORTD, pinoe
    ldi delayaux,1      
    rcall delay1micro              
    cbi PORTD, pinoe      
    ldi delayaux,1         
    rcall delay1micro             
    ret

Escreve_W:
    ldi ZH, high(letra_w)
    ldi ZL, low(letra_w)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_A:
    ldi ZH, high(letra_A)
    ldi ZL, low(letra_A)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_S:
    ldi ZH, high(letra_s)
    ldi ZL, low(letra_s)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_H:
    ldi ZH, high(letra_h)
    ldi ZL, low(letra_h)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_I:
    ldi ZH, high(letra_i)
    ldi ZL, low(letra_i)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_N:
    ldi ZH, high(letra_n)
    ldi ZL, low(letra_n)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_G:
    ldi ZH, high(letra_g)
    ldi ZL, low(letra_g)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_T:
    ldi ZH, high(letra_t)
    ldi ZL, low(letra_t)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_O:
    ldi ZH, high(letra_o)
    ldi ZL, low(letra_o)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_E:
    ldi ZH, high(letra_e)
    ldi ZL, low(letra_e)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_P:
    ldi ZH, high(letra_p)
    ldi ZL, low(letra_p)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_D:
    ldi ZH, high(letra_d)
    ldi ZL, low(letra_d)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_R:
    ldi ZH, high(letra_r)
    ldi ZL, low(letra_r)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_SPC:
    ldi ZH, high(letra_espaco)
    ldi ZL, low(letra_espaco)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_ESPECIAL:
    ldi ZH, high(letra_infinito)
    ldi ZL, low(letra_infinito)
    rcall escrever
    rcall rotinaposescrita
    ret

Escreve_CLS:
    ldi aux, limpar           
    rcall escreverinstrucao
    ldi delayaux, 4                    
    rcall delay1mili
    ldi incremento,0x00
    ret

rotinaposescrita:
    ldi delayaux,100
    rcall delay1mili
    inc incremento
    ret

delay1mili:
    push YL               
    push YH                    
    ldi YL, low (((16000)-18)/4)
    ldi YH, high(((16000)-18)/4)  
    delayloop:
    sbiw YH:YL, 1    
    brne delayloop     
    pop YH                         
    pop YL         
    dec delayaux  
    brne delay1mili       
    ret

delay1micro:
    push delayaux                     
    pop delayaux                            
    push delayaux                          
    pop delayaux
    dec delayaux             
    brne delay1micro                    
    ret
