; Ch5 Programming Exercise 3. Simple Addition (1)
; Write a program that clears the screen, locates the cursor near the middle of the screen,
; prompts the user for two integers, adds the integers, and displays their sum.

INCLUDE Irvine32.inc

MID_ROW = 12                ; 화면 중앙 근처 행
MID_COL = 30                ; 화면 중앙 근처 열

.data
prompt1 BYTE "Enter the first integer:  ",0
prompt2 BYTE "Enter the second integer: ",0
sumMsg  BYTE "Sum: ",0

.code
main PROC
    call Clrscr                     ; 화면 지우기
    call AddTwoIntegers
    call Crlf
    exit
main ENDP

;---------------------------------------
; AddTwoIntegers: 화면 중앙에서 정수 2개를
; 입력받아 합을 출력
;---------------------------------------
AddTwoIntegers PROC USES eax ebx edx
    ; 첫 번째 정수 입력
    mov  dh,MID_ROW
    mov  dl,MID_COL
    call Gotoxy                     ; 커서 이동 (DH=행, DL=열)
    mov  edx,OFFSET prompt1
    call WriteString
    call ReadInt                    ; EAX = 입력값
    mov  ebx,eax                    ; 첫 값 보관

    ; 두 번째 정수 입력 (한 줄 아래)
    mov  dh,MID_ROW+1
    mov  dl,MID_COL
    call Gotoxy
    mov  edx,OFFSET prompt2
    call WriteString
    call ReadInt
    add  eax,ebx                    ; EAX = 합

    ; 합 출력
    mov  dh,MID_ROW+2
    mov  dl,MID_COL
    call Gotoxy
    mov  edx,OFFSET sumMsg
    call WriteString
    call WriteInt                   ; 부호 있는 정수 출력
    ret
AddTwoIntegers ENDP

END main
