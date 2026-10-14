; Ch5 Programming Exercise 10. Fibonacci Generator
; Write a procedure that produces N values in the Fibonacci number series and stores them in an
; array of doubleword. Input parameters should be a pointer to an array of doubleword, a
; counter of the number of values to generate. Write a test program that calls your procedure,
; passing N = 47. The first value in the array will be 1, and the last value will be 2,971,215,073.
; Use the Visual Studio debugger to open and inspect the array contents.

INCLUDE Irvine32.inc

FIB_COUNT = 47

.data
fibArray DWORD FIB_COUNT DUP(?)

.code
main PROC
    mov  esi,OFFSET fibArray        ; 배열 주소
    mov  ecx,FIB_COUNT              ; 생성 개수 N
    call FibGenerator

    ; 확인용 출력 (디버거로 fibArray를 봐도 됨)
    mov  esi,OFFSET fibArray
    mov  ecx,FIB_COUNT
L1:
    mov  eax,[esi]
    call WriteDec                   ; 부호 없는 값 (마지막 2971215073)
    call Crlf
    add  esi,TYPE fibArray
    loop L1
    exit
main ENDP

;---------------------------------------
; FibGenerator: 피보나치 수 N개를 배열에 저장
; Receives: ESI = DWORD 배열 주소, ECX = N
; 수열: 1, 1, 2, 3, 5, ...
;---------------------------------------
FibGenerator PROC USES eax ebx ecx edx esi
    mov  eax,1                      ; 현재 값 F(n)
    mov  ebx,0                      ; 이전 값 F(n-1)
L1:
    mov  [esi],eax                  ; 현재 값 저장
    mov  edx,eax                    ; 현재 값 임시 보관
    add  eax,ebx                    ; 다음 값 = 현재 + 이전
    mov  ebx,edx                    ; 이전 ← 현재
    add  esi,TYPE DWORD
    loop L1
    ret
FibGenerator ENDP

END main
