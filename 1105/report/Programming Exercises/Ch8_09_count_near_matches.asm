; Ch8 Programming Exercise 9. Counting Nearly Matching Elements
;
; Write a procedure named CountNearMatches that receives pointers to two arrays of signed dou-
; blewords, a parameter that indicates the length of the two arrays, and a parameter that indicates the
; maximum allowed difference (called diff) between any two matching elements. For each element
; xi in the first array, if the difference between it and the corresponding yi in the second array is less
; than or equal to diff, increment a count. At the end, return a count of the number of nearly match-
; ing array elements in EAX. Write a test program that calls CountNearMatches and passes pointers
; to two different pairs of arrays. Use the INVOKE statement to call your procedure and pass stack
; parameters. Create a PROTO declaration for CountMatches. Save and restore any registers (other
; than EAX) changed by your procedure.

INCLUDE Irvine32.inc

CountNearMatches PROTO,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    count:DWORD,
    diff:DWORD

.data
; 첫 번째 쌍, diff = 2 → |차이| = 0,3,2,1,10 → 3개
x1 SDWORD  5, -4, 10,  0, 100
y1 SDWORD  5, -1,  8, -1,  90
; 두 번째 쌍, diff = 5 → |차이| = 5,6,0,4,20,5 → 4개
x2 SDWORD -10, 20, 7, -3,  50, 0
y2 SDWORD  -5, 14, 7,  1,  30, -5
msg BYTE "Nearly matching elements: ",0

.code
main PROC
    INVOKE CountNearMatches, ADDR x1, ADDR y1, LENGTHOF x1, 2
    call ShowResult                 ; 3
    INVOKE CountNearMatches, ADDR x2, ADDR y2, LENGTHOF x2, 5
    call ShowResult                 ; 4
    exit
main ENDP

;--------------------------------------------------------
ShowResult PROC
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
CountNearMatches PROC USES ebx ecx edx esi edi,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    count:DWORD,
    diff:DWORD
; |x[i] - y[i]| <= diff 인 원소 개수를 EAX로 반환
;--------------------------------------------------------
    mov  esi,pArr1
    mov  edi,pArr2
    mov  ecx,count
    mov  eax,0                      ; 개수
    jecxz Done
L1: mov  ebx,[esi]
    sub  ebx,[edi]                  ; EBX = x[i] - y[i]
    jns  Compare                    ; 음수가 아니면 그대로
    neg  ebx                        ; 음수면 절댓값으로
Compare:
    cmp  ebx,diff
    ja   Next                       ; |차이| > diff 이면 건너뜀 (절댓값이므로 부호 없는 비교)
    inc  eax
Next:
    add  esi,TYPE SDWORD
    add  edi,TYPE SDWORD
    loop L1
Done:
    ret                             ; PROC가 RET 16 생성
CountNearMatches ENDP

END main
