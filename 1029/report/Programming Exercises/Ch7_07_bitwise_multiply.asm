; Ch7 Programming Exercise 7. Bitwise Multiplication
;
; Write a procedure named BitwiseMultiply that multiplies any unsigned 32-bit integer
; by EAX, using only shifting and addition. Pass the integer to the procedure in the
; EBX register, and return the product in the EAX register. Write a short test program
; that calls the procedure and displays the product. (We will assume that the product
; is never larger than 32 bits.) This is a fairly challenging program to write. One
; possible approach is to use a loop to shift the multiplier to the right, keeping
; track of the number of shifts that occur before the Carry flag is set. The resulting
; shift count can then be applied to the SHL instruction, using the multiplicand as the
; destination operand. Then, the same process must be repeated until you find the last
; 1 bit in the multiplier.

INCLUDE Irvine32.inc

.data
multiplicands DWORD 123, 7, 1000, 0, 65535
multipliers   DWORD 36, 9, 1000, 55, 2
msgX   BYTE " * ",0
msgEq  BYTE " = ",0

.code
main PROC
    mov  esi,0
    mov  ecx,LENGTHOF multiplicands
L1: mov  eax,multiplicands[esi]
    call WriteDec
    mov  edx,OFFSET msgX
    call WriteString
    mov  eax,multipliers[esi]
    call WriteDec
    mov  edx,OFFSET msgEq
    call WriteString

    mov  eax,multiplicands[esi]    ; EAX = 피승수
    mov  ebx,multipliers[esi]      ; EBX = 승수
    call BitwiseMultiply           ; EAX = 곱
    call WriteDec
    call Crlf

    add  esi,TYPE DWORD
    loop L1
    exit
main ENDP

;--------------------------------------------------------
BitwiseMultiply PROC
; 시프트와 덧셈만으로 EAX * EBX를 계산한다 (부호 없는 수).
; 승수의 각 1비트 위치 k마다 (피승수 << k)를 결과에 더한다.
;   예: 123 * 36 = 123 * (2^5 + 2^2) = (123 << 5) + (123 << 2)
; Receives: EAX = 피승수, EBX = 승수
; Returns:  EAX = 곱 (32비트를 넘지 않는다고 가정)
;--------------------------------------------------------
    push ebx
    push ecx
    push edx
    mov  edx,0                     ; EDX = 누적 결과
    mov  ecx,eax                   ; ECX = 피승수 (매 단계 왼쪽으로 1비트씩 밀림)
L1: cmp  ebx,0
    je   Done                      ; 승수에 남은 1비트가 없으면 종료
    shr  ebx,1                     ; 승수의 최하위 비트를 CF로
    jnc  L2                        ; 0이면 더하지 않음
    add  edx,ecx                   ; 1이면 현재 (피승수 << k)를 더함
L2: shl  ecx,1                     ; 다음 자리: 피승수 * 2
    jmp  L1
Done:
    mov  eax,edx
    pop  edx
    pop  ecx
    pop  ebx
    ret
BitwiseMultiply ENDP

END main
