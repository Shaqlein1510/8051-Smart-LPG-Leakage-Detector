; Reconstructed 8051 Assembly from LPD_Detector-1.hex
; Target MCU: 8051 / AT89C51
; IMPORTANT: This is a disassembly/reconstruction of the HEX file.
; It is not guaranteed to be the original source ASM (original comments,
; labels, and formatting are not recoverable from a HEX file).

            ORG     0000H

RESET_VECTOR:
            LJMP    MAIN

; ============================================================
; MAIN PROGRAM
; ADC input is read from Port 1.
; Port 2 is used for the LCD data bus.
; P3.0 = LCD RS, P3.1 = LCD RW, P3.2 = LCD EN
; P3.3 = Green LED, P3.4 = Yellow LED
; P3.5 = Red LED, P3.6 = Buzzer, P3.7 = Relay/Fan
;
; Thresholds encoded in the HEX:
;   65H = 101 decimal
;   B5H = 181 decimal
; ============================================================

MAIN:
            MOV     P1,#0FFH
            MOV     P2,#00H

            SETB    P3.3             ; Green LED initially OFF/ON logic depends on hardware
            SETB    P3.4             ; Yellow LED
            SETB    P3.5             ; Red LED
            CLR     P3.6             ; Buzzer
            CLR     P3.7             ; Relay/Fan
            CLR     P3.2             ; LCD Enable

            ACALL   DELAY_SHORT
            SETB    P3.2
            ACALL   LCD_INIT

MAIN_LOOP:
            MOV     A,P1             ; Read 8-bit ADC value
            CLR     C
            SUBB    A,#65H           ; Compare with 101
            JC      NORMAL

            MOV     A,P1             ; Read ADC again
            CLR     C
            SUBB    A,#0B5H          ; Compare with 181
            JC      LOW_LEAKAGE

            ACALL   HIGH_LEAKAGE
            SJMP    MAIN_LOOP


; ============================================================
; NORMAL / NO LEAKAGE
; ============================================================
NORMAL:
            CLR     P3.3
            SETB    P3.4
            SETB    P3.5
            CLR     P3.6
            CLR     P3.7

            ACALL   LCD_CLEAR

            MOV     A,#80H
            ACALL   LCD_CMD
            MOV     DPTR,#MSG_TITLE
            ACALL   LCD_STRING

            MOV     A,#0C0H
            ACALL   LCD_CMD
            MOV     DPTR,#MSG_NORMAL
            ACALL   LCD_STRING

            ACALL   DELAY_LONG
            SJMP    MAIN_LOOP


; ============================================================
; LOW LEAKAGE / WARNING
; ============================================================
LOW_LEAKAGE:
            SETB    P3.3
            CLR     P3.4
            SETB    P3.5
            CLR     P3.6
            CLR     P3.7

            ACALL   LCD_CLEAR

            MOV     A,#80H
            ACALL   LCD_CMD
            MOV     DPTR,#MSG_TITLE
            ACALL   LCD_STRING

            MOV     A,#0C0H
            ACALL   LCD_CMD
            MOV     DPTR,#MSG_LOW
            ACALL   LCD_STRING

            ACALL   DELAY_LONG
            SJMP    MAIN_LOOP


; ============================================================
; HIGH LEAKAGE / CRITICAL
; ============================================================
HIGH_LEAKAGE:
            SETB    P3.3
            SETB    P3.4
            CLR     P3.5
            SETB    P3.6
            SETB    P3.7

            ACALL   LCD_CLEAR

            MOV     A,#80H
            ACALL   LCD_CMD
            MOV     DPTR,#MSG_HIGH
            ACALL   LCD_STRING

            MOV     A,#0C0H
            ACALL   LCD_CMD
            MOV     DPTR,#MSG_FAN
            ACALL   LCD_STRING

            ACALL   DELAY_LONG
            RET


; ============================================================
; LCD INITIALIZATION
; ============================================================
LCD_INIT:
            ACALL   DELAY_LONG
            MOV     A,#38H            ; 8-bit, 2-line LCD mode
            ACALL   LCD_CMD
            MOV     A,#0CH            ; Display ON
            ACALL   LCD_CMD
            MOV     A,#01H            ; Clear display
            ACALL   LCD_CMD
            MOV     A,#06H            ; Entry mode
            ACALL   LCD_CMD
            RET


; ============================================================
; SEND LCD COMMAND
; ============================================================
LCD_CMD:
            MOV     P2,A
            CLR     P3.0              ; RS = 0
            SETB    P3.1              ; RW = 1 in the encoded firmware
            ACALL   DELAY_SHORT
            CLR     P3.1
            ACALL   DELAY_SHORT
            RET


; ============================================================
; SEND LCD DATA
; ============================================================
LCD_DATA:
            MOV     P2,A
            SETB    P3.0              ; RS = 1
            SETB    P3.1              ; RW = 1 in the encoded firmware
            ACALL   DELAY_SHORT
            CLR     P3.1
            ACALL   DELAY_SHORT
            RET


; ============================================================
; LCD CLEAR
; ============================================================
LCD_CLEAR:
            MOV     A,#01H
            ACALL   LCD_CMD
            ACALL   DELAY_SHORT
            RET


; ============================================================
; DISPLAY NULL-TERMINATED STRING
; DPTR points to the string in program memory.
; ============================================================
LCD_STRING:
            CLR     A
            MOVC    A,@A+DPTR
            JZ      LCD_STRING_DONE
            ACALL   LCD_DATA
            INC     DPTR
            SJMP    LCD_STRING

LCD_STRING_DONE:
            RET


; ============================================================
; SHORT DELAY
; ============================================================
DELAY_SHORT:
            MOV     R6,#05H
            MOV     R7,#0FFH

DELAY_SHORT_R7:
            DJNZ    R7,DELAY_SHORT_R7
            DJNZ    R6,DELAY_SHORT_R7
            RET


; ============================================================
; LONG DELAY
; ============================================================
DELAY_LONG:
            MOV     R5,#05H
            MOV     R6,#0FFH
            MOV     R7,#0FFH

DELAY_LONG_R7:
            DJNZ    R7,DELAY_LONG_R7
            DJNZ    R6,DELAY_LONG_R7
            DJNZ    R5,DELAY_LONG_R7
            RET


; ============================================================
; TEXT STRINGS RECOVERED FROM HEX
; ============================================================
MSG_TITLE:
            DB      'LPG GAS DETECTOR',00H

MSG_NORMAL:
            DB      'GAS NORMAL',00H

MSG_LOW:
            DB      'LOW LEAKAGE',00H

MSG_HIGH:
            DB      '!!! LPG LEAK !!!',00H

MSG_FAN:
            DB      'FAN + BUZZER ON',00H

            END
