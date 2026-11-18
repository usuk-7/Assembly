; Ch9 Programming Exercise 10. Letter Matrix
;
; Create a procedure that generates a four-by-four matrix of randomly chosen capital letters.
; When choosing the letters, there must be a 50% probability that the chosen letter is a vowel.
; Write a test program with a loop that calls your procedure five times and displays each matrix in
; the console window. Following is sample output for the first three matrices:
;     D W A L      K X S V      P O A Z
;     S I V W      N U U O      A E A U
;     U I O L      O R Q O      G K A E
;     L A I I      A U U T      I A G D

INCLUDE Irvine32.inc

ROWS = 4
COLS = 4

.data
vowels     BYTE "AEIOU"
consonants BYTE "BCDFGHJKLMNPQRSTVWXYZ"
matrix     BYTE ROWS*COLS DUP(?)

.code
main PROC
    call Randomize              ; 난수 시드 초기화
    mov  ecx,5                  ; 행렬 5개
L1: push ecx
    mov  esi,OFFSET matrix
    call GenLetterMatrix        ; 행렬 생성
    call ShowMatrix             ; 출력
    call Crlf
    pop  ecx
    loop L1
    exit
main ENDP

;--------------------------------------------------------
GenLetterMatrix PROC USES eax ecx edi
; 4x4 행렬을 대문자로 채운다. 각 글자는 50% 확률로 모음.
; Receives: ESI = 행렬(16바이트) 주소
;--------------------------------------------------------
    mov  edi,esi
    mov  ecx,ROWS*COLS          ; 16칸
    cld
L1: mov  eax,2
    call RandomRange            ; EAX = 0 또는 1 (각 50%)
    cmp  eax,0
    jne  Consonant
    mov  eax,LENGTHOF vowels    ; 모음 5개 중 하나
    call RandomRange
    mov  al,vowels[eax]
    jmp  Store
Consonant:
    mov  eax,LENGTHOF consonants ; 자음 21개 중 하나
    call RandomRange
    mov  al,consonants[eax]
Store:
    stosb                       ; [EDI] = AL, EDI++
    loop L1
    ret
GenLetterMatrix ENDP

;--------------------------------------------------------
ShowMatrix PROC USES eax ebx ecx esi
; Receives: ESI = 행렬 주소. 행 단위로 "A B C D" 형식 출력
;--------------------------------------------------------
    mov  ebx,0                  ; 행 오프셋
R1: mov  ecx,0                  ; 열 인덱스
C1: mov  al,[esi + ebx + ecx]   ; matrix[row][col] (ESI+행 오프셋+열)
    call WriteChar
    mov  al,' '
    call WriteChar
    inc  ecx
    cmp  ecx,COLS
    jb   C1
    call Crlf
    add  ebx,COLS               ; 다음 행
    cmp  ebx,ROWS*COLS
    jb   R1
    ret
ShowMatrix ENDP

END main
