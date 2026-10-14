; Ch5 Programming Exercise 11. Finding Multiples of K
; In a byte array of size N, write a procedure that finds all multiples of K that are less than N.
; Initialize the array to all zeros at the beginning of the program, and then whenever a multiple is
; found, set the corresponding array element to 1. Your procedure must save and restore any
; registers it modifies. Call your procedure twice, with K = 2, and again with K = 3. Let N equal to 50.
; Run your program in the debugger and verify that the array values were set correctly. Note: This
; procedure can be a useful tool when finding prime integers. An efficient algorithm for finding
; prime numbers is known as the Sieve of Eratosthenes. You will be able to implement this
; algorithm when conditional statements are covered in Chapter 6.

INCLUDE Irvine32.inc

N = 50

.data
array2 BYTE N DUP(?)                ; K=2 결과
array3 BYTE N DUP(?)                ; K=3 결과

.code
main PROC
    ; 배열을 0으로 초기화
    mov  esi,OFFSET array2
    mov  ecx,N
    call ClearArray
    mov  esi,OFFSET array3
    call ClearArray

    ; K = 2
    mov  esi,OFFSET array2
    mov  ecx,N
    mov  ebx,2
    call FindMultiples

    ; K = 3
    mov  esi,OFFSET array3
    mov  ebx,3
    call FindMultiples

    ; 결과 확인 (디버거 대신 메모리 덤프)
    mov  esi,OFFSET array2
    mov  ecx,N
    mov  ebx,TYPE BYTE
    call DumpMem
    mov  esi,OFFSET array3
    call DumpMem
    exit
main ENDP

;---------------------------------------
; ClearArray: BYTE 배열을 0으로 채움
; Receives: ESI = 배열 주소, ECX = 크기
;---------------------------------------
ClearArray PROC USES ecx esi
L1:
    mov  BYTE PTR [esi],0
    inc  esi
    loop L1
    ret
ClearArray ENDP

;---------------------------------------
; FindMultiples: N보다 작은 K의 배수(K, 2K, ...)
; 위치를 1로 표시 (0은 제외)
; Receives: ESI = 배열 주소, ECX = N, EBX = K (0 < K < N)
; 모든 수정 레지스터 저장/복원 (USES)
;---------------------------------------
FindMultiples PROC USES eax ecx edx edi
    ; 배수 개수 = (N-1) / K  → 조건문 없이 LOOP 횟수로 사용
    mov  eax,ecx
    dec  eax
    mov  edx,0
    div  ebx                        ; EAX = 배수 개수
    mov  ecx,eax

    mov  edi,ebx                    ; 첫 배수 = K
L1:
    mov  BYTE PTR [esi+edi],1       ; 배수 위치 표시
    add  edi,ebx                    ; 다음 배수
    loop L1
    ret
FindMultiples ENDP

END main
