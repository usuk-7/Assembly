; Ch8 Programming Exercise 8. Counting Matching Elements
;
; Write a procedure named CountMatches that receives points to two arrays of signed double-
; words, and a third parameter that indicates the length of the two arrays. For each element xi in
; the first array, if the corresponding yi in the second array is equal, increment a count. At the end,
; return a count of the number of matching array elements in EAX. Write a test program that calls
; your procedure and passes pointers to two different pairs of arrays. Use the INVOKE statement
; to call your procedure and pass stack parameters. Create a PROTO declaration for Count-
; Matches. Save and restore any registers (other than EAX) changed by your procedure.

INCLUDE Irvine32.inc

CountMatches PROTO,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    count:DWORD

.data
; 첫 번째 쌍: 같은 위치에 같은 값 3개 (인덱스 0, 2, 4)
x1 SDWORD  1, -2,  3, 4, -5
y1 SDWORD  1,  2,  3, 0, -5
; 두 번째 쌍: 같은 위치에 같은 값 2개 (인덱스 1, 5)
x2 SDWORD 10, -20, 30, 40, 50, -60, 70
y2 SDWORD 11, -20, 31, 41, 51, -60, 69
msg BYTE "Matching elements: ",0

.code
main PROC
    INVOKE CountMatches, ADDR x1, ADDR y1, LENGTHOF x1
    call ShowResult                 ; 3
    INVOKE CountMatches, ADDR x2, ADDR y2, LENGTHOF x2
    call ShowResult                 ; 2
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
CountMatches PROC USES ebx ecx esi edi,
    pArr1:PTR SDWORD,
    pArr2:PTR SDWORD,
    count:DWORD
; x[i] == y[i] 인 원소 개수를 EAX로 반환
;--------------------------------------------------------
    mov  esi,pArr1
    mov  edi,pArr2
    mov  ecx,count
    mov  eax,0                      ; 일치 개수
    jecxz Done
L1: mov  ebx,[esi]                  ; x[i]
    cmp  ebx,[edi]                  ; y[i]와 비교
    jne  Next
    inc  eax                        ; 같으면 증가
Next:
    add  esi,TYPE SDWORD
    add  edi,TYPE SDWORD
    loop L1
Done:
    ret
CountMatches ENDP

END main
