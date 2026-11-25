; Ch10 Programming Exercise 5. mReadInt Macro
;
; Create a macro named mReadInt that reads a 16- or 32-bit signed integer from standard input and
; returns the value in an argument. Use conditional operators to allow the macro to adapt to the size
; of the desired result. Write a program that tests the macro, passing it operands of various sizes.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;--------------------------------------------------------
mReadInt MACRO dest:REQ
;
; 부호 있는 정수를 입력받아 dest에 저장한다.
; TYPE dest(어셈블 시점 상수)로 크기를 판단:
;   2바이트 → AX 저장, 4바이트 → EAX 저장, 그 외 → 어셈블 중 오류
;--------------------------------------------------------
    IF (TYPE dest) EQ 2
        push eax
        call ReadInt            ;; EAX = 입력값
        mov  dest,ax            ;; 16비트 결과
        pop  eax
    ELSEIF (TYPE dest) EQ 4
        push eax
        call ReadInt
        mov  dest,eax           ;; 32비트 결과
        pop  eax
    ELSE
        ECHO ---------------------------------------------
        ECHO * Error: mReadInt argument must be 16 or 32 bits
        ECHO ---------------------------------------------
    ENDIF
ENDM

.data
wordVal  SWORD ?
dwordVal SDWORD ?

.code
main PROC
    mWrite "Enter a 16-bit signed integer: "
    mReadInt wordVal                ; WORD 크기로 확장됨
    mWrite "Enter a 32-bit signed integer: "
    mReadInt dwordVal               ; DWORD 크기로 확장됨

    mWrite "wordVal  = "
    movsx eax,wordVal               ; 부호 확장해서 출력
    call WriteInt
    call Crlf
    mWrite "dwordVal = "
    mov  eax,dwordVal
    call WriteInt
    call Crlf
    exit
main ENDP
END main
