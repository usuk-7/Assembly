; Ch5 Programming Exercise 6. Random Strings
; Create a procedure that generates a random string of length L, containing all capital letters.
; When calling the procedure, pass the value of L in EAX, and pass a pointer to an array of byte
; that will hold the random string. Write a test program that calls your procedure 20 times and
; displays the strings in the console window.

INCLUDE Irvine32.inc

STR_LEN = 10                        ; 문자열 길이 L

.data
buffer BYTE STR_LEN+1 DUP(0)        ; L개 문자 + 종료 0

.code
main PROC
    call Randomize
    mov  ecx,20                     ; 20번 생성
L1:
    mov  eax,STR_LEN                ; EAX = L
    mov  esi,OFFSET buffer          ; ESI = 버퍼 주소
    call CreateRandomString
    mov  edx,OFFSET buffer
    call WriteString
    call Crlf
    loop L1
    exit
main ENDP

;---------------------------------------
; CreateRandomString: 대문자 난수 문자열 생성
; Receives: EAX = 길이 L, ESI = BYTE 배열 주소
; Returns:  배열에 문자열 저장 (끝에 0 추가)
;---------------------------------------
CreateRandomString PROC USES eax ecx esi
    mov  ecx,eax                    ; L번 반복
L1:
    mov  eax,26                     ; 0~25 난수
    call RandomRange
    add  al,'A'                     ; 'A'~'Z'로 변환
    mov  [esi],al
    inc  esi
    loop L1
    mov  BYTE PTR [esi],0           ; 문자열 종료
    ret
CreateRandomString ENDP

END main
