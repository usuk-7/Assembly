; Ch7 Programming Exercise 5. Prime Numbers
;
; Write a program that generates all prime numbers between 2 and 1000, using the Sieve
; of Eratosthenes method. You can find many articles that describe the method for
; finding primes in this manner on the Internet. Display all the prime values.

INCLUDE Irvine32.inc

MAX_N = 1000

.data
sieve BYTE (MAX_N + 1) DUP(0)      ; sieve[i] = 0 → 소수 후보, 1 → 합성수

.code
main PROC
    ; ----- 체 만들기 -----
    mov  ebx,2                     ; EBX = 현재 소수 p
Outer:
    mov  eax,ebx
    mul  ebx                       ; EAX = p * p
    cmp  eax,MAX_N
    ja   Print                     ; p*p > 1000이면 체 완성
    cmp  sieve[ebx],0
    jne  NextP                     ; 이미 지워진 수면 건너뜀
Inner:                             ; p*p부터 p 간격으로 배수 지우기
    mov  sieve[eax],1
    add  eax,ebx
    cmp  eax,MAX_N
    jbe  Inner
NextP:
    inc  ebx
    jmp  Outer

    ; ----- 소수 출력 -----
Print:
    mov  esi,2
    mov  edi,0                     ; 한 줄에 10개씩 출력하기 위한 카운터
L1: cmp  sieve[esi],0
    jne  Skip
    mov  eax,esi
    call WriteDec
    mov  al,9                      ; 탭
    call WriteChar
    inc  edi
    cmp  edi,10
    jb   Skip
    call Crlf
    mov  edi,0
Skip:
    inc  esi
    cmp  esi,MAX_N
    jbe  L1
    call Crlf
    exit
main ENDP

END main
