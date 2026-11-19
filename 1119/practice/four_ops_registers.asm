; 두 정수를 입력받아 사칙연산 결과와, 각 연산 직후 AX, BX, CX, DX 레지스터 내용을 출력
;   연산 전: AX = A, BX = B, CX = A(원래 값 보관), DX = 0
;   덧셈/뺄셈: AX = 결과
;   곱셈 (imul bx): DX:AX = 32비트 결과
;   나눗셈 (cwd + idiv bx): AX = 몫, DX = 나머지
; 빌드: MASM32 (ml /c /coff, link /subsystem:console /entry:main kernel32.lib)
.386
.model flat, stdcall
.stack 4096

ExitProcess   PROTO :DWORD
GetStdHandle  PROTO :DWORD
ReadConsoleA  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

PrintStr  PROTO :DWORD
PrintHex  PROTO :DWORD
PrintDec  PROTO :DWORD
PrintExpr PROTO :DWORD

STD_INPUT_HANDLE  equ -10
STD_OUTPUT_HANDLE equ -11

.data
promptA  db "Enter integer A (-32768 ~ 32767): ", 0
promptB  db "Enter integer B (-32768 ~ 32767): ", 0
opAdd    db " + ", 0
opSub    db " - ", 0
opMul    db " * ", 0
opDiv    db " / ", 0
sEq      db " = ", 0
sRem     db ", remainder ", 0
crlf     db 13, 10, 0
nAX      db "    AX=", 0
nBX      db "h  BX=", 0
nCX      db "h  CX=", 0
nDX      db "h  DX=", 0
nEnd     db "h", 13, 10, 13, 10, 0
sDivZero db "Division skipped: B = 0", 13, 10, 0
sDivOvf  db "Division skipped: -32768 / -1 overflows 16-bit", 13, 10, 0

hIn      dd ?
hOut     dd ?
nRead    dd ?
written  dd ?
inBuf    db 34 dup(0)       ; 32바이트만 읽으므로 뒤에 항상 0이 남음
numBuf   db 12 dup(?)
hexBuf   db 5 dup(?)
numA     dw ?
numB     dw ?
rAX      dw ?               ; Snap이 저장한 레지스터 값
rBX      dw ?
rCX      dw ?
rDX      dw ?

.code
main:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax

    ; ---- 입력 ----
    invoke PrintStr, offset promptA
    call ReadInt
    mov numA, ax
    invoke PrintStr, offset promptB
    call ReadInt
    mov numB, ax
    invoke PrintStr, offset crlf

    ; ---- 덧셈 ----
    call LoadRegs
    add ax, bx              ; AX = A + B
    call Snap
    invoke PrintExpr, offset opAdd
    movsx eax, rAX
    invoke PrintDec, eax
    invoke PrintStr, offset crlf
    call DumpRegs

    ; ---- 뺄셈 ----
    call LoadRegs
    sub ax, bx              ; AX = A - B
    call Snap
    invoke PrintExpr, offset opSub
    movsx eax, rAX
    invoke PrintDec, eax
    invoke PrintStr, offset crlf
    call DumpRegs

    ; ---- 곱셈 ----
    call LoadRegs
    imul bx                 ; DX:AX = A * B
    call Snap
    invoke PrintExpr, offset opMul
    movsx eax, rDX          ; 32비트 결과 = (DX << 16) | AX
    shl eax, 16
    mov ax, rAX
    invoke PrintDec, eax
    invoke PrintStr, offset crlf
    call DumpRegs

    ; ---- 나눗셈 ----
    cmp numB, 0
    je  divZero
    cmp numB, -1
    jne doDiv
    cmp numA, -32768
    je  divOvf
doDiv:
    call LoadRegs
    cwd                     ; DX:AX = A (부호 확장)
    idiv bx                 ; AX = 몫, DX = 나머지
    call Snap
    invoke PrintExpr, offset opDiv
    movsx eax, rAX
    invoke PrintDec, eax
    invoke PrintStr, offset sRem
    movsx eax, rDX
    invoke PrintDec, eax
    invoke PrintStr, offset crlf
    call DumpRegs
    jmp done
divZero:
    invoke PrintStr, offset sDivZero
    jmp done
divOvf:
    invoke PrintStr, offset sDivOvf
done:
    invoke ExitProcess, 0

;------------------------------------------------------------
; LoadRegs: 연산 전 상태로 설정 (AX = A, BX = B, CX = A, DX = 0)
;------------------------------------------------------------
LoadRegs PROC
    mov ax, numA
    mov bx, numB
    mov cx, ax
    xor dx, dx
    ret
LoadRegs ENDP

;------------------------------------------------------------
; Snap: 현재 AX, BX, CX, DX 값을 메모리에 저장 (레지스터 변경 없음)
;------------------------------------------------------------
Snap PROC
    mov rAX, ax
    mov rBX, bx
    mov rCX, cx
    mov rDX, dx
    ret
Snap ENDP

;------------------------------------------------------------
; DumpRegs: Snap으로 저장한 값을 "AX=....h  BX=....h ..." 형식으로 출력
;------------------------------------------------------------
DumpRegs PROC
    invoke PrintStr, offset nAX
    movzx eax, rAX
    invoke PrintHex, eax
    invoke PrintStr, offset nBX
    movzx eax, rBX
    invoke PrintHex, eax
    invoke PrintStr, offset nCX
    movzx eax, rCX
    invoke PrintHex, eax
    invoke PrintStr, offset nDX
    movzx eax, rDX
    invoke PrintHex, eax
    invoke PrintStr, offset nEnd
    ret
DumpRegs ENDP

;------------------------------------------------------------
; PrintExpr: "A <op> B = " 출력 (모든 레지스터 보존)
;------------------------------------------------------------
PrintExpr PROC opStr:DWORD
    pushad
    movsx eax, numA
    invoke PrintDec, eax
    invoke PrintStr, opStr
    movsx eax, numB
    invoke PrintDec, eax
    invoke PrintStr, offset sEq
    popad
    ret
PrintExpr ENDP

;------------------------------------------------------------
; ReadInt: 콘솔에서 한 줄 읽어 부호 있는 10진 정수로 변환
; 반환: EAX (호출 쪽에서 AX만 사용 -> 범위 밖이면 하위 16비트로 잘림)
;------------------------------------------------------------
ReadInt PROC USES ebx esi edi
    invoke ReadConsoleA, hIn, offset inBuf, 32, offset nRead, 0
    mov esi, offset inBuf
    xor eax, eax
    xor edi, edi            ; edi = 1 이면 음수
skipSp:
    cmp byte ptr [esi], ' '
    jne sign
    inc esi
    jmp skipSp
sign:
    cmp byte ptr [esi], '-'
    jne digit
    mov edi, 1
    inc esi
digit:
    movzx ebx, byte ptr [esi]
    sub ebx, '0'
    cmp ebx, 9
    ja  endNum              ; 숫자가 아니면 끝 (CR, LF, 0 등)
    imul eax, 10
    add eax, ebx
    inc esi
    jmp digit
endNum:
    test edi, edi
    jz  rdOk
    neg eax
rdOk:
    ret
ReadInt ENDP

;------------------------------------------------------------
; PrintStr: 0으로 끝나는 문자열 출력 (모든 레지스터 보존)
;------------------------------------------------------------
PrintStr PROC pStr:DWORD
    pushad
    mov edi, pStr
    xor ecx, ecx
lenLoop:
    cmp byte ptr [edi+ecx], 0
    je  doWrite
    inc ecx
    jmp lenLoop
doWrite:
    invoke WriteConsoleA, hOut, pStr, ecx, offset written, 0
    popad
    ret
PrintStr ENDP

;------------------------------------------------------------
; PrintHex: val의 하위 16비트를 16진 4자리로 출력 (모든 레지스터 보존)
;------------------------------------------------------------
PrintHex PROC val:DWORD
    pushad
    mov edx, val
    mov ecx, 4
    mov edi, offset hexBuf
hexLoop:
    rol dx, 4               ; 상위 니블부터 꺼냄
    mov al, dl
    and al, 0Fh
    cmp al, 9
    jbe isDigit
    add al, 7               ; 'A'-'0'-10
isDigit:
    add al, '0'
    mov [edi], al
    inc edi
    loop hexLoop
    mov byte ptr [edi], 0
    invoke PrintStr, offset hexBuf
    popad
    ret
PrintHex ENDP

;------------------------------------------------------------
; PrintDec: val을 부호 있는 10진수로 출력 (모든 레지스터 보존)
;------------------------------------------------------------
PrintDec PROC val:DWORD
    pushad
    mov eax, val
    mov edi, offset numBuf + 11
    mov byte ptr [edi], 0
    mov ebx, 10
    xor esi, esi
    test eax, eax
    jns decLoop
    neg eax
    mov esi, 1
decLoop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz decLoop
    test esi, esi
    jz  decOut
    dec edi
    mov byte ptr [edi], '-'
decOut:
    invoke PrintStr, edi
    popad
    ret
PrintDec ENDP

end main
