; Ch4 Programming Exercise 4: Copying a Word Array to a DoubleWord array
; Write a program that uses a loop to copy all the elements from an unsigned
; Word (16-bit) array into an unsigned doubleword (32-bit) array.

INCLUDE Irvine32.inc

.data
wordArray  WORD 1000h, 2000h, 0FFFFh, 8000h, 0001h
dwordArray DWORD LENGTHOF wordArray DUP(?)   ; 같은 개수의 DWORD 공간

.code
main PROC
    mov esi, 0                           ; 공통 인덱스
    mov ecx, LENGTHOF wordArray          ; 원소 개수만큼 반복

L1:
    ; unsigned이므로 MOVZX로 상위 16비트를 0으로 채워 확장
    movzx eax, wordArray[esi*TYPE wordArray]     ; 스케일 2
    mov dwordArray[esi*TYPE dwordArray], eax     ; 스케일 4
    inc esi
    loop L1

    ; 결과 확인: 00001000 00002000 0000FFFF 00008000 00000001
    mov esi, OFFSET dwordArray
    mov ecx, LENGTHOF dwordArray
    mov ebx, TYPE dwordArray
    call DumpMem

    invoke ExitProcess, 0
main ENDP
END main
