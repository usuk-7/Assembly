; Ch5 Programming Exercise 1. Draw Text Colors
; Write a program that displays the same string in four different colors, using a loop.
; Call the SetTextColor procedure from the book's link library. Any colors may be chosen,
; but you may find it easiest to change the foreground color.

INCLUDE Irvine32.inc

.data
msg    BYTE "Assembly Language is fun!",0
colors DWORD lightRed, lightGreen, lightCyan, yellow   ; 사용할 4가지 전경색

.code
main PROC
    mov  ecx,LENGTHOF colors        ; 반복 횟수 = 색 개수(4)
    mov  esi,OFFSET colors          ; 색 배열 포인터
L1:
    mov  eax,[esi]                  ; 현재 색 (배경 black = 0)
    call SetTextColor
    call ShowMessage                ; 문자열 출력
    add  esi,TYPE colors            ; 다음 색으로
    loop L1

    mov  eax,lightGray + (black*16) ; 기본 색으로 복구
    call SetTextColor
    exit
main ENDP

;---------------------------------------
; ShowMessage: msg를 출력하고 줄바꿈
;---------------------------------------
ShowMessage PROC USES edx
    mov  edx,OFFSET msg
    call WriteString
    call Crlf
    ret
ShowMessage ENDP

END main
