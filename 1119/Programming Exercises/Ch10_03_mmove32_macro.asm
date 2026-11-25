; Ch10 Programming Exercise 3. mMove32 Macro
;
; Write a macro named mMove32 that receives two 32-bit memory operands. The macro should
; move the source operand to the destination operand. Write a program that tests your macro.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;--------------------------------------------------------
mMove32 MACRO dest:REQ, source:REQ
;
; 32비트 메모리 → 메모리 이동. MOV는 메모리끼리 직접
; 옮길 수 없으므로 EAX를 거쳐서 옮긴다(EAX는 보존).
;--------------------------------------------------------
    push eax
    mov  eax,source
    mov  dest,eax
    pop  eax
ENDM

.data
val1 DWORD 12345678h
val2 DWORD 0
val3 DWORD 0FFFFFFFFh

.code
main PROC
    mWrite "Before: val2 = "
    mov  eax,val2
    call WriteHex
    call Crlf

    mMove32 val2, val1              ; val2 = val1
    mWrite "After mMove32 val2,val1: val2 = "
    mov  eax,val2
    call WriteHex
    call Crlf

    mMove32 val1, val3              ; val1 = val3
    mWrite "After mMove32 val1,val3: val1 = "
    mov  eax,val1
    call WriteHex
    call Crlf
    exit
main ENDP
END main
