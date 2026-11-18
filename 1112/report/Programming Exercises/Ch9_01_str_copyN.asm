; Ch9 Programming Exercise 1. Improved Str_copy Procedure
;
; The Str_copy procedure shown in this chapter does not limit the number of characters to be
; copied. Create a new version (named Str_copyN) that receives an additional input parameter
; indicating the maximum number of characters to be copied.

INCLUDE Irvine32.inc

Str_copyN PROTO,
    source:PTR BYTE,
    target:PTR BYTE,
    maxChars:DWORD

.data
source   BYTE "ABCDEFGHIJ",0
target1  BYTE 6 DUP(0FFh)            ; 최대 5글자 + null
target2  BYTE 21 DUP(0FFh)           ; 최대 20글자 + null
msg1     BYTE "Copy max 5  : ",0
msg2     BYTE "Copy max 20 : ",0

.code
main PROC
    ; source보다 짧게 제한 → "ABCDE"
    INVOKE Str_copyN, ADDR source, ADDR target1, 5
    mov  edx,OFFSET msg1
    call WriteString
    mov  edx,OFFSET target1
    call WriteString
    call Crlf

    ; source보다 길게 제한 → source 전체 "ABCDEFGHIJ"
    INVOKE Str_copyN, ADDR source, ADDR target2, 20
    mov  edx,OFFSET msg2
    call WriteString
    mov  edx,OFFSET target2
    call WriteString
    call Crlf
    exit
main ENDP

;--------------------------------------------------------
Str_copyN PROC USES eax ecx esi edi,
    source:PTR BYTE,            ; source string
    target:PTR BYTE,            ; target string
    maxChars:DWORD              ; 복사할 최대 문자 수
;
; source를 target으로 최대 maxChars 글자까지 복사하고
; 항상 null로 끝맺는다.
; Requires: target은 maxChars+1 바이트 이상이어야 함
;--------------------------------------------------------
    mov  esi,source
    mov  edi,target
    mov  ecx,maxChars           ; 남은 복사 가능 글자 수
    cld                         ; 정방향 (ESI, EDI 증가)
    jecxz Done                  ; 0글자면 null만 넣음
L1: lodsb                       ; AL = [ESI], ESI++
    cmp  al,0                   ; source가 먼저 끝났나?
    je   Done
    stosb                       ; [EDI] = AL, EDI++
    loop L1                     ; 최대 개수만큼 반복
Done:
    mov  BYTE PTR [edi],0       ; target 끝에 null
    ret
Str_copyN ENDP

END main
