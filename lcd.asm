.include "./m328Pdef.inc"
.equ clock = 16000000
.def temp = R16
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
.equ pinoe = PB1
.equ pinors = PB0
.equ pino4 = PD4
.equ pino5 = PD5
.equ pino6 = PD6
.equ pino7 = PD7

.org 0x0000
rjmp setup

string1:
.db "WASHINGTON 1",0
string2:
.db "E PEDRO GAYA 2",0

setup:
    ;inicializa topo da pilha
    ldi temp,low(RAMEND)
    out SPL,temp
    ldi temp,high(RAMEND)
    out SPH,temp
    ;configura portd e portb como output
    LDI temp,0xFF
    OUT DDRD,temp
    OUT DDRB,temp
    ;inicializa o lcd
    rcall inicializar
    ;string1
    ldi ZH, high(string1)
    ldi ZL, low(string1)
    ldi temp, linha1
    rcall escrevertexto
    ;string2
    ldi ZH, high(string2)
    ldi ZL, low(string2)
    ldi temp, linha2
    rcall escrevertexto

main:
    rjmp main

inicializar:
;delay de inicialização do display
    ldi temp, 100                       ; initial 40 mSec delay
    rcall delayTx1mS
;configura pinos E e RS
    cbi PORTB, pinors
    cbi PORTB, pinoe
; Reset the LCD controller.
    ldi temp, resetardisplay      ; first part of reset sequence
    rcall lcd_write_4
    ldi temp, 10                        ; 4.1 mS delay (min)
    rcall delayTx1mS

    ldi temp, resetardisplay         ; second part of reset sequence
    rcall lcd_write_4
    ldi temp, 200                       ; 100 uS delay (min)
    rcall delayTx1uS

    ldi temp, resetardisplay         ; third part of reset sequence
    rcall lcd_write_4
    ldi temp, 200                       ; this delay is omitted in the data sheet
    rcall delayTx1uS

    ldi temp, modo4bits       ; set 4-bit mode
    rcall lcd_write_4
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS
; Function Set instruction
    ldi temp, modo4bits      ; set mode, lines, and font
    rcall lcd_write_instruction_4d
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS
; The next three instructions are specified in the data sheet as part of the initialization routine,
;   so it is a good idea (but probably not necessary) to do them just as specified and then redo them
;   later if the application requires a different configuration.
; Display On/Off Control instruction
    ldi temp, desligardisplay           ; turn display OFF
    rcall lcd_write_instruction_4d
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS
; Clear Display instruction
    ldi temp, limpar                ; clear display RAM
    rcall lcd_write_instruction_4d
    ldi temp, 4                         ; 1.64 mS delay (min)
    rcall delayTx1mS
; Entry Mode Set instruction
    ldi temp, modoentrada           ; set desired shift characteristics
    rcall lcd_write_instruction_4d
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS
; Display On/Off Control instruction
    ldi temp, ligardisplay             ; turn the display ON
    rcall lcd_write_instruction_4d
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS
    ret

escrevertexto:
    push ZH                              ; preserve pointer registers
    push ZL
    lsl ZL                              ; shift the pointer one bit left for the lpm instruction
    rol ZH
    ori temp, posicaocursor          ; convert the plain address to a set cursor instruction
    rcall lcd_write_instruction_4d         ; set up the first DDRAM address
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS

escrevertexto_loop:
    ;fica em loop até que não existam mais caracteres no string a ser escrito
    lpm temp, Z+ ;pega um caractere
    cpi temp,  0
    breq escrevertexto_finalizado
    rcall escrevercaractere
    ldi temp, 80                        ; 40 uS delay (min)
    rcall delayTx1uS
    rjmp escrevertexto_loop

escrevertexto_finalizado:
    pop ZL
    pop ZH
    ret

escrevercaractere:
    sbi PORTB, pinors        ; select the Data Register (RS high)
    cbi PORTB, pinoe        ; make sure E is initially low
    rcall lcd_write_4                     ; write the upper 4-bits of the data
    swap temp                            ; swap high and low nibbles
    rcall lcd_write_4                     ; write the lower 4-bits of the data
    ret

lcd_write_instruction_4d:
    cbi PORTB, pinors         ; select the Instruction Register (RS low)
    cbi PORTB, pinoe           ; make sure E is initially low
    rcall lcd_write_4                     ; write the upper 4-bits of the instruction
    swap temp                            ; swap high and low nibbles
    rcall lcd_write_4                     ; write the lower 4-bits of the instruction
    ret

lcd_write_4:
    out PORTD, temp
    sbi PORTB, pinoe          ; Enable pin high
    rcall delay1uS                        ; implement 'Data set-up time' (80 nS) and 'Enable pulse width' (230 nS)
    cbi PORTB, pinoe           ; Enable pin low
    rcall delay1uS                        ; implement 'Data hold time' (10 nS) and 'Enable cycle time' (500 nS)
    ret

delayYx1mS:
    rcall delay1mS                        ; delay for 1 mS
    sbiw YH:YL, 1                        ; update the the delay counter
    brne delayYx1mS                      ; counter is not zero
    ret

delayTx1mS:
    rcall delay1mS                        ; delay for 1 mS
    dec temp                            ; update the delay counter
    brne delayTx1mS                      ; counter is not zero
    ret

delay1mS:
    push YL                              ; [2] preserve registers
    push YH                              ; [2]
    ldi YL, low (((clock/1000)-18)/4)    ; [1] delay counter
    ldi YH, high(((clock/1000)-18)/4)    ; [1]

delay1mS_01:
    sbiw YH:YL, 1                        ; [2] update the the delay counter
    brne delay1mS_01                     ; [2] delay counter is not zero
    pop YH                              ; [2] restore registers
    pop YL                              ; [2]
    ret                                     ; [4]

delayTx1uS:
    rcall delay1uS                        ; delay for 1 uS
    dec temp                            ; decrement the delay counter
    brne delayTx1uS                      ; counter is not zero
    ret

delay1uS:
    push temp                            ; [2] these instructions do nothing except consume clock cycles
    pop temp                            ; [2]
    push temp                            ; [2]
    pop temp                            ; [2]
    ret                                     ; [4]
        