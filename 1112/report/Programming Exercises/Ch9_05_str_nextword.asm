; Ch9 Programming Exercise 5. Str_nextWord Procedure
;
; Write a procedure called Str_nextWord that scans a string for the first occurrence of a certain
; delimiter character and replaces the delimiter with a null byte. There are two input parameters: a
; pointer to the string and the delimiter character. After the call, if the delimiter was found, the Zero
; flag is set and EAX contains the offset of the next character beyond the delimiter. Otherwise, the
; Zero flag is clear and EAX is undefined. The following example code passes the address of target
; and a comma as the delimiter:
;     .data
;     target BYTE "Johnson,Calvin",0
;     .code
;     INVOKE Str_nextWord, ADDR target, ','
;     jnz notFound
; In Figure 9-5, after calling Str_nextWord, EAX points to the character following the position
; where the comma was found (and replaced).

INCLUDE Irvine32.inc

Str_nextWord PROTO,
    pString:PTR BYTE,
    delimiter:BYTE

.data
target BYTE "Johnson,Calvin",0
list   BYTE "red,green,blue,yellow",0
msgTok BYTE "Token: ",0

.code
main PROC
    ; 예제: "Johnson,Calvin" → "Johnson" / "Calvin"
    mov  esi,OFFSET target
    call ShowTokens
    call Crlf
    ; 여러 단어 연속 분리
    mov  esi,OFFSET list
    call ShowTokens
    exit
main ENDP

;--------------------------------------------------------
ShowTokens PROC
; ESI = 문자열. ','로 나눈 단어를 한 줄씩 출력
;--------------------------------------------------------
L1: INVOKE Str_nextWord, esi, ','
    pushfd                      ; ZF 보관 (출력이 플래그를 바꿀 수 있음)
    mov  edx,OFFSET msgTok
    call WriteString
    mov  edx,esi                ; 현재 단어 (구분자 자리가 null이 됨)
    call WriteString
    call Crlf
    popfd
    jnz  Done                   ; 구분자 없음 → 마지막 단어였음
    mov  esi,eax                ; 다음 단어 시작
    jmp  L1
Done:
    ret
ShowTokens ENDP

;--------------------------------------------------------
Str_nextWord PROC USES ecx edi,
    pString:PTR BYTE,           ; 검색할 문자열
    delimiter:BYTE              ; 구분 문자
;
; Returns: 찾으면 ZF = 1, EAX = 구분자 다음 문자 주소
;          못 찾으면 ZF = 0
;--------------------------------------------------------
    INVOKE Str_length, pString  ; EAX = 길이
    mov  ecx,eax                ; 스캔 횟수
    jecxz NotFound              ; 빈 문자열
    mov  edi,pString
    mov  al,delimiter           ; SCASB가 비교할 값
    cld
    repne scasb                 ; 구분자를 만날 때까지
    jne  NotFound               ; 끝까지 없음
    mov  BYTE PTR [edi-1],0     ; 구분자 자리를 null로 (EDI는 한 칸 뒤)
    mov  eax,edi                ; EAX = 다음 문자 위치
    cmp  eax,eax                ; ZF = 1
    jmp  Done
NotFound:
    or   eax,1                  ; ZF = 0
Done:
    ret
Str_nextWord ENDP

END main
