; Average5.asm
; 정수 5개를 입력받아 합계와 평균(소수 둘째 자리까지)을 출력한다.
; Irvine32 없이 Windows API(kernel32)만 사용한다.

.386
.model flat, stdcall
.stack 4096
ExitProcess   PROTO STDCALL :DWORD
GetStdHandle  PROTO STDCALL :DWORD
WriteConsoleA PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ReadConsoleA  PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

STD_INPUT  equ -10
STD_OUTPUT equ -11
COUNT      equ 5            ; 입력받을 숫자 개수
BUFSIZE    equ 64           ; 입력 버퍼 크기

.data
titleMsg  db "Enter 5 integers.", 0Dh, 0Ah, 0
promptMsg db "Number ", 0
colonMsg  db ": ", 0
errMsg    db "Invalid input. Try again.", 0Dh, 0Ah, 0
sumMsg    db "Sum     : ", 0
avgMsg    db "Average : ", 0
minusStr  db "-", 0
dotStr    db ".", 0
zeroStr   db "0", 0
crlf      db 0Dh, 0Ah, 0

hIn     dd ?                ; 표준 입력 핸들
hOut    dd ?                ; 표준 출력 핸들
written dd ?                ; WriteConsoleA가 쓴 글자 수
readCnt dd ?                ; ReadConsoleA가 읽은 글자 수
sum     dd 0                ; 합계
inBuf   db BUFSIZE + 1 dup(0)
numBuf  db 12 dup(0)        ; 부호 + 10자리 + NULL

.code
main:
    invoke GetStdHandle, STD_INPUT
    mov hIn, eax
    invoke GetStdHandle, STD_OUTPUT
    mov hOut, eax

    mov esi, offset titleMsg
    call PrintStr

    mov ebx, 1              ; ebx = 현재 번호 (1 ~ 5)
inputLoop:
    ; "Number N: " 출력
    mov esi, offset promptMsg
    call PrintStr
    mov eax, ebx
    call PrintInt
    mov esi, offset colonMsg
    call PrintStr

    call ReadInt            ; eax = 값, ecx = 1(성공) / 0(실패)
    cmp ecx, 0
    je badInput

    add sum, eax            ; 합계에 더함
    inc ebx
    cmp ebx, COUNT
    jbe inputLoop
    jmp showResult

badInput:
    mov esi, offset errMsg
    call PrintStr
    jmp inputLoop           ; 같은 번호 다시 입력

showResult:
    ; 합계 출력
    mov esi, offset sumMsg
    call PrintStr
    mov eax, sum
    call PrintInt
    mov esi, offset crlf
    call PrintStr

    ; 평균 출력: 평균 × 100 = sum × 100 / 5 = sum × 20 (나머지 없이 정확함)
    mov esi, offset avgMsg
    call PrintStr
    mov eax, sum
    imul eax, eax, 20       ; eax = 평균 × 100
    cmp eax, 0
    jge notNeg
    neg eax                 ; 절댓값으로 바꾸고 '-' 먼저 출력
    mov esi, offset minusStr
    call PrintStr
notNeg:
    xor edx, edx
    mov ecx, 100
    div ecx                 ; eax = 정수부, edx = 소수부(0~99)
    call PrintInt           ; 정수부
    mov esi, offset dotStr
    call PrintStr
    mov eax, edx
    cmp eax, 10
    jae twoDigits
    mov esi, offset zeroStr ; 한 자리면 앞에 0 붙임 (예: .05)
    call PrintStr
twoDigits:
    call PrintInt           ; 소수부
    mov esi, offset crlf
    call PrintStr

    invoke ExitProcess, 0

;------------------------------------------------------------
; PrintStr: NULL로 끝나는 문자열 출력
; 입력: esi = 문자열 주소 / 모든 레지스터 보존
;------------------------------------------------------------
PrintStr PROC
    pushad
    xor ecx, ecx
lenLoop:
    cmp byte ptr [esi + ecx], 0
    je lenDone
    inc ecx
    jmp lenLoop
lenDone:
    invoke WriteConsoleA, hOut, esi, ecx, offset written, 0
    popad
    ret
PrintStr ENDP

;------------------------------------------------------------
; PrintInt: 부호 있는 32비트 정수를 10진수로 출력
; 입력: eax = 값 / 모든 레지스터 보존
;------------------------------------------------------------
PrintInt PROC
    pushad
    mov edi, offset numBuf + 11
    mov byte ptr [edi], 0   ; 문자열 끝
    xor ebx, ebx            ; ebx = 음수 표시
    test eax, eax
    jns convStart
    neg eax
    mov ebx, 1
convStart:
    mov ecx, 10
convLoop:                   ; 10으로 나눈 나머지를 뒤에서부터 채움
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz convLoop
    cmp ebx, 0
    je printIt
    dec edi
    mov byte ptr [edi], '-'
printIt:
    mov esi, edi
    call PrintStr
    popad
    ret
PrintInt ENDP

;------------------------------------------------------------
; ReadInt: 한 줄 입력받아 부호 있는 정수로 변환
; 출력: eax = 값, ecx = 1(성공) / 0(잘못된 입력)
; 허용: 앞뒤 공백, '+' 또는 '-' 부호
;------------------------------------------------------------
ReadInt PROC
    push ebx
    push esi
    push edi

    invoke ReadConsoleA, hIn, offset inBuf, BUFSIZE, offset readCnt, 0
    mov edx, readCnt
    mov byte ptr inBuf[edx], 0  ; 끝에 NULL

    mov esi, offset inBuf
    xor eax, eax            ; eax = 결과값
    xor ebx, ebx            ; ebx = 음수 표시
    xor edi, edi            ; edi = 읽은 숫자 개수

skipSpace:                  ; 앞 공백 건너뜀
    mov dl, [esi]
    cmp dl, ' '
    je nextSpace
    cmp dl, 9               ; 탭
    jne checkSign
nextSpace:
    inc esi
    jmp skipSpace

checkSign:
    cmp dl, '-'
    jne checkPlus
    mov ebx, 1
    inc esi
    jmp digitLoop
checkPlus:
    cmp dl, '+'
    jne digitLoop
    inc esi

digitLoop:                  ; eax = eax × 10 + 숫자
    movzx edx, byte ptr [esi]
    cmp dl, '0'
    jb digitDone
    cmp dl, '9'
    ja digitDone
    sub edx, '0'
    imul eax, eax, 10
    add eax, edx
    inc edi
    inc esi
    jmp digitLoop

digitDone:                  ; 뒤에는 공백/줄바꿈/끝만 허용
    mov dl, [esi]
    cmp dl, ' '
    je nextTrail
    cmp dl, 9
    je nextTrail
    cmp dl, 0Dh
    je checkDigits
    cmp dl, 0Ah
    je checkDigits
    cmp dl, 0
    je checkDigits
    jmp fail
nextTrail:
    inc esi
    jmp digitDone

checkDigits:
    cmp edi, 0              ; 숫자가 하나도 없으면 실패
    je fail
    cmp ebx, 0
    je success
    neg eax
success:
    mov ecx, 1
    jmp done
fail:
    xor ecx, ecx
done:
    pop edi
    pop esi
    pop ebx
    ret
ReadInt ENDP

end main
