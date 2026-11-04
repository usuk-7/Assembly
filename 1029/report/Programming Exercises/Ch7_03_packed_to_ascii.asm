; Ch7 Programming Exercise 3. Packed Decimal Conversion
;
; Write a procedure named PackedToAsc that converts a 4-byte packed decimal integer
; to a string of ASCII decimal digits. Pass the packed integer and the address of a
; buffer holding the ASCII digits to the procedure. Write a short test program that
; passes at least 5 packed decimal integers to your procedure.

INCLUDE Irvine32.inc

.data
packedVals DWORD 12345678h, 00000000h, 99999999h, 08723654h, 00000237h, 40102050h
buffer     BYTE 8 DUP(?), 0        ; 8자리 + 널 종료

.code
main PROC
    mov  edi,OFFSET packedVals
    mov  ecx,LENGTHOF packedVals
L1: push ecx
    mov  eax,[edi]                 ; 변환할 팩 십진수
    mov  esi,OFFSET buffer         ; 결과 버퍼
    call PackedToAsc
    mov  edx,OFFSET buffer
    call WriteString               ; 예: 12345678
    call Crlf
    add  edi,TYPE DWORD
    pop  ecx
    loop L1
    exit
main ENDP

;--------------------------------------------------------
PackedToAsc PROC
; 4바이트 팩 십진수를 8자리 ASCII 문자열로 바꾼다.
; Receives: EAX = 팩 십진 정수, ESI = 8바이트 버퍼 주소
; Returns:  버퍼에 ASCII 숫자 8개 (최상위 자리부터)
;--------------------------------------------------------
    pushad
    mov  ecx,8                     ; 니블(자리) 8개
L1: rol  eax,4                     ; 최상위 니블을 AL 하위 4비트로 회전
    mov  bl,al
    and  bl,0Fh                    ; 한 자리(0~9)만 남김
    or   bl,30h                    ; ASCII 숫자로 변환
    mov  [esi],bl
    inc  esi
    loop L1                        ; 8번 회전하면 EAX는 원래 값으로 돌아옴
    popad
    ret
PackedToAsc ENDP

END main
