; Ch9 Programming Exercise 7. Sieve of Eratosthenes
;
; The Sieve of Eratosthenes, invented by the Greek mathematician of the same name, provides a
; quick way to find all prime numbers within a given range. The algorithm involves creating an array
; of bytes in which positions are "marked" by inserting 1s in the following manner: Beginning with
; position 2 (which is a prime number), insert a 1 in each array position that is a multiple of 2. Then
; do the same thing for multiples of 3, the next prime number. Find the next prime number after 3,
; which is 5, and mark all positions that are multiples of 5. Proceed in this manner until all multiples
; of primes have been found. The remaining positions of the array that are unmarked indicate which
; numbers are prime. For this program, create a 65,000-element array and display all primes
; between 2 and 65,000. Declare the array in an uninitialized data segment (see Section 3.4.11) and
; use STOSB to fill it with zeros.

INCLUDE Irvine32.inc

LIMIT = 65000

.data?
sieve BYTE LIMIT+1 DUP(?)       ; 인덱스 0..65000 (인덱스 = 숫자)

.data
msgCount BYTE "Number of primes: ",0
primeCnt DWORD 0

.code
main PROC
    ; 1) STOSB로 배열 전체를 0(= 소수 후보)으로 채움
    mov  edi,OFFSET sieve
    mov  ecx,LIMIT+1
    mov  al,0
    cld
    rep  stosb

    ; 2) i*i <= LIMIT 인 i에 대해, i가 소수면 i의 배수를 1로 표시
    mov  ebx,2                  ; EBX = i
Outer:
    mov  eax,ebx
    mul  ebx                    ; EAX = i*i (EDX는 0)
    cmp  eax,LIMIT
    ja   Display                ; i*i > LIMIT 이면 끝
    cmp  sieve[ebx],0           ; 이미 합성수로 표시됨?
    jne  NextI
Inner:                          ; EAX = j (i*i부터 시작, i*i 미만 배수는 이미 표시됨)
    mov  sieve[eax],1           ; 합성수 표시
    add  eax,ebx                ; j += i
    cmp  eax,LIMIT
    jbe  Inner
NextI:
    inc  ebx
    jmp  Outer

    ; 3) 표시되지 않은(0) 위치 = 소수 출력
Display:
    mov  esi,2
D1: cmp  sieve[esi],0
    jne  D2
    mov  eax,esi
    call WriteDec
    mov  al,' '
    call WriteChar
    inc  primeCnt
D2: inc  esi
    cmp  esi,LIMIT
    jbe  D1

    call Crlf
    call Crlf
    mov  edx,OFFSET msgCount
    call WriteString
    mov  eax,primeCnt
    call WriteDec
    call Crlf
    exit
main ENDP

END main
