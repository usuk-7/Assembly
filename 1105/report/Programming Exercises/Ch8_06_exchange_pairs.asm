; Ch8 Programming Exercise 6. Exchanging Integers
;
; Create an array of randomly ordered integers. Using the Swap procedure from Section 8.4.6 as a
; tool, write a loop that exchanges each consecutive pair of integers in the array.

INCLUDE Irvine32.inc

Swap         PROTO, pValX:PTR DWORD, pValY:PTR DWORD
FillRandom   PROTO, pArray:PTR DWORD, count:DWORD
DisplayArray PROTO, pArray:PTR DWORD, count:DWORD

COUNT = 10                          ; 짝수 개 (쌍 단위로 교환)

.data
array   DWORD COUNT DUP(?)
before  BYTE "Before: ",0
after   BYTE "After:  ",0

.code
main PROC
    call Randomize                  ; 난수 시드 초기화
    INVOKE FillRandom, ADDR array, COUNT

    mov  edx,OFFSET before
    call WriteString
    INVOKE DisplayArray, ADDR array, COUNT

    ; 연속된 쌍 (0,1), (2,3), (4,5) ... 를 교환
    mov  esi,OFFSET array
    mov  ecx,COUNT / 2              ; 쌍의 개수
L1: lea  edi,[esi+4]                ; 쌍의 두 번째 원소 주소
    INVOKE Swap, esi, edi           ; 레지스터에 담긴 포인터 전달
    add  esi,8                      ; 다음 쌍으로 (원소 2개 = 8바이트)
    loop L1

    mov  edx,OFFSET after
    call WriteString
    INVOKE DisplayArray, ADDR array, COUNT
    exit
main ENDP

;--------------------------------------------------------
FillRandom PROC USES eax ecx esi,
    pArray:PTR DWORD,
    count:DWORD
; 배열을 0~99 범위의 난수로 채운다.
;--------------------------------------------------------
    mov  esi,pArray
    mov  ecx,count
L1: mov  eax,100
    call RandomRange                ; EAX = 0~99
    mov  [esi],eax
    add  esi,4
    loop L1
    ret
FillRandom ENDP

;--------------------------------------------------------
DisplayArray PROC USES eax ecx esi,
    pArray:PTR DWORD,
    count:DWORD
; 배열 원소를 공백으로 구분해 한 줄에 출력
;--------------------------------------------------------
    mov  esi,pArray
    mov  ecx,count
L1: mov  eax,[esi]
    call WriteDec
    mov  al,' '
    call WriteChar
    add  esi,4
    loop L1
    call Crlf
    ret
DisplayArray ENDP

;-------------------------------------------------------
Swap PROC USES eax esi edi,
    pValX:PTR DWORD,                ; pointer to first integer
    pValY:PTR DWORD                 ; pointer to second integer
; Exchange the values of two 32-bit integers (교재 8.4.6)
;-------------------------------------------------------
    mov  esi,pValX                  ; get pointers
    mov  edi,pValY
    mov  eax,[esi]                  ; get first integer
    xchg eax,[edi]                  ; exchange with second
    mov  [esi],eax                  ; replace first integer
    ret                             ; PROC generates RET 8 here
Swap ENDP

END main
