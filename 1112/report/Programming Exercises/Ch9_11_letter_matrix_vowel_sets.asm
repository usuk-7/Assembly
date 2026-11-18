; Ch9 Programming Exercise 11. Letter Matrix/Sets with Vowels
;
; Use the letter matrix generated in the previous programming exercise as a starting point for this
; program. Generate a single random four-by-four letter matrix in which each letter has a 50% prob-
; ability of being a vowel. Traverse each matrix row, column, and diagonal, generating sets of letters.
; Display only four-letter sets containing exactly two vowels. Suppose, for example, the following
; matrix was generated:
;     P O A Z
;     A E A U
;     G K A E
;     I A G D
; Then the four-letter sets displayed by the program would be POAZ, GKAE, IAGD, PAGI,
; ZUED, PEAD, and ZAKI. The order of letters within each set is unimportant.

INCLUDE Irvine32.inc

N = 4                           ; 4x4

.data
vowels     BYTE "AEIOU"
consonants BYTE "BCDFGHJKLMNPQRSTVWXYZ"
sample     BYTE "POAZ","AEAU","GKAE","IAGD"   ; 문제의 예시 행렬 (검증용)
matrix     BYTE N*N DUP(?)
setBuf     BYTE N DUP(?),0      ; 추출한 4글자 집합 + null
msgSample  BYTE "[Sample matrix]",0dh,0ah,0
msgRandom  BYTE "[Random matrix]",0dh,0ah,0
msgSets    BYTE "Sets with exactly two vowels: ",0

.code
main PROC
    ; 1) 문제의 예시 행렬로 결과 확인 → POAZ GKAE IAGD PAGI ZUED PEAD ZAKI
    mov  edx,OFFSET msgSample
    call WriteString
    mov  esi,OFFSET sample
    call ProcessMatrix
    call Crlf

    ; 2) 무작위 행렬 하나 생성 후 처리
    call Randomize
    mov  edx,OFFSET msgRandom
    call WriteString
    mov  esi,OFFSET matrix
    call GenLetterMatrix
    call ProcessMatrix
    exit
main ENDP

;--------------------------------------------------------
ProcessMatrix PROC USES eax ebx ecx
; ESI = 행렬. 행렬 출력 후 행/열/대각선 집합 검사
;--------------------------------------------------------
    call ShowMatrix
    mov  edx,OFFSET msgSets
    call WriteString

    ; 행: 시작 = r*N, 간격 1
    mov  ecx,0
Rows:
    mov  eax,ecx
    imul eax,N                  ; 행 시작 인덱스
    mov  ebx,1                  ; 간격
    call CheckSet
    inc  ecx
    cmp  ecx,N
    jb   Rows

    ; 열: 시작 = c, 간격 N
    mov  ecx,0
Cols:
    mov  eax,ecx
    mov  ebx,N
    call CheckSet
    inc  ecx
    cmp  ecx,N
    jb   Cols

    ; 주대각선: 시작 0, 간격 N+1 / 반대 대각선: 시작 N-1, 간격 N-1
    mov  eax,0
    mov  ebx,N+1
    call CheckSet
    mov  eax,N-1
    mov  ebx,N-1
    call CheckSet
    call Crlf
    ret
ProcessMatrix ENDP

;--------------------------------------------------------
CheckSet PROC USES eax ebx ecx edx edi
; ESI = 행렬, EAX = 시작 인덱스, EBX = 간격
; matrix[EAX + k*EBX] (k=0..3)를 setBuf에 모으고,
; 모음이 정확히 2개면 출력한다.
;--------------------------------------------------------
    mov  edi,0                  ; setBuf 인덱스 k
    mov  edx,0                  ; 모음 개수
L1: push eax
    mov  al,[esi + eax]         ; 해당 위치 글자
    mov  setBuf[edi],al
    call IsVowel                ; ZF = 1이면 모음
    jne  NotV
    inc  edx
NotV:
    pop  eax
    add  eax,ebx                ; 다음 위치
    inc  edi
    cmp  edi,N
    jb   L1
    cmp  edx,2                  ; 모음이 정확히 2개?
    jne  Done
    push edx
    mov  edx,OFFSET setBuf
    call WriteString
    mov  al,' '
    call WriteChar
    pop  edx
Done:
    ret
CheckSet ENDP

;--------------------------------------------------------
IsVowel PROC USES ecx edi
; AL = 문자. 모음이면 ZF = 1, 아니면 ZF = 0
; (SCASB로 모음 목록에서 AL 검색)
;--------------------------------------------------------
    mov  edi,OFFSET vowels
    mov  ecx,LENGTHOF vowels
    cld
    repne scasb                 ; 찾으면 ZF = 1로 멈춤
    ret
IsVowel ENDP

;--------------------------------------------------------
GenLetterMatrix PROC USES eax ecx edi
; ESI = 행렬. 각 글자 50% 확률로 모음 (연습문제 10과 동일)
;--------------------------------------------------------
    mov  edi,esi
    mov  ecx,N*N
    cld
L1: mov  eax,2
    call RandomRange            ; 0 또는 1
    cmp  eax,0
    jne  Consonant
    mov  eax,LENGTHOF vowels
    call RandomRange
    mov  al,vowels[eax]
    jmp  Store
Consonant:
    mov  eax,LENGTHOF consonants
    call RandomRange
    mov  al,consonants[eax]
Store:
    stosb
    loop L1
    ret
GenLetterMatrix ENDP

;--------------------------------------------------------
ShowMatrix PROC USES eax ebx ecx
; ESI = 행렬 출력
;--------------------------------------------------------
    mov  ebx,0                  ; 행 오프셋
R1: mov  ecx,0                  ; 열
C1: mov  al,[esi + ebx + ecx]
    call WriteChar
    mov  al,' '
    call WriteChar
    inc  ecx
    cmp  ecx,N
    jb   C1
    call Crlf
    add  ebx,N
    cmp  ebx,N*N
    jb   R1
    ret
ShowMatrix ENDP

END main
