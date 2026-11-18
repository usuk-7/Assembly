; Ch9 Programming Exercise 2. Str_concat Procedure
;
; Write a procedure named Str_concat that concatenates a source string to the end of a target
; string. Sufficient space must exist in the target string to accommodate the new characters. Pass
; pointers to the source and target strings. Here is a sample call:
;     .data
;     targetStr BYTE "ABCDE",10 DUP(0)
;     sourceStr BYTE "FGH",0
;     .code
;     INVOKE Str_concat, ADDR targetStr, ADDR sourceStr

INCLUDE Irvine32.inc

Str_concat PROTO,
    target:PTR BYTE,
    source:PTR BYTE

.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0
source2   BYTE "IJ",0
msg       BYTE "Result: ",0

.code
main PROC
    INVOKE Str_concat, ADDR targetStr, ADDR sourceStr   ; "ABCDEFGH"
    call ShowTarget
    INVOKE Str_concat, ADDR targetStr, ADDR source2     ; "ABCDEFGHIJ"
    call ShowTarget
    exit
main ENDP

;--------------------------------------------------------
ShowTarget PROC
;--------------------------------------------------------
    mov  edx,OFFSET msg
    call WriteString
    mov  edx,OFFSET targetStr
    call WriteString
    call Crlf
    ret
ShowTarget ENDP

;--------------------------------------------------------
Str_concat PROC USES eax edi,
    target:PTR BYTE,            ; 이어붙일 대상(공간 충분해야 함)
    source:PTR BYTE             ; 뒤에 붙일 문자열
;
; target 끝(null 위치)부터 source를 복사한다.
;--------------------------------------------------------
    INVOKE Str_length, target   ; EAX = target 길이
    mov  edi,target
    add  edi,eax                ; EDI = target의 null 위치
    INVOKE Str_copy, source, edi  ; null 위치부터 source(+null) 복사
    ret
Str_concat ENDP

END main
