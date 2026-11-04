; Ch7 Programming Exercise 4. Encryption Using Rotate Operations
;
; Write a procedure that performs simple encryption by rotating each plaintext byte a
; varying number of positions in different directions. For example, in the following
; array that represents the encryption key, a negative value indicates a rotation to
; the left and a positive value indicates a rotation to the right. The integer in each
; position indicates the magnitude of the rotation:
;     key BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6
; Your procedure should loop through a plaintext message and align the key to the
; first 10 bytes of the message. Rotate each plaintext byte by the amount indicated by
; its matching key array value. Then, align the key to the next 10 bytes of the message
; and repeat the process. Write a program that tests your encryption procedure by
; calling it twice, with different data sets.

INCLUDE Irvine32.inc

KEY_LEN = 10

.data
key   SBYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6

msg1  BYTE "Assembly language is fun!",0
msg2  BYTE "Rotate each byte by the key, then rotate back.",0

lblPlain BYTE "Plain    : ",0
lblEnc   BYTE "Encrypted: ",0
lblDec   BYTE "Decrypted: ",0

.code
main PROC
    mov  esi,OFFSET msg1
    mov  ecx,LENGTHOF msg1 - 1     ; 널 문자 제외
    call TestOne

    mov  esi,OFFSET msg2
    mov  ecx,LENGTHOF msg2 - 1
    call TestOne
    exit
main ENDP

;--------------------------------------------------------
TestOne PROC
; 한 메시지를 출력 → 암호화(16진수 출력) → 복호화 후 출력
; Receives: ESI = 메시지 주소, ECX = 길이
;--------------------------------------------------------
    pushad
    mov  edx,OFFSET lblPlain
    call WriteString
    mov  edx,esi
    call WriteString
    call Crlf

    mov  edx,0                     ; EDX = 0 → 암호화
    call Encrypt
    mov  edx,OFFSET lblEnc
    call WriteString
    call ShowHex                   ; 암호문은 출력 불가 문자가 섞여 16진수로 표시
    call Crlf

    mov  edx,1                     ; EDX = 1 → 복호화 (반대 방향 회전)
    call Encrypt
    mov  edx,OFFSET lblDec
    call WriteString
    mov  edx,esi
    call WriteString
    call Crlf
    call Crlf
    popad
    ret
TestOne ENDP

;--------------------------------------------------------
Encrypt PROC
; 각 바이트를 key 값만큼 회전한다 (음수 = 왼쪽, 양수 = 오른쪽).
; key는 10바이트 단위로 메시지에 반복 정렬된다.
; Receives: ESI = 메시지 주소, ECX = 길이,
;           EDX = 0 암호화 / 1 복호화(방향 반대)
; Returns:  메시지가 제자리에서 변환됨
;--------------------------------------------------------
    pushad
    mov  edi,0                     ; EDI = key 인덱스
L1: mov  al,key[edi]               ; 회전량 (부호 있음)
    cmp  edx,0
    je   L2
    neg  al                        ; 복호화: 방향 반대
L2: push ecx
    cmp  al,0
    jl   RotLeft                   ; 음수면 왼쪽 회전
    mov  cl,al                     ; 양수(또는 0): 오른쪽 회전
    ror  BYTE PTR [esi],cl
    jmp  Next
RotLeft:
    neg  al                        ; 크기만 취함
    mov  cl,al
    rol  BYTE PTR [esi],cl
Next:
    pop  ecx
    inc  esi                       ; 다음 메시지 바이트
    inc  edi                       ; 다음 key
    cmp  edi,KEY_LEN
    jb   L3
    mov  edi,0                     ; 10바이트마다 key 다시 처음부터
L3: loop L1
    popad
    ret
Encrypt ENDP

;--------------------------------------------------------
ShowHex PROC
; 메시지 바이트들을 16진수로 출력
; Receives: ESI = 주소, ECX = 길이
;--------------------------------------------------------
    pushad
L1: mov  al,[esi]
    call WriteHexB
    mov  al,' '
    call WriteChar
    inc  esi
    loop L1
    popad
    ret
ShowHex ENDP

END main
