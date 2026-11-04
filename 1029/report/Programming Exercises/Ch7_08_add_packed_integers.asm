; Ch7 Programming Exercise 8. Add Packed Integers
;
; Extend the AddPacked procedure from Section 7.6.1 so that it adds two packed decimal
; integers of arbitrary size (both lengths must be the same). Write a test program that
; passes AddPacked several pairs of integers: 4-byte, 8-byte, and 16-byte. We suggest
; that you use the following registers to pass information to the procedure:
;     ESI - pointer to the first number
;     EDI - pointer to the second number
;     EDX - pointer to the sum
;     ECX - number of bytes to add

INCLUDE Irvine32.inc

.data
; 팩 십진수는 리틀 엔디언으로 저장 (DWORD/QWORD로 선언하면 자동으로 그렇게 됨)
; 4-byte: 12345678 + 87654321 = 99999999
p4a  DWORD 12345678h
p4b  DWORD 87654321h
s4   BYTE  5 DUP(0)                ; 합은 1바이트 더 필요

; 8-byte: 9999999999999999 + 0000000000000001 = 1 0000000000000000
p8a  QWORD 9999999999999999h
p8b  QWORD 0000000000000001h
s8   BYTE  9 DUP(0)

; 16-byte: 상위 8바이트 / 하위 8바이트 순서로 메모리에 두기 위해 QWORD 2개 (하위 먼저)
p16a QWORD 5555555555555555h, 1234567890123456h
p16b QWORD 4444444444444445h, 8765432109876543h
s16  BYTE  17 DUP(0)
; 결과 = 1 0000000000000000 0000000000000000 (두 QWORD 모두 10^16 자리올림)

.code
main PROC
    mov  esi,OFFSET p4a
    mov  edi,OFFSET p4b
    mov  edx,OFFSET s4
    mov  ecx,SIZEOF p4a
    call AddPacked
    mov  esi,OFFSET s4
    mov  ecx,SIZEOF s4
    call ShowPacked                ; 0099999999
    call Crlf

    mov  esi,OFFSET p8a
    mov  edi,OFFSET p8b
    mov  edx,OFFSET s8
    mov  ecx,SIZEOF p8a
    call AddPacked
    mov  esi,OFFSET s8
    mov  ecx,SIZEOF s8
    call ShowPacked                ; 010000000000000000
    call Crlf

    mov  esi,OFFSET p16a
    mov  edi,OFFSET p16b
    mov  edx,OFFSET s16
    mov  ecx,SIZEOF p16a
    call AddPacked
    mov  esi,OFFSET s16
    mov  ecx,SIZEOF s16
    call ShowPacked                ; 01 + 0이 32개
    call Crlf

    exit
main ENDP

;--------------------------------------------------------
AddPacked PROC
; 같은 길이의 두 팩 십진수를 더한다.
; Receives: ESI = 첫 번째 수, EDI = 두 번째 수,
;           EDX = 합 버퍼 (ECX + 1 바이트), ECX = 바이트 수
; Returns:  합 버퍼에 팩 십진 합 (리틀 엔디언)
;--------------------------------------------------------
    pushad
    clc                            ; 첫 자리는 캐리 없음
L1: mov  al,[esi]                  ; MOV는 플래그 영향 없음
    adc  al,[edi]                  ; 이전 바이트의 십진 캐리 포함
    daa                            ; AL을 팩 십진수로 조정, 캐리는 CF로
    mov  [edx],al
    inc  esi                       ; INC는 CF를 바꾸지 않음
    inc  edi
    inc  edx
    loop L1                        ; LOOP도 플래그 영향 없음
    mov  al,0                      ; 마지막 캐리를 여분 바이트에 저장
    adc  al,0
    mov  [edx],al
    popad
    ret
AddPacked ENDP

;--------------------------------------------------------
ShowPacked PROC
; 팩 십진수를 최상위 바이트부터 출력 (각 바이트 = 2자리)
; Receives: ESI = 주소, ECX = 바이트 수
;--------------------------------------------------------
    pushad
    add  esi,ecx
    dec  esi                       ; 최상위 바이트
L1: mov  al,[esi]
    call WriteHexB                 ; 팩 십진 바이트는 16진수 출력이 곧 십진 2자리
    dec  esi
    loop L1
    popad
    ret
ShowPacked ENDP

END main
