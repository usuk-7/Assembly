; Ch7 Programming Exercise 2. Extended Subtraction Procedure
;
; Create a procedure named Extended_Sub that subtracts two binary integers of
; arbitrary size. The storage size of the two integers must be the same, and their
; size must be a multiple of 32 bits. Write a test program that passes several pairs
; of integers, each at least 10 bytes long.

INCLUDE Irvine32.inc

.data
; 각 정수는 리틀 엔디언 DWORD 배열 (최하위 DWORD가 먼저). 크기 12바이트(96비트)
a1  DWORD 00000001h, 00000000h, 00000005h      ; 00000005 00000000 00000001
b1  DWORD 00000002h, 00000000h, 00000001h      ; 00000001 00000000 00000002
r1  DWORD 3 DUP(?)                             ; 결과 = 00000003 FFFFFFFF FFFFFFFF

a2  DWORD 89ABCDEFh, 01234567h, 0FEDCBA98h, 76543210h   ; 16바이트
b2  DWORD 11111111h, 22222222h, 33333333h, 44444444h
r2  DWORD 4 DUP(?)                             ; 결과 = 320FEDCC CBA98764 DF012345 789ABCDE

a3  DWORD 0, 0, 0                              ; 0 - 1 = FFFFFFFF FFFFFFFF FFFFFFFF (-1)
b3  DWORD 1, 0, 0
r3  DWORD 3 DUP(?)

.code
main PROC
    ; pair 1
    mov  esi,OFFSET a1
    mov  edi,OFFSET b1
    mov  ebx,OFFSET r1
    mov  ecx,LENGTHOF a1           ; DWORD 개수
    call Extended_Sub
    mov  esi,OFFSET r1
    mov  ecx,LENGTHOF r1
    call Display_Big
    call Crlf

    ; pair 2
    mov  esi,OFFSET a2
    mov  edi,OFFSET b2
    mov  ebx,OFFSET r2
    mov  ecx,LENGTHOF a2
    call Extended_Sub
    mov  esi,OFFSET r2
    mov  ecx,LENGTHOF r2
    call Display_Big
    call Crlf

    ; pair 3
    mov  esi,OFFSET a3
    mov  edi,OFFSET b3
    mov  ebx,OFFSET r3
    mov  ecx,LENGTHOF a3
    call Extended_Sub
    mov  esi,OFFSET r3
    mov  ecx,LENGTHOF r3
    call Display_Big
    call Crlf

    exit
main ENDP

;--------------------------------------------------------
Extended_Sub PROC
; [ESI] - [EDI] 를 계산해 [EBX]에 저장한다.
; Receives: ESI = 피감수, EDI = 감수, EBX = 결과 버퍼,
;           ECX = DWORD 개수 (크기는 32비트의 배수)
; Returns:  CF = 1이면 최종 빌림 발생 (결과가 음수)
;--------------------------------------------------------
    push eax
    push esi
    push edi
    push ebx
    push ecx
    clc                            ; 첫 뺄셈에 빌림 없음
L1: mov  eax,[esi]                 ; MOV는 플래그 영향 없음
    sbb  eax,[edi]                 ; 이전 빌림(CF)까지 함께 뺌
    mov  [ebx],eax
    lea  esi,[esi+4]               ; LEA는 CF를 바꾸지 않음 (ADD 대신 사용)
    lea  edi,[edi+4]
    lea  ebx,[ebx+4]
    loop L1                        ; LOOP도 플래그를 바꾸지 않음
    pop  ecx                       ; POP은 플래그 영향 없음 → CF 유지
    pop  ebx
    pop  edi
    pop  esi
    pop  eax
    ret
Extended_Sub ENDP

;--------------------------------------------------------
Display_Big PROC
; DWORD 배열 정수를 최상위 DWORD부터 16진수로 출력한다.
; Receives: ESI = 배열 주소, ECX = DWORD 개수
;--------------------------------------------------------
    pushad
    lea  esi,[esi+ecx*4-4]         ; 마지막(최상위) DWORD
L1: mov  eax,[esi]
    call WriteHex
    mov  al,' '
    call WriteChar
    sub  esi,4
    loop L1
    popad
    ret
Display_Big ENDP

END main
