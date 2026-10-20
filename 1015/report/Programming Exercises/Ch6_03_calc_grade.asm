; Chapter 6 - Programming Exercise 3. Test Score Evaluation
;
; Create a procedure named CalcGrade that receives an integer value between
; 0 and 100, and returns a single capital letter in the AL register.
; Preserve all other register values between calls to the procedure. The
; letter returned by the procedure should be according to the following
; ranges:
;       Score Range     Letter Grade
;       90 to 100       A
;       80 to 89        B
;       70 to 79        C
;       60 to 69        D
;       0 to 59         F
; Write a test program that generates 10 random integers between 50 and 100,
; inclusive. Each time an integer is generated, pass it to the CalcGrade
; procedure. You can test your program using a debugger, or if you prefer
; to use the book's library, you can display each integer and its
; corresponding letter grade.

INCLUDE Irvine32.inc

.data
msgSep  BYTE "  ->  ",0

.code
main PROC
    call Randomize
    mov  ecx,10                     ; generate 10 scores

L1:
    mov  eax,51
    call RandomRange                ; EAX = 0..50
    add  eax,50                     ; EAX = 50..100
    call WriteDec                   ; display the score (EAX is preserved)

    mov  edx,OFFSET msgSep
    call WriteString

    call CalcGrade                  ; AL = letter grade
    call WriteChar                  ; display the letter
    call Crlf
    loop L1

    exit
main ENDP

;-----------------------------------------------------------
CalcGrade PROC
; Converts a numeric score into a letter grade.
; Receives: AL = score (0..100)
; Returns:  AL = 'A', 'B', 'C', 'D' or 'F'
;           (all other registers are untouched)
;-----------------------------------------------------------
    cmp  al,90
    jae  GradeA                     ; score >= 90
    cmp  al,80
    jae  GradeB                     ; score >= 80
    cmp  al,70
    jae  GradeC                     ; score >= 70
    cmp  al,60
    jae  GradeD                     ; score >= 60
    mov  al,'F'                     ; otherwise 0..59
    jmp  Done
GradeA:
    mov  al,'A'
    jmp  Done
GradeB:
    mov  al,'B'
    jmp  Done
GradeC:
    mov  al,'C'
    jmp  Done
GradeD:
    mov  al,'D'
Done:
    ret
CalcGrade ENDP

END main
