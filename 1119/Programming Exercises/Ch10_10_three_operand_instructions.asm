; Ch10 Programming Exercise 10. Three-Operand Instructions
;
; Some computer instruction sets permit arithmetic instructions with three operands. Such opera-
; tions sometimes appear in simple virtual assemblers used to introduce students to the concept of
; assembly language or using intermediate language in compilers. In the following macros,
; assume EAX is reserved for macro operations and is not preserved. Other registers modified by
; the macro must be preserved. All parameters are signed memory doublewords. Write macros
; that simulate the following operations:
;   a. add3 destination, source1, source2
;   b. sub3 destination, source1, source2 (destination = source1 - source2)
;   c. mul3 destination, source1, source2
;   d. div3 destination, source1, source2 (destination = source1 / source2)
; For example, the following macro calls implement the expression x = (w + y) * z:
;     .data
;     temp DWORD ?
;     .code
;     add3 temp, w, y        ; temp = w + y
;     mul3 x, temp, z        ; x = temp * z
; Write a program that tests your macros by implementing four arithmetic expressions, each
; involving multiple operations.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;--------------------------------------------------------
; 모든 매크로: EAX는 작업용(보존 안 함), 나머지는 보존
;--------------------------------------------------------
add3 MACRO dest:REQ, src1:REQ, src2:REQ
    mov  eax,src1
    add  eax,src2               ;; EAX = src1 + src2
    mov  dest,eax
ENDM

sub3 MACRO dest:REQ, src1:REQ, src2:REQ
    mov  eax,src1
    sub  eax,src2               ;; EAX = src1 - src2
    mov  dest,eax
ENDM

mul3 MACRO dest:REQ, src1:REQ, src2:REQ
    mov  eax,src1
    imul eax,src2               ;; 2-피연산자 IMUL: EDX를 건드리지 않음 (부호 있는 곱)
    mov  dest,eax
ENDM

div3 MACRO dest:REQ, src1:REQ, src2:REQ
    push edx                    ;; IDIV가 EDX를 바꾸므로 보존
    mov  eax,src1
    cdq                         ;; EAX 부호를 EDX로 확장 → EDX:EAX
    idiv src2                   ;; EAX = 몫, EDX = 나머지
    mov  dest,eax
    pop  edx
ENDM

;--------------------------------------------------------
mShowResult MACRO msg, var
; "msg 값" 출력 (부호 있는 10진수)
;--------------------------------------------------------
    mWrite msg
    mov  eax,var
    call WriteInt
    call Crlf
ENDM

.data
w     SDWORD 10
y     SDWORD 5
z     SDWORD 3
v     SDWORD -4
x     SDWORD ?
temp  SDWORD ?
temp2 SDWORD ?

.code
main PROC
    ; 1) x = (w + y) * z  = (10 + 5) * 3 = 45
    add3 temp, w, y
    mul3 x, temp, z
    mShowResult "x = (w + y) * z       = ", x

    ; 2) x = (w - y) / z  = (10 - 5) / 3 = 1
    sub3 temp, w, y
    div3 x, temp, z
    mShowResult "x = (w - y) / z       = ", x

    ; 3) x = w * y - z * v  = 50 - (-12) = 62
    mul3 temp, w, y
    mul3 temp2, z, v
    sub3 x, temp, temp2
    mShowResult "x = w * y - z * v     = ", x

    ; 4) x = (w + v) * (y - z) / v  = 6 * 2 / -4 = -3
    add3 temp, w, v
    sub3 temp2, y, z
    mul3 temp, temp, temp2
    div3 x, temp, v
    mShowResult "x = (w+v)*(y-z) / v   = ", x
    exit
main ENDP
END main
