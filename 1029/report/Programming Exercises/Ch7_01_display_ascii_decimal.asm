; Ch7 Programming Exercise 1. Display ASCII Decimal
;
; Write a procedure named WriteScaled that outputs a decimal ASCII number with an
; implied decimal point. Suppose the following number were defined as follows, where
; DECIMAL_OFFSET indicates that the decimal point must be inserted five positions
; from the right side of the number:
;     DECIMAL_OFFSET = 5
;     .data
;     decimal_one BYTE "100123456789765"
; WriteScaled would display the number like this:
;     1001234567.89765
; When calling WriteScaled, pass the number's offset in EDX, the number length in ECX,
; and the decimal offset in EBX. Write a test program that passes three numbers of
; different sizes to the WriteScaled procedure.

INCLUDE Irvine32.inc

.data
num1 BYTE "100123456789765"        ; 15자리, 소수점 오른쪽 5자리
num2 BYTE "31415926"               ; 8자리, 소수점 오른쪽 7자리
num3 BYTE "12345"                  ; 5자리, 소수점 오른쪽 2자리

.code
main PROC
    mov  edx,OFFSET num1
    mov  ecx,SIZEOF num1
    mov  ebx,5
    call WriteScaled               ; 1001234567.89765
    call Crlf

    mov  edx,OFFSET num2
    mov  ecx,SIZEOF num2
    mov  ebx,7
    call WriteScaled               ; 3.1415926
    call Crlf

    mov  edx,OFFSET num3
    mov  ecx,SIZEOF num3
    mov  ebx,2
    call WriteScaled               ; 123.45
    call Crlf

    exit
main ENDP

;--------------------------------------------------------
WriteScaled PROC
; ASCII 십진수 문자열을 가정된 소수점과 함께 출력한다.
; Receives: EDX = 문자열 주소, ECX = 문자열 길이,
;           EBX = 오른쪽에서 소수점까지의 자리 수
; Returns:  nothing
;--------------------------------------------------------
    pushad
    mov  esi,edx                   ; ESI = 현재 문자 위치

    ; 1) 정수 부분: (길이 - 소수점 오프셋) 개의 문자 출력
    mov  edi,ecx                   ; EDI = 전체 길이 보관
    sub  ecx,ebx                   ; ECX = 정수 부분 자리 수
    jbe  L_point                   ; 정수 부분이 없으면 바로 소수점
L1: mov  al,[esi]
    call WriteChar
    inc  esi
    loop L1

L_point:
    ; 2) 소수점 출력
    mov  al,'.'
    call WriteChar

    ; 3) 소수 부분: EBX개의 문자 출력
    mov  ecx,ebx
    jecxz L_done                   ; 소수 부분이 없으면 끝
L2: mov  al,[esi]
    call WriteChar
    inc  esi
    loop L2

L_done:
    popad
    ret
WriteScaled ENDP

END main
