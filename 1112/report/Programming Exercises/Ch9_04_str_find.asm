; Ch9 Programming Exercise 4. Str_find Procedure
;
; Write a procedure named Str_find that searches for the first matching occurrence of a source string
; inside a target string and returns the matching position. The input parameters should be a pointer to
; the source string and a pointer to the target string. If a match is found, the procedure sets the Zero
; flag and EAX points to the matching position in the target string. Otherwise, the Zero flag is clear
; and EAX is undefined. The following code, for example, searches for "ABC" and returns with EAX
; pointing to the "A" in the target string:
;     .data
;     target BYTE "123ABC342432",0
;     source BYTE "ABC",0
;     pos    DWORD ?
;     .code
;     INVOKE Str_find, ADDR source, ADDR target
;     jnz notFound
;     mov pos,eax                    ; store the position value

INCLUDE Irvine32.inc

Str_find PROTO,
    pSource:PTR BYTE,
    pTarget:PTR BYTE

.data
target  BYTE "123ABC342432",0
source  BYTE "ABC",0
source2 BYTE "XYZ",0
pos     DWORD ?
msgFound    BYTE "Found at index ",0
msgNotFound BYTE "Not found",0

.code
main PROC
    INVOKE Str_find, ADDR source, ADDR target   ; "ABC" → index 3
    call ShowResult
    INVOKE Str_find, ADDR source2, ADDR target  ; "XYZ" → not found
    call ShowResult
    exit
main ENDP

;--------------------------------------------------------
ShowResult PROC
; Str_find 직후 호출: ZF와 EAX로 결과 출력
;--------------------------------------------------------
    jnz  notFound
    mov  pos,eax                    ; 일치 위치(주소) 저장
    mov  edx,OFFSET msgFound
    call WriteString
    sub  eax,OFFSET target          ; 주소 → 인덱스
    call WriteDec
    jmp  done
notFound:
    mov  edx,OFFSET msgNotFound
    call WriteString
done:
    call Crlf
    ret
ShowResult ENDP

;--------------------------------------------------------
Str_find PROC USES ebx ecx edx esi edi,
    pSource:PTR BYTE,           ; 찾을 문자열
    pTarget:PTR BYTE            ; 검색 대상 문자열
;
; Returns: 찾으면 ZF = 1, EAX = target 안의 일치 위치
;          못 찾으면 ZF = 0
;--------------------------------------------------------
    INVOKE Str_length, pSource
    mov  ebx,eax                ; EBX = source 길이
    INVOKE Str_length, pTarget  ; EAX = target 길이
    cmp  ebx,0                  ; 빈 source는 "못 찾음"으로 처리
    je   NotFound
    cmp  ebx,eax                ; source가 더 길면 불가능
    ja   NotFound
    sub  eax,ebx
    inc  eax
    mov  edx,eax                ; EDX = 비교할 시작 위치 개수
    mov  edi,pTarget            ; EDI = 현재 시작 위치
    cld
L1: push edi                    ; 시작 위치 보관
    mov  esi,pSource
    mov  ecx,ebx                ; source 길이만큼 비교
    repe cmpsb                  ; 같은 동안 비교
    pop  edi
    je   Found                  ; 끝까지 같았으면 ZF = 1
    inc  edi                    ; 다음 시작 위치
    dec  edx
    jnz  L1
NotFound:
    or   eax,1                  ; 결과 ≠ 0 → ZF = 0
    jmp  Done
Found:
    mov  eax,edi                ; EAX = 일치 위치
    cmp  eax,eax                ; ZF = 1
Done:
    ret                         ; (USES의 pop은 플래그를 바꾸지 않음)
Str_find ENDP

END main
