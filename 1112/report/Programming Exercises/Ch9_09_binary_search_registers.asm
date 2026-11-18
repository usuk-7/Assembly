; Ch9 Programming Exercise 9. Binary Search
;
; Rewrite the binary search procedure shown in this chapter by using registers for mid, first, and
; last. Add comments to clarify the registers' usage.

INCLUDE Irvine32.inc

BinarySearch PROTO,
    pArray:PTR DWORD,
    Count:DWORD,
    searchVal:DWORD

.data
array  SDWORD -50, -12, -3, 0, 4, 9, 15, 22, 37, 48, 60, 91   ; 정렬된 배열
prompt BYTE "Enter a signed integer to find (e.g. 37, -3, 5): ",0
msg1   BYTE "The value was not found.",0
msg2   BYTE "The value was found at position ",0

.code
main PROC
    mov  edx,OFFSET prompt
    call WriteString
    call ReadInt                ; EAX = 찾을 값
    INVOKE BinarySearch, ADDR array, LENGTHOF array, eax
    call ShowResults
    exit
main ENDP

;--------------------------------------------------------
ShowResults PROC
; EAX = 위치 (-1이면 없음)
;--------------------------------------------------------
    .IF eax == -1
      mov  edx,OFFSET msg1
      call WriteString
    .ELSE
      mov  edx,OFFSET msg2
      call WriteString
      call WriteDec
    .ENDIF
    call Crlf
    ret
ShowResults ENDP

;--------------------------------------------------------------
; BinarySearch (register version)
; Searches an array of signed integers for a single value.
; Receives: Pointer to array, array size, search value.
; Returns: If a match is found, EAX = the array position of the
;          matching element; otherwise, EAX = -1.
;
; 레지스터 사용:
;   EBX = 배열 시작 주소
;   ECX = first (탐색 범위의 첫 인덱스)
;   EDX = last  (탐색 범위의 마지막 인덱스)
;   EAX = mid   (중간 인덱스, 찾으면 그대로 반환값)
;   ESI = values[mid]
;   EDI = searchVal
;--------------------------------------------------------------
BinarySearch PROC USES ebx ecx edx esi edi,
    pArray:PTR DWORD,           ; pointer to array
    Count:DWORD,                ; array size
    searchVal:DWORD             ; search value

    mov  ebx,pArray             ; EBX = 배열 주소
    mov  edi,searchVal          ; EDI = 찾을 값
    mov  ecx,0                  ; first = 0
    mov  edx,Count
    dec  edx                    ; last = Count - 1

L1: cmp  ecx,edx                ; while (first <= last)
    jg   NotFound
    mov  eax,ecx                ; mid = (first + last) / 2
    add  eax,edx
    sar  eax,1
    mov  esi,[ebx + eax*4]      ; ESI = values[mid] (배율 4)
    cmp  esi,edi
    jl   GoRight                ; values[mid] < searchVal
    jg   GoLeft                 ; values[mid] > searchVal
    jmp  Done                   ; 같음: EAX = mid 반환

GoRight:
    lea  ecx,[eax+1]            ; first = mid + 1
    jmp  L1
GoLeft:
    lea  edx,[eax-1]            ; last = mid - 1
    jmp  L1

NotFound:
    mov  eax,-1                 ; search failed
Done:
    ret
BinarySearch ENDP

END main
