; Ch4 Programming Exercise 7: Copy a String in Reverse Order
; Write a program with a loop and indirect addressing that copies a string from
; source to target, reversing the character order in the process. Use the
; following variables:
;   source BYTE "This is the source string",0
;   target BYTE SIZEOF source DUP('#')

INCLUDE Irvine32.inc

.data
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')

.code
main PROC
    mov esi, OFFSET source + SIZEOF source - 2   ; source의 마지막 문자 (널 문자 앞)
    mov edi, OFFSET target                       ; target의 시작
    mov ecx, SIZEOF source - 1                   ; 널 제외한 문자 개수

L1:
    mov al, [esi]                        ; 뒤에서부터 한 글자 읽기
    mov [edi], al                        ; 앞에서부터 쓰기
    dec esi
    inc edi
    loop L1

    mov BYTE PTR [edi], 0                ; target 끝에 널 문자

    ; 결과 출력: gnirts ecruos eht si sihT
    mov edx, OFFSET target
    call WriteString
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
