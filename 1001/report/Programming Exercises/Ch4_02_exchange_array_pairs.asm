; Ch4 Programming Exercise 2: Exchanging Pairs of Array Values
; Write a program with a loop and indexed addressing that exchanges every pair
; of values in an array with an even number of elements. Therefore, item i will
; exchange with item i+1, and item i+2 will exchange with item i+3, and so on.

INCLUDE Irvine32.inc

.data
array DWORD 1,2,3,4,5,6,7,8              ; 원소 개수는 짝수여야 함

.code
main PROC
    mov esi, 0                           ; 인덱스 i (0, 2, 4, ...)
    mov ecx, LENGTHOF array / 2          ; 쌍의 개수만큼 반복

L1:
    ; array[i] <-> array[i+1] 교환 (스케일 팩터 TYPE array = 4)
    mov eax, array[esi*TYPE array]               ; EAX = array[i]
    xchg eax, array[esi*TYPE array + TYPE array] ; EAX = array[i+1], array[i+1] = 옛 array[i]
    mov array[esi*TYPE array], eax               ; array[i] = 옛 array[i+1]
    add esi, 2                           ; 다음 쌍으로
    loop L1

    ; 결과 확인: 2,1,4,3,6,5,8,7
    mov esi, OFFSET array
    mov ecx, LENGTHOF array
    mov ebx, TYPE array
    call DumpMem

    invoke ExitProcess, 0
main ENDP
END main
