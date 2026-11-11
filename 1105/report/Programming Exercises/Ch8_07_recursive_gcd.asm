; Ch8 Programming Exercise 7. Greatest Common Divisor
;
; Write a recursive implementation of Euclid's algorithm for finding the greatest common divisor
; (GCD) of two integers. Descriptions of this algorithm are available in algebra books and on the
; Web. Write a test program that calls your GCD procedure five times, using the following pairs of
; integers: (5,20), (24,18), (11,7), (432,226), (26,13). After each procedure call, display the GCD.

INCLUDE Irvine32.inc

GCD PROTO, x:DWORD, y:DWORD

.data
xVals DWORD 5, 24, 11, 432, 26
yVals DWORD 20, 18, 7, 226, 13
msg1  BYTE "GCD(",0
msg2  BYTE ", ",0
msg3  BYTE ") = ",0

.code
main PROC
    mov  esi,0                      ; 배열 인덱스(바이트 단위)
    mov  ecx,LENGTHOF xVals
L1: mov  edx,OFFSET msg1            ; "GCD(x, y) = " 출력
    call WriteString
    mov  eax,xVals[esi]
    call WriteDec
    mov  edx,OFFSET msg2
    call WriteString
    mov  eax,yVals[esi]
    call WriteDec
    mov  edx,OFFSET msg3
    call WriteString

    INVOKE GCD, xVals[esi], yVals[esi]  ; EAX = GCD
    call WriteDec
    call Crlf

    add  esi,TYPE DWORD
    loop L1
    exit
main ENDP

;--------------------------------------------------------
GCD PROC USES ebx edx,
    x:DWORD,                        ; [ebp+8]
    y:DWORD                         ; [ebp+12]
; 유클리드 호제법 (재귀)
;   GCD(x, 0) = x
;   GCD(x, y) = GCD(y, x mod y)
; Returns: EAX = GCD(x, y)
;--------------------------------------------------------
    mov  eax,x
    mov  ebx,y
    cmp  ebx,0                      ; 종료 조건: y == 0
    je   Done                       ; EAX = x 가 답
    mov  edx,0                      ; EDX:EAX = x (부호 없는 나눗셈 준비)
    div  ebx                        ; EDX = x mod y
    INVOKE GCD, ebx, edx            ; 재귀 호출 GCD(y, x mod y) → EAX
Done:
    ret                             ; 각 호출의 스택 프레임은 RET 8로 정리됨
GCD ENDP

END main
