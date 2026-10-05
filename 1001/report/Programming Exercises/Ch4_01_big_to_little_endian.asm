; Ch4 Programming Exercise 1: Converting from Big Endian to Little Endian
; Write a program that uses the variables below and MOV instructions to copy
; the value from bigEndian to littleEndian, reversing the order of the bytes.
; The number's 32-bit value is understood to be 12345678 hexadecimal.
;   .data
;   bigEndian BYTE 12h,34h,56h,78h
;   littleEndian DWORD ?

INCLUDE Irvine32.inc

.data
bigEndian    BYTE 12h,34h,56h,78h
littleEndian DWORD ?

.code
main PROC
    ; bigEndian[0]이 최상위 바이트 → littleEndian의 가장 높은 주소(+3)로
    mov al, bigEndian[0]                 ; 12h
    mov BYTE PTR littleEndian+3, al
    mov al, bigEndian[1]                 ; 34h
    mov BYTE PTR littleEndian+2, al
    mov al, bigEndian[2]                 ; 56h
    mov BYTE PTR littleEndian+1, al
    mov al, bigEndian[3]                 ; 78h → 최하위 바이트는 가장 낮은 주소(+0)
    mov BYTE PTR littleEndian+0, al

    ; 결과 확인: littleEndian = 12345678h
    mov eax, littleEndian
    call WriteHex                        ; 출력: 12345678
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
