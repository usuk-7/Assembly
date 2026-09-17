; Ch3 Programming Exercise 4: Symbolic Text Constants
; Write a program that defines symbolic names for several string literals
; (characters between quotes). Use each symbolic name in a variable
; definition.

INCLUDE Irvine32.inc

; TEXTEQU를 이용해 문자열 리터럴에 기호 이름을 붙인다
GREETING TEXTEQU <"Hello, Assembly!">
FAREWELL TEXTEQU <"Goodbye!">
AUTHOR   TEXTEQU <"Usuk">

.data
; 위에서 정의한 기호 텍스트 상수를 실제 변수 정의에 사용
greetMsg  BYTE GREETING, 0
byeMsg    BYTE FAREWELL, 0
authorMsg BYTE AUTHOR, 0

.code
main PROC
    mov edx, OFFSET greetMsg
    call WriteString
    call Crlf

    mov edx, OFFSET byeMsg
    call WriteString
    call Crlf

    mov edx, OFFSET authorMsg
    call WriteString
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
