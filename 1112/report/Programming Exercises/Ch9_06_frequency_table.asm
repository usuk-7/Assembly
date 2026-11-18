; Ch9 Programming Exercise 6. Constructing a Frequency Table
;
; Write a procedure named Get_frequencies that constructs a character frequency table. Input to
; the procedure should be a pointer to a string and a pointer to an array of 256 doublewords initial-
; ized to all zeros. Each array position is indexed by its corresponding ASCII code. When the pro-
; cedure returns, each entry in the array contains a count of how many times the corresponding
; character occurred in the string. For example,
;     .data
;     target BYTE "AAEBDCFBBC",0
;     freqTable DWORD 256 DUP(0)
;     .code
;     INVOKE Get_frequencies, ADDR target, ADDR freqTable
; Figure 9-6 shows a picture of the string and entries 41 (hexadecimal) through 4B in the fre-
; quency table. Position 41 contains the value 2 because the letter A (ASCII code 41h) occurred
; twice in the string. Similar counts are shown for other characters.

INCLUDE Irvine32.inc

Get_frequencies PROTO,
    pString:PTR BYTE,
    pTable:PTR DWORD

.data
target    BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
msgHead   BYTE "Index  Char  Count",0dh,0ah,0
sep       BYTE "h    ",0
sep2      BYTE "     ",0

.code
main PROC
    INVOKE Get_frequencies, ADDR target, ADDR freqTable

    ; Figure 9-6처럼 41h ~ 4Bh 항목 출력
    mov  edx,OFFSET msgHead
    call WriteString
    mov  esi,41h                ; 시작 인덱스
L1: mov  eax,esi
    mov  ebx,1                  ; 1바이트 16진수
    call WriteHexB
    mov  edx,OFFSET sep
    call WriteString
    mov  eax,esi                ; 문자 자체 출력 (AL = 하위 바이트)
    call WriteChar
    mov  edx,OFFSET sep2
    call WriteString
    mov  eax,freqTable[esi*4]   ; 빈도 값
    call WriteDec
    call Crlf
    inc  esi
    cmp  esi,4Bh
    jbe  L1
    exit
main ENDP

;--------------------------------------------------------
Get_frequencies PROC USES eax esi edi,
    pString:PTR BYTE,           ; 문자열
    pTable:PTR DWORD            ; 256개 DWORD 표 (0으로 초기화)
;
; 문자열의 각 문자 ASCII 코드를 인덱스로 표의 값을 1씩 증가
;--------------------------------------------------------
    mov  esi,pString
    mov  edi,pTable
    cld
L1: lodsb                       ; AL = 다음 문자
    cmp  al,0                   ; 문자열 끝?
    je   Done
    movzx eax,al                ; 인덱스로 쓰기 위해 32비트 확장
    inc  DWORD PTR [edi + eax*4]  ; table[code]++
    jmp  L1
Done:
    ret
Get_frequencies ENDP

END main
