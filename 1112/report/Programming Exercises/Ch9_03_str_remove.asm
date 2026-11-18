; Ch9 Programming Exercise 3. Str_remove Procedure
;
; Write a procedure named Str_remove that removes n characters from a string. Pass a pointer to
; the position in the string where the characters are to be removed. Pass an integer specifying the
; number of characters to remove. The following code, for example, shows how to remove "xxxx"
; from target:
;     .data
;     target BYTE "abcxxxxdefghijklmop",0
;     .code
;     INVOKE Str_remove, ADDR [target+3], 4

INCLUDE Irvine32.inc

Str_remove PROTO,
    pStart:PTR BYTE,
    nChars:DWORD

.data
target  BYTE "abcxxxxdefghijklmop",0
target2 BYTE "hello world",0
msg     BYTE "Result: ",0

.code
main PROC
    ; target+3 위치부터 4글자("xxxx") 제거 → "abcdefghijklmop"
    INVOKE Str_remove, OFFSET target + 3, 4
    mov  edx,OFFSET target
    call ShowResult

    ; 남은 길이보다 많이 지우면 끝까지 잘림 → "hello"
    INVOKE Str_remove, OFFSET target2 + 5, 100
    mov  edx,OFFSET target2
    call ShowResult
    exit
main ENDP

;--------------------------------------------------------
ShowResult PROC
; Receives: EDX = 출력할 문자열
;--------------------------------------------------------
    push edx
    mov  edx,OFFSET msg
    call WriteString
    pop  edx
    call WriteString
    call Crlf
    ret
ShowResult ENDP

;--------------------------------------------------------
Str_remove PROC USES eax ecx esi edi,
    pStart:PTR BYTE,            ; 지우기 시작할 위치
    nChars:DWORD                ; 지울 글자 수
;
; pStart부터 nChars 글자를 지우고 뒷부분을 앞으로 당긴다.
;--------------------------------------------------------
    INVOKE Str_length, pStart   ; EAX = pStart부터 남은 길이
    mov  ecx,nChars
    cmp  ecx,eax                ; 남은 길이보다 많이 지우려 하나?
    jbe  L1
    mov  ecx,eax                ; 그렇다면 남은 길이까지만
L1: mov  edi,pStart             ; 목적지 = 지울 위치
    mov  esi,edi
    add  esi,ecx                ; 출발지 = 지운 글자 다음
    sub  eax,ecx                ; 당겨올 글자 수
    mov  ecx,eax
    inc  ecx                    ; null 바이트 포함
    cld                         ; 정방향 (겹쳐도 앞으로 당기므로 안전)
    rep  movsb                  ; 뒷부분을 앞으로 복사
    ret
Str_remove ENDP

END main
