; Chapter 6 - Programming Exercise 4. College Registration
;
; Using the College Registration example from Section 6.7.3 as a starting
; point, do the following:
;  - Recode the logic using CMP and conditional jump instructions (instead
;    of the .IF and .ELSEIF directives).
;  - Perform range checking on the credits value; it cannot be less than 1
;    or greater than 30. If an invalid entry is discovered, display an
;    appropriate error message.
;  - Prompt the user for the grade average and credits values.
;  - Display a message that shows the outcome of the evaluation, such as
;    "The student can register" or "The student cannot register".
;
; Rules (from the original example):
;   register if gradeAverage > 350
;   or if (gradeAverage > 250) AND (credits <= 16)
;   or if credits <= 12

INCLUDE Irvine32.inc

.data
promptAvg   BYTE "Enter grade average (0 to 400): ",0
promptCred  BYTE "Enter number of credits (1 to 30): ",0
msgBadAvg   BYTE "Error: grade average must be between 0 and 400.",0dh,0ah,0
msgBadCred  BYTE "Error: credits must be between 1 and 30.",0dh,0ah,0
msgCan      BYTE "The student can register",0dh,0ah,0
msgCannot   BYTE "The student cannot register",0dh,0ah,0

gradeAverage WORD ?
credits      WORD ?

.code
main PROC
    ; ---- input ----
    mov  edx,OFFSET promptAvg
    call WriteString
    call ReadInt                    ; EAX = grade average
    mov  gradeAverage,ax

    mov  edx,OFFSET promptCred
    call WriteString
    call ReadInt                    ; EAX = credits
    mov  credits,ax

    ; ---- range checking (negative numbers become large unsigned values) ----
    cmp  gradeAverage,400
    ja   BadAverage                 ; > 400 (or negative)
    cmp  credits,1
    jb   BadCredits                 ; < 1
    cmp  credits,30
    ja   BadCredits                 ; > 30 (or negative)

    ; ---- registration logic with CMP and conditional jumps ----
    cmp  gradeAverage,350           ; gradeAverage > 350 ?
    ja   CanRegister                ; yes: can register

    cmp  gradeAverage,250           ; (gradeAverage > 250) AND (credits <= 16) ?
    jbe  Check3                     ; first part false: try next rule
    cmp  credits,16
    jbe  CanRegister                ; both true: can register

Check3:
    cmp  credits,12                 ; credits <= 12 ?
    jbe  CanRegister                ; yes: can register

CannotRegister:
    mov  edx,OFFSET msgCannot
    jmp  ShowMsg

CanRegister:
    mov  edx,OFFSET msgCan
    jmp  ShowMsg

BadAverage:
    mov  edx,OFFSET msgBadAvg
    jmp  ShowMsg

BadCredits:
    mov  edx,OFFSET msgBadCred

ShowMsg:
    call WriteString
    exit
main ENDP

END main
