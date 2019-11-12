.include "./m328Pdef.inc"
.equ clock = 16000000
.def aux = R16
.def delayaux = R17
.def incremento = R18
.equ linha1 = 0x00 ;endereço da linha 1 do display
.equ linha2 = 0x40 ;endereço da linha 2 do display
;instruções do lcd
.equ limpar = 0b00000001
.equ home = 0b00000010
.equ modoentrada = 0b00000110
.equ desligardisplay = 0b00001000
.equ ligardisplay = 0b00001100
.equ resetardisplay = 0b00110000
.equ modo4bits = 0b00101000
.equ posicaocursor = 0b10000000
;pinos do display lcd
.equ pinoe = PB1
.equ pinors = PB0
.equ pino4 = PD4
.equ pino5 = PD5
.equ pino6 = PD6
.equ pino7 = PD7
.org 0x0000
rjmp setup
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
string1: .db "Pedro Gaya",0
string2: .db "Washington",0
string3: .db "Soh eu",0

setup:
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
    OUT DDRB,aux
    OUT PORTC,aux
    ;inicializa o lcd
    rcall inicializar
    ldi incremento,0x00
    ;string1
    ;ldi ZH, high(string1)
    ;ldi ZL, low(string1)
    ;ldi aux, linha1
    ;rcall escrevertexto
    ;string2
    ;ldi ZH, high(string2)
    ;ldi ZL, low(string2)
    ;ldi aux, linha2
    ;rcall escrevertexto

main:
    rjmp main

inicializar:
;delay de inicialização do display
    ldi delayaux, 100                       ; initial 40 mSec delay
    rcall delay1mili
;configura pinos E e RS
    cbi PORTB, pinors
    cbi PORTB, pinoe
;configura o lcd para o uso: 3 instruções de reset, duas de modo 4 bits, uma de desligar, uma de limpar, uma de enviar dados e uma de ligar
    ldi aux, resetardisplay      ; first part of reset sequence
    rcall escreverdados
    ldi delayaux, 10                        ; 4.1 mS delay (min)
    rcall delay1mili

    ldi aux, resetardisplay         ; second part of reset sequence
    rcall escreverdados
    ldi delayaux,200          ; Enable pin high
    rcall delay1micro 

    ldi aux, resetardisplay         ; third part of reset sequence
    rcall escreverdados
    ldi delayaux, 200         ; Enable pin high
    rcall delay1micro 

    ldi aux, modo4bits       ; set 4-bit mode
    rcall escreverdados
    ldi delayaux, 80         ; Enable pin high
    rcall delay1micro 

    ldi aux, modo4bits      ; set mode, lines, and font
    rcall escreverinstrucao
    ldi delayaux, 80         ; Enable pin high
    rcall delay1micro 

    ldi aux, desligardisplay           ; turn display OFF
    rcall escreverinstrucao
    ldi delayaux, 80         ; Enable pin high
    rcall delay1micro 

    ldi aux, limpar                ; clear display RAM
    rcall escreverinstrucao
    ldi delayaux, 4                         ; 1.64 mS delay (min)
    rcall delay1mili

    ldi aux, modoentrada           ; set desired shift characteristics
    rcall escreverinstrucao
    ldi delayaux, 80         ; Enable pin high
    rcall delay1micro 

    ldi aux, ligardisplay             ; turn the display ON
    rcall escreverinstrucao
    ldi delayaux, 80         ; Enable pin high
    rcall delay1micro 
    ret

escrevertexto:
    push ZH              
    push ZL
    lsl ZL                         
    rol ZH
    ori aux, posicaocursor    
    rcall escreverinstrucao       
    ldi delayaux, 80  
    rcall delay1micro 

escrevertexto_loop:
    ;fica em loop até que não existam mais caracteres no string a ser escrito
    lpm aux, Z+ ;pega um caractere
    cpi aux,  0
    breq escrevertexto_finalizado
    rcall escrevercaractere
    ldi delayaux, 80 
    rcall delay1micro 
    rjmp escrevertexto_loop

escrevertexto_finalizado:
    pop ZL
    pop ZH
    ret

escrevercaractere:
    sbi PORTB, pinors        ; select the Data Register (RS high)
    cbi PORTB, pinoe        ; make sure E is initially low
    rcall escreverdados                     ; write the upper 4-bits of the data
    swap aux                            ; swap high and low nibbles
    rcall escreverdados                     ; write the lower 4-bits of the data
    ret

escreverinstrucao:
    cbi PORTB, pinors         ; select the Instruction Register (RS low)
    cbi PORTB, pinoe           ; make sure E is initially low
    rcall escreverdados                     ; write the upper 4-bits of the instruction
    swap aux                            ; swap high and low nibbles
    rcall escreverdados                     ; write the lower 4-bits of the instruction
    ret

escreverdados:
    out PORTD, aux
    sbi PORTB, pinoe
    ldi delayaux,1          ; Enable pin high
    rcall delay1micro                       ; implement 'Data set-up time' (80 nS) and 'Enable pulse width' (230 nS)
    cbi PORTB, pinoe           ; Enable pin low
    ldi delayaux,1          ; Enable pin high
    rcall delay1micro                       ; implement 'Data hold time' (10 nS) and 'Enable cycle time' (500 nS)
    ret

delay1mili:
    push YL                              ; [2] preserve registers
    push YH                              ; [2]
    ldi YL, low (((clock/1000)-18)/4)    ; [1] delay counter
    ldi YH, high(((clock/1000)-18)/4)    ; [1]
    delayloop:
    sbiw YH:YL, 1                        ; [2] update the the delay counter
    brne delayloop                    ; [2] delay counter is not zero
    pop YH                              ; [2] restore registers
    pop YL                       ; delay for 1 mS
    dec delayaux                            ; update the delay counter
    brne delay1mili                      ; counter is not zero
    ret

delay1micro:
    push delayaux                     
    pop delayaux                            
    push delayaux                          
    pop delayaux                       ; delay for 1 uS
    dec delayaux                            ; decrement the delay counter
    brne delay1micro                      ; counter is not zero
    ret

interrupcao:
    cpi incremento, 16
    breq trocalinha
    rjmp continua
    trocalinha:
    ldi incremento,0x40
    continua:
    mov aux,incremento
    ldi ZH, high(letra_o)
    ldi ZL, low(letra_o)
    rcall escrevertexto
    ldi delayaux,100
    rcall delay1mili
    inc incremento
    reti

