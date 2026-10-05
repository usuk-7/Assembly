; Ch4 Programming Exercise 3: Summing the Gaps between Array Values
; Write a program with a loop and indexed addressing that calculates the sum of
; all the gaps between successive array elements. The array elements are
; doublewords, sequenced in nondecreasing order. So, for example, the array
; {0, 2, 5, 9, 10} has gaps of 2, 3, 4, and 1, whose sum equals 10.

INCLUDE Irvine32.inc

.data
array DWORD 0,2,5,9,10

.code
main PROC
    mov eax, 0                           ; 갭의 합계
    mov esi, 1                           ; 인덱스는 1부터 (array[i] - array[i-1])
    mov ecx, LENGTHOF array - 1          ; 갭 개수 = 원소 개수 - 1

L1:
    mov edx, array[esi*TYPE array]       ; EDX = array[i]
    sub edx, array[esi*TYPE array - TYPE array] ; EDX = array[i] - array[i-1] (갭)
    add eax, edx                         ; 합계에 누적
    inc esi
    loop L1

    ; 결과 확인: 10
    call WriteDec
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
