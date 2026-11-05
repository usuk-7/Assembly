.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO STDCALL :DWORD
GetStdHandle PROTO STDCALL :DWORD
WriteConsoleW PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

.data
; UTF-16 문자열: "2025964048 " + 최(CD5C) 우(C6B0) 석(C11D) + CR LF
msg dw '2','0','2','5','9','6','4','0','4','8',' '
    dw 0CD5Ch, 0C6B0h, 0C11Dh, 0Dh, 0Ah
msgLen equ ($ - msg) / 2      ; 바이트 수 / 2 = 글자 수
written dd ?

.code
main:
    invoke GetStdHandle, -11
    invoke WriteConsoleW, eax, offset msg, msgLen, offset written, 0
    invoke ExitProcess, 0
end main
