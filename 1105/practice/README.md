# 1105 실습

`PrintStudentInfo.asm`은 콘솔에 학번과 이름 `2025964048 최우석`을 출력하는 32비트 MASM 프로그램입니다.

## 코드

```asm
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO STDCALL :DWORD
GetStdHandle PROTO STDCALL :DWORD
WriteConsoleW PROTO STDCALL :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

.data
msg dw '2','0','2','5','9','6','4','0','4','8',' '
    dw 0CD5Ch, 0C6B0h, 0C11Dh, 0Dh, 0Ah
msgLen equ ($ - msg) / 2
written dd ?

.code
main:
    invoke GetStdHandle, -11
    invoke WriteConsoleW, eax, offset msg, msgLen, offset written, 0
    invoke ExitProcess, 0
end main
```

## 설명

### 지시어 (1~3행)

| 행 | 코드 | 의미 |
|---|---|---|
| 1 | `.386` | 386 명령어 세트를 사용합니다. `.model flat`보다 먼저 와야 합니다. |
| 2 | `.model flat, stdcall` | 32비트 flat 메모리 모델과 stdcall 호출 규약을 지정합니다. `INVOKE`와 `PROTO`가 동작하려면 필요합니다. |
| 3 | `.stack 4096` | 스택 4096바이트를 확보합니다. 관례로 적는 줄입니다. |

### 함수 원형 (4~6행)

`PROTO`는 사용할 Windows API의 이름과 인자 개수를 어셈블러에 알려줍니다. `INVOKE`는 이 정보로 인자를 검사하고 push합니다.

- `ExitProcess`: 프로세스를 종료합니다. 인자는 종료 코드 1개입니다.
- `GetStdHandle`: 표준 입출력 핸들을 반환합니다. 인자는 핸들 종류 1개입니다.
- `WriteConsoleW`: 콘솔에 유니코드(UTF-16) 문자열을 씁니다. 인자는 5개입니다.

### 데이터 (`.data`)

- `msg`: UTF-16 문자열입니다. 글자 하나가 2바이트(`dw`)입니다.
  - 숫자와 공백은 `'2'`처럼 문자로 적었습니다.
  - 한글은 유니코드 값으로 적었습니다: 최 = `0CD5Ch`, 우 = `0C6B0h`, 석 = `0C11Dh`.
  - `0Dh`, `0Ah`는 줄바꿈(CR, LF)입니다.
- `msgLen`: `$`는 현재 주소입니다. `$ - msg`는 문자열의 바이트 수이고, 2로 나누면 글자 수(16)입니다. `WriteConsoleW`는 바이트 수가 아니라 글자 수를 받습니다.
- `written`: 실제로 출력한 글자 수를 받는 4바이트 변수입니다.

### 코드 (`.code`)

1. `invoke GetStdHandle, -11`: `-11`은 `STD_OUTPUT_HANDLE`입니다. 표준 출력 핸들이 `eax`에 반환됩니다.
2. `invoke WriteConsoleW, eax, offset msg, msgLen, offset written, 0`: 인자는 순서대로 출력 핸들, 문자열 주소, 글자 수, 쓴 글자 수를 받을 변수 주소, 예약값(항상 0)입니다.
3. `invoke ExitProcess, 0`: 종료 코드 0으로 프로그램을 끝냅니다.

`end main`은 소스의 끝이며 진입점을 `main`으로 지정합니다.

## 왜 `WriteConsoleW`인가

`WriteConsoleA`로 한글을 출력하면 소스 파일 인코딩과 콘솔 코드페이지가 맞아야 합니다. 맞지 않으면 글자가 깨집니다. 문자열을 UTF-16 값으로 직접 정의하고 `WriteConsoleW`를 쓰면 이 문제가 없습니다.

## 빌드와 실행

`kernel32.lib`를 링크해야 합니다. `PROTO`와 `INVOKE`는 어셈블 단계에서만 도움이 되고, 링크는 자동으로 되지 않습니다.

```
ml /c /coff PrintStudentInfo.asm
link /subsystem:console PrintStudentInfo.obj kernel32.lib
PrintStudentInfo.exe
```

Visual Studio의 교재 프로젝트는 링커 설정에 `kernel32.lib`가 이미 들어 있을 수 있습니다.

## 참고

- 콘솔 폰트가 한글을 지원하지 않으면 글자가 □로 보일 수 있습니다.
- Irvine32 라이브러리를 쓰지 않고 Windows API를 직접 호출합니다.
