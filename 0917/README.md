# 3장. Assembly Language Fundamentals (어셈블리 프로그래밍)

## 1. 기본 언어 요소 (Basic Language Elements, 3.1)

이 장은 MASM 어셈블러의 기본 구성 요소(리터럴, 식별자, 지시어, 명령어)와 프로그램을 어셈블·실행·디버깅하는 방법을 다룬다.

### 1.1 첫 번째 어셈블리 프로그램 (First Assembly Language Program, 3.1.1)
- 어셈블리 언어는 CPU 레지스터와 플래그까지 모두 보여주는 total information 언어다. 그만큼 데이터 표현 방식과 명령어 형식을 프로그래머가 직접 세밀하게 관리해야 한다.
- 가장 단순한 AddTwo 예제:
  ```
  1: main PROC
  2:   mov eax,5            ; move 5 to the eax register
  3:   add eax,6            ; add 6 to the eax register
  4:
  5:   INVOKE ExitProcess,0 ; end the program
  6: main ENDP
  ```
  main PROC는 프로그램의 entry point가 되는 main 프로시저를 시작하고, INVOKE ExitProcess,0은 윈도우 서비스를 호출해 프로그램을 종료하며, main ENDP는 프로시저의 끝을 표시한다.
- 여기에 sum이라는 변수를 추가하면 덧셈 결과를 저장할 수 있다.
  ```
  .data
  sum DWORD 0           ; create a variable named sum
  .code
  main PROC
    mov eax,5
    add eax,6
    mov sum,eax
    INVOKE ExitProcess,0
  main ENDP
  ```
  sum은 DWORD 키워드로 크기가 32비트임을 지정해 선언되며, 어셈블리의 크기 키워드는 값 검사를 하지 않고 오직 크기만 지정한다. .data와 .code로 표시된 영역을 segment라고 부르며, 이후 .stack이 세 번째 segment로 등장한다.

### 1.2 정수 리터럴 (Integer Literals, 3.1.2)
- Integer literal은 `[{+ | -}] digits [radix]` 형식이다. radix 문자: h(hexadecimal), q/o(octal), d(decimal), b(binary), r(encoded real), t(decimal alternate), y(binary alternate).
- radix 표시가 없으면 자동으로 decimal로 간주된다. 예를 들어 1101은 "b"를 붙이지 않으면 decimal 1101로 취급되어 1101b(binary)와 다른 값이 된다.
- 유효한 예: 26, 26d(둘 다 decimal), 11010011b(binary), 42q·42o(octal), 1Ah·0A3h(hexadecimal). hex literal이 문자로 시작할 경우 어셈블러가 식별자로 오인하지 않도록 앞에 반드시 0을 붙여야 한다(0A3h).

### 1.3 상수 정수 표현식 (Constant Integer Expressions, 3.1.3)
- Integer expression은 integer literal과 산술 연산자로 이루어진 표현식이며 반드시 32비트로 저장 가능한 정수 값으로 계산되고, assembly time에만 계산된다.
- 연산자 우선순위(1이 가장 높음): 괄호(1) → 단항 +,-(2) → *,/,MOD(3, 동순위) → 이항 +,-(4).
- 계산 예: `4 + 5 * 2`(곱셈 먼저), `12 -1 MOD 5`(나머지 먼저), `16 / 5 = 3`, `-(3 + 4) * (6 - 1) = -35`, `-3 + 4 * 6 - 1 = 20`, `25 mod 3 = 1`. 순서를 외우기보다 괄호로 명확히 하는 것이 좋다.

### 1.4 실수 리터럴 (Real Number Literals, 3.1.4)
- 10진수 real은 `[sign]integer.[integer][exponent]` 형식이며 최소 숫자 1개와 소수점이 필요하다. 예: `2.`, `+3.0`, `-44.2E+05`, `26.E5`.
- Encoded real은 IEEE 부동소수점 형식을 16진수로 표현한 것이다. 예를 들어 decimal +1.0의 2진 표현 `0011 1111 1000 0000 ...`을 encoded real로 쓰면 `3F800000r`가 된다. x86 명령어는 정수 처리 위주라 real 상수는 당장 자주 쓰이지 않는다.

### 1.5 문자 리터럴 (Character Literals, 3.1.5)
- Character literal은 작은따옴표나 큰따옴표로 감싼 단일 문자이며, 어셈블러는 그 문자의 ASCII 코드 값을 정수로 저장한다. 예: `'A'`는 메모리에 65(41h)로 저장된다.

### 1.6 문자열 리터럴 (String Literals, 3.1.6)
- String literal은 공백을 포함한 문자들의 나열을 따옴표로 감싼 것이다(`'ABC'`, `"Good night, Gracie"`). 인용부호 안에 다른 종류의 인용부호를 넣는 것도 가능하다(`"This isn't a test"`).
- 문자열도 정수 바이트값들의 나열로 메모리에 저장된다. 예를 들어 "ABCD"는 41h, 42h, 43h, 44h 네 바이트로 저장된다.

### 1.7 예약어 (Reserved Words, 3.1.7)
- 예약어는 특별한 의미를 가지며 정해진 문맥에서만 쓸 수 있고 기본적으로 대소문자를 구분하지 않는다. 종류는 다음과 같다.
  - MOV, ADD, MUL 같은 instruction mnemonics
  - 레지스터 이름
  - 어셈블 방법을 지시하는 directives
  - 변수·operand의 크기·용도 정보를 제공하는 attributes(예: BYTE, WORD)
  - 상수 표현식에 쓰이는 연산자
  - @data처럼 assembly time에 상수 정수 값을 반환하는 predefined symbol

### 1.8 식별자 (Identifiers, 3.1.8)
- Identifier는 변수·상수·프로시저·code label을 가리키는 프로그래머 지정 이름이다. 1~247자, 대소문자 무관, 첫 글자는 문자(A..Z, a..z)·밑줄(_)·@·?·$ 중 하나여야 하며 이후에는 숫자도 올 수 있다. 예약어와 같은 이름은 쓸 수 없다.
- 좋은 예: lineCount, firstValue, xCoord. 허용되지만 비권장: _lineCount, $first, @myFile(@ 기호와 밑줄은 어셈블러·컴파일러가 선행 문자로 자주 쓰므로 피하는 것이 좋다).

### 1.9 지시어 (Directives, 3.1.9)
- Directive는 소스 코드에 포함된 명령으로 어셈블러가 인식하고 그 자리에서 처리한다. runtime에 실행되지 않으며, 변수·매크로·프로시저 정의, segment 이름 지정 등 housekeeping 작업을 담당한다. 기본적으로 대소문자를 구분하지 않는다(.data, .DATA, .Data 동일).
- Directive와 instruction의 차이: DWORD directive는 공간만 예약하지만, MOV instruction은 runtime에 실제로 값을 이동시킨다.
  ```
  myVar DWORD 26
  mov   eax,myVar
  ```
- Segment를 정의하는 directive: .data(변수 정의 영역), .code(실행 명령어 영역), .stack(런타임 스택 영역, 크기 지정. 예: `.stack 100h`). 어셈블러마다 directive 집합은 다를 수 있다(예: MASM의 REPT는 다른 어셈블러에서 인식 안 될 수 있음).

### 1.10 명령어 (Instructions, 3.1.10)
- Instruction은 어셈블될 때 기계어 바이트로 번역되는 문장이며 형식은 `[label:] mnemonic [operands] [;comment]`이다. label(선택)·mnemonic(필수)·operand(대개 필요)·comment(선택)로 구성된다.
- Label에는 두 종류가 있다. data label은 변수의 위치를 식별하고(`count DWORD 100`), code label은 점프·반복 명령어의 목표 지점이며 반드시 콜론(:)으로 끝나야 한다.
  ```
  target:
      mov   ax,bx
      ...
      jmp   target
  ```
- 대표적인 mnemonic: MOV(값 이동), ADD(덧셈), SUB(뺄셈), MUL(곱셈), JMP(점프), CALL(프로시저 호출).
- Operand는 레지스터·메모리·정수 리터럴(표현식)·입출력 포트가 될 수 있고, instruction은 0~3개의 operand를 가질 수 있다. `stc`는 operand 없음, `inc eax`는 1개, `mov count,ebx`는 2개(첫 번째가 destination operand, 두 번째가 source operand), `imul eax,ebx,5`는 3개(EBX와 5를 곱해 EAX에 저장)다.
- 주석은 `;`로 시작하는 한 줄 주석과, COMMENT 지시어+사용자 지정 기호로 시작해 같은 기호가 다시 나올 때까지 이어지는 블록 주석 두 가지 방식이 있다.
- NOP(No Operation)은 1바이트를 차지하며 아무 동작도 하지 않는 명령으로, 코드를 효율적인 주소 경계에 맞추기 위해 컴파일러·어셈블러가 삽입하기도 한다.

## 2. 예제: 정수 더하고 빼기 (Example: Adding and Subtracting Integers, 3.2)

### 2.1 AddTwo 프로그램 (The AddTwo Program, 3.2.1)
- 완전히 동작하는 AddTwo.asm:
  ```
  .386
  .model flat,stdcall
  .stack 4096
  ExitProcess PROTO, dwExitCode:DWORD

  .code
  main PROC
    mov   eax,5
    add   eax,6
    INVOKE ExitProcess,0
  main ENDP
  END main
  ```
- `.386`은 32비트 레지스터·주소에 접근 가능한 최소 CPU를 지정한다. `.model flat,stdcall`에서 flat은 protected mode용 코드를 생성한다는 뜻이고, stdcall은 32비트 윈도우 서비스 호출에 필요한 calling convention이다. `.stack 4096`은 런타임 스택에 4096바이트를 확보하며, 이 스택은 파라미터·복귀 주소·지역 변수를 저장하는 데 쓰인다.
- `ExitProcess PROTO, dwExitCode:DWORD`는 함수 프로토타입 선언이다. dwExitCode는 운영체제로 반환되는 값으로, 0은 대개 성공, 그 외는 오류 코드를 의미한다.
- main ENDP는 시작한 이름(main)과 같아야 하고, END main은 어셈블할 마지막 줄을 표시하는 동시에 프로그램 entry point를 지정한다.

### 2.2 AddTwo 프로그램 실행과 디버깅 (Running and Debugging the AddTwo Program, 3.2.2)
- 비주얼 스튜디오에서 새 소스 파일 추가 → Build Project(Error List에서 에러 확인, 성공 시 "Build succeeded") → 디버깅(Step Over F10/Shift+F8, 또는 breakpoint 설정 후 Start Debugging) 순으로 진행한다. breakpoint에서 멈추면 그 줄은 아직 실행되지 않은 상태다.
- Registers 창(Debug→Windows→Registers)에서 레지스터 값을 볼 수 있고, 우클릭 Flags로 개별 상태 플래그를 볼 수 있다: OV(overflow), UP(direction), EI(interrupt), PL(sign), ZR(zero), AC(auxiliary carry), PE(parity), CY(carry). 실행 중 값이 바뀐 레지스터는 빨간색으로 강조 표시된다.
- 변수 값은 마우스를 올리거나 Watch 창(Watch1~4)에 드래그해 지켜볼 수 있다.
- 어셈블-링크-실행 사이클: Step1(text editor로 source file 작성) → Step2(assembler가 object file, 옵션으로 listing file 생성. 에러 시 Step1로 복귀) → Step3(linker가 link library의 필요한 프로시저를 결합해 executable file 생성) → Step4(OS loader가 실행 파일을 메모리에 읽어 시작 주소로 분기).

### 2.3 프로그램 템플릿 (Program Template, 3.2.3)
- 재사용 가능한 shell program(Template.asm)은 다음 골격을 갖춘다.
  ```
  .386
  .model flat,stdcall
  .stack 4096
  ExitProcess PROTO, dwExitCode:DWORD

  .data
      ; declare variables here
  .code
  main PROC
      ; write your code here
      INVOKE ExitProcess,0
  main ENDP
  END main
  ```
  프로그램 설명, 작성자 이름, 작성 날짜, 수정 정보 등을 주석으로 남기는 것이 이후 코드를 다시 볼 때 도움이 된다.

## 3. 어셈블·링크·실행 (Assembling, Linking, and Running Programs, 3.3)

### 3.1 어셈블-링크-실행 사이클 (The Assemble-Link-Execute Cycle, 3.3.1)
- 어셈블리 소스는 목표 컴퓨터에서 바로 실행될 수 없다. assembler가 기계어 object file로 번역하고, linker가 object file과 link library의 프로시저를 결합해 executable file을 만든다.
- 명령줄 예: `ml /c /coff AddTwo.asm`(어셈블), `link file1.obj ... /SUBSYSTEM:CONSOLE /OUT:Program.exe`(링크).

### 3.2 리스팅 파일 (Listing File, 3.3.2)
- Listing file에는 소스 코드 사본, 각 명령어의 주소, 기계 코드 바이트(16진수), 심볼 테이블이 담긴다. 숙련된 프로그래머는 이를 이용해 프로그램의 상세 정보를 확인한다.
- AddTwo 리스팅 예: .code 세그먼트는 오프셋 00000000에서 시작하고(실제 메모리 적재 시 절대 주소로 변환됨), `mov eax,5`는 opcode B8과 32비트 값 00000005로 번역된다. INVOKE ExitProcess,0은 실제로는 PUSH와 CALL 두 문장으로 확장되어 어셈블된다.

## 4. 데이터 정의 (Defining Data, 3.4)

### 4.1 내장 데이터 타입 (Intrinsic Data Types, 3.4.1)
- Intrinsic data types는 크기, 부호 유무, 정수/실수 여부로 데이터를 구분한다. 예를 들어 DWORD(32비트, 부호 없음)와 SDWORD(32비트, 부호 있음)는 서로 바꿔 쓸 수 있는데, 어셈블러는 오직 크기만 검사하고 부호를 강제로 검사하지 않는다.

  | 타입 | 용도 |
  |---|---|
  | BYTE / SBYTE | 8비트 부호 없는/있는 정수 |
  | WORD / SWORD | 16비트 부호 없는/있는 정수 |
  | DWORD / SDWORD | 32비트 부호 없는/있는 정수 |
  | FWORD | 48비트 정수(보호 모드 far 포인터) |
  | QWORD | 64비트 정수 |
  | TBYTE | 80비트(10바이트) 정수 |
  | REAL4 / REAL8 / REAL10 | 4/8/10바이트 IEEE 실수 |

### 4.2 데이터 정의문 (Data Definition Statement, 3.4.2)
- `[name] directive initializer [,initializer]...` 형식으로 메모리에 변수 저장 공간을 확보한다. initializer는 값이 0이라도 최소 하나는 필요하며, `?`를 쓰면 미초기화 상태로 남는다.
- 레거시 directive: DB(8비트), DW(16비트), DD(32비트 정수/실수), DQ(64비트 정수/실수), DT(80비트 정수 정의). 초기값 표기 방식(00110010b, 32h, 50d)이 달라도 어셈블러는 모두 같은 이진 데이터로 변환한다.

### 4.3 AddTwo 프로그램에 변수 추가 (Adding a Variable to the AddTwo Program, 3.4.3)
- sum DWORD 0을 추가한 AddTwoSum 버전에서 `mov sum,eax`까지 실행하면 sum 값은 11이 된다. Watch 창에 드래그하거나 마우스를 올려 값을 확인할 수 있다.

### 4.4 BYTE와 SBYTE 데이터 정의 (Defining BYTE and SBYTE Data, 3.4.4)
- BYTE/SBYTE는 8비트 저장 공간을 할당한다. 예: `value2 BYTE 0`(최소 unsigned byte), `value4 SBYTE -128`(최소 signed byte), `value6 BYTE ?`(미초기화). DB로도 8비트 변수를 정의할 수 있다.
- Multiple initializers를 쓰면 라벨은 오직 첫 번째 초기값의 오프셋만 가리킨다. `list BYTE 10,20,30,40`에서 list=0000(값10), 0001(20), 0002(30), 0003(40)이다. 라벨 없이 이어서 더 정의할 수도 있다.
- 문자열은 null-terminated string(끝에 0 바이트)으로 정의한다(`greeting1 BYTE "Good afternoon",0`). 줄 연속 문자(`\`)로 여러 줄에 나눠 쓸 수 있고, 0Dh·0Ah는 CR/LF(줄바꿈) 문자다.
- DUP 연산자는 정수 표현식을 카운터로 써서 반복 데이터를 만든다: `BYTE 20 DUP(0)`(20바이트 0), `BYTE 20 DUP(?)`(미초기화 20바이트), `BYTE 4 DUP("STACK")`("STACKSTACKSTACKSTACK").

### 4.5 WORD와 SWORD 데이터 정의 (Defining WORD and SWORD Data, 3.4.5)
- WORD/SWORD는 16비트 저장 공간을 만든다(`word1 WORD 65535`, `word2 SWORD -32768`). 레거시 DW도 쓸 수 있다. 배열은 원소를 나열하거나 DUP를 쓴다: `myList WORD 1,2,3,4,5`는 각 원소가 2바이트라 오프셋이 2씩 증가한다.

### 4.6 DWORD와 SDWORD 데이터 정의 (Defining DWORD and SDWORD Data, 3.4.6)
- DWORD/SDWORD는 32비트 저장 공간을 만든다(레거시 DD도 가능). DWORD는 다른 변수의 오프셋을 담는 포인터 변수로도 쓸 수 있다(`pVal DWORD val3`). 더블워드 배열의 각 원소는 4바이트씩 차지한다.

### 4.7 QWORD 데이터 정의 (Defining QWORD Data, 3.4.7)
- QWORD는 64비트(8바이트) 값을 위한 저장 공간을 할당한다(`quad1 QWORD 1234567812345678h`). 레거시 DQ도 같은 용도로 쓴다.

### 4.8 팩드 BCD(TBYTE) 데이터 정의 (Defining Packed BCD (TBYTE) Data, 3.4.8)
- Packed BCD는 정수를 10바이트 패키지로 저장하며, 최상위 바이트를 제외한 각 바이트가 두 개의 10진 숫자를 담는다. 최상위 바이트의 최상위 비트가 부호를 나타낸다(80h=음수, 00h=양수). 표현 범위는 -999,999,999,999,999,999 ~ +999,999,999,999,999,999다.
- TBYTE로 선언하며 초기값은 반드시 16진수로 써야 한다: `intVal TBYTE 800000000000001234h`(-1234, 유효), `intVal TBYTE -1234`(무효, 이진 정수로 인코딩되기 때문). Real 값을 BCD로 바꾸려면 FLD로 부동소수점 스택에 올린 뒤 FBSTP로 반올림해 변환한다.

### 4.9 부동소수점 타입 정의 (Defining Floating-Point Types, 3.4.9)
- REAL4(4바이트, 유효자릿수 6, 범위 약 1.18×10⁻³⁸~3.40×10³⁸), REAL8(8바이트, 15자릿수), REAL10(10바이트, 19자릿수)이며, 레거시 DD/DQ/DT로도 정의 가능하다. 이 값들은 유한한 정밀도·범위를 가지는 부동소수점 값이라는 점에서 수학적 실수와 다르다.

### 4.10 변수를 더하는 프로그램 (A Program That Adds Variables, 3.4.10)
- x86 명령어 집합은 한 변수를 다른 변수에 직접 더하는 것을 허용하지 않으므로, EAX를 accumulator로 써서 순서대로 더한다.
  ```
  mov eax,firstval
  add eax,secondval
  add eax,thirdval
  mov sum,eax
  ```
  firstval=20002000h, secondval=11111111h, thirdval=22222222h일 때 최종 sum은 16진수 53335333이 된다.

### 4.11 리틀 엔디안 순서 (Little-Endian Order, 3.4.11)
- x86 프로세서는 little-endian(최하위 바이트부터 낮은 주소에 저장) 순서를 쓴다. 더블워드 12345678h가 오프셋 0000에 저장되면 78h(0000), 56h(0001), 34h(0002), 12h(0003) 순으로 저장된다.
- big-endian(최상위 바이트부터 저장)을 쓰는 시스템도 있으며, 같은 값을 저장하면 순서가 반대(12,34,56,78)가 된다.

  | 구분 | little-endian | big-endian |
  |---|---|---|
  | 대표 CPU | Intel 계열 | AMD 계열 |
  | 특징 | 연산에 최적화 | 네트워크 전송에 최적화 |
  | 저장 순서 | 최하위 바이트부터 저장 | 최상위 바이트부터 저장 |

### 4.12 초기화되지 않은 데이터 선언 (Declaring Uninitialized Data, 3.4.12)
- `.DATA?` 지시어는 미초기화 데이터를 선언하며, 대용량 미초기화 블록을 정의할 때 컴파일된 프로그램의 크기를 줄여준다(예: `bigArray DWORD 5000 DUP(?)`를 `.data?` 아래 두면 실제 값을 담지 않아 프로그램이 커지지 않는다).
- 어셈블러는 .code와 .data를 프로그램 안에서 자유롭게 오갈 수 있게 해준다. 다만 이렇게 섞어 쓰면 프로그램이 읽기 어려워질 수 있다.

## 5. 심볼릭 상수 (Symbolic Constants, 3.5)

- Symbol(심볼릭 상수)은 식별자를 정수 표현식이나 텍스트와 연결한 것으로 저장 공간을 쓰지 않고 assembler가 스캔할 때만 쓰이며 runtime에 값이 바뀌지 않는다. 반면 variable은 저장 공간을 쓰고 runtime에 값이 바뀔 수 있다.

### 5.1 등호 지시어 (Equal-Sign Directive, 3.5.1)
- `name = expression` 형식으로 심볼 이름을 정수 표현식과 연결한다. 예를 들어 `COUNT = 500`으로 정의해 두면 이후 `mov eax, COUNT`는 어셈블 시 `mov eax, 500`으로 치환된다. 값을 한 번만 재정의하면 프로그램 전체의 COUNT 사용처가 자동으로 바뀌므로 유지보수가 쉬워진다.
- Current location counter($)는 현재 프로그램 문장의 오프셋을 가리키는 심볼이다(`selfPtr DWORD $`).
- 등호(=)로 정의한 심볼은 같은 소스 파일 안에서 재정의(redefinition)할 수 있다. 재정의는 실행 순서와 무관하게 어셈블러가 소스를 순차적으로 스캔하는 순서(전처리 단계)에 따라 반영된다.

### 5.2 배열과 문자열의 크기 계산 (Calculating the Sizes of Arrays and Strings, 3.5.2)
- 배열 크기를 직접 숫자로 적으면 나중에 원소를 추가·삭제할 때 값을 놓쳐 오류가 생기기 쉽다. `ListSize = ($ - list)`처럼 현재 위치 카운터에서 시작 오프셋을 빼면 어셈블러가 자동으로 계산해 준다. 단, ListSize는 반드시 list 정의 바로 다음에 와야 정확하다.
- 워드/더블워드처럼 바이트가 아닌 배열은 전체 바이트 크기를 원소 크기(2 또는 4)로 나눠야 원소 개수가 나온다.

### 5.3 EQU 지시어 (EQU Directive, 3.5.3)
- EQU는 심볼 이름을 정수 표현식, 기존 심볼, 또는 임의의 텍스트(`<text>`)와 연결한다. 정수로 계산되지 않는 값을 정의할 때 유용하다(`PI EQU <3.1416>`).
- `matrix1 EQU 10 * 10`처럼 정수 표현식으로 쓰면 계산된 값(100)이 대입되지만, `matrix2 EQU <10 * 10>`처럼 텍스트로 감싸면 "10 * 10" 텍스트 자체가 그대로 복사된다.
- EQU로 정의한 심볼은 등호(=)와 달리 같은 파일 안에서 재정의할 수 없다.

### 5.4 TEXTEQU 지시어 (TEXTEQU Directive, 3.5.4)
- TEXTEQU는 EQU와 비슷하게 text macro를 만든다. 텍스트, 기존 텍스트 매크로, 상수 표현식(`%constExpr`) 세 형식으로 대입할 수 있다.
- 텍스트 매크로는 서로 조합해 쌓아 올릴 수 있다(`move TEXTEQU <mov>`, `setupAL TEXTEQU <move al,count>` → 최종적으로 `mov al,10`으로 어셈블). TEXTEQU로 정의한 심볼은 언제든 재정의할 수 있다.

## 6. 64비트 프로그래밍 (64-Bit Programming, 3.6)

- MASM은 64비트 코드를 지원하며, 32비트 버전과 비교했을 때 다음과 같은 차이가 있다.
  - `.386`, `.model flat,stdcall`, `.stack 4096`이 필요 없다.
  - PROTO 선언에 매개변수를 붙이지 않는다(`ExitProcess PROTO`).
  - INVOKE 대신 mov+call 두 명령으로 프로그램을 종료한다(`mov ecx,0` / `call ExitProcess`).
  - END 지시어가 진입점을 지정하지 않는다.
- 32비트보다 큰 값을 다루려면 64비트 레지스터(RAX 등)와 변수(QWORD)를 쓰면 된다(`sum QWORD 0`, `mov rax,5`, `add rax,6`, `mov sum,rax`).
- 비주얼 스튜디오 12에 포함된 64비트 MASM 11.0은 INVOKE 지시어를 지원하지 않으며, 64비트 프로그램은 반드시 64비트 윈도우에서 실행해야 한다.
