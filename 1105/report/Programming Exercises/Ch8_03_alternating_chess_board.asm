; Ch8 Programming Exercise 3. Chess Board with Alternating Colors
;
; This exercise extends Exercise 2. Every 500 milliseconds, change the color of the colored
; squares and redisplay the board. Continue until you have shown the board 16 times, using all
; possible 4-bit background colors. (The white squares remain white throughout.)

INCLUDE Irvine32.inc

DrawSquare PROTO, row:DWORD, col:DWORD, bkColor:DWORD
DrawRow    PROTO, row:DWORD, darkColor:DWORD
DrawBoard  PROTO, darkColor:DWORD

SQUARE_WIDTH = 4

.code
main PROC
    call Clrscr
    mov  ecx,0                      ; 배경색 0~15
L1: INVOKE DrawBoard, ecx           ; 색칠된 칸을 현재 색으로 다시 그림
    mov  eax,500
    call Delay                      ; 500ms 대기
    inc  ecx
    cmp  ecx,16                     ; 16가지 색을 모두 보여줄 때까지
    jb   L1

    mov  eax,lightGray + (black * 16)   ; 기본 색 복원
    call SetTextColor
    mov  dh,9
    mov  dl,0
    call Gotoxy
    call WaitMsg
    exit
main ENDP

;--------------------------------------------------------
DrawBoard PROC USES ecx,
    darkColor:DWORD                 ; 색칠된 칸의 배경색
;--------------------------------------------------------
    mov  ecx,0
L1: INVOKE DrawRow, ecx, darkColor
    inc  ecx
    cmp  ecx,8
    jb   L1
    ret
DrawBoard ENDP

;--------------------------------------------------------
DrawRow PROC USES eax ecx,
    row:DWORD,
    darkColor:DWORD
; (row + col)이 홀수인 칸은 darkColor, 짝수인 칸은 항상 white
;--------------------------------------------------------
    mov  ecx,0
L1: mov  eax,row
    add  eax,ecx
    test eax,1
    jz   LightSq
    mov  eax,darkColor
    jmp  Draw
LightSq:
    mov  eax,white                  ; 흰 칸은 계속 흰색 유지
Draw:
    INVOKE DrawSquare, row, ecx, eax
    inc  ecx
    cmp  ecx,8
    jb   L1
    ret
DrawRow ENDP

;--------------------------------------------------------
DrawSquare PROC USES eax ecx edx,
    row:DWORD,
    col:DWORD,
    bkColor:DWORD
; 지정 위치에 배경색 칸 하나를 출력
;--------------------------------------------------------
    mov  eax,bkColor
    shl  eax,4                      ; background * 16
    call SetTextColor               ; 글자색 black(0)

    mov  eax,col
    imul eax,SQUARE_WIDTH
    mov  dl,al                      ; DL = 열
    mov  eax,row
    mov  dh,al                      ; DH = 행
    call Gotoxy

    mov  ecx,SQUARE_WIDTH
    mov  al,' '
L1: call WriteChar
    loop L1
    ret
DrawSquare ENDP

END main
