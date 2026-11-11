; Ch8 Programming Exercise 2. Chess Board
;
; Write a program that draws an 8 x 8 chess board, with alternating gray and white squares. You
; can use the SetTextColor and Gotoxy procedures from the Irvine32 library. Avoid the use of
; global variables, and use declared parameters in all procedures. Use short procedures that are
; focused on a single task.

INCLUDE Irvine32.inc

DrawSquare PROTO, row:DWORD, col:DWORD, bkColor:DWORD
DrawRow    PROTO, row:DWORD, darkColor:DWORD
DrawBoard  PROTO, darkColor:DWORD

SQUARE_WIDTH = 4                    ; 한 칸의 가로 문자 수 (세로 1줄과 비율 맞춤)

.code
main PROC
    call Clrscr
    INVOKE DrawBoard, gray          ; 회색/흰색 체스판 그리기

    ; 색을 기본(흰 글자/검은 배경)으로 되돌리고 체스판 아래로 커서 이동
    mov  eax,lightGray + (black * 16)
    call SetTextColor
    mov  dh,9                       ; row
    mov  dl,0                       ; column
    call Gotoxy
    call WaitMsg
    exit
main ENDP

;--------------------------------------------------------
DrawBoard PROC USES ecx,
    darkColor:DWORD                 ; 짙은 칸의 배경색
; 8개의 행을 차례로 그린다.
;--------------------------------------------------------
    mov  ecx,0                      ; row = 0
L1: INVOKE DrawRow, ecx, darkColor
    inc  ecx
    cmp  ecx,8
    jb   L1
    ret
DrawBoard ENDP

;--------------------------------------------------------
DrawRow PROC USES eax ecx,
    row:DWORD,                      ; 행 번호 0~7
    darkColor:DWORD
; 한 행의 8칸을 그린다. (row + col)이 홀수면 짙은 칸, 짝수면 흰 칸.
;--------------------------------------------------------
    mov  ecx,0                      ; col = 0
L1: mov  eax,row
    add  eax,ecx                    ; row + col
    test eax,1                      ; 홀짝 검사
    jz   LightSq
    mov  eax,darkColor              ; 홀수: 짙은 칸
    jmp  Draw
LightSq:
    mov  eax,white                  ; 짝수: 흰 칸
Draw:
    INVOKE DrawSquare, row, ecx, eax
    inc  ecx
    cmp  ecx,8
    jb   L1
    ret
DrawRow ENDP

;--------------------------------------------------------
DrawSquare PROC USES eax ecx edx,
    row:DWORD,                      ; 행 번호
    col:DWORD,                      ; 열 번호
    bkColor:DWORD                   ; 칸의 배경색
; 지정 위치에 배경색이 칠해진 칸 하나(공백 SQUARE_WIDTH개)를 출력한다.
;--------------------------------------------------------
    ; SetTextColor: EAX = foreground + (background * 16)
    mov  eax,bkColor
    shl  eax,4                      ; 배경색 * 16
    add  eax,black                  ; 글자색은 의미 없음(공백 출력)
    call SetTextColor

    ; Gotoxy: DH = 행, DL = 열(화면 문자 단위)
    mov  eax,col
    imul eax,SQUARE_WIDTH           ; 칸 너비만큼 열 위치 계산
    mov  dl,al
    mov  eax,row
    mov  dh,al
    call Gotoxy

    mov  ecx,SQUARE_WIDTH
    mov  al,' '
L1: call WriteChar                  ; 공백으로 칸을 채움
    loop L1
    ret
DrawSquare ENDP

END main
