; Ch4 Programming Exercise 6: Reverse an Array
; Use a loop with indirect or indexed addressing to reverse the elements of an
; integer array in place. Do not copy the elements to any other array. Use the
; SIZEOF, TYPE, and LENGTHOF operators to make the program as flexible as
; possible if the array size and type should be changed in the future.

INCLUDE Irvine32.inc

.data
array DWORD 1,2,3,4,5,6,7,8,9,10

.code
main PROC
    ; 양 끝을 가리키는 포인터 (간접 주소 지정)
    mov esi, OFFSET array                            ; 첫 원소
    mov edi, OFFSET array + SIZEOF array - TYPE array ; 마지막 원소
    mov ecx, LENGTHOF array / 2                      ; 교환 횟수 = 절반

L1:
    ; [esi] <-> [edi] 교환 (DWORD 기준; 타입 바꾸면 레지스터 크기도 맞출 것)
    mov eax, [esi]
    xchg eax, [edi]
    mov [esi], eax
    add esi, TYPE array                  ; 앞 포인터 → 다음
    sub edi, TYPE array                  ; 뒤 포인터 → 이전
    loop L1

    ; 결과 확인: 10,9,8,...,1
    mov esi, OFFSET array
    mov ecx, LENGTHOF array
    mov ebx, TYPE array
    call DumpMem

    invoke ExitProcess, 0
main ENDP
END main
