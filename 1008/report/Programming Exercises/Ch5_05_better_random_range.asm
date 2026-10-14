; Ch5 Programming Exercise 5. BetterRandomRange Procedure
; The RandomRange procedure from the Irvine32 library generates a pseudorandom integer between
; 0 and N - 1. Your task is to create an improved version that generates an integer between M and
; N-1. Let the caller pass M in EBX and N in EAX. If we call the procedure BetterRandomRange, the
; following code is a sample test:
;     mov  ebx,-300      ; lower bound
;     mov  eax,100       ; upper bound
;     call BetterRandomRange
; Write a short test program that calls BetterRandomRange from a loop that repeats 50 times.
; Display each randomly generated value.

INCLUDE Irvine32.inc

.code
main PROC
    call Randomize                  ; 난수 시드 초기화
    mov  ecx,50                     ; 50번 반복
L1:
    mov  ebx,-300                   ; M (하한)
    mov  eax,100                    ; N (상한, 결과는 N-1까지)
    call BetterRandomRange
    call WriteInt                   ; 부호 있는 값 출력
    call Crlf
    loop L1
    exit
main ENDP

;---------------------------------------
; BetterRandomRange: M ~ N-1 범위 난수 생성
; Receives: EBX = M, EAX = N
; Returns:  EAX = 난수 (M <= EAX <= N-1)
;---------------------------------------
BetterRandomRange PROC
    sub  eax,ebx                    ; 범위 크기 = N - M
    call RandomRange                ; EAX = 0 ~ (N-M-1)
    add  eax,ebx                    ; M만큼 이동 → M ~ N-1
    ret
BetterRandomRange ENDP

END main
