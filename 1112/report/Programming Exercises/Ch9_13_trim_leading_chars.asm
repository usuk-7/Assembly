; Ch9 Programming Exercise 13. Trimming Leading Characters
;
; Create a variant of the Str_trim procedure that lets the caller remove all instances of a leading
; character from a string. For example, if you were to call it with a pointer to the string "###ABC"
; and pass it the # character, the resulting string would be "ABC."

INCLUDE Irvine32.inc

Str_trimLeading PROTO,
    pString:PTR BYTE,
    char:BYTE

.data
s1 BYTE "###ABC",0              ; → "ABC"
s2 BYTE "ABC",0                 ; → "ABC" (변화 없음)
s3 BYTE "###",0                 ; → ""
s4 BYTE "#A#",0                 ; → "A#" (앞쪽만 제거)
s5 BYTE 0                       ; → "" (빈 문자열)

.code
main PROC
    INVOKE Str_trimLeading, ADDR s1, '#'
    mov  edx,OFFSET s1
    call ShowString
    INVOKE Str_trimLeading, ADDR s2, '#'
    mov  edx,OFFSET s2
    call ShowString
    INVOKE Str_trimLeading, ADDR s3, '#'
    mov  edx,OFFSET s3
    call ShowString
    INVOKE Str_trimLeading, ADDR s4, '#'
    mov  edx,OFFSET s4
    call ShowString
    INVOKE Str_trimLeading, ADDR s5, '#'
    mov  edx,OFFSET s5
    call ShowString
    exit
main ENDP

;--------------------------------------------------------
ShowString PROC USES eax
; EDX = 문자열. [문자열] 형태로 출력
;--------------------------------------------------------
    mov  al,'['
    call WriteChar
    call WriteString
    mov  al,']'
    call WriteChar
    call Crlf
    ret
ShowString ENDP

;------------------------------------------------------------
; Str_trimLeading
; 문자열 앞쪽에 연속된 char를 모두 제거한다.
; 남길 부분(첫 비제거 문자 ~ null)을 문자열 시작으로 당겨 복사.
; Returns: nothing
;------------------------------------------------------------
Str_trimLeading PROC USES eax ecx esi edi,
    pString:PTR BYTE,           ; points to string
    char:BYTE                   ; character to remove
    mov  esi,pString
    mov  al,char
L1: cmp  [esi],al               ; 앞 문자가 제거 대상인가?
    jne  L2                     ; 아니면 (null 포함) 멈춤
    inc  esi                    ; 맞으면 다음 문자로
    jmp  L1
L2: mov  edi,pString
    cmp  esi,edi                ; 제거한 문자가 없으면
    je   L3                     ; 그대로 종료
    INVOKE Str_length, esi      ; EAX = 남길 부분 길이
    mov  ecx,eax
    inc  ecx                    ; null 포함
    cld                         ; 정방향: 앞으로 당기므로 겹쳐도 안전
    rep  movsb                  ; [ESI] → [EDI]
L3: ret
Str_trimLeading ENDP

END main
