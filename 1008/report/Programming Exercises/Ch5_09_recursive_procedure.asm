; Ch5 Programming Exercise 9. Recursive Procedure
; Direct recursion is the term we use when a procedure calls itself. Of course, you never want to
; let a procedure keep calling itself forever, because the runtime stack would fill up. Instead, you
; must limit the recursion in some way. Write a program that calls a recursive procedure. Inside
; this procedure, add 1 to a counter so you can verify the number of times it executes. Run your
; program with a debugger, and at the end of the program, check the counter's value. Put a number
; in ECX that specifies the number of times you want to allow the recursion to continue. Using
; only the LOOP instruction (and no other conditional statements from later chapters), find a way
; for the recursive procedure to call itself a fixed number of times.

INCLUDE Irvine32.inc

.data
counter DWORD 0                     ; 실행 횟수

.code
main PROC
    mov  ecx,10                     ; 재귀 허용 횟수
    call Recurse
    mov  eax,counter                ; 디버거에서 확인할 값 (10)
    call WriteDec
    call Crlf
    exit
main ENDP

;---------------------------------------
; Recurse: ECX번 자기 자신을 호출
; Receives: ECX = 호출 횟수
; LOOP가 ECX를 1 줄이고 0이 아니면 L1으로 점프 → 재귀
; ECX가 0이 되면 점프 안 함 → ret로 되돌아감
;---------------------------------------
Recurse PROC
    inc  counter                    ; 실행될 때마다 +1
    loop L1                         ; ECX-1, ECX≠0이면 재귀
    ret                             ; ECX=0 → 재귀 종료
L1:
    call Recurse                    ; 자기 자신 호출
    ret
Recurse ENDP

END main
