# 10장. Structures and Macros (어셈블리 프로그래밍)

## 1. 구조체 (Structures, 10.1)
- 구조체는 논리적으로 관련된 변수들을 하나로 묶은 틀(템플릿)이다. 구조체 안의 각 변수를 필드(field)라고 한다. 프로그램은 구조체 전체를 한 덩어리로 다룰 수도 있고, 필드 하나씩 접근할 수도 있다. 보통 필드마다 자료형이 다르다.
- 유니언(union)도 여러 식별자를 묶지만, 모든 식별자가 같은 메모리 영역을 겹쳐서 쓴다는 점이 다르다(1.7절).
- 구조체를 쓰면 데이터를 묶어서 프로시저에 넘기기 쉽다. 예를 들어 인자가 20개인 프로시저는 순서·개수를 틀리기 쉽지만, 구조체에 모두 넣고 그 주소 하나만 넘기면 스택도 주소 하나(4바이트)만 쓰고, 호출된 쪽에서 구조체 내용을 직접 고칠 수도 있다.
- 어셈블리의 구조체는 C/C++ 구조체와 사실상 같아서, Windows API의 구조체도 약간만 옮기면 그대로 쓸 수 있다.
- 구조체 사용 3단계:
  1. 구조체를 정의한다.
  2. 그 타입의 변수(구조체 변수)를 하나 이상 선언한다.
  3. 실행 명령어로 필드에 접근한다.

```asm
COORD STRUCT          ; Windows API의 화면 좌표 구조체
    X WORD ?          ; offset 00
    Y WORD ?          ; offset 02
COORD ENDS
```

### 1.1 구조체 정의 (Defining Structures, 10.1.1)
- STRUCT와 ENDS 지시어로 정의한다. 안의 필드는 일반 변수 선언과 같은 문법으로 쓰고, 필드 개수 제한은 사실상 없다.

```asm
name STRUCT
    field-declarations
name ENDS
```

- 필드 초기값(field initializer): 구조체 변수를 만들 때 이 값이 들어간다.
  - `?` : 값 미정
  - 문자열 리터럴: 따옴표로 감싼 문자열
  - 정수: 정수 상수나 정수 식
  - 배열: DUP 연산자로 배열 원소 초기화

```asm
Employee STRUCT
    IdNum    BYTE "000000000"
    LastName BYTE 30 DUP(0)
    Years    WORD 0
    SalaryHistory DWORD 0,0,0,0
Employee ENDS
```

- 구조체 정의는 그 타입의 변수를 선언하는 곳보다 앞에 있어야 한다.

#### 필드 정렬 (Aligning Structure Fields)
- 메모리 접근 성능을 위해 각 필드는 자기 자료형 크기에 맞는 주소 경계에 있어야 한다. 그렇지 않으면 CPU가 그 필드에 접근하는 데 시간이 더 걸린다(예: DWORD는 4의 배수 주소).
- `ALIGN datatype` 지시어는 다음 필드나 변수의 주소를 해당 경계에 맞춘다. 필요하면 앞에 빈 바이트(패딩)를 넣는다.

```asm
Employee STRUCT
    IdNum    BYTE "000000000"     ; 9
    LastName BYTE 30 DUP(0)       ; 30
    ALIGN    WORD                 ; 1 byte added  (39 → 40)
    Years    WORD 0               ; 2
    ALIGN    DWORD                ; 2 bytes added (42 → 44)
    SalaryHistory DWORD 0,0,0,0   ; 16
Employee ENDS                     ; 60 total
```

| 멤버 타입 | 정렬 경계 |
|---|---|
| BYTE, SBYTE | 8비트(바이트) |
| WORD, SWORD | 16비트(워드) |
| DWORD, SDWORD | 32비트(더블워드) |
| QWORD | 64비트(쿼드워드) |
| REAL4 | 32비트 |
| REAL8 | 64비트 |
| structure | 멤버 중 가장 큰 정렬 요구 |
| union | 첫 번째 멤버의 정렬 요구 |

### 1.2 구조체 변수 선언 (Declaring Structure Variables, 10.1.2)
- 문법: `identifier structureType < initializer-list >`
- 초기값 목록은 생략 가능하다. 쓰는 경우 쉼표로 구분한 어셈블 시점 상수이고, 필드 선언 순서대로 왼쪽부터 채운다.
- 빈 꺾쇠 `< >`는 정의에 적힌 기본값을 그대로 쓴다. 일부 필드만 새 값으로 덮어쓸 수도 있다.

```asm
.data
point1 COORD <5,10>        ; X = 5,  Y = 10
point2 COORD <20>          ; X = 20, Y = ?
point3 COORD <>            ; X = ?,  Y = ?
worker Employee <>         ; 기본값

person1 Employee <"555223333">     ; IdNum만 덮어씀
person2 Employee {"555223333"}     ; 중괄호 { }도 가능
person3 Employee <,"dJones">       ; 쉼표로 IdNum 건너뛰고 LastName 지정
person4 Employee <,,,2 DUP(20000)> ; SalaryHistory 앞 2개만 20000, 나머지 0
```

- 문자열 필드에 필드보다 짧은 문자열을 주면 남는 자리는 공백으로 채운다. 끝에 null 바이트가 자동으로 붙지 않는다.
- 배열 필드에 초기값을 덜 주면 나머지는 0으로 채운다.
- 쉼표를 자리 표시자로 써서 필드를 건너뛸 수 있다.

#### 구조체 배열과 변수 정렬
- DUP로 구조체 배열을 만든다.

```asm
NumPoints = 3
AllPoints COORD NumPoints DUP(<0,0>)
```

- 구조체 변수 자체도 가장 큰 멤버 크기 경계에 정렬하는 것이 좋다. Employee는 DWORD 필드가 있으므로 `ALIGN DWORD` 뒤에 선언한다.

### 1.3 구조체 변수 참조 (Referencing Structure Variables, 10.1.3)
- TYPE과 SIZEOF로 구조체 크기를 얻는다. TYPE은 저장 단위 바이트 수, LENGTHOF는 배열 원소 개수, SIZEOF = LENGTHOF × TYPE이다.

```asm
TYPE Employee     ; 60
SIZEOF Employee   ; 60
SIZEOF worker     ; 60
```

- 필드 참조에는 구조체 이름(또는 변수)을 한정자로 붙인다(`.` 연산자). 아래는 어셈블 시점에 계산되는 상수식이다.

```asm
TYPE Employee.SalaryHistory      ; 4
LENGTHOF Employee.SalaryHistory  ; 4
SIZEOF Employee.SalaryHistory    ; 16
TYPE Employee.Years              ; 2
```

- 실행 시점 참조 예:

```asm
mov dx,worker.Years
mov worker.SalaryHistory,20000         ; 첫 번째 급여
mov [worker.SalaryHistory+4],30000     ; 두 번째 급여 (DWORD라서 +4)
mov edx,OFFSET worker.LastName         ; 필드 주소
```

#### 간접·인덱스 피연산자
- 레지스터(ESI 등)로 구조체 필드를 가리킬 수 있다. 구조체 주소를 프로시저에 넘기거나 구조체 배열을 다룰 때 유용하다. 이때는 반드시 PTR로 구조체 타입을 알려 줘야 한다.

```asm
mov esi,OFFSET worker
mov ax,(Employee PTR [esi]).Years   ; OK
mov ax,[esi].Years                  ; 오류: Years가 어느 구조체 필드인지 모름
```

- 인덱스 피연산자로 구조체 배열의 원소에 접근한다. 인덱스는 "원소 번호 × TYPE 구조체"이다.

```asm
.data
department Employee 5 DUP(<>)
.code
mov esi,TYPE Employee            ; index = 1 (두 번째 직원)
mov department[esi].Years, 4
```

#### 배열 순회 예제 (AllPoints.asm)

```asm
INCLUDE Irvine32.inc
NumPoints = 3
.data
ALIGN WORD
AllPoints COORD NumPoints DUP(<0,0>)
.code
main PROC
    mov  edi,0                 ; array index
    mov  ecx,NumPoints         ; loop counter
    mov  ax,1                  ; starting X, Y values
L1: mov  (COORD PTR AllPoints[edi]).X,ax
    mov  (COORD PTR AllPoints[edi]).Y,ax
    add  edi,TYPE COORD        ; 다음 원소 (4바이트)
    inc  ax
    loop L1
    exit
main ENDP
END main
```
- 결과: (1,1), (2,2), (3,3)

#### 정렬된 멤버의 성능
- 정렬 안 한 EmployeeBad와 ALIGN을 넣은 Employee로, 0FFFFFFFFh번 루프 돌며 `emp.Years`, `emp.SalaryHistory`에 쓰는 시간을 GetMSeconds로 쟀다.
- 결과: 정렬 6141ms, 비정렬 6203ms로 62ms 차이. 차이가 작은 것은 CPU 내부 캐시가 정렬 문제를 상당 부분 가려 주기 때문으로 보인다.

### 1.4 예제: 시스템 시간 표시 (Displaying the System Time, 10.1.4)
- Windows 콘솔 함수로 커서 위치를 정하고 시스템 시간을 읽는다. 미리 정의된 COORD, SYSTEMTIME 구조체를 쓴다(둘 다 SmallWin.inc에 있고 Irvine32.inc가 포함함).

```asm
SYSTEMTIME STRUCT
    wYear WORD ?
    wMonth WORD ?
    wDayOfWeek WORD ?
    wDay WORD ?
    wHour WORD ?
    wMinute WORD ?
    wSecond WORD ?
    wMilliseconds WORD ?
SYSTEMTIME ENDS
```

- 사용하는 API:
  - `GetLocalTime`: SYSTEMTIME 주소를 받아 현지 시간을 채운다.
  - `GetStdHandle`: 표준 콘솔 출력 핸들(정수)을 돌려준다. 인자는 `STD_OUTPUT_HANDLE`(= -11).
  - `SetConsoleCursorPosition`: 핸들과 COORD(값 전달)를 받아 커서를 옮긴다.
- 필드는 WORD라서 WriteDec 전에 `movzx eax, ...`로 32비트로 넓힌다.

```asm
; ShowTime.asm
INCLUDE Irvine32.inc
.data
sysTime SYSTEMTIME <>
XYPos COORD <10,5>
consoleHandle DWORD ?
colonStr BYTE ":",0
.code
main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov consoleHandle,eax
    INVOKE SetConsoleCursorPosition, consoleHandle, XYPos
    INVOKE GetLocalTime, ADDR sysTime
    movzx eax,sysTime.wHour      ; hours
    call WriteDec
    mov   edx,OFFSET colonStr    ; ":"
    call WriteString
    movzx eax,sysTime.wMinute    ; minutes
    call WriteDec
    call WriteString
    movzx eax,sysTime.wSecond    ; seconds
    call WriteDec
    call Crlf
    call WaitMsg
    exit
main ENDP
END main
```
- 출력 예: `12:16:35`

### 1.5 구조체를 포함하는 구조체 (Structures Containing Structures, 10.1.5)
- 구조체의 필드로 다른 구조체를 넣을 수 있다. 예: 사각형 = 왼쪽 위 + 오른쪽 아래 COORD.

```asm
Rectangle STRUCT
    UpperLeft  COORD <>
    LowerRight COORD <>
Rectangle ENDS

rect1 Rectangle < >
rect2 Rectangle { }
rect3 Rectangle { {10,10}, {50,20} }
rect4 Rectangle < <10,10>, <50,20> >
```

- 중첩 필드는 점을 이어서 참조한다. 간접 참조나 OFFSET도 중첩 필드까지 쓸 수 있다.

```asm
mov rect1.UpperLeft.X, 10
mov esi,OFFSET rect1
mov (Rectangle PTR [esi]).UpperLeft.Y, 10
mov edi,OFFSET rect2.LowerRight
mov (COORD PTR [edi]).X, 50
mov edi,OFFSET rect2.LowerRight.X
mov WORD PTR [edi], 50
```

### 1.6 예제: 술 취한 사람의 걸음 (Drunkard's Walk, 10.1.6)
- 교수가 격자 중앙(25,25)에서 출발해 매 걸음 북·남·동·서 중 하나를 무작위로 고르며 걷는 시뮬레이션이다. 각 걸음 위치를 COORD 배열에 저장한다.

```asm
WalkMax = 50
DrunkardWalk STRUCT
    path COORD WalkMax DUP(<0,0>)   ; 걸음 위치 배열
    pathsUsed WORD 0                ; 실제 걸은 수
DrunkardWalk ENDS
```

- 핵심 흐름(TakeDrunkenWalk, ESI = 구조체 주소):
  - `mov edi,esi` / `add edi,OFFSET DrunkardWalk.path` 로 path 배열 시작 주소를 EDI에 구한다. 여기서 `OFFSET DrunkardWalk.path`는 구조체 시작으로부터 필드까지의 거리(0)이다.
  - 현재 위치 currX, currY(LOCAL 변수)를 StartX, StartY로 초기화하고, ECX = WalkMax로 루프한다.
  - 루프마다 현재 위치를 `(COORD PTR [edi]).X/Y`에 저장하고 화면에 출력한 뒤, `RandomRange(4)`로 0~3을 골라 방향을 바꾼다.
  - `add edi,TYPE COORD`로 다음 칸으로 간다.
  - 끝나면 `mov (DrunkardWalk PTR [esi]).pathsUsed, WalkMax`로 걸음 수를 기록한다.

```asm
Again:
    mov ax,currX
    mov (COORD PTR [edi]).X,ax
    mov ax,currY
    mov (COORD PTR [edi]).Y,ax
    INVOKE DisplayPosition, currX, currY
    mov eax,4                  ; choose a direction (0-3)
    call RandomRange
    .IF eax == 0               ; North
      dec currY
    .ELSEIF eax == 1           ; South
      inc currY
    .ELSEIF eax == 2           ; West
      dec currX
    .ELSE                      ; East
      inc currX
    .ENDIF
    add edi,TYPE COORD         ; point to next COORD
    loop Again
```

- 현재 버전에서는 pathsUsed가 항상 WalkMax이지만, 호수·건물 같은 장애물을 검사하도록 바꾸면 루프가 일찍 끝나 더 작아질 수 있다.

### 1.7 유니언 선언과 사용 (Declaring and Using Unions, 10.1.7)
- 구조체는 필드마다 오프셋이 다르지만, 유니언은 모든 필드가 같은 오프셋(0)에서 시작한다. 유니언 크기 = 가장 긴 필드 크기.

```asm
unionname UNION          ; 독립 선언
    union-fields
unionname ENDS

structname STRUCT        ; 구조체 안에 직접 선언
    structure-fields
    UNION unionname
        union-fields
    ENDS
structname ENDS
```

- 필드 선언 규칙은 구조체와 같지만, 각 필드는 초기값을 하나만 가질 수 있다.

```asm
Integer UNION
    D DWORD 0
    W WORD 0
    B BYTE 0
Integer ENDS
```

- 초기값은 모두 같은 값으로 맞추는 것이 좋다. D=1, W=5, B=8처럼 다르게 줘도 어셈블러는 첫 필드 값만 쓰므로 `myInt Integer <>`의 D, W, B는 모두 1이 된다.
- 구조체 안에 유니언을 넣는 방법은 두 가지다: 이미 정의한 유니언 타입을 필드로 쓰기(`FileID Integer <>`), 또는 구조체 안에서 `UNION FileID ... ENDS`로 직접 선언하기.
- 유니언 변수 선언은 구조체와 같지만 초기값은 최대 1개만 허용된다.

```asm
val1 Integer <12345678h>
val2 Integer <100h>
val3 Integer <>
mov val3.B, al      ; 사용할 땐 반드시 필드 이름을 지정
mov val3.W, ax      ; 같은 메모리를 다른 크기로 접근
mov val3.D, eax
```

- 유니언은 구조체도 담을 수 있다. 예: Windows의 INPUT_RECORD는 EventType 필드로 어떤 레코드인지 표시하고, Event 유니언 안에 KEY_EVENT_RECORD, MOUSE_EVENT_RECORD 등 여러 구조체 중 하나만 쓴다(크기·배치가 달라도 한 번에 하나만 사용).

## 2. 매크로 (Macros, 10.2)

### 2.1 개요 (Overview, 10.2.1)
- 매크로 프로시저는 이름 붙인 명령어 묶음이다. 매크로를 호출하면 그 코드 사본이 호출한 자리에 그대로 삽입된다. 이를 인라인 확장(inline expansion)이라 한다. "호출"이라고 부르지만 실제 CALL 명령어는 없다.
- 값을 반환하지 않는 것이 매크로 프로시저, 값을 반환하는 것이 매크로 함수다. 보통 "매크로"는 매크로 프로시저를 뜻한다.
- 배치: 매크로 정의는 보통 소스 맨 앞에 두거나 별도 파일에 넣고 INCLUDE로 가져온다. 매크로는 어셈블러의 전처리 단계(preprocessing step)에서 확장된다.
  - 전처리기는 매크로 정의를 읽고 나머지 소스를 훑으면서, 호출 위치마다 매크로 코드를 끼워 넣는다.
  - 호출보다 정의가 먼저 나와야 한다.
  - 정의만 하고 호출하지 않은 매크로는 실행 파일에 코드가 생기지 않는다.

```asm
PrintX MACRO
    mov  al,'X'
    call WriteChar
ENDM
.code
PrintX          ; → mov al,'X' / call WriteChar 로 치환 (텍스트 치환)
```

### 2.2 매크로 정의 (Defining Macros, 10.2.2)

```asm
macroname MACRO parameter-1, parameter-2...
    statement-list
ENDM
```

- MACRO와 ENDM 사이 문장은 호출될 때까지 어셈블되지 않는다. 매개변수 개수 제한은 없고 쉼표로 구분한다.
- 관례: 본문은 들여쓰기하고, 이름 앞에 m을 붙인다(mPutChar, mWriteString, mGotoxy).
- 매개변수는 호출자가 넘긴 텍스트 인자를 받는 자리표시자다. 정수·변수 이름 등 무엇을 넘겨도 전처리기는 텍스트로만 취급하고 타입 검사를 하지 않는다. 타입이 안 맞으면 확장된 뒤 어셈블러가 오류를 낸다.

```asm
mPutchar MACRO char
    push eax
    mov  al,char
    call WriteChar
    pop  eax
ENDM
```

### 2.3 매크로 호출 (Invoking Macros, 10.2.3)
- 문법: `macroname argument-1, argument-2, ...`
- 인자 순서는 매개변수 순서와 같아야 하지만 개수는 달라도 된다. 인자가 많으면 경고, 적으면 남는 매개변수는 빈칸이 된다.
- 리스팅 파일(.LST)에서 확장 결과를 볼 수 있다. 왼쪽 숫자 1은 매크로 확장 레벨이고, 매크로 안에서 다른 매크로를 부르면 증가한다.

```asm
        mov  al,'A'
        mov  ecx,20
L1:     mPutchar al           ; macro call
1       push eax
1       mov  al,al
1       call WriteChar
1       pop  eax
        inc  al
        loop L1               ; A~T 20글자 출력
```

- 매크로 vs 프로시저: 매크로는 CALL/RET 오버헤드가 없어 보통 더 빠르다. 대신 큰 매크로를 여러 번 호출하면 호출마다 코드가 복사되어 프로그램 크기가 커진다.
- 디버깅: 어셈블 후 .LST 파일로 확장 결과를 확인하고, 디버거의 디스어셈블리 화면에서 매크로 호출 뒤에 생성된 코드를 볼 수 있다. Irvine32는 STDCALL 규약이라 함수 이름 앞에 `_`가 붙어 보인다(예: `_Gotoxy@0`).

### 2.4 추가 매크로 기능 (Additional Macro Features, 10.2.4)

#### 필수 매개변수 (REQ)
- `매개변수:REQ`로 지정하면 인자 없이 호출했을 때 어셈블러가 오류를 낸다. 필수 매개변수가 여럿이면 각각에 REQ를 붙인다.

```asm
mPutchar MACRO char:REQ
```

#### 매크로 주석
- 매크로 안의 일반 주석(`;`)은 확장될 때마다 같이 복사된다. 확장 결과에서 빼고 싶으면 `;;`로 쓴다.

#### ECHO 지시어
- 어셈블하는 동안 표준 출력에 문자열을 표시한다. 실행 중이 아니라 어셈블 중에 나온다.

```asm
mPutchar MACRO char:REQ
    ECHO Expanding the mPutchar macro
    ...
ENDM
```

#### LOCAL 지시어
- 매크로 안에 라벨(데이터 이름, 코드 라벨)이 있으면 두 번 호출 시 같은 이름이 두 번 정의되어 오류가 난다.
- `LOCAL 라벨`로 선언하면 전처리기가 확장할 때마다 `??nnnn` 형태의 고유 이름으로 바꿔 준다. 코드 라벨(L1 등)에도 LOCAL을 써야 한다.

```asm
makeString MACRO text
    LOCAL string
    .data
    string BYTE text,0
ENDM
; makeString "Hello"   → ??0000 BYTE "Hello",0
; makeString "Goodbye" → ??0001 BYTE "Goodbye",0
```

#### 코드와 데이터를 함께 가진 매크로

```asm
mWrite MACRO text
    LOCAL string               ;; local label
    .data
    string BYTE text,0         ;; define the string
    .code
    push edx
    mov  edx,OFFSET string
    call WriteString
    pop  edx
ENDM
```
- 호출할 때마다 문자열이 고유 라벨(??0000, ??0001...)로 데이터 영역에 생기고, MOV도 그 라벨을 가리키도록 맞춰진다.

#### 중첩 매크로 (Nested Macros)
- 매크로 안에서 다른 매크로를 호출하는 것. 전처리기는 그 자리에서 다시 확장하며, 바깥 매크로의 인자는 안쪽 매크로에 그대로 전달된다.
- 짧고 단순한 매크로를 만들어 조합하는 모듈식 설계가 좋다.

```asm
mWriteln MACRO text
    mWrite text        ; 중첩 호출 (확장 레벨 2)
    call   Crlf        ; 레벨 1
ENDM
```

### 2.5 교재 매크로 라이브러리 (Using the Book's Macro Library, 10.2.5)
- `INCLUDE Macros.inc`를 Irvine32.inc 다음에 추가하면 쓸 수 있다(32비트 모드 전용). 일부는 Irvine32 프로시저의 래퍼(wrapper)이고, 일부는 새 기능이다.

| 매크로 | 매개변수 | 설명 |
|---|---|---|
| mDump | varName, useLabel | 변수를 이름·기본 속성대로 표시 |
| mDumpMem | address, itemCount, componentSize | 메모리 범위 표시 |
| mGotoxy | X, Y | 콘솔 커서 위치 지정 |
| mReadString | varName | 키보드에서 문자열 입력 |
| mShow | itsName, format | 변수/레지스터를 여러 형식으로 표시 |
| mShowRegister | regName, regValue | 32비트 레지스터 이름과 값을 16진수로 표시 |
| mWrite | text | 문자열 리터럴 출력 |
| mWriteSpace | count | 공백 출력(기본 1개) |
| mWriteString | buffer | 문자열 변수 내용 출력 |

- mDumpMem: DumpMem 프로시저를 호출하며 세 인자를 ESI, ECX, EBX에 넣는다. 그래서 이 세 레지스터를 인자로 넘기면 안 된다. 내부에서 EBX, ECX, ESI를 push/pop으로 보존한다.

```asm
array DWORD 1000h,2000h,3000h,4000h
mDumpMem OFFSET array, LENGTHOF array, TYPE array   ; 00001000 00002000 ...
mDumpMem OFFSET array, SIZEOF array, TYPE BYTE      ; 00 10 00 00 00 20 ... (리틀엔디언 바이트)
```
  - `mDumpMem esp, 8, TYPE DWORD`로 스택을 찍으면 매크로가 push한 ESI(3), ECX(2), EBX(1)가 맨 위에 먼저 보이고, 그 뒤에 미리 push한 값들이 보인다.
- mDump: 변수의 주소와 내용을 16진수로 출력한다. 두 번째 인자를 주면 "Variable name: diskSize"처럼 이름도 표시한다. 내부적으로 IFNB(빈칸 아님 검사)와 `&varName`(치환 연산자)를 쓰고 mDumpMem을 호출한다.
- mGotoxy: X, Y(BYTE)를 DL, DH에 넣고 Gotoxy를 호출한다. 즉시값, 메모리, 레지스터 모두 가능하다.
  - 레지스터 충돌 주의: `mGotoxy dh,dl`처럼 부르면 `mov dh,dl` 다음 `mov dl,dh`가 되어, 첫 줄에서 DH가 이미 덮어써져 잘못된 값이 들어간다. 그래서 매크로 주석에 "인자로 쓰면 안 되는 레지스터"를 적어 두는 것이 좋다.
- mReadString: 버퍼 이름을 받아 `EDX = OFFSET 버퍼`, `ECX = SIZEOF 버퍼`로 ReadString을 호출한다(ECX, EDX 보존).
- mShow: 레지스터/변수의 이름과 값을 형식 코드대로 표시한다. H=16진, D=부호없는 10진, I=부호있는 10진, B=2진, N=줄바꿈. 기본값은 "HIN". 매크로 안에서 레지스터를 바꾸기 전에 원래 값을 먼저 표시하도록 만들어져 있다.

```asm
mov ax,4096
mShow AX          ; AX = 1000h +4096d
mShow AX,DBN      ; AX = 4096d 0001 0000 0000 0000b
```

- mShowRegister: `mShowRegister EBX, ebx` → `EBX=7FFD9000`. 이름에 공백이 있으면 `<Stack Pointer>`처럼 꺾쇠로 감싼다. 내부에서 `" &regName=",0` 문자열을 LOCAL로 만든다.
- mWriteSpace: `count:=<1>`(기본 인자 1). `spaces BYTE count DUP(' '),0`을 만들어 출력한다.
- mWriteString: EDX를 보존하고 `OFFSET buffer`로 WriteString을 호출한다.

### 2.6 예제: 래퍼 (Wrappers, 10.2.6)
- 매크로가 매개변수 전달과 레지스터 보존을 숨겨 주므로 프로그램이 짧아진다.

```asm
; Wraps.asm
INCLUDE Irvine32.inc
INCLUDE Macros.inc
.data
array DWORD 1,2,3,4,5,6,7,8
firstName BYTE 31 DUP(?)
lastName  BYTE 31 DUP(?)
.code
main PROC
    mGotoxy 0,0
    mWrite <"Sample Macro Program",0dh,0ah>
    mGotoxy 0,5
    mWrite "Please enter your first name: "
    mReadString firstName
    call Crlf
    mWrite "Please enter your last name: "
    mReadString lastName
    call Crlf
    mWrite "Your name is "
    mWriteString firstName
    mWriteSpace
    mWriteString lastName
    call Crlf
    mDumpMem OFFSET array, LENGTHOF array, TYPE array
    exit
main ENDP
END main
```

## 3. 조건부 어셈블리 지시어 (Conditional-Assembly Directives, 10.3)
- 매크로와 함께 써서 매크로를 더 유연하게 만든다. 모두 어셈블 시점에 평가된다. 6장의 `.IF/.ENDIF`는 실행 시점에 레지스터·변수 값을 검사하는 것이므로 전혀 다르다.

```asm
IF condition
    statements
[ELSE
    statements]
ENDIF
```

| 지시어 | 설명 |
|---|---|
| IF expression | 식이 참(0이 아님)이면 어셈블. 관계 연산자 LT, GT, EQ, NE, LE, GE |
| IFB <argument> | 인자가 비어 있으면 어셈블 (꺾쇠 필수) |
| IFNB <argument> | 인자가 비어 있지 않으면 어셈블 |
| IFIDN <arg1>,<arg2> | 두 인자가 같으면(대소문자 구분) 어셈블 |
| IFIDNI <arg1>,<arg2> | 두 인자가 같으면(대소문자 무시) 어셈블 |
| IFDIF <arg1>,<arg2> | 두 인자가 다르면(대소문자 구분) 어셈블 |
| IFDIFI <arg1>,<arg2> | 두 인자가 다르면(대소문자 무시) 어셈블 |
| IFDEF name | name이 정의되어 있으면 어셈블 |
| IFNDEF name | name이 정의되어 있지 않으면 어셈블 |
| ENDIF | 조건 블록 끝 |
| ELSE | 앞 조건이 거짓이면 ENDIF까지 어셈블 |
| ELSEIF expression | 앞 조건이 거짓이고 이 식이 참이면 어셈블 |
| EXITM | 매크로를 즉시 빠져나가 이후 문장을 확장하지 않음 |

### 3.1 누락된 인자 검사 (Checking for Missing Arguments, 10.3.1)
- 인자 없이 mWriteString을 부르면 `mov edx,OFFSET` 뒤가 비어 "missing operand" 오류가 난다.
- IFB로 빈 인자를 검사하고, ECHO로 어셈블 중 오류 메시지를 띄운 뒤 EXITM으로 코드 생성 없이 빠져나갈 수 있다.

```asm
mWriteString MACRO string
    IFB <string>
      ECHO * Error: parameter missing in mWriteString
      ECHO * (no code generated)
      EXITM
    ENDIF
    push edx
    mov  edx,OFFSET string
    call WriteString
    pop  edx
ENDM
```

### 3.2 기본 인자 초기값 (Default Argument Initializers, 10.3.2)
- 문법: `paramname := < argument >`. 인자가 빠지면 이 기본값을 쓴다.

```asm
mWriteln MACRO text:=<" ">
    mWrite text
    call Crlf
ENDM
```
- 빈 문자열 `""`는 기본값으로 쓸 수 없어 오류가 난다. 따옴표 사이에 공백 하나 이상 넣어야 한다.

### 3.3 불리언 식 (Boolean Expressions, 10.3.3)

| 연산자 | 의미 |
|---|---|
| LT | 작다 |
| GT | 크다 |
| EQ | 같다 |
| NE | 같지 않다 |
| LE | 작거나 같다 |
| GE | 크거나 같다 |

### 3.4 IF, ELSE, ENDIF 지시어 (10.3.4)
- IF 뒤에는 상수 불리언 식이 와야 한다. 정수 상수, 기호 상수, 상수 매크로 인자는 쓸 수 있지만 레지스터나 변수 이름은 쓸 수 없다(어셈블 시점에 값을 모르므로).
- 예: mGotoxyConst는 X, Y가 상수일 때 범위(0 ≤ X < 80, 0 ≤ Y < 25)를 검사한다. LOCAL 상수 ERRS에 오류 수를 세고, 0보다 크면 EXITM으로 빠져나간다.

```asm
mGotoxyConst MACRO X:REQ, Y:REQ
    LOCAL ERRS                    ;; local constant
    ERRS = 0
    IF (X LT 0) OR (X GT 79)
       ECHO Warning: First argument to mGotoxy (X) is out of range.
       ERRS = 1
    ENDIF
    IF (Y LT 0) OR (Y GT 24)
       ECHO Warning: Second argument to mGotoxy (Y) is out of range.
       ERRS = ERRS + 1
    ENDIF
    IF ERRS GT 0                  ;; if errors found,
      EXITM                       ;; exit the macro
    ENDIF
    push edx
    mov  dh,Y
    mov  dl,X
    call Gotoxy
    pop  edx
ENDM
```

### 3.5 IFIDN과 IFIDNI 지시어 (10.3.5)
- 두 기호(매크로 매개변수 포함)가 같은지 비교한다. IFIDNI는 대소문자 무시, IFIDN은 대소문자 구분.
- 주 용도: 호출자가 매크로 내부에서 쓰는 레지스터를 인자로 넘겨 충돌하는 것을 막는다.

```asm
mReadBuf MACRO bufferPtr, maxChars
    IFIDNI <maxChars>,<EDX>        ; edx, EDX, Edx 모두 걸림
       ECHO Warning: Second argument to mReadBuf cannot be EDX
       EXITM
    ENDIF
    push ecx
    push edx
    mov  edx,bufferPtr             ; 여기서 EDX가 덮어써지기 때문
    mov  ecx,maxChars
    call ReadString
    pop  edx
    pop  ecx
ENDM
; mReadBuf OFFSET buffer,edx  → 경고 발생
```

### 3.6 예제: 행렬 행 합계 (Summing a Matrix Row, 10.3.6)
- 9장의 calc_row_sum 프로시저(BYTE 행렬 전용)를 BYTE/WORD/DWORD 모두 되는 매크로로 바꾸는 과정이다.
  1. PROC → MACRO, ENDP → ENDM, RET 삭제. 매크로엔 USES가 없으므로 push/pop을 직접 넣는다.
  2. 레지스터로 받던 값을 매크로 매개변수(index, arrayOffset, rowSize)로 바꾸고 매크로 안에서 레지스터에 넣는다.
  3. 원소 타입 매개변수 eltType 추가.
  4. rowSize는 바이트 수이므로 원소 개수로 바꿔야 한다. `shr ecx,(TYPE eltType / 2)` — BYTE는 1/2=0, WORD는 2/2=1, DWORD는 4/2=2만큼 시프트하므로 각각 ÷1, ÷2, ÷4가 된다.
  5. 원소 읽기는 `eltType PTR [ebx + esi*(TYPE eltType)]`로 스케일 팩터를 쓴다. MOVZX는 DWORD 원본을 받을 수 없으므로 IFIDNI로 DWORD일 땐 MOV를 쓰게 분기한다.
  6. 라벨 L1은 LOCAL로 선언한다(여러 번 호출 대비).

```asm
mCalc_row_sum MACRO index, arrayOffset, rowSize, eltType
; Returns: EAX = sum
LOCAL L1
    push ebx
    push ecx
    push esi
    mov  eax,index
    mov  ebx,arrayOffset
    mov  ecx,rowSize
    mul  ecx                          ; row index * row size
    add  ebx,eax                      ; row offset
    shr  ecx,(TYPE eltType / 2)       ; byte=0, word=1, dword=2
    mov  eax,0                        ; accumulator
    mov  esi,0                        ; column index
L1:
    IFIDNI <eltType>, <DWORD>
      mov   edx,eltType PTR[ebx + esi*(TYPE eltType)]
    ELSE
      movzx edx,eltType PTR[ebx + esi*(TYPE eltType)]
    ENDIF
    add  eax,edx
    inc  esi
    loop L1
    pop  esi
    pop  ecx
    pop  ebx
ENDM
```

- 행 크기는 `RowSizeB = ($ - tableB)`처럼 첫 행 바로 뒤에서 위치 카운터로 계산한다.

```asm
mCalc_row_sum index, OFFSET tableB, RowSizeB, BYTE
mCalc_row_sum index, OFFSET tableW, RowSizeW, WORD
mCalc_row_sum index, OFFSET tableD, RowSizeD, DWORD
```

### 3.7 특수 연산자 (Special Operators, 10.3.7)

| 연산자 | 이름 |
|---|---|
| & | 치환 연산자 (substitution) |
| < > | 리터럴 텍스트 연산자 (literal-text) |
| ! | 리터럴 문자 연산자 (literal-character) |
| % | 확장 연산자 (expansion) |

#### 치환 연산자 (&)
- 매개변수 이름이 문자열 리터럴 안에 있으면 전처리기는 그냥 글자로 보고 치환하지 않는다. `&`를 붙이면 강제로 인자 값을 넣는다.

```asm
mShowRegister MACRO regName
.data
tempStr BYTE " &regName=",0     ; mShowRegister ECX → " ECX="
```

#### 확장 연산자 (%)
- 텍스트 매크로를 펼치거나 상수식을 계산해 텍스트로 바꾼다.
  - TEXTEQU와 함께: `count = 10` / `sumVal TEXTEQU %(5 + count)` → "15"
  - 매크로 인자로: `mGotoxyConst %(5 * 10), %(3 + 4)` → `mov dh,7` / `mov dl,50`로 확장. 상수만 받는 매크로에 식을 넘길 수 있다.
- 줄 맨 앞의 %: 그 줄의 모든 텍스트 매크로와 매크로 함수를 펼친다.

```asm
ECHO The array contains (SIZEOF array) bytes    ; 그대로 출력됨 (실패)
ECHO The array contains %(SIZEOF array) bytes   ; 이것도 그대로 출력됨 (실패)

TempStr TEXTEQU %(SIZEOF array)
%   ECHO The array contains TempStr bytes        ; → The array contains 32 bytes
```

- 줄 번호 표시: `@LINE`은 현재 소스 줄 번호를 돌려주는 미리 정의된 연산자다. Mul32 매크로는 두 번째 인자가 EAX면(MUL 전에 EAX를 op1로 덮어쓰므로 불가) 호출된 줄 번호와 함께 오류를 표시한다.

```asm
Mul32 MACRO op1, op2, product
    IFIDNI <op2>,<EAX>
      LINENUM TEXTEQU %(@LINE)
%     ECHO * Error on line LINENUM: EAX cannot be the second
      ECHO * argument when invoking the MUL32 macro.
      EXITM
    ENDIF
    push eax
    mov  eax,op1
    mul  op2
    mov  product,eax
    pop  eax
ENDM
; 40번 줄에서 MUL32 val1,eax,val3 → "Error on line 40: ..."
```

#### 리터럴 텍스트 연산자 (< >)
- 여러 문자·기호를 하나의 텍스트로 묶어 전처리기가 별개 인자로 나누지 못하게 한다. 쉼표, %, &, ; 같은 특수 문자가 든 문자열에 특히 필요하다.

```asm
mWrite "Line three", 0dh, 0ah     ; 인자 3개로 해석 → 뒤 두 개 버려짐
mWrite <"Line three", 0dh, 0ah>   ; 인자 1개로 해석
```

#### 리터럴 문자 연산자 (!)
- 미리 정의된 연산자 문자 하나를 일반 문자로 취급하게 한다.

```asm
BadYValue TEXTEQU <Warning: Y-coordinate is !> 24>   ; > 가 텍스트 끝으로 해석되지 않음
```

- %, &, !를 함께 쓴 예:

```asm
ShowWarning MACRO message
    mWrite "&message"        ; & 로 인자를 문자열 안에 넣음
ENDM
.code
ShowWarning %BadYValue       ; % 로 BadYValue를 실제 텍스트로 펼침
; 출력: Warning: Y-coordinate is > 24
```

### 3.8 매크로 함수 (Macro Functions, 10.3.8)
- 매크로 함수는 매크로 프로시저처럼 문장 묶음에 이름을 붙이지만, 항상 EXITM으로 상수(정수 또는 문자열)를 반환한다는 점이 다르다. EXITM은 이후 확장을 모두 멈춘다.

```asm
IsDefined MACRO symbol
    IFDEF symbol
      EXITM <-1>         ;; True
    ELSE
      EXITM <0>          ;; False
    ENDIF
ENDM
```

- 매크로 함수를 호출할 땐 인자 목록을 괄호로 감싼다: `IF IsDefined( RealMode )`
- 활용: 메모리 모델에 따라 다른 코드나 INCLUDE 파일을 고를 수 있다.

```asm
IF IsDefined( RealMode )
    INCLUDE Irvine16.inc
ELSE
    INCLUDE Irvine32.inc
ENDIF
```

- RealMode 기호 정의 방법: 소스 맨 앞에 `RealMode = 1`을 쓰거나, 명령줄 `ML -c -DRealMode=1 myProg.asm`의 -D 옵션으로 정의한다. 보호 모드용은 `ML -c myProg.asm`으로 정의하지 않는다.
- Startup 매크로 안에 `IF IsDefined(RealMode)` → `mov ax,@data / mov ds,ax`를 넣으면, HelloNew.asm 하나로 실제 모드와 보호 모드 양쪽 모두 어셈블할 수 있다.

## 4. 반복 블록 정의 (Defining Repeat Blocks, 10.4)
- MASM의 반복 지시어 WHILE, REPEAT, FOR, FORC는 LOOP 명령어와 달리 어셈블 시점에만 동작하며 상수 값을 조건·카운터로 쓴다.

| 지시어 | 반복 기준 |
|---|---|
| WHILE | 불리언 식이 참인 동안 |
| REPEAT | 카운터 값만큼 |
| FOR | 쉼표로 구분된 기호 목록의 각 원소마다 |
| FORC | 문자열의 각 문자마다 |

### 4.1 WHILE 지시어 (10.4.1)
- 상수식이 참인 동안 블록을 반복 생성한다.

```asm
WHILE constExpression
    statements
ENDM
```

- 예: 1부터 F0000000h 미만의 피보나치 수를 어셈블 시점 상수로 DWORD 데이터로 생성한다(결과는 .LST 파일에서 확인).

```asm
.data
val1 = 1
val2 = 1
DWORD val1                 ; first two values
DWORD val2
val3 = val1 + val2
WHILE val3 LT 0F0000000h
    DWORD val3
    val1 = val2
    val2 = val3
    val3 = val1 + val2
ENDM
```

### 4.2 REPEAT 지시어 (10.4.2)
- 부호 없는 정수 상수식만큼 블록을 반복한다. DUP처럼 배열을 만드는 데 쓸 수 있다.

```asm
WEEKS_PER_YEAR = 52
WeatherReadings STRUCT
    location BYTE 50 DUP(0)
    REPEAT WEEKS_PER_YEAR
      LOCAL rainfall, humidity     ; 반복마다 이름 중복 오류 방지
      rainfall DWORD ?
      humidity DWORD ?
    ENDM
WeatherReadings ENDS
```

### 4.3 FOR 지시어 (10.4.3)
- 쉼표로 구분된 기호 목록을 차례로 돌며 반복한다. 첫 반복에 parameter = arg1, 다음 반복에 arg2 ...

```asm
FOR parameter,<arg1,arg2,arg3,...>
    statements
ENDM
```

- 예: 수강 신청 — COURSE(과목 번호, 학점), SEMESTER(COURSE 6개 배열 + NumCourses).

```asm
COURSE STRUCT
    Number  BYTE 9 DUP(?)
    Credits BYTE ?
COURSE ENDS
SEMESTER STRUCT
    Courses COURSE 6 DUP(<>)
    NumCourses WORD ?
SEMESTER ENDS
.data
FOR semName,<Fall2013,Spring2014,Summer2014,Fall2014>
    semName SEMESTER <>
ENDM
; → Fall2013 SEMESTER <>, Spring2014 SEMESTER <>, ... 4개 변수 생성
```

### 4.4 FORC 지시어 (10.4.4)
- 문자열의 문자를 하나씩 돌며 반복한다. `<`와 `>`는 FORC 문법(꺾쇠)과 충돌하므로 `!`를 앞에 붙인다.

```asm
Delimiters LABEL BYTE
FORC code,<@#$%^&*!<!>>
    BYTE "&code"
ENDM
; → BYTE "@", BYTE "#", BYTE "$", ..., BYTE "<", BYTE ">" (문자 조회 테이블)
```

### 4.5 예제: 연결 리스트 (Linked List, 10.4.5)
- 연결 리스트의 각 노드는 데이터 영역과 다음 노드 주소를 담은 링크 영역으로 되어 있다. 마지막 노드의 링크는 보통 null(0)이다.
- 구조체 + REPEAT로 어셈블러가 노드들을 연속으로 만들게 한다.

```asm
ListNode STRUCT
    NodeData DWORD ?        ; the node's data
    NextPtr  DWORD ?        ; pointer to next node
ListNode ENDS

TotalNodeCount = 15
NULL = 0
Counter = 0
.data
LinkedList LABEL PTR ListNode
REPEAT TotalNodeCount
    Counter = Counter + 1
    ListNode <Counter, ($ + Counter * SIZEOF ListNode)>
ENDM
ListNode <0,0>              ; tail node
```

- `$ + Counter * SIZEOF ListNode`: REPEAT 블록 안에서 위치 카운터 `$`는 첫 노드 위치에 고정된 것처럼 쓰이므로, Counter × 노드 크기(8)를 더하면 다음 노드 주소가 된다.
- 순회: NextPtr가 NULL인 꼬리 노드를 만나면 멈춘다(고정 카운터 대신).

```asm
    mov  esi,OFFSET LinkedList
NextNode:
    mov  eax,(ListNode PTR [esi]).NextPtr
    cmp  eax,NULL               ; 꼬리 노드인가?
    je   quit
    mov  eax,(ListNode PTR [esi]).NodeData
    call WriteDec
    call Crlf
    mov  esi,(ListNode PTR [esi]).NextPtr   ; 다음 노드로
    jmp  NextNode
quit:
```
- 출력: 1부터 15까지 한 줄씩.

## 5. 장 요약 (Chapter Summary, 10.5)
- 구조체는 사용자 정의 타입을 만드는 틀이다. Windows API에 이미 많은 구조체가 정의되어 있고, 프로그램과 라이브러리 사이 데이터 전달에 쓰인다. 필드마다 기본값(field initializer)을 줄 수 있다.
- 구조체 정의 자체는 메모리를 쓰지 않고, 구조체 변수가 메모리를 쓴다. SIZEOF는 변수가 쓰는 바이트 수를 돌려준다.
- 점 연산자(.)로 필드를 참조한다. 간접 피연산자를 쓸 때는 `(COORD PTR [esi]).X`처럼 PTR로 구조체 타입을 밝혀야 한다.
- 구조체는 다른 구조체를 필드로 가질 수 있다(DrunkardWalk 안의 COORD 배열).
- 매크로는 보통 프로그램 앞부분에 정의하고, 호출하면 전처리기가 그 자리에 코드 사본을 넣는다. mGotoxy, mDumpMem, mWriteString처럼 프로시저 호출을 감싸는 래퍼로 쓰면 매개변수 전달과 레지스터 보존이 간단해진다.
- 매크로 프로시저는 값을 반환하지 않고, 매크로 함수는 상수를 반환한다.
- IF, IFNB, IFIDNI 같은 조건부 어셈블리 지시어로 범위 밖·누락·잘못된 타입의 인자를 찾아내고, ECHO로 어셈블 중 오류 메시지를 보여 줄 수 있다.
- & 는 매개변수 치환, % 는 텍스트 매크로 확장·상수식의 텍스트 변환, < > 는 여러 문자를 하나의 리터럴로 묶기, ! 는 미리 정의된 연산자를 일반 문자로 취급.
- 반복 블록 지시어(WHILE, REPEAT, FOR, FORC)로 반복되는 코드를 줄일 수 있다.
