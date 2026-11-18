; Ch9 Programming Exercise 14. Trimming a Set of Characters
;
; Create a variant of the Str_trim procedure that lets the caller remove all instances of a set of
; characters from the end of a string. For example, if you were to call it with a pointer to the string
; "ABC#$&" and pass it a pointer to an array of filter characters containing "%#!;$&*", the result-
; ing string would be "ABC".

INCLUDE Irvine32.inc

Str_trimSet PROTO,
    pString:PTR BYTE,
    pFilter:PTR BYTE

.data
filter BYTE "%#!;$&*",0
s1 BYTE "ABC#$&",0              ; → "ABC"
s2 BYTE "#$&",0                 ; → "" (전부 필터 문자)
s3 BYTE "A#B$",0                ; → "A#B" (끝쪽만 제거)
s4 BYTE "Hello",0               ; → "Hello" (변화 없음)

.code
main PROC
    INVOKE Str_trimSet, ADDR s1, ADDR filter
    mov  edx,OFFSET s1
    call ShowString
    INVOKE Str_trimSet, ADDR s2, ADDR filter
    mov  edx,OFFSET s2
    call ShowString
    INVOKE Str_trimSet, ADDR s3, ADDR filter
    mov  edx,OFFSET s3
    call ShowString
    INVOKE Str_trimSet, ADDR s4, ADDR filter
    mov  edx,OFFSET s4
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
; Str_trimSet
; 문자열 끝에서부터, 필터 집합에 속한 문자를 모두 제거한다.
; 각 문자가 집합에 있는지는 REPNE SCASB로 필터 문자열을 검색.
; Returns: nothing
;------------------------------------------------------------
Str_trimSet PROC USES eax ecx edx esi edi,
    pString:PTR BYTE,           ; 대상 문자열
    pFilter:PTR BYTE            ; 제거할 문자 집합 (null 종료)
    INVOKE Str_length, pFilter
    mov  edx,eax                ; EDX = 필터 문자 개수
    cmp  edx,0                  ; 필터가 비면 할 일 없음
    je   L3
    INVOKE Str_length, pString  ; EAX = 문자열 길이
    cmp  eax,0                  ; 빈 문자열
    je   L3
    mov  esi,pString
    add  esi,eax
    dec  esi                    ; ESI = 마지막 문자
    cld
L1: mov  al,[esi]               ; 현재 문자
    mov  edi,pFilter
    mov  ecx,edx
    repne scasb                 ; 필터 집합에서 AL 검색
    jne  L2                     ; 집합에 없음 → 여기서 멈춤
    dec  esi                    ; 집합에 있음 → 한 칸 앞으로
    cmp  esi,pString            ; 문자열 시작을 지나쳤나?
    jae  L1
L2: mov  BYTE PTR [esi+1],0     ; 남길 마지막 문자 뒤에 null
                                ; (전부 제거되면 ESI = 시작-1 → 첫 칸이 null)
L3: ret
Str_trimSet ENDP

END main
