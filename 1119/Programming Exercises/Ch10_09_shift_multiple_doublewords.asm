; Ch10 Programming Exercise 9. Shifting Multiple Doublewords
;
; Create a macro that shifts an array of 32-bit integers a variable number of bits in either direction,
; using the SHRD and SHLD instructions. Write a test program that tests your macro by shifting
; the same array in both directions and displaying the resulting values. You can assume that the
; array is in little-endian order. Here is a sample macro declaration:
;     mShiftDoublewords MACRO arrayName, direction, numberOfBits
;     Parameters:
;        arrayName       Name of the array
;        direction       Right (R) or Left (L)
;        numberOfBits    Number of bit positions to shift
;
; 가정: 배열 전체가 하나의 큰 정수이고 arrayName[0]이 가장 하위 DWORD(리틀엔디언).
;       numberOfBits는 1~31 (8비트 상수 또는 BYTE 변수).

INCLUDE Irvine32.inc
INCLUDE Macros.inc

;------------------------------------------------------------
mShiftDoublewords MACRO arrayName:REQ, direction:REQ, numberOfBits:REQ
;
; 오른쪽(R): 하위 원소부터, 바로 위 원소의 하위 비트를 끌어와 채움
;   [i] = SHRD [i], [i+1], n   (i = 0 .. N-2),  마지막 원소는 SHR
; 왼쪽(L):  상위 원소부터, 바로 아래 원소의 상위 비트를 끌어와 채움
;   [i] = SHLD [i], [i-1], n   (i = N-1 .. 1),  첫 원소는 SHL
; 사용 레지스터 ECX, EDX, ESI는 보존. ECX/EDX/ESI를 인자로 쓰지 말 것.
;------------------------------------------------------------
    LOCAL L1, Done
    push ecx
    push edx
    push esi
    mov  cl,numberOfBits                ;; 시프트 횟수(CL)

    IFIDNI <direction>,<R>
        mov  esi,OFFSET arrayName       ;; 가장 하위 원소부터
        mov  edx,LENGTHOF arrayName - 1 ;; SHRD 반복 횟수
        push edx
    L1:
        cmp  DWORD PTR [esp],0
        je   Done
        mov  edx,[esi+4]                ;; 바로 위 원소
        shrd DWORD PTR [esi],edx,cl     ;; 위 원소의 하위 비트가 현재 원소 상위로
        add  esi,4
        dec  DWORD PTR [esp]
        jmp  L1
    Done:
        add  esp,4                      ;; 임시 카운터 제거
        shr  DWORD PTR [esi],cl         ;; 최상위 원소: 0이 채워짐
    ELSEIFIDNI <direction>,<L>
        mov  esi,OFFSET arrayName + (LENGTHOF arrayName - 1) * 4  ;; 최상위 원소부터
        mov  edx,LENGTHOF arrayName - 1 ;; SHLD 반복 횟수
        push edx
    L1:
        cmp  DWORD PTR [esp],0
        je   Done
        mov  edx,[esi-4]                ;; 바로 아래 원소
        shld DWORD PTR [esi],edx,cl     ;; 아래 원소의 상위 비트가 현재 원소 하위로
        sub  esi,4
        dec  DWORD PTR [esp]
        jmp  L1
    Done:
        add  esp,4
        shl  DWORD PTR [esi],cl         ;; 최하위 원소: 0이 채워짐
    ELSE
        ECHO * Error: direction must be R or L
    ENDIF

    pop  esi
    pop  edx
    pop  ecx
ENDM

;------------------------------------------------------------
mShowArray MACRO arrayName:REQ
; 배열을 상위 원소부터 16진수로 출력 (큰 정수처럼 보이게)
;------------------------------------------------------------
    LOCAL L2
    push eax
    push ecx
    push esi
    mov  esi,OFFSET arrayName + (LENGTHOF arrayName - 1) * 4
    mov  ecx,LENGTHOF arrayName
L2: mov  eax,[esi]
    call WriteHex
    mov  al,' '
    call WriteChar
    sub  esi,4
    loop L2
    call Crlf
    pop  esi
    pop  ecx
    pop  eax
ENDM

.data
; array[0]이 최하위. 화면엔 [3] [2] [1] [0] 순서로 출력됨
array DWORD 89ABCDEFh, 01234567h, 0FEDCBA98h, 76543210h
bits  BYTE 4

.code
main PROC
    mWrite "Original        : "
    mShowArray array

    mShiftDoublewords array, R, 4       ; 오른쪽 4비트 (상수)
    mWrite "Shift right 4   : "
    mShowArray array

    mShiftDoublewords array, L, bits    ; 왼쪽 4비트 (변수) → 최상위 니블만 0이 됨
    mWrite "Shift left 4    : "
    mShowArray array

    mShiftDoublewords array, L, 12      ; 왼쪽 12비트
    mWrite "Shift left 12   : "
    mShowArray array

    mShiftDoublewords array, R, 12      ; 오른쪽 12비트
    mWrite "Shift right 12  : "
    mShowArray array
    exit
main ENDP
END main
