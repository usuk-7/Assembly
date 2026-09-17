; Ch3 Programming Exercise 1: Integer Expression Calculation
; Using the AddTwo program from Section 3.2 as a reference, write a program
; that calculates the following expression, using registers:
;   A = (A + B) - (C + D)
; Assign integer values to the EAX, EBX, ECX, and EDX registers.

INCLUDE Irvine32.inc

.code
main PROC
    ; 레지스터에 정수 값 대입 (A=EAX, B=EBX, C=ECX, D=EDX)
    mov eax, 10          ; A = 10
    mov ebx, 20          ; B = 20
    mov ecx, 5           ; C = 5
    mov edx, 3           ; D = 3

    ; A = A + B
    add eax, ebx          ; EAX = 10 + 20 = 30

    ; ECX = C + D (임시로 ECX에 C+D 결과 저장)
    add ecx, edx           ; ECX = 5 + 3 = 8

    ; A = (A + B) - (C + D)
    sub eax, ecx           ; EAX = 30 - 8 = 22

    call WriteInt            ; EAX 값 출력 (결과 확인용)
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
