; Ch8 Programming Exercise 5. DifferentInputs Procedure
;
; Write a procedure named DifferentInputs that returns EAX = 1 if the values of its three input
; parameters are all different; otherwise, return with EAX = 0. Use the PROC directive with a
; parameter list when declaring the procedure. Create a PROTO declaration for your procedure,
; and call it five times from a test program that passes different inputs.

INCLUDE Irvine32.inc

DifferentInputs PROTO, val1:SDWORD, val2:SDWORD, val3:SDWORD

.data
msg BYTE "DifferentInputs returned: ",0

.code
main PROC
    INVOKE DifferentInputs, 1, 2, 3         ; 모두 다름 → 1
    call ShowResult
    INVOKE DifferentInputs, 5, 5, 7         ; 1,2번 같음 → 0
    call ShowResult
    INVOKE DifferentInputs, 4, 9, 4         ; 1,3번 같음 → 0
    call ShowResult
    INVOKE DifferentInputs, -8, 0, -8       ; 1,3번 같음 → 0
    call ShowResult
    INVOKE DifferentInputs, -1, 10, 100     ; 모두 다름 → 1
    call ShowResult
    exit
main ENDP

;--------------------------------------------------------
ShowResult PROC
;--------------------------------------------------------
    push edx
    mov  edx,OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    pop  edx
    ret
ShowResult ENDP

;--------------------------------------------------------
DifferentInputs PROC USES ebx,
    val1:SDWORD,
    val2:SDWORD,
    val3:SDWORD
; 세 값이 모두 다르면 EAX = 1, 하나라도 같으면 EAX = 0
;--------------------------------------------------------
    mov  ebx,val1
    cmp  ebx,val2                   ; val1 == val2 ?
    je   Same
    cmp  ebx,val3                   ; val1 == val3 ?
    je   Same
    mov  ebx,val2
    cmp  ebx,val3                   ; val2 == val3 ?
    je   Same
    mov  eax,1                      ; 모두 다름
    jmp  Done
Same:
    mov  eax,0
Done:
    ret                             ; PROC가 RET 12 생성
DifferentInputs ENDP

END main
