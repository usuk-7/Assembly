; Ch8 Programming Exercise 10. Show Procedure Parameters
;
; Write a procedure named ShowParams that displays the address and hexadecimal value of the
; 32-bit parameters on the runtime stack of the procedure that called it. The parameters are to be
; displayed in order from the lowest address to the highest. Input to the procedure will be a single
; integer that indicates the number of parameters to display. For example, suppose the following
; statement in main calls MySample, passing three arguments:
;       INVOKE MySample, 1234h, 5000h, 6543h
; Next, inside MySample, you should be able to call ShowParams, passing the number of param-
; eters you want to display:
;       MySample PROC first:DWORD, second:DWORD, third:DWORD
;       paramCount = 3
;       call ShowParams, paramCount
; ShowParams should display output in the following format:
;       Stack parameters:
;       ---------------------------
;       Address 0012FF80 = 00001234
;       Address 0012FF84 = 00005000
;       Address 0012FF88 = 00006543

INCLUDE Irvine32.inc

MySample   PROTO, first:DWORD, second:DWORD, third:DWORD
ShowParams PROTO, numParams:DWORD

.data
title1  BYTE "Stack parameters:",0dh,0ah
        BYTE "---------------------------",0dh,0ah,0
addrMsg BYTE "Address ",0
eqMsg   BYTE " = ",0

.code
main PROC
    INVOKE MySample, 1234h, 5000h, 6543h
    exit
main ENDP

;--------------------------------------------------------
MySample PROC first:DWORD, second:DWORD, third:DWORD
; 매개변수가 3개인 예제 프로시저. 자신의 스택 매개변수를 ShowParams로 출력.
; (책의 "call ShowParams, paramCount"는 MASM 문법이 아니므로 INVOKE 사용)
;--------------------------------------------------------
    paramCount = 3
    INVOKE ShowParams, paramCount
    ret                             ; PROC가 RET 12 생성
MySample ENDP

;--------------------------------------------------------
ShowParams PROC USES eax ebx ecx edx esi,
    numParams:DWORD
; 호출한 프로시저의 스택 매개변수를 낮은 주소부터 출력한다.
;
; ShowParams의 스택 프레임:
;   [ebp+8]  = numParams
;   [ebp+4]  = MySample로 돌아갈 복귀 주소
;   [ebp]    = MySample의 EBP (저장된 EBP)  ← 이것을 이용
; MySample의 프레임:
;   [MySample EBP + 8]  = first
;   [MySample EBP + 12] = second
;   [MySample EBP + 16] = third
;--------------------------------------------------------
    mov  edx,OFFSET title1
    call WriteString

    mov  ebx,[ebp]                  ; 호출자(MySample)의 EBP
    lea  esi,[ebx+8]                ; 호출자의 첫 번째 매개변수 주소
    mov  ecx,numParams
    jecxz Done
L1: mov  edx,OFFSET addrMsg
    call WriteString
    mov  eax,esi                    ; 주소 출력 (8자리 16진수)
    call WriteHex
    mov  edx,OFFSET eqMsg
    call WriteString
    mov  eax,[esi]                  ; 그 주소의 값 출력
    call WriteHex
    call Crlf
    add  esi,4                      ; 다음 매개변수 (높은 주소 쪽)
    loop L1
Done:
    ret
ShowParams ENDP

END main
