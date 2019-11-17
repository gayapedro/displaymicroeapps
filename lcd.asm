.include "./m328Pdef.inc"
.include "./lcd.h"
.def aux = R16
.def delayaux = R17
.def incremento = R18

.org 0x0000
rjmp configuracao
.org 0x0008
rjmp interrupcao
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
    ;interrupcao
    ldi r16, (1<<PCIE1)		
	sts PCICR, r16
    ldi r16, (1<<PCIF1)			
	out PCIFR, r16
    ldi r16, (1<<PCINT8)
    sts PCMSK1, r16
    sei
    ;inicializa topo da pilha
    ldi aux,low(RAMEND)
    out SPL,aux
    ldi aux,high(RAMEND)
    out SPH,aux
    ;configura portd e portb como output
    LDI aux,0x00
    OUT DDRC,aux
    LDI aux,0xFF
    OUT DDRD,aux
    OUT PORTC,aux
    ;inicializa o lcd
    rcall inicializar
    ldi incremento,0x00

main:
    rjmp main

inicializar:
;delay de inicialização do display
    ldi delayaux, 100                       ; initial 40 mSec delay
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

interrupcao:
    rcall Escreve_G
    reti
