;****************** main.s ***************
; Program initially written by: Yerraballi and Valvano
; Author: Place your name here
; Date Created: 1/15/2018 
; Last Modified: 1/18/2019 
; Brief description of the program: Spring 2019 Lab1
; The objective of this system is to implement odd-bit counting system
; Hardware connections: 
;  Output is positive logic, 1 turns on the LED, 0 turns off the LED
;  Inputs are negative logic, meaning switch not pressed is 1, pressed is 0
;    PE0 is an input 
;    PE1 is an input 
;    PE2 is an input 
;    PE3 is the output
; Overall goal: 
;   Make the output 1 if there is an odd number of 1's at the inputs, 
;     otherwise make the output 0
; The specific operation of this system 
;   Initialize Port E to make PE0,PE1,PE2 inputs and PE3 an output
;   Over and over, read the inputs, calculate the result and set the output

; NOTE: Do not use any conditional branches in your solution. 
;       We want you to think of the solution in terms of logical and shift operations

GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

      THUMB
      AREA    DATA, ALIGN=2
;global variables go here
      ALIGN
      AREA    |.text|, CODE, READONLY, ALIGN=2
      EXPORT  Start
Start
	  LDR R1, =SYSCTL_RCGCGPIO_R
	  LDR R0, [R1] ;takes the content of R1
	  ORR R0, #0x10 ;taking whatever is in R0 and ORing it with a one will always make it a one
	  STR R0, [R1]
 
	  NOP ;waiting for the clock
	  NOP
	  NOP
	  NOP
 
	  LDR R1, =GPIO_PORTE_DIR_R ;set direction of the ports as input or outputs
	  LDR R0, [R1]
	  AND R0, #0xF8
	  ORR R0, #0x08
	  ;ORR R0, #0x08 ;sets output port
	  ;AND R0, #0xF8;preserving the rest of bits so they aren't touched
	  STR R0, [R1]
 
	  LDR R1, =GPIO_PORTE_DEN_R ;set digital enabler
	  LDR R0, [R1]
	  ORR R0, #0xF ;enables the first 4 pins we are using
	  STR R0, [R1]
 
loop
	  LDR R0, =GPIO_PORTE_DATA_R
	  LDR R1, [R0]

	  AND R2, #0x0 ;clearing registers
	  AND R3, #0x0
	  AND R4, #0x0
	  AND R5, #0x0

	  AND R1, #0x07;isolate the input port bits
	  AND R2, R1, #0x01 ;isolates the input port 1 bits
	  AND R3, R1, #0x02
	  AND R4, R1, #0x04

	  LSR R3, #1 ;shifts isolated pins into the same column
	  LSR R4, #2

	  EOR R5, R2, R3; eor the bits in port 0 & port 1
	  EOR R5, R5, R4; if the number in R5 becomes 0 LED stays off and if it becomes 1 LED is on

	  LSL R5, #3 ;shifts the 1 or 0 into pin 3
	  STR R5, [R0]
	  
      B    loop

      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file
          