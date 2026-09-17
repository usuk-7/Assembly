; Ch3 Programming Exercise 3: Data Definitions
; Write a program that contains a definition of each data type listed in
; Table 3-2 in Section 3.4. Initialize each variable to a value that is
; consistent with its data type.
;
; 이 파일은 실행 결과보다 "데이터 정의" 자체가 목적이므로 .data 섹션 위주로 작성한다.

INCLUDE Irvine32.inc

.data
byteVar   BYTE   255                 ; BYTE: 부호 없는 8비트 (0~255)
sbyteVar  SBYTE  -128                ; SBYTE: 부호 있는 8비트 (-128~127)
wordVar   WORD   65535                ; WORD: 부호 없는 16비트 (0~65535)
swordVar  SWORD  -32768               ; SWORD: 부호 있는 16비트 (-32768~32767)
dwordVar  DWORD  4294967295          ; DWORD: 부호 없는 32비트
sdwordVar SDWORD -2147483648         ; SDWORD: 부호 있는 32비트
fwordVar  FWORD  1234567890AAh       ; FWORD: 48비트(6바이트), 주로 far 포인터 등에 사용
qwordVar  QWORD  123456789ABCDEF0h   ; QWORD: 64비트 (MASM에는 부호 있는 SQWORD 타입이 없음)
tbyteVar  TBYTE  0123456789ABCDEF0123h ; TBYTE: 10바이트(80비트), packed BCD/확장 실수용
real4Var  REAL4  3.14                 ; REAL4: 단정도 부동소수점 (4바이트)
real8Var  REAL8  3.141592653589        ; REAL8: 배정도 부동소수점 (8바이트)
real10Var REAL10 3.14159265358979323846 ; REAL10: 확장정도 부동소수점 (10바이트)

.code
main PROC
    ; 정의만으로도 목적을 달성하지만, 간단히 하나 출력해서 조립/링크 확인
    mov eax, dwordVar
    call WriteDec
    call Crlf

    invoke ExitProcess, 0
main ENDP
END main
