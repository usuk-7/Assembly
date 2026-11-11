; Ch8 Programming Exercise 4. FindThrees Procedure
;
; Create a procedure named FindThrees that returns 1 if an array has three consecutive values of
; 3 somewhere in the array. Otherwise, return 0. The procedure's input parameter list contains a
; pointer to the array and the array's size. Use the PROC directive with a parameter list when
; declaring the procedure. Preserve all registers (except EAX) that are modified by the procedure.
; Write a test program that calls FindThrees several times with different arrays.

INCLUDE Irvine32.inc

FindThrees PROTO, pArray:PTR SDWORD, arraySize:DWORD

.data
arr1 SDWORD 1, 3, 3, 3, 5               ; 있음 → 1
arr2 SDWORD 3, 3, 1, 3, 3               ; 없음 → 0
arr3 SDWORD 7, 8, 3, 3                  ; 3이 두 개뿐 → 0
arr4 SDWORD 3, 3, 3                     ; 배열 전체 → 1
arr5 SDWORD 2, 3, 3, 4, 3, 3, 3, 3      ; 뒤쪽에 있음 → 1
msg  BYTE "FindThrees returned: ",0

.code
main PROC
    INVOKE FindThrees, ADDR arr1, LENGTHOF arr1
    call ShowResult
    INVOKE FindThrees, ADDR arr2, LENGTHOF arr2
    call ShowResult
    INVOKE FindThrees, ADDR arr3, LENGTHOF arr3
    call ShowResult
    INVOKE FindThrees, ADDR arr4, LENGTHOF arr4
    call ShowResult
    INVOKE FindThrees, ADDR arr5, LENGTHOF arr5
    call ShowResult
    exit
main ENDP

;--------------------------------------------------------
ShowResult PROC
; EAX 값을 출력
;--------------------------------------------------------
    push edx
    mov  edx,OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    pop  edx
    ret
ShowResult ENDP

;--------------------------------------------------------
FindThrees PROC USES ecx edx esi,
    pArray:PTR SDWORD,
    arraySize:DWORD
; 배열에 3이 연속 세 번 나오면 EAX = 1, 아니면 EAX = 0
; 방법: 연속된 3의 개수(EDX)를 세다가 3이 아닌 값을 만나면 0으로 리셋
;--------------------------------------------------------
    mov  esi,pArray
    mov  ecx,arraySize
    mov  edx,0                      ; 연속된 3의 개수
    mov  eax,0                      ; 기본 반환값 0
    jecxz Done
L1: cmp  SDWORD PTR [esi],3
    jne  Reset
    inc  edx                        ; 3이면 개수 증가
    cmp  edx,3
    je   Found                      ; 세 개 연속 → 성공
    jmp  Next
Reset:
    mov  edx,0                      ; 연속이 끊기면 리셋
Next:
    add  esi,TYPE SDWORD
    loop L1
    jmp  Done
Found:
    mov  eax,1
Done:
    ret
FindThrees ENDP

END main
