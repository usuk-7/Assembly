; Ch4 Programming Exercise 5: Fibonacci Numbers
; Write a program that uses a loop to calculate the first seven values of the
; Fibonacci number sequence, described by the following formula:
; Fib(1) = 1, Fib(2) = 1, Fib(n) = Fib(n - 1) + Fib(n - 2).

INCLUDE Irvine32.inc

.data
fib DWORD 7 DUP(?)                       ; Fib(1) ~ Fib(7) 저장

.code
main PROC
    ; 초기값 Fib(1) = 1, Fib(2) = 1
    mov fib[0], 1
    mov fib[4], 1

    mov esi, 2                           ; 세 번째 원소부터 계산
    mov ecx, LENGTHOF fib - 2            ; 남은 5개 계산

L1:
    mov eax, fib[esi*4 - 4]              ; Fib(n-1)
    add eax, fib[esi*4 - 8]              ; + Fib(n-2)
    mov fib[esi*4], eax                  ; Fib(n) 저장
    inc esi
    loop L1

    ; 결과 출력: 1 1 2 3 5 8 13
    mov esi, 0
    mov ecx, LENGTHOF fib
L2:
    mov eax, fib[esi*4]
    call WriteDec
    mov al, ' '
    call WriteChar
    inc esi
    loop L2
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
