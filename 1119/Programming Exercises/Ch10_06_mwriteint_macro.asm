; Ch10 Programming Exercise 6. mWriteInt Macro
;
; Create a macro named mWriteInt that writes a signed integer to standard output by calling
; the WriteInt library procedure. The argument passed to the macro can be a byte, word, or
; doubleword. Use conditional operators in the macro so it adapts to the size of the argument.
; Write a program that tests the macro, passing it arguments of different sizes.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;--------------------------------------------------------
mWriteInt MACRO value:REQ
;
; 부호 있는 정수 출력. WriteInt는 EAX(32비트)를 받으므로
; BYTE/WORD는 MOVSX로 부호 확장, DWORD는 그대로 MOV.
; (MOVSX는 32비트 원본을 받을 수 없어서 분기가 필요함)
;--------------------------------------------------------
    push eax
    IF (TYPE value) EQ 1
        movsx eax,value
    ELSEIF (TYPE value) EQ 2
        movsx eax,value
    ELSEIF (TYPE value) EQ 4
        mov   eax,value
    ELSE
        ECHO * Error: mWriteInt argument must be 8, 16, or 32 bits
        pop  eax                ;; 앞에서 push한 EAX 정리 후 종료
        EXITM
    ENDIF
    call WriteInt
    pop  eax
ENDM

.data
bVal SBYTE  -100
wVal SWORD  -30000
dVal SDWORD -2000000000

.code
main PROC
    mWrite "byte  : "
    mWriteInt bVal          ; -100
    call Crlf
    mWrite "word  : "
    mWriteInt wVal          ; -30000
    call Crlf
    mWrite "dword : "
    mWriteInt dVal          ; -2000000000
    call Crlf

    mov  bl,7Fh
    mWrite "BL    : "
    mWriteInt bl            ; 레지스터도 가능 (+127)
    call Crlf
    exit
main ENDP
END main
