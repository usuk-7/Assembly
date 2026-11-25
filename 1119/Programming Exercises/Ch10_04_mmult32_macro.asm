; Ch10 Programming Exercise 4. mMult32 Macro
;
; Create a macro named mMult32 that multiplies two 32-bit memory operands and produces a
; 32-bit product. Write a program that tests your macro.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;--------------------------------------------------------
mMult32 MACRO product:REQ, op1:REQ, op2:REQ
;
; product = op1 * op2 (32비트 부호 없는 곱, 하위 32비트만 저장)
; MUL은 EDX:EAX에 64비트 결과를 만들므로 EAX, EDX를 보존한다.
; 주의: EAX, EDX를 인자로 넘기지 말 것.
;--------------------------------------------------------
    push eax
    push edx
    mov  eax,op1
    mul  op2                ;; EDX:EAX = EAX * op2
    mov  product,eax        ;; 하위 32비트만 결과로
    pop  edx
    pop  eax
ENDM

.data
a      DWORD 1234
b      DWORD 5678
c1     DWORD 65536
d1     DWORD 300
result DWORD ?

.code
main PROC
    mMult32 result, a, b            ; 1234 * 5678 = 7006652
    mWrite "1234 * 5678 = "
    mov  eax,result
    call WriteDec
    call Crlf

    mMult32 result, c1, d1          ; 65536 * 300 = 19660800
    mWrite "65536 * 300 = "
    mov  eax,result
    call WriteDec
    call Crlf
    exit
main ENDP
END main
