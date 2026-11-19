# 사칙연산 + 레지스터 출력 (four_ops_registers.asm)

두 정수 A, B를 입력받아 덧셈·뺄셈·곱셈·나눗셈 결과를 출력하고,
각 연산 직후의 **AX, BX, CX, DX** 레지스터 값을 16진수로 함께 출력하는 MASM 프로그램.

## 빌드 / 실행

MASM32(`C:\masm32`) 필요. VS Code에서 `Ctrl+Shift+B` (`.vscode/tasks.json`의 `build asm`) 또는:

```
C:\masm32\bin\ml /c /coff four_ops_registers.asm
C:\masm32\bin\link /subsystem:console /entry:main /LIBPATH:C:\masm32\lib four_ops_registers.obj kernel32.lib
four_ops_registers.exe
```

Irvine 라이브러리 없이 Win32 API(`ReadConsoleA`, `WriteConsoleA`, `GetStdHandle`, `ExitProcess`)만 사용한다.
콘솔 API를 쓰므로 콘솔 창에서 직접 실행해야 한다 (파이프/리다이렉트 입력은 동작하지 않음).

## 실행 예시

```
Enter integer A (-32768 ~ 32767): -100
Enter integer B (-32768 ~ 32767): 7

-100 + 7 = -93
    AX=FFA3h  BX=0007h  CX=FF9Ch  DX=0000h

-100 - 7 = -107
    AX=FF95h  BX=0007h  CX=FF9Ch  DX=0000h

-100 * 7 = -700
    AX=FD44h  BX=0007h  CX=FF9Ch  DX=FFFFh

-100 / 7 = -14, remainder -2
    AX=FFF2h  BX=0007h  CX=FF9Ch  DX=FFFEh
```

## 레지스터 사용

매 연산 전에 `LoadRegs`로 **AX = A, BX = B, CX = A(원래 값 보관), DX = 0** 으로 맞춘 뒤 연산한다.

| 연산 | 명령 | 결과 위치 |
|------|------|-----------|
| 덧셈 | `add ax, bx` | AX = A + B |
| 뺄셈 | `sub ax, bx` | AX = A − B |
| 곱셈 | `imul bx` | DX:AX = A × B (32비트, DX = 상위 16비트) |
| 나눗셈 | `cwd` → `idiv bx` | AX = 몫, DX = 나머지 |

- 곱셈 예: `300 * 300 = 90000 = 0001_5F90h` → `DX=0001h`, `AX=5F90h`
- 음수 곱 예: `-700 = FFFF_FD44h` → `DX=FFFFh`, `AX=FD44h`
- `cwd`는 나누기 전에 AX의 부호를 DX로 확장한다 (A가 음수면 DX = FFFFh). `idiv`가 DX:AX를 피제수로 쓰기 때문이다.

## 프로시저 구성

| 이름 | 역할 |
|------|------|
| `ReadInt` | 한 줄 입력을 부호 있는 10진 정수로 변환 (EAX 반환) |
| `LoadRegs` | AX, BX, CX, DX를 연산 전 상태로 설정 |
| `Snap` | 연산 직후의 AX~DX를 메모리(`rAX`~`rDX`)에 저장 |
| `DumpRegs` | 저장한 레지스터 값을 `AX=....h` 형식으로 출력 |
| `PrintExpr` | `A <연산자> B = ` 출력 |
| `PrintStr` / `PrintDec` / `PrintHex` | 문자열 / 부호 있는 10진수 / 16진 4자리 출력 (모든 레지스터 보존) |

출력 프로시저가 레지스터를 바꾸기 때문에, 연산 직후 `Snap`으로 값을 먼저 저장하고 그 값을 출력한다.

## 제한 사항

- 16비트 부호 있는 정수(-32768 ~ 32767) 기준. 범위를 벗어난 입력은 하위 16비트로 잘린다.
- 덧셈/뺄셈은 16비트 오버플로가 나면 값이 넘어간다 (예: `-32768 + -1 = 32767`).
- B = 0 이면 나눗셈을 건너뛴다 (`idiv` 0 나누기 예외 방지).
- A = -32768, B = -1 이면 몫 32768이 16비트를 넘어 `idiv` 예외가 나므로 나눗셈을 건너뛴다.
- 프롬프트는 콘솔 코드페이지 문제로 한글 대신 영어로 출력한다.
