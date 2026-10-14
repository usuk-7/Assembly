; Ch5 Programming Exercise 2. Linking Array Items
; Suppose you are given three data items that indicate a starting index in a list, an array of
; characters, and an array of link index. You are to write a program that traverses the links and
; locates the characters in their correct sequence. For each character you locate, copy it to a
; new array. Suppose you used the following sample data, and assumed the arrays use zero-based indexes:
;     start = 1
;     chars:   H  A  C  E  B  D  F  G
;     links:   0  4  5  6  2  3  7  0
; Then the values copied (in order) to the output array would be A,B,C,D,E,F,G,H. Declare the
; character array as type BYTE, and to make the problem more interesting, declare the links array
; type DWORD.

INCLUDE Irvine32.inc

.data
start  DWORD 1
chars  BYTE  'H','A','C','E','B','D','F','G'
links  DWORD 0,4,5,6,2,3,7,0
output BYTE  LENGTHOF chars DUP(?),0     ; 결과 배열 + 문자열 종료용 0

.code
main PROC
    call TraverseLinks
    mov  edx,OFFSET output
    call WriteString                     ; ABCDEFGH
    call Crlf
    exit
main ENDP

;---------------------------------------
; TraverseLinks: start부터 links를 따라가며
; chars의 문자를 output에 순서대로 복사
;---------------------------------------
TraverseLinks PROC USES eax ecx esi edi
    mov  ecx,LENGTHOF chars              ; 문자 개수만큼 반복
    mov  esi,start                       ; 현재 인덱스
    mov  edi,0                           ; output 인덱스
L1:
    mov  al,chars[esi]                   ; 현재 위치의 문자
    mov  output[edi],al                  ; 결과 배열에 복사
    inc  edi
    mov  esi,links[esi*4]                ; 다음 인덱스 (DWORD라 *4)
    loop L1
    ret
TraverseLinks ENDP

END main
