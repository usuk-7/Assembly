# 1112 - 정수 5개 평균 구하기 (MASM32)

정수 5개를 입력받아 **합계**와 **평균**(소수 둘째 자리까지)을 출력하는 32비트 x86 어셈블리 프로그램.
Irvine32 라이브러리 없이 Windows API(`kernel32.lib`)만 사용함.

## 실행 예시

```
Enter 5 integers.
Number 1: 10
Number 2: 20
Number 3: abc
Invalid input. Try again.
Number 3: 33
Number 4: -5
Number 5: 7
Sum     : 65
Average : 13.00
```

## 폴더 구성

```
1112/
├── .vscode/
│   └── tasks.json   # VS Code 빌드 설정 (Ctrl+Shift+B)
├── Average5.asm     # 소스 코드
├── .gitignore       # .obj, .exe 제외
└── README.md
```

## 실행 환경

| 항목 | 내용 |
|---|---|
| OS | Windows (32비트 콘솔 프로그램) |
| 어셈블러/링커 | [MASM32 SDK](https://www.masm32.com/) (`C:\masm32`에 설치) |
| 에디터 | VS Code |
| 라이브러리 | `kernel32.lib` |

### 설정 방법

1. MASM32 SDK를 `C:\masm32`에 설치.
2. 이 폴더를 VS Code로 열기.
3. `Average5.asm`을 연 상태에서 `Ctrl+Shift+B` → `build asm` 실행.
4. 터미널에서 실행:
   ```
   .\Average5.exe
   ```

### 수동 빌드

```
C:\masm32\bin\ml /c /coff Average5.asm
C:\masm32\bin\link /subsystem:console /entry:main /LIBPATH:C:\masm32\lib Average5.obj kernel32.lib
Average5.exe
```

## 동작 방식

### 전체 흐름

1. `GetStdHandle`로 입력(-10), 출력(-11) 핸들 얻음.
2. `ebx`를 1~5로 돌리며 `Number N: ` 출력 → `ReadInt`로 한 줄 입력.
3. 잘못된 입력이면 오류 메시지 출력 후 같은 번호 다시 입력.
4. 올바르면 `sum`에 더함.
5. 합계와 평균 출력 후 `ExitProcess`.

### 평균 계산

정수 나눗셈만 쓰기 위해 평균에 100을 곱한 값을 구함.

```
평균 × 100 = sum × 100 / 5 = sum × 20
```

- 5로 나누면 소수부는 항상 .00 / .20 / .40 / .60 / .80 → `sum × 20`이면 오차 없음.
- 이 값을 100으로 `div` → 몫 = 정수부, 나머지 = 소수부.
- 음수면 먼저 `neg`로 절댓값 만들고 `-` 출력.
- 소수부가 한 자리(0~9)면 앞에 `0` 붙임.

### 프로시저

| 이름 | 입력 | 출력 | 하는 일 |
|---|---|---|---|
| `PrintStr` | `esi` = 문자열 주소 | - | NULL까지 길이 세고 `WriteConsoleA`로 출력 |
| `PrintInt` | `eax` = 정수 | - | 10으로 나눈 나머지를 버퍼 뒤에서부터 채워 10진 문자열로 변환 후 출력 |
| `ReadInt` | - | `eax` = 값, `ecx` = 1/0 | `ReadConsoleA`로 한 줄 읽고 정수로 변환 |

`PrintStr`, `PrintInt`는 `pushad`/`popad`로 모든 레지스터 보존.

### 입력 검사 (`ReadInt`)

- 앞뒤 공백, 탭 허용.
- `+`, `-` 부호 허용.
- 숫자가 없거나 숫자 뒤에 다른 문자가 있으면 실패 (`12a`, `abc`, 빈 줄).
- 변환식: `eax = eax × 10 + (문자 - '0')`.

## 제한

- 32비트 정수 범위를 넘는 입력·합계는 검사하지 않음 (오버플로 가능).
- 콘솔에서 직접 입력해야 함 (`ReadConsoleA`는 파이프/리다이렉트 입력 미지원).
