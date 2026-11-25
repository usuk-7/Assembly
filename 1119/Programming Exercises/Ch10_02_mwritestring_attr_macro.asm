; Ch10 Programming Exercise 2. mWritestringAttr Macro
;
; (Requires reading ahead to Section 11.1.11.) Create a macro that writes a null-terminated string to
; the console with a given text color. The macro parameters should include the string name and the
; color. Hint: Call SetTextColor from the book's link library. Write a program that tests your macro
; with several strings in different colors. Sample call:
;     .data
;     myString db "Here is my string",0
;     .code
;     mWritestring myString, white

INCLUDE Irvine32.inc

DEFAULT_COLOR = lightGray + (black * 16)     ; 기본 콘솔 색 (회색 글자/검정 배경)

;--------------------------------------------------------
mWritestringAttr MACRO strName:REQ, color:REQ
;
; null 종료 문자열을 지정한 색으로 출력하고 원래 색으로 되돌린다.
; strName: 문자열 변수 이름, color: 글자색(+배경색*16)
;--------------------------------------------------------
    push eax
    push edx
    mov  eax,color                  ;; SetTextColor: EAX = 색상
    call SetTextColor
    mov  edx,OFFSET strName         ;; WriteString: EDX = 문자열 주소
    call WriteString
    mov  eax,DEFAULT_COLOR          ;; 색 복구
    call SetTextColor
    pop  edx
    pop  eax
ENDM

.data
myString BYTE "Here is my string",0
str2     BYTE "This line is yellow",0
str3     BYTE "This line is light red",0
str4     BYTE "Blue text on white background",0

.code
main PROC
    mWritestringAttr myString, white
    call Crlf
    mWritestringAttr str2, yellow
    call Crlf
    mWritestringAttr str3, lightRed
    call Crlf
    mWritestringAttr str4, <blue + (white * 16)>   ; 식은 < >로 묶어 한 인자로 전달
    call Crlf
    exit
main ENDP
END main
