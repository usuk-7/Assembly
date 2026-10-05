; Ch4 Programming Exercise 8: Shifting the Elements in an Array
; Using a loop and indexed addressing, write code that rotates the members of a
; 32-bit integer array forward one position. The value at the end of the array
; must wrap around to the first position. For example, the array [10,20,30,40]
; would be transformed into [40,10,20,30].

INCLUDE Irvine32.inc

.data
array DWORD 10,20,30,40

.code
main PROC
    ; 마지막 원소를 미리 저장 (나중에 맨 앞에 넣음)
    mov ebx, array[(LENGTHOF array - 1) * TYPE array]

    ; 뒤에서부터 한 칸씩 뒤로 이동: array[i] = array[i-1]
    mov esi, LENGTHOF array - 1          ; 마지막 인덱스부터
    mov ecx, LENGTHOF array - 1          ; 이동 횟수
L1:
    mov eax, array[esi*TYPE array - TYPE array]  ; array[i-1]
    mov array[esi*TYPE array], eax               ; → array[i]
    dec esi
    loop L1

    mov array[0], ebx                    ; 저장해둔 마지막 값 → 첫 위치

    ; 결과 확인: 40,10,20,30
    mov esi, OFFSET array
    mov ecx, LENGTHOF array
    mov ebx, TYPE array
    call DumpMem

    invoke ExitProcess, 0
main ENDP
END main
