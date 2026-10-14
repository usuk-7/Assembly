; Ch5 Programming Exercise 8. Color Matrix
; Write a program that displays a single character in all possible combinations of foreground and
; background colors (16 x 16 = 256). The colors are numbered from 0 to 15, so you can use a
; nested loop to generate all possible combinations.

INCLUDE Irvine32.inc

.code
main PROC
    mov  ebx,0                      ; 배경색 0~15
    mov  ecx,16                     ; 바깥 루프: 배경색 16개
Outer:
    push ecx                        ; 바깥 루프 카운터 저장
    call ShowRow                    ; 한 배경색에 대해 전경색 16개 출력
    inc  ebx                        ; 다음 배경색
    pop  ecx
    loop Outer

    mov  eax,lightGray + (black*16) ; 기본 색 복구
    call SetTextColor
    exit
main ENDP

;---------------------------------------
; ShowRow: 배경색 EBX에서 전경색 0~15로
; 문자 하나씩 출력 후 줄바꿈
; Receives: EBX = 배경색
;---------------------------------------
ShowRow PROC USES eax ecx edi
    mov  edi,0                      ; 전경색 0~15
    mov  ecx,16                     ; 안쪽 루프
Inner:
    mov  eax,ebx
    shl  eax,4                      ; 배경색 * 16
    add  eax,edi                    ; + 전경색
    call SetTextColor
    mov  al,'A'
    call WriteChar
    inc  edi
    loop Inner

    mov  eax,lightGray + (black*16) ; 줄 끝은 기본 색으로
    call SetTextColor
    call Crlf
    ret
ShowRow ENDP

END main
