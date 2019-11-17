;pinos do display lcd
.equ pinoe = PD3
.equ pinors = PD2
.equ pino4 = PD4
.equ pino5 = PD5
.equ pino6 = PD6
.equ pino7 = PD7

;comandos do lcd
.equ limpar = 0b00000001
.equ home = 0b00000010
.equ modoentrada = 0b00000110
.equ desligardisplay = 0b00001000
.equ ligardisplay = 0b00001100
.equ resetardisplay = 0b00110000
.equ modo4bits = 0b00101000
.equ posicaocursor = 0b10000000