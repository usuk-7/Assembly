; Ch5 Programming Exercise 4. Simple Addition (2)
; Use the solution program from the preceding exercise as a starting point. Let this new program
; repeat the same steps three times, using a loop. Clear the screen after each loop iteration.

INCLUDE Irvine32.inc

MID_ROW = 12
MID_COL = 30

.data
prompt1 BYTE "Enter the first integer:  ",0
prompt2 BYTE "Enter the second integer: ",0
sumMsg  BYTE "Sum: ",0

.code
main PROC
    mov  ecx,3                      ; 3번 반복
L1:
    call Clrscr
    call AddTwoIntegers
    call Crlf
    call Crlf
    call WaitMsg                    ; 결과 확인할 시간 ("Press any key...")
    call Clrscr                     ; 반복마다 화면 지우기
    loop L1
    exit
main ENDP

;---------------------------------------
; AddTwoIntegers: 화면 중앙에서 정수 2개를
; 입력받아 합을 출력 (ECX 등 레지스터 보존)
;---------------------------------------
AddTwoIntegers PROC USES eax ebx edx
    mov  dh,MID_ROW
    mov  dl,MID_COL
    call Gotoxy
    mov  edx,OFFSET prompt1
    call WriteString
    call ReadInt
    mov  ebx,eax                    ; 첫 값 보관

    mov  dh,MID_ROW+1
    mov  dl,MID_COL
    call Gotoxy
    mov  edx,OFFSET prompt2
    call WriteString
    call ReadInt
    add  eax,ebx                    ; 합

    mov  dh,MID_ROW+2
    mov  dl,MID_COL
    call Gotoxy
    mov  edx,OFFSET sumMsg
    call WriteString
    call WriteInt
    ret
AddTwoIntegers ENDP

END main
