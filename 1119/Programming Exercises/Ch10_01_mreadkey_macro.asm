; Ch10 Programming Exercise 1. mReadkey Macro
;
; Create a macro that waits for a keystroke and returns the key that was pressed. The macro
; should include parameters for the ASCII code and keyboard scan code. Hint: Call ReadChar
; from the book's link library. Write a program that tests your macro. For example, the following
; code waits for a key; when it returns, the two arguments contain the ASCII code and scan code:
;     .data
;     ascii BYTE ?
;     scan BYTE ?
;     .code
;     mReadkey ascii, scan

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;--------------------------------------------------------
mReadkey MACRO asciiVar:REQ, scanVar:REQ
;
; 키 하나를 기다렸다가 ASCII 코드와 스캔 코드를 돌려준다.
; ReadChar: AL = ASCII 코드, AH = 스캔 코드
; 주의: AL, AH를 인자로 넘기지 말 것(pop eax에서 덮어써짐)
;--------------------------------------------------------
    push eax                ;; EAX 보존
    call ReadChar           ;; 키 입력 대기
    mov  asciiVar,al        ;; ASCII 코드 저장
    mov  scanVar,ah         ;; 스캔 코드 저장
    pop  eax
ENDM

.data
ascii BYTE ?
scan  BYTE ?

.code
main PROC
    mov  ecx,3                      ; 키 3번 테스트
L1:
    mWrite "Press any key: "
    mReadkey ascii, scan            ; 매크로 호출

    call Crlf
    mWrite "  ASCII code = "
    movzx eax,ascii
    call WriteHex                   ; 16진수로 출력
    mWrite "h   Scan code = "
    movzx eax,scan
    call WriteHex
    mWrite "h"
    call Crlf
    loop L1

    exit
main ENDP
END main
