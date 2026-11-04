; Ch7 Programming Exercise 6. Greatest Common Divisor (GCD)
;
; The greatest common divisor (GCD) of two integers is the largest integer that will
; evenly divide both integers. The GCD algorithm involves integer division in a loop,
; described by the following pseudocode:
;     int GCD(int x, int y)
;     {
;         x = abs(x)    // absolute value
;         y = abs(y)
;         do {
;             int n = x % y
;             x = y
;             y = n
;         } while (y > 0)
;         return x
;     }
; Implement this function in assembly language and write a test program that calls the
; function several times, passing it different values. Display all results on the screen.

INCLUDE Irvine32.inc

.data
xVals SDWORD 48, 81, -24, 17, 1071, 100
yVals SDWORD 18, 27, 36, 5, -462, 75
msg1  BYTE "GCD(",0
msg2  BYTE ", ",0
msg3  BYTE ") = ",0

.code
main PROC
    mov  esi,0                     ; 배열 인덱스
    mov  ecx,LENGTHOF xVals
L1: push ecx
    mov  edx,OFFSET msg1
    call WriteString
    mov  eax,xVals[esi]
    call WriteInt
    mov  edx,OFFSET msg2
    call WriteString
    mov  eax,yVals[esi]
    call WriteInt
    mov  edx,OFFSET msg3
    call WriteString

    mov  eax,xVals[esi]            ; x
    mov  ebx,yVals[esi]            ; y
    call GCD                       ; EAX = 결과
    call WriteDec
    call Crlf

    add  esi,TYPE SDWORD
    pop  ecx
    loop L1
    exit
main ENDP

;--------------------------------------------------------
GCD PROC
; 두 정수의 최대공약수 (유클리드 호제법)
; Receives: EAX = x, EBX = y  (y ≠ 0)
; Returns:  EAX = GCD(x, y)
;--------------------------------------------------------
    push ebx
    push edx
    ; x = abs(x)
    cmp  eax,0
    jge  L_absY
    neg  eax
L_absY:                            ; y = abs(y)
    cmp  ebx,0
    jge  L_loop
    neg  ebx
L_loop:
    mov  edx,0                     ; 부호 없는 나눗셈 준비 (값은 이미 양수)
    div  ebx                       ; EDX = x % y
    mov  eax,ebx                   ; x = y
    mov  ebx,edx                   ; y = n
    cmp  ebx,0
    ja   L_loop                    ; while (y > 0)
    pop  edx
    pop  ebx
    ret                            ; EAX = x
GCD ENDP

END main
