; Ch9 Programming Exercise 8. Bubble Sort
;
; Add a variable to the BubbleSort procedure in Section 9.5.1 that is set to 1 whenever a pair of
; values is exchanged within the inner loop. Use this variable to exit the sort before its normal
; completion if you discover that no exchanges took place during a complete pass through the
; array. (This variable is commonly known as an exchange flag.)

INCLUDE Irvine32.inc

BubbleSort PROTO,
    pArray:PTR DWORD,
    Count:DWORD

.data
arr1 SDWORD 3, 1, 7, 5, 2, 9, 4, 3      ; Figure 9-4 데이터
arr2 SDWORD 1, 2, 3, 4, 5, 6, 7, 8      ; 이미 정렬됨 → 1회 pass 후 종료
passCount DWORD ?                       ; 실제 수행한 pass 수 (확인용)
msgPass   BYTE "Passes: ",0

.code
main PROC
    mov  esi,OFFSET arr1
    mov  ecx,LENGTHOF arr1
    call PrintArr
    INVOKE BubbleSort, ADDR arr1, LENGTHOF arr1
    call PrintArr
    call ShowPasses              ; 정상보다 적은 pass 수

    call Crlf
    mov  esi,OFFSET arr2
    mov  ecx,LENGTHOF arr2
    call PrintArr
    INVOKE BubbleSort, ADDR arr2, LENGTHOF arr2
    call PrintArr
    call ShowPasses              ; 1
    exit
main ENDP

;--------------------------------------------------------
PrintArr PROC USES eax ecx esi
; ESI = 배열, ECX = 개수
;--------------------------------------------------------
L1: mov  eax,[esi]
    call WriteInt
    mov  al,' '
    call WriteChar
    add  esi,4
    loop L1
    call Crlf
    ret
PrintArr ENDP

;--------------------------------------------------------
ShowPasses PROC USES eax edx
;--------------------------------------------------------
    mov  edx,OFFSET msgPass
    call WriteString
    mov  eax,passCount
    call WriteDec
    call Crlf
    ret
ShowPasses ENDP

;-------------------------------------------------------
BubbleSort PROC USES eax ecx esi,
    pArray:PTR DWORD,           ; pointer to array
    Count:DWORD                 ; array size
    LOCAL exchangeFlag:DWORD    ; 이번 pass에서 교환이 있었으면 1
;
; 32비트 부호 있는 정수 배열을 오름차순 버블 정렬.
; 한 pass 동안 교환이 없으면 이미 정렬된 것이므로 즉시 종료.
;-------------------------------------------------------
    mov  passCount,0
    mov  ecx,Count
    cmp  ecx,1                  ; 원소 0~1개면 정렬할 것 없음
    jbe  L4
    dec  ecx                    ; 최대 pass 수 = Count - 1
L1: push ecx                    ; save outer loop count
    inc  passCount
    mov  exchangeFlag,0         ; pass 시작: 교환 없음
    mov  esi,pArray             ; point to first value
L2: mov  eax,[esi]              ; get array value
    cmp  [esi+4],eax            ; compare a pair of values
    jge  L3                     ; [ESI] <= [ESI+4] 이면 교환 안 함
                                ; (같은 값도 교환하지 않아야 플래그가 정확함)
    xchg eax,[esi+4]            ; exchange the pair
    mov  [esi],eax
    mov  exchangeFlag,1         ; 교환 발생 표시
L3: add  esi,4                  ; move both pointers forward
    loop L2                     ; inner loop
    pop  ecx                    ; retrieve outer loop count
    cmp  exchangeFlag,0         ; 이번 pass에서 교환이 없었나?
    je   L4                     ; 그렇다면 정렬 완료 → 조기 종료
    loop L1                     ; else repeat outer loop
L4: ret
BubbleSort ENDP

END main
