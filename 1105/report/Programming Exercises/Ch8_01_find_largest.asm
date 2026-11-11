; Ch8 Programming Exercise 1. FindLargest Procedure
;
; Create a procedure named FindLargest that receives two parameters: a pointer to a signed
; doubleword array, and a count of the array's length. The procedure must return the value of
; the largest array member in EAX. Use the PROC directive with a parameter list when declaring
; the procedure. Preserve all registers (except EAX) that are modified by the procedure.
; Write a test program that calls FindLargest and passes three different arrays of different
; lengths. Be sure to include negative values in your arrays. Create a PROTO declaration for
; FindLargest.

INCLUDE Irvine32.inc

; 프로토타입: INVOKE보다 먼저 선언해야 함
FindLargest PROTO,
    pArray:PTR SDWORD,          ; 배열 포인터
    count:DWORD                 ; 배열 길이

.data
array1 SDWORD 5, -3, 17, 8, -20
array2 SDWORD -50, -12, -7, -99, -1, -33, -8
array3 SDWORD 1000, -2000, 300, 4500, -6000, 4499, 12, -1, 0, 4400
msg    BYTE "Largest value: ",0

.code
main PROC
    INVOKE FindLargest, ADDR array1, LENGTHOF array1
    call ShowResult                 ; 17

    INVOKE FindLargest, ADDR array2, LENGTHOF array2
    call ShowResult                 ; -1 (모두 음수인 배열)

    INVOKE FindLargest, ADDR array3, LENGTHOF array3
    call ShowResult                 ; 4500
    exit
main ENDP

;--------------------------------------------------------
ShowResult PROC
; EAX에 담긴 결과를 메시지와 함께 출력
;--------------------------------------------------------
    push edx
    mov  edx,OFFSET msg
    call WriteString
    call WriteInt                   ; 부호 있는 정수 출력
    call Crlf
    pop  edx
    ret
ShowResult ENDP

;--------------------------------------------------------
FindLargest PROC USES ecx esi,
    pArray:PTR SDWORD,              ; [ebp+8]
    count:DWORD                     ; [ebp+12]
; 부호 있는 더블워드 배열에서 최댓값을 찾는다.
; Returns: EAX = 최댓값 (count = 0이면 EAX = 80000000h, 최소 정수)
;--------------------------------------------------------
    mov  esi,pArray                 ; 배열 시작 주소
    mov  ecx,count
    mov  eax,80000000h              ; 가장 작은 SDWORD로 초기화
    jecxz L3                        ; 길이 0이면 바로 종료
L1: cmp  [esi],eax                  ; 현재 원소 vs 현재 최댓값
    jle  L2                         ; 부호 있는 비교: 작거나 같으면 건너뜀
    mov  eax,[esi]                  ; 더 크면 최댓값 갱신
L2: add  esi,TYPE SDWORD            ; 다음 원소
    loop L1
L3: ret                             ; PROC가 RET 8 생성
FindLargest ENDP

END main
