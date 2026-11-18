; Ch9 Programming Exercise 12. Calculating the Sum of an Array Row
;
; Write a procedure named calc_row_sum that calculates the sum of a single row in a two-dimensional
; array of bytes, words, or doublewords. The procedure should have the following stack parame-
; ters: array offset, row size, array type, row index. It must return the sum in EAX. Use explicit
; stack parameters, not INVOKE or extended PROC. Write a program that tests your procedure
; with arrays of byte, word, and doubleword. Prompt the user for the row index, and display the
; sum of the selected row.

INCLUDE Irvine32.inc

NUM_ROWS = 3
NUM_COLS = 4                    ; row size = 한 행의 원소 개수

.data
tableB BYTE   10,  20,  30,  40
       BYTE   50,  60,  70,  80
       BYTE   90, 100, 110, 120
tableW WORD  100, 200, 300, 400
       WORD  500, 600, 700, 800
       WORD  900,1000,1100,1200
tableD DWORD 1000, 2000, 3000, 4000
       DWORD 5000, 6000, 7000, 8000
       DWORD 9000,10000,11000,12000

prompt  BYTE "Enter a row index (0-2): ",0
msgErr  BYTE "Invalid row index.",0
msgB    BYTE "Byte  table row sum: ",0
msgW    BYTE "Word  table row sum: ",0
msgD    BYTE "Dword table row sum: ",0
rowIdx  DWORD ?

.code
main PROC
    mov  edx,OFFSET prompt
    call WriteString
    call ReadDec                ; EAX = 행 번호 (부호 없는 정수)
    cmp  eax,NUM_ROWS
    jb   Valid
    mov  edx,OFFSET msgErr
    call WriteString
    call Crlf
    exit
Valid:
    mov  rowIdx,eax

    ; 매개변수는 오른쪽부터 push: row index, type, row size, offset
    push rowIdx                 ; [ebp+20] row index
    push TYPE tableB            ; [ebp+16] array type (1)
    push NUM_COLS               ; [ebp+12] row size
    push OFFSET tableB          ; [ebp+8]  array offset
    call calc_row_sum
    mov  edx,OFFSET msgB
    call ShowSum

    push rowIdx
    push TYPE tableW            ; 2
    push NUM_COLS
    push OFFSET tableW
    call calc_row_sum
    mov  edx,OFFSET msgW
    call ShowSum

    push rowIdx
    push TYPE tableD            ; 4
    push NUM_COLS
    push OFFSET tableD
    call calc_row_sum
    mov  edx,OFFSET msgD
    call ShowSum
    exit
main ENDP

;--------------------------------------------------------
ShowSum PROC
; EDX = 메시지, EAX = 합계
;--------------------------------------------------------
    call WriteString
    call WriteDec
    call Crlf
    ret
ShowSum ENDP

;--------------------------------------------------------
; calc_row_sum
; 2차원 배열(byte/word/dword)의 한 행의 합을 구한다.
; Stack parameters (STDCALL, 호출된 쪽이 ret 16으로 정리):
;   [ebp+8]  = array offset
;   [ebp+12] = row size (한 행의 원소 개수)
;   [ebp+16] = array type (1, 2, 4)
;   [ebp+20] = row index
; Returns: EAX = 행의 합 (부호 없는 값으로 더함)
;--------------------------------------------------------
arrOffset EQU <DWORD PTR [ebp+8]>
rowSize   EQU <DWORD PTR [ebp+12]>
arrType   EQU <DWORD PTR [ebp+16]>
rowIndex  EQU <DWORD PTR [ebp+20]>

calc_row_sum PROC
    push ebp                    ; 스택 프레임 생성
    mov  ebp,esp
    push ebx
    push ecx
    push edx
    push esi

    ; 행 시작 주소 = offset + rowIndex * rowSize * type
    mov  eax,rowIndex
    mul  rowSize                ; EAX = rowIndex * rowSize
    mul  arrType                ; EAX = 바이트 오프셋 (EDX 무시)
    mov  ebx,arrOffset
    add  ebx,eax                ; EBX = 행 시작 주소

    mov  ecx,rowSize            ; 원소 개수만큼 반복
    mov  esi,arrType            ; ESI = 원소 크기 (포인터 증가량)
    mov  eax,0                  ; 합계
L1: cmp  esi,1
    je   IsByte
    cmp  esi,2
    je   IsWord
    add  eax,[ebx]              ; DWORD
    jmp  Next
IsByte:
    movzx edx,BYTE PTR [ebx]    ; BYTE → 32비트 확장
    add  eax,edx
    jmp  Next
IsWord:
    movzx edx,WORD PTR [ebx]    ; WORD → 32비트 확장
    add  eax,edx
Next:
    add  ebx,esi                ; 다음 원소
    loop L1

    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  ebp
    ret  16                     ; 매개변수 4개(16바이트) 정리
calc_row_sum ENDP

END main
