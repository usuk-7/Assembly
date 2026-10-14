; Ch5 Programming Exercise 7. Random Screen Locations
; Write a program that displays a single character at 100 random screen locations, using a timing
; delay of 100 milliseconds. Hint: Use the GetMaxXY procedure to determine the current size of
; the console window.

INCLUDE Irvine32.inc

.data
rows BYTE ?                         ; 콘솔 행 수
cols BYTE ?                         ; 콘솔 열 수

.code
main PROC
    call Randomize
    call Clrscr
    call GetMaxXY                   ; AX = 행 수, DX = 열 수
    mov  rows,al
    mov  cols,dl

    mov  ecx,100                    ; 100개 위치
L1:
    call ShowRandomChar
    mov  eax,100                    ; 100ms 지연
    call Delay
    loop L1

    mov  dh,rows                    ; 커서를 맨 아래로 옮겨 마무리
    dec  dh
    mov  dl,0
    call Gotoxy
    exit
main ENDP

;---------------------------------------
; ShowRandomChar: 무작위 위치에 '*' 출력
;---------------------------------------
ShowRandomChar PROC USES eax edx
    movzx eax,cols
    call RandomRange                ; 0 ~ cols-1
    mov  dl,al                      ; 열
    movzx eax,rows
    call RandomRange                ; 0 ~ rows-1
    mov  dh,al                      ; 행
    call Gotoxy
    mov  al,'*'
    call WriteChar
    ret
ShowRandomChar ENDP

END main
