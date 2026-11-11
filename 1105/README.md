# 8장. Advanced Procedures (어셈블리 프로그래밍)

## 1. 개요 (Introduction, 8.1)
- 이 장은 서브루틴 호출의 내부 구조, 특히 런타임 스택이 어떻게 쓰이는지를 다룬다. C/C++로 OS나 디바이스 드라이버 수준 코드를 디버깅할 때 스택 내용을 직접 봐야 하는 경우가 많아서 중요하다.
- 대부분의 현대 언어는 서브루틴을 호출하기 전에 인자를 스택에 push하고, 서브루틴은 지역 변수도 스택에 저장한다. 값/참조 전달, 지역 변수 생성·소멸, 재귀 구현 방식을 살펴본다.
- 서브루틴은 언어마다 부르는 이름이 다르다.

| 언어 | 서브루틴 명칭 |
|---|---|
| C / C++ | function (함수) |
| Java | method (메서드) |
| MASM | procedure (프로시저) |

- 호출하는 쪽이 넘기는 값은 인자(argument), 호출된 서브루틴이 받는 쪽에서는 매개변수(parameter)라고 부른다.

## 2. 스택 프레임 (Stack Frames, 8.2)

### 2.1 스택 매개변수 (Stack Parameters, 8.2.1)
- 앞 장까지는 Irvine32 라이브러리처럼 레지스터로 매개변수를 넘겼다. 이 장에서는 런타임 스택으로 매개변수를 넘긴다. 32비트 모드의 Windows API 함수는 항상 스택 매개변수를 쓰고, 64비트 모드에서는 레지스터와 스택을 섞어서 쓴다.
- 스택 프레임(stack frame, 또는 활성 레코드 activation record)은 전달된 인자, 복귀 주소, 지역 변수, 저장된 레지스터를 위해 스택에 마련된 영역이다.
- 스택 프레임 생성 순서:
  1. 인자가 있으면 스택에 push한다.
  2. 서브루틴을 호출한다(CALL이 복귀 주소를 push).
  3. 서브루틴 시작 시 EBP를 push한다.
  4. EBP = ESP로 설정한다. 이후 EBP가 모든 매개변수 접근의 기준(base)이 된다.
  5. 지역 변수가 있으면 ESP를 감소시켜 공간을 확보한다.
  6. 저장해야 할 레지스터가 있으면 push한다.
- 스택 프레임 구조는 메모리 모델과 인자 전달 규약에 직접 영향을 받는다. 거의 모든 고급 언어가 스택 인자를 쓰고, 32비트 Windows API를 호출하려면 반드시 스택으로 인자를 넘겨야 한다.

### 2.2 레지스터 매개변수의 단점 (Disadvantages of Register Parameters, 8.2.2)
- Microsoft는 32비트 프로그램에 fastcall이라는 규약을 두고 있다. 매개변수를 레지스터(EAX, EBX, ECX, EDX, 가끔 EDI, ESI)에 넣어 넘기므로 스택 push보다 빠르다는 장점이 있다.
- 하지만 이 레지스터들은 루프 카운터나 연산 피연산자로도 쓰인다. 그래서 호출 전에 기존 값을 push로 저장하고, 인자를 넣고, 복귀 후 pop으로 복구해야 한다. 이 추가 push/pop 때문에 코드가 지저분해지고, 얻으려던 속도 이점도 사라진다.

```
push ebx                    ; save register values
push ecx
push esi
mov  esi,OFFSET array       ; starting OFFSET
mov  ecx,LENGTHOF array     ; size, in units
mov  ebx,TYPE array         ; doubleword format
call DumpMem                ; display memory
pop  esi                    ; restore register values
pop  ecx
pop  ebx
```

- 실행 경로가 여러 개면 push/pop 짝을 맞추기 어렵다. 아래에서 EAX = 1이면 error_exit로 점프하는데, 스택에 레지스터 3개가 남아 있어서 RET이 엉뚱한 주소로 복귀한다. 이런 버그는 눈에 잘 띄지 않는다.

```
 1: push ebx
 2: push ecx
 3: push esi
 4: mov  esi,OFFSET array
 5: mov  ecx,LENGTHOF array
 6: mov  ebx,TYPE array
 7: call DumpMem
 8: cmp  eax,1              ; error flag set?
 9: je   error_exit         ; exit with flag set
10:
11: pop  esi
12: pop  ecx
13: pop  ebx
14: ret
15: error_exit:
16: mov  edx,offset error_msg
17: ret                     ; 스택에 값 3개가 남아 있어 잘못된 주소로 복귀
```

- 스택 매개변수 방식은 호출 직전에 인자를 push만 하면 되므로 유연하다. DumpMem이 스택 매개변수를 쓴다면 다음처럼 호출한다.

```
push TYPE array
push LENGTHOF array
push OFFSET array
call DumpMem
```

- 스택에 push하는 인자는 두 종류다. 값 인자(value argument: 변수·상수의 값)와 참조 인자(reference argument: 변수의 주소).

#### 값 전달 (Passing by Value)
- 값 전달은 값의 복사본을 스택에 push하는 것이다. 호출된 쪽에서 바꿔도 원래 변수에는 영향이 없다.
- C/C++처럼 인자는 역순으로 push한다. `int sum = AddTwo(val1, val2);`에 해당하는 코드:

```
.data
val1 DWORD 5
val2 DWORD 6
.code
push val2
push val1
call AddTwo
; CALL 직전 스택: [6(val2)] 위, [5(val1)] ← ESP
```

#### 참조 전달 (Passing by Reference)
- 참조 전달은 객체의 주소(offset)를 push한다. 호출된 쪽은 이 주소로 원래 변수를 직접 수정할 수 있다. C의 `Swap(&val1, &val2);`와 같다.

```
push OFFSET val2
push OFFSET val1
call Swap
```

#### 배열 전달 (Passing Arrays)
- 고급 언어는 배열을 항상 참조로 넘긴다. 즉 배열의 주소만 push한다.
- 배열을 값으로 넘기면 원소를 하나하나 push해야 해서 매우 느리고 스택 공간도 많이 쓰기 때문이다.

```
.data
array DWORD 50 DUP(?)
.code
push OFFSET array
call ArrayFill
```

### 2.3 스택 매개변수 접근 (Accessing Stack Parameters, 8.2.3)
- C/C++ 함수는 프롤로그(prologue)로 시작한다. EBP를 저장하고 EBP를 스택 top(ESP)에 맞춘다. 필요하면 복원할 레지스터를 push한다.
- 끝에는 에필로그(epilogue)가 있다. EBP를 복원하고 RET으로 호출자에게 돌아간다.
- `int AddTwo(int x, int y) { return x + y; }`를 어셈블리로 만들면, `push ebp` / `mov ebp,esp` 이후 스택은 다음과 같다(AddTwo(5, 6) 호출 시 6이 먼저 push됨).

| 내용 | 위치 |
|---|---|
| 6 (두 번째 인자 y) | [EBP + 12] |
| 5 (첫 번째 인자 x) | [EBP + 8] |
| return address | [EBP + 4] |
| 저장된 EBP | [EBP] ← EBP, ESP |

- 이후 레지스터를 더 push해도 ESP만 변하고 EBP는 그대로라서 매개변수 오프셋은 바뀌지 않는다.
- 기준-오프셋 주소 지정(base-offset addressing): EBP를 기준 레지스터로, 상수를 오프셋으로 써서 매개변수에 접근한다. 32비트 반환값은 보통 EAX에 담는다.

```
AddTwo PROC
    push ebp
    mov  ebp,esp            ; base of stack frame
    mov  eax,[ebp + 12]     ; second parameter
    add  eax,[ebp + 8]      ; first parameter
    pop  ebp
    ret
AddTwo ENDP
```

#### 명시적 스택 매개변수 (Explicit Stack Parameters)
- [ebp + 8]처럼 오프셋을 상수로 직접 적어서 매개변수를 참조하는 것을 명시적 스택 매개변수라고 한다.
- 가독성을 위해 EQU로 기호 상수를 정의하기도 한다.

```
y_param EQU [ebp + 12]
x_param EQU [ebp + 8]
AddTwo PROC
    push ebp
    mov  ebp,esp
    mov  eax,y_param
    add  eax,x_param
    pop  ebp
    ret
AddTwo ENDP
```

#### 스택 정리 (Cleaning Up the Stack)
- 서브루틴이 끝난 후 매개변수를 스택에서 제거하지 않으면 메모리 누수가 생기고 스택이 망가진다.
- 루프에서 AddTwo를 계속 호출하면 호출당 12바이트(인자 4바이트 × 2 + 복귀 주소 4바이트)씩 쌓여 결국 스택 오버플로가 난다.
- 더 심각한 경우: main → Example1 → AddTwo 구조에서 인자를 정리하지 않으면, Example1의 RET 시점에 ESP가 복귀 주소가 아니라 정수 5를 가리킨다. RET이 5를 EIP에 넣고 주소 5로 점프하려다 런타임 예외가 발생해 OS가 프로그램을 종료한다.

```
main PROC
    call Example1
    exit
main ENDP
Example1 PROC
    push 6
    push 5
    call AddTwo
    ret                     ; stack is corrupted! (ESP가 5를 가리킴)
Example1 ENDP
```

### 2.4 32비트 호출 규약 (32-Bit Calling Conventions, 8.2.4)
- Windows 32비트 환경에서 가장 많이 쓰는 규약은 C 호출 규약과 STDCALL이다. 어셈블리 함수를 C/C++에서 호출하거나, 어셈블리에서 Windows API를 호출할 때 둘 다 필요하다.

#### C 호출 규약 (The C Calling Convention)
- C/C++이 사용한다. 매개변수를 역순으로 push한다. `AddTwo(A, B)`는 B를 먼저, A를 나중에 push한다.
- 스택 정리는 호출자(caller)가 한다. CALL 다음에 매개변수 크기 합만큼 ESP에 더한다.

```
Example1 PROC
    push 6
    push 5
    call AddTwo
    add  esp,8              ; 2개 × 4바이트 스택 정리
    ret
Example1 ENDP
```

#### STDCALL 호출 규약 (STDCALL Calling Convention)
- 역시 역순으로 push하지만, 스택 정리는 호출된 프로시저(callee)가 한다. RET에 정수 피연산자를 주면 복귀 후 ESP에 그 값을 더한다. 이 정수는 매개변수가 차지한 바이트 수와 같아야 한다.

```
AddTwo PROC
    push ebp
    mov  ebp,esp
    mov  eax,[ebp + 12]     ; second parameter
    add  eax,[ebp + 8]      ; first parameter
    pop  ebp
    ret  8                  ; clean up the stack
AddTwo ENDP
```

| 구분 | C 규약 | STDCALL |
|---|---|---|
| push 순서 | 역순 | 역순 |
| 스택 정리 주체 | 호출자 (`add esp,n`) | 피호출자 (`ret n`) |
| 장점 | 가변 개수 인자 가능 (printf 등) | 호출 코드가 한 줄 짧고, 정리를 빼먹을 일이 없음 |
| 사용처 | C/C++ | Windows API, Irvine32 |

- C 규약이 가변 인자를 지원하는 이유: printf처럼 인자 개수가 호출마다 다르면 함수 쪽에서 RET에 고정 상수를 넣을 수 없다. 그래서 정리 책임을 호출자에게 맡긴다.
- Irvine32는 Windows API 호출 시 STDCALL을, Irvine64는 x64 호출 규약을 쓴다. 이 장의 예제는 따로 말하지 않으면 STDCALL을 가정한다.

#### 레지스터 저장과 복원 (Saving and Restoring Registers)
- 서브루틴은 레지스터를 바꾸기 전에 스택에 저장해 두고 복귀 직전에 복원하는 것이 좋다.
- 저장 위치는 `mov ebp,esp` 직후, 지역 변수 공간 확보 직전이 이상적이다. 그래야 이미 스택에 있는 매개변수의 EBP 기준 오프셋이 변하지 않는다(스택은 EBP 아래로 자라기 때문).

```
MySub PROC
    push ebp                ; save base pointer
    mov  ebp,esp            ; base of stack frame
    push ecx
    push edx                ; save EDX
    mov  eax,[ebp+8]        ; get the stack parameter
    .
    .
    pop  edx                ; restore saved registers
    pop  ecx
    pop  ebp                ; restore base pointer
    ret                     ; [EBP+4]에 있던 return address를 pop하여 호출한 함수로 복귀
MySub ENDP
```

| 내용 | 위치 |
|---|---|
| (parameter) | [EBP + 8] |
| return address | [EBP + 4] |
| EBP | ← EBP |
| ECX | |
| EDX | ← ESP |

### 2.5 지역 변수 (Local Variables, 8.2.5)
- 하나의 서브루틴 안에서 생성·사용·소멸하는 변수를 지역 변수라 한다. 런타임 스택의 EBP 아래쪽에 만든다.
- 어셈블 시점에 기본값을 줄 수는 없고 실행 중에 초기화한다.
- 스택 항목은 기본 32비트라서 각 변수 크기는 4의 배수로 올림된다. 아래 C++ 함수의 지역 변수 X, Y에 총 8바이트가 잡힌다.

```
void MySub()
{
    int X = 10;
    int Y = 20;
}
```

| 변수 | 바이트 | 스택 오프셋 |
|---|---|---|
| X | 4 | EBP − 4 |
| Y | 4 | EBP − 8 |

```
MySub PROC
    push ebp
    mov  ebp,esp
    sub  esp,8                      ; create locals
    mov  DWORD PTR [ebp-4],10       ; X
    mov  DWORD PTR [ebp-8],20       ; Y
    mov  esp,ebp                    ; remove locals from stack
    pop  ebp
    ret
MySub ENDP
```

- 끝나기 전에 `mov esp,ebp`로 ESP를 EBP로 되돌려 지역 변수를 해제한다.
- 이 줄을 빼면 `pop ebp`가 EBP에 20을 넣고, RET이 주소 10으로 분기해 프로세서 예외로 프로그램이 멈춘다.
- 가독성을 위해 지역 변수 오프셋도 기호로 정의할 수 있다.

```
X_local EQU DWORD PTR [ebp-4]
Y_local EQU DWORD PTR [ebp-8]
MySub PROC
    push ebp
    mov  ebp,esp
    sub  esp,8              ; reserve space for locals
    mov  X_local,10
    mov  Y_local,20
    mov  esp,ebp            ; remove locals from stack
    pop  ebp
    ret
MySub ENDP
```

### 2.6 참조 매개변수 (Reference Parameters, 8.2.6)
- 참조 매개변수도 EBP 기준-오프셋 방식으로 접근한다. 값 자체가 포인터이므로 보통 레지스터에 옮긴 뒤 간접 피연산자로 사용한다. 예: `mov esi,[ebp+12]`.
- ArrayFill 예제: 배열을 16비트 의사난수로 채운다. 배열 포인터(참조)와 길이(값) 두 인자를 받는다.

```
.data
count = 100
array WORD count DUP(?)
.code
push OFFSET array
push count
call ArrayFill
```

| 내용 | 위치 |
|---|---|
| offset (array) | [EBP + 12] |
| count | [EBP + 8] |
| return address | [EBP + 4] |
| EBP | ← EBP, ESP |

```
ArrayFill PROC
    push ebp
    mov  ebp,esp
    pushad                  ; save registers
    mov  esi,[ebp+12]       ; offset of array
    mov  ecx,[ebp+8]        ; array length
    cmp  ecx,0              ; ECX == 0?
    je   L2                 ; yes: skip over loop
L1:
    mov  eax,10000h         ; get random 0 - FFFFh
    call RandomRange        ; from the link library
    mov  [esi],ax           ; insert value in array
    add  esi,TYPE WORD      ; move to next element
    loop L1
L2: popad                   ; restore registers
    pop  ebp
    ret  8                  ; clean up the stack
ArrayFill ENDP
```

### 2.7 LEA 명령어 (LEA Instruction, 8.2.7)
- LEA는 간접 피연산자의 주소(유효 주소)를 반환한다. 간접 피연산자는 레지스터를 포함하므로 주소가 실행 중에 계산된다.
- OFFSET은 어셈블 시점에 알려진 주소에만 쓸 수 있으므로, 스택 위 변수의 주소는 LEA로 구해야 한다. `mov esi,OFFSET [ebp-30]`은 어셈블 에러다.
- 예: 지역 배열 `char myString[30]`을 '*'로 채운다. 배열은 30바이트지만 ESP를 더블워드 경계에 맞추려고 32를 뺀다.

```
void makeArray()
{
    char myString[30];
    for( int i = 0; i < 30; i++ )
        myString[i] = '*';
}
```

```
makeArray PROC
    push ebp
    mov  ebp,esp
    sub  esp,32             ; myString is at EBP-30
    lea  esi,[ebp-30]       ; load address of myString
    mov  ecx,30             ; loop counter
L1: mov  BYTE PTR [esi],'*' ; fill one position
    inc  esi                ; move to next
    loop L1                 ; continue until ECX = 0
    add  esp,32             ; remove the array (restore ESP)
    pop  ebp
    ret
makeArray ENDP
```

### 2.8 ENTER와 LEAVE 명령어 (ENTER and LEAVE Instructions, 8.2.8)
- ENTER는 호출된 프로시저의 스택 프레임을 자동으로 만든다. 다음 세 동작을 한 번에 한다.
  1. EBP를 push (`push ebp`)
  2. EBP를 프레임 기준으로 설정 (`mov ebp,esp`)
  3. 지역 변수 공간 확보 (`sub esp,numbytes`)
- 형식: `ENTER numbytes, nestinglevel`. 둘 다 즉시값이다.
  - numbytes: 지역 변수용 바이트 수. ESP를 더블워드 경계에 맞추려고 항상 4의 배수로 올림된다.
  - nestinglevel: 렉시컬 중첩 수준. 호출자 프레임에서 복사해 올 프레임 포인터 개수를 정한다. 우리 프로그램에서는 항상 0이다.

| ENTER 사용 | 동등한 코드 |
|---|---|
| `enter 0,0` | `push ebp` / `mov ebp,esp` |
| `enter 8,0` | `push ebp` / `mov ebp,esp` / `sub esp,8` |

- `enter 8,0` 실행 후 스택: 저장된 EBP ← EBP, 그 아래 미정값(????) 두 칸, 마지막 칸 ← ESP.
- ENTER를 쓰면 같은 프로시저 끝에 반드시 LEAVE를 쓰는 것이 좋다. 안 그러면 지역 변수 공간이 해제되지 않아 RET이 엉뚱한 복귀 주소를 꺼낸다.
- LEAVE는 ENTER의 반대다. ESP와 EBP를 프로시저 호출 시점 값으로 되돌린다. 즉 `mov esp,ebp` + `pop ebp`와 같다.

```
MySub PROC              ; 동등한 코드
    enter 8,0           ;   push ebp / mov ebp,esp / sub esp,8
    .
    .
    leave               ;   mov esp,ebp / pop ebp
    ret
MySub ENDP
```

### 2.9 LOCAL 지시어 (LOCAL Directive, 8.2.9)
- LOCAL은 ENTER의 고급 대체물이다. 지역 변수를 이름과 크기 속성으로 선언한다. ENTER는 이름 없는 공간 한 덩어리만 잡는 것과 다르다.
- 사용하려면 PROC 지시어 바로 다음 줄에 와야 한다.
- 형식: `LOCAL varlist`, 각 변수는 `label:type`. type은 WORD, DWORD 같은 표준 타입이나 사용자 정의 타입(10장의 구조체 등)이다. 여러 줄에 걸쳐 쓸 수 있다.

```
MySub PROC
    LOCAL var1:BYTE                     ; 바이트 변수
BubbleSort PROC
    LOCAL temp:DWORD, SwapFlag:BYTE     ; 여러 개
Merge PROC
    LOCAL pArray:PTR WORD               ; 16비트 정수에 대한 포인터
    LOCAL TempArray[10]:DWORD           ; 대괄호로 배열 크기 지정
```

- MASM 코드 생성: LOCAL temp:DWORD 하나를 선언하면 MASM은 다음을 만든다. `add esp,0FFFFFFFCh`는 ESP에 −4를 더하는 것, 즉 4바이트 확보다.

```
Example1 PROC                   ; MASM이 생성한 코드
    LOCAL temp:DWORD            ;   push ebp
    mov  eax,temp               ;   mov  ebp,esp
    ret                         ;   add  esp,0FFFFFFFCh   ; add -4 to ESP
Example1 ENDP                   ;   mov  eax,[ebp-4]
                                ;   leave
                                ;   ret
```

- 스택: return address / EBP ← EBP / temp [EBP − 4] ← ESP.

### 2.10 Microsoft x64 호출 규약 (The Microsoft x64 Calling Convention, 8.2.10)
- 64비트 프로그램에서 C/C++ 컴파일러와 Windows API가 쓰는 규약이다. Windows 함수나 C/C++ 함수를 호출할 때만 따르면 된다.
- 주요 규칙:
  1. CALL은 주소가 64비트이므로 RSP에서 8을 뺀다.
  2. 처음 네 매개변수는 RCX, RDX, R8, R9 순서로 레지스터에 넣는다. 그 이상은 스택에 왼쪽→오른쪽 순서로 push한다.
  3. 64비트보다 작은 매개변수는 0 확장되지 않으므로 상위 비트는 정해지지 않은 값이다.
  4. 64비트 이하 정수 반환값은 RAX에 넣는다.
  5. 호출자는 최소 32바이트의 섀도 공간(shadow space)을 스택에 확보해야 한다. 피호출자가 레지스터 매개변수를 여기에 저장할 수 있다.
  6. 호출 시 RSP는 16바이트 경계에 정렬돼 있어야 한다. CALL이 8바이트 복귀 주소를 push하므로, 호출자는 32바이트 외에 8을 더 빼야 한다.
  7. 매개변수와 섀도 공간 제거는 호출자 책임이다.
  8. 64비트보다 큰 반환값은 스택에 두고 RCX가 그 위치를 가리킨다.
  9. RAX, RCX, RDX, R8, R9, R10, R11은 피호출자가 바꿀 수 있으므로, 유지하려면 호출자가 저장·복원한다.
  10. RBX, RBP, RDI, RSI, R12~R15는 피호출자가 보존해야 한다.

| 구분 | 레지스터 |
|---|---|
| 매개변수 1~4 | RCX, RDX, R8, R9 |
| 반환값 | RAX |
| 피호출자가 바꿀 수 있음(volatile) | RAX, RCX, RDX, R8, R9, R10, R11 |
| 피호출자가 보존해야 함(non-volatile) | RBX, RBP, RDI, RSI, R12~R15 |

## 3. 재귀 (Recursion, 8.3)
- 재귀 서브루틴은 직접 또는 간접적으로 자기 자신을 호출하는 서브루틴이다. 연결 리스트나 그래프처럼 반복 패턴이 있는 자료 구조에서 경로를 되짚어야 할 때 유용하다.
- 끝없는 재귀(Endless Recursion): 종료 조건이 없으면 호출할 때마다 복귀 주소 4바이트가 쌓이고 RET은 실행되지 않아 결국 스택 오버플로로 멈춘다.

```
; Endless Recursion (Endless.asm)
INCLUDE Irvine32.inc
.data
endlessStr BYTE "This recursion never stops",0
.code
main PROC
    call Endless
    exit
main ENDP
Endless PROC
    mov  edx,OFFSET endlessStr
    call WriteString
    call Endless
    ret                     ; never executes
Endless ENDP
END main
```

### 3.1 재귀로 합 구하기 (Recursively Calculating a Sum, 8.3.1)
- 쓸모 있는 재귀 서브루틴은 항상 종료 조건이 있다. 종료 조건이 참이 되면 대기 중인 RET들이 차례로 실행되며 스택이 풀린다(unwind).
- CalcSum은 1부터 n까지 합을 구한다. n은 ECX로 받고 합은 EAX로 반환한다.

```
; Sum of Integers (RecursiveSum.asm)
INCLUDE Irvine32.inc
.code
main PROC
    mov  ecx,5              ; count = 5
    mov  eax,0              ; holds the sum
    call CalcSum            ; calculate sum
L1: call WriteDec           ; display EAX
    call Crlf
    exit
main ENDP
;--------------------------------------------
CalcSum PROC
; Receives: ECX = count,  Returns: EAX = sum
;--------------------------------------------
    cmp  ecx,0              ; check counter value
    jz   L2                 ; quit if zero
    add  eax,ecx            ; otherwise, add to sum
    dec  ecx                ; decrement counter
    call CalcSum            ; recursive call
L2: ret
CalcSum ENDP
end Main
```

- 처음 두 줄이 ECX = 0인지 검사해 재귀를 멈춘다. 처음 RET에 도달하면 이전 CalcSum 호출로, 그다음 또 이전 호출로 차례로 돌아간다.

| 스택에 push된 주소 | ECX | EAX |
|---|---|---|
| L1 | 5 | 0 |
| L2 | 4 | 5 |
| L2 | 3 | 9 |
| L2 | 2 | 12 |
| L2 | 1 | 14 |
| L2 | 0 | 15 |

- 단순한 재귀도 스택을 많이 쓴다. 호출마다 최소 4바이트(복귀 주소)가 쓰인다.

### 3.2 팩토리얼 계산 (Calculating a Factorial, 8.3.2)
- 재귀 서브루틴은 임시 데이터를 스택 매개변수에 저장하는 경우가 많다. 재귀 호출이 풀릴 때 이 값들을 다시 쓸 수 있다.

```
int factorial(int n)
{
    if(n == 0)
        return 1;
    else
        return n * factorial(n-1);
}
```

- n!을 구하려면 (n−1)!을 구할 수 있다고 가정하고 n을 0까지 줄인다. 정의상 0! = 1(기저 사례, base case)이다. 되돌아오면서 곱을 누적한다.

| 재귀 호출(내려감) | 되돌아옴(올라감) |
|---|---|
| 5! = 5 × 4! | 5 × 24 = 120 |
| 4! = 4 × 3! | 4 × 6 = 24 |
| 3! = 3 × 2! | 3 × 2 = 6 |
| 2! = 2 × 1! | 2 × 1 = 2 |
| 1! = 1 × 0! | 1 × 1 = 1 |
| 0! = 1 (base case) | 1 = 1 |

- 어셈블리 구현: n(0~12의 부호 없는 정수)을 스택으로 넘기고 결과는 EAX로 받는다. EAX가 32비트라 담을 수 있는 최대 팩토리얼은 12! = 479,001,600이다.

```
; Calculating a Factorial (Fact.asm)
INCLUDE Irvine32.inc
.code
main PROC
    push 5                  ; calc 5!
    call Factorial          ; calculate factorial (EAX)
    call WriteDec           ; display it
    call Crlf
    exit
main ENDP
;--------------------------------------------
Factorial PROC
; Receives: [ebp+8] = n,  Returns: eax = n!
;--------------------------------------------
    push ebp
    mov  ebp,esp
    mov  eax,[ebp+8]        ; get n
    cmp  eax,0              ; n > 0?
    ja   L1                 ; yes: continue
    mov  eax,1              ; no: return 1 as the value of 0!
    jmp  L2                 ; and return to the caller
L1: dec  eax
    push eax                ; Factorial(n-1)
    call Factorial
; 이 아래는 각 재귀 호출이 복귀할 때 실행된다.
ReturnFact:
    mov  ebx,[ebp+8]        ; get n
    mul  ebx                ; EDX:EAX = EAX * EBX
L2: pop  ebp                ; return EAX
    ret  4                  ; clean up stack
Factorial ENDP
END main
```

- N = 3으로 추적해 보면:
  - 첫 호출: 스택에 N=3, 복귀 주소, 저장된 EBP가 쌓인다. [EBP+8]에서 N을 읽는다. 3 > 0이므로 L1로 가서 2를 push하고 재귀 호출한다.
  - 같은 식으로 N=2, N=1, N=0 프레임이 차례로 쌓여 최대 4개의 프레임이 동시에 존재한다.
  - N = 0이면 EAX = 1로 두고 L2로 가서 `pop ebp` / `ret 4`로 프레임 하나를 제거한다.
  - 이후 ReturnFact에서 현재 프레임의 N([EBP+8])을 EAX에 곱한다: 1×1 = 1 → 2×1 = 2 → 3×2 = 6. 프레임이 하나씩 사라지며 최종 EAX = 6 = 3!이 된다. 곱의 상위 절반 EDX는 0이라 무시한다.

| 단계 | 활성 프레임 | EAX |
|---|---|---|
| N=0 호출 | N=3, 2, 1, 0 | 1 (0!) |
| N=0 복귀 후 | N=3, 2, 1 | 1 × 1 = 1 |
| N=1 복귀 후 | N=3, 2 | 2 × 1 = 2 |
| N=2 복귀 후 | N=3 | 3 × 2 = 6 |

- 팁: 재귀 호출 시 어떤 레지스터가 바뀌는지 주의해야 한다. 첫 호출에서 쓴 EAX 값이 다음 호출에서 덮어써진다. 보존해야 할 값이 있으면 재귀 호출 전에 push하고 복귀 후 pop한다. Factorial에서는 EAX를 보존할 필요가 없다.

## 4. INVOKE, ADDR, PROC, PROTO (INVOKE, ADDR, PROC, and PROTO, 8.4)
- 32비트 모드에서 INVOKE, PROC, PROTO 지시어와 ADDR 연산자는 고급 언어에 가까운 편리함을 준다.
- 다만 런타임 스택의 실제 구조를 가리기 때문에 교육적으로는 논란이 있다. 먼저 저수준 호출 원리를 이해하고 쓰는 것이 좋다.
- 모듈 경계를 넘어 프로시저를 호출할 때는 PROTO가 인자 목록을 선언과 대조해 검사해 주므로 이 지시어들을 쓰는 것이 낫다.

### 4.1 INVOKE 지시어 (INVOKE Directive, 8.4.1)
- INVOKE는 32비트 모드 전용이다. .MODEL의 언어 지정자 순서대로 인자를 push하고 프로시저를 호출한다. 여러 인자를 한 줄로 넘길 수 있어 CALL의 편리한 대체물이다.
- 형식: `INVOKE procedureName [, argumentList]`
- INVOKE는 다음을 자동으로 해 주는 함수 호출용 매크로로 볼 수 있다.
  1. 인자를 순서에 맞춰 스택에 push
  2. call 명령으로 함수 실행
  3. 호출 규약(stdcall, cdecl 등)에 따라 스택 정리까지 처리
- 인자는 함수 선언 순서대로 쓰면 되고, STDCALL에서는 어셈블러가 역순으로 push한다.

```
push TYPE array             ; CALL 사용
push LENGTHOF array
push OFFSET array
call DumpArray

INVOKE DumpArray, OFFSET array, LENGTHOF array, TYPE array   ; INVOKE 한 줄
```

- 인자 개수 제한이 거의 없고, 인자를 여러 줄에 나눠 쓰며 주석을 달 수 있다.

```
INVOKE DumpArray,           ; displays an array
    OFFSET array,           ; points to the array
    LENGTHOF array,         ; the array length
    TYPE array              ; array component size
```

| 인자 유형 | 예 |
|---|---|
| 즉시값 | 10, 3000h, OFFSET mylist, TYPE array |
| 정수 식 | (10 * 20), COUNT |
| 변수 | myList, array, myWord, myDword |
| 주소 식 | [myList+2], [ebx + esi] |
| 레지스터 | eax, bl, edi |
| ADDR name | ADDR myList |
| OFFSET name | OFFSET myList |

- EAX, EDX 덮어쓰기 주의: 32비트보다 작은 인자를 넘기면 INVOKE가 인자를 확장하는 과정에서 EAX와 EDX를 덮어쓰는 경우가 많다. 항상 32비트 인자를 넘기거나, 호출 전후로 EAX, EDX를 저장·복원한다.

### 4.2 ADDR 연산자 (ADDR Operator, 8.4.2)
- ADDR도 32비트 모드 전용이며, INVOKE로 호출할 때 포인터 인자를 넘기는 데 쓴다. 예: `INVOKE FillArray, ADDR myArray`
- ADDR에 넘기는 인자는 어셈블 시점 상수여야 한다. `INVOKE mySub, ADDR [ebp+12]`는 에러다.
- ADDR은 INVOKE와 함께만 쓸 수 있다. `mov esi, ADDR myArray`는 에러다.
- 예: 더블워드 배열의 첫 두 원소 주소를 Swap에 넘기면 어셈블러는 다음 코드를 만든다(STDCALL).

```
.data
Array DWORD 20 DUP(?)
.code
INVOKE Swap,                ; 생성 코드
    ADDR Array,             ;   push OFFSET Array+4
    ADDR [Array+4]          ;   push OFFSET Array
                            ;   call Swap
```

### 4.3 PROC 지시어 (PROC Directive, 8.4.3)
- PROC는 프로시저를 정의하는 지시어다. 32비트 모드 기본 형식:
  - `label PROC [attributes] [USES reglist], parameter_list`
  - attributes = `[distance] [langtype] [visibility] [prologuearg]`

| 속성 | 설명 |
|---|---|
| distance | NEAR 또는 FAR. 어셈블러가 만드는 RET 종류(RET/RETF)를 결정 |
| langtype | 호출 규약(C, PASCAL, STDCALL 등). .MODEL에 지정된 언어를 덮어씀 |
| visibility | 다른 모듈에 대한 가시성. PRIVATE, PUBLIC(기본), EXPORT. EXPORT는 링커가 이름을 export 테이블에 넣으며 PUBLIC도 겸함 |
| prologuearg | 프롤로그·에필로그 코드 생성에 영향을 주는 인자 |

#### 매개변수 목록 (Parameter Lists)
- PROC에 쉼표로 구분된 이름 있는 매개변수 목록을 선언하면, 코드에서 [ebp+8] 같은 오프셋 대신 이름으로 참조할 수 있다.
- 매개변수가 같은 줄에 있으면 PROC 뒤 쉼표는 생략 가능하다. 여러 줄에 나눠 써도 된다.

```
label PROC [attributes] [USES reglist],
    parameter_1,
    parameter_2,
    ...
    parameter_n

label PROC [attributes], parameter_1, parameter_2, ..., parameter_n
```

- 매개변수 하나는 `paramName:type` 형식이다.
  - 이름의 범위는 해당 프로시저 안(지역 범위)이다. 다른 프로시저에서 같은 이름을 써도 되지만, 전역 변수나 코드 레이블 이름과 겹치면 안 된다.
  - type은 BYTE, SBYTE, WORD, SWORD, DWORD, SDWORD, FWORD, QWORD, TBYTE 또는 한정된 타입(qualified type)인 PTR BYTE, PTR WORD, PTR DWORD 등 포인터 타입이다. TYPEDEF, STRUCT로도 만들 수 있다(10장).

#### PROC 예제
- 예 1. AddTwo: 더블워드 두 개를 받아 합을 EAX로 반환. MASM이 이름을 EBP 오프셋으로 바꾸고, STDCALL이므로 RET에 상수를 붙인다. `push ebp` / `mov ebp,esp` 대신 `enter 0,0`을 써도 같다.

```
AddTwo PROC,                ; MASM이 생성한 코드
    val1:DWORD,             ;   push ebp
    val2:DWORD              ;   mov  ebp,esp
    mov  eax,val1           ;   mov  eax,dword ptr [ebp+8]
    add  eax,val2           ;   add  eax,dword ptr [ebp+0Ch]
    ret                     ;   leave
AddTwo ENDP                 ;   ret  8
```

- 예 2. 바이트 배열 포인터를 받는 FillArray, 예 3. 더블워드 포인터 두 개를 받는 Swap:

```
FillArray PROC,
    pArray:PTR BYTE
    ...
FillArray ENDP

Swap PROC,
    pValX:PTR DWORD,
    pValY:PTR DWORD
    ...
Swap ENDP
```

- 예 4. Read_File: 바이트 포인터 pBuffer를 받고, 지역 변수 fileHandle을 두며, EAX와 EBX를 USES로 저장한다. MASM은 지역 변수 공간을 먼저 확보한 뒤 USES 레지스터를 push한다.

```
Read_File PROC USES eax ebx,        ; MASM이 생성한 코드
    pBuffer:PTR BYTE                ;   push ebp
    LOCAL fileHandle:DWORD          ;   mov  ebp,esp
    mov  esi,pBuffer                ;   add  esp,0FFFFFFFCh       ; create fileHandle
    mov  fileHandle,eax             ;   push eax                  ; save EAX
    .                               ;   push ebx                  ; save EBX
    .                               ;   mov  esi,dword ptr [ebp+8]    ; pBuffer (parameter)
    ret                             ;   mov  dword ptr [ebp-4],eax    ; fileHandle
Read_File ENDP                      ;   pop  ebx
                                    ;   pop  eax
                                    ;   leave
                                    ;   ret  4
```

- 생성 코드의 시작을 `enter 4,0` + `push eax`…로 만들 수도 있었다(Microsoft가 그렇게 하지 않았을 뿐).

#### PROC이 수정하는 RET (RET Instruction Modified by PROC)
- 매개변수가 n개인 PROC에 STDCALL이 기본일 때 MASM은 다음 진입·종료 코드를 만든다. RET의 상수는 매개변수 수 × 4다(각 매개변수가 더블워드이므로).

```
push ebp
mov  ebp,esp
.
.
leave
ret  (n*4)
```

- STDCALL은 Irvine32.inc를 INCLUDE하면 기본값이고, 모든 Windows API 호출에 쓰인다.

#### 매개변수 전달 규약 지정 (Specifying the Parameter Passing Protocol)
- PROC의 attributes 필드에서 호출 규약을 지정해 .MODEL 기본값을 덮어쓸 수 있다. INVOKE는 그 규약에 맞는 코드를 만든다.

```
Example1 PROC C,
    parm1:DWORD, parm2:DWORD

Example1 PROC STDCALL,
    parm1:DWORD, parm2:DWORD
```

### 4.4 PROTO 지시어 (PROTO Directive, 8.4.4)
- 64비트 모드에서 PROTO는 외부 프로시저를 알려 주는 용도로만 쓴다(`ExitProcess PROTO`).
- 32비트 모드에서는 매개변수 목록까지 포함할 수 있다. PROTO는 기존 프로시저의 프로토타입(이름 + 매개변수 목록)을 만든다. 정의 전에 호출할 수 있게 하고, 인자 개수와 타입이 정의와 맞는지 검사한다.
- MASM은 INVOKE로 호출하는 모든 프로시저에 프로토타입을 요구한다. PROTO가 INVOKE보다 먼저 나와야 한다.

```
MySub PROTO         ; procedure prototype
INVOKE MySub        ; procedure call
MySub PROC          ; procedure implementation
...
MySub ENDP
```

- 프로시저 정의가 INVOKE보다 앞에 있으면 PROC 자체가 프로토타입 역할을 하므로 PROTO가 필요 없다.
- 이미 만든 PROC 선언에서 프로토타입 만드는 법: PROC을 PROTO로 바꾸고, USES와 레지스터 목록이 있으면 지운다.

```
ArraySum PROC USES esi ecx,
    ptrArray:PTR DWORD,     ; points to the array
    szArray:DWORD           ; array size

ArraySum PROTO,
    ptrArray:PTR DWORD,     ; points to the array
    szArray:DWORD           ; array size
```

- PROTO에서도 호출 규약을 지정할 수 있으며, PROC 선언과 일치해야 한다. 예: `Example1 PROTO C, parm1:DWORD, parm2:DWORD`

#### 어셈블 시점 인자 검사 (Assembly Time Argument Checking)
- MASM은 인자 개수가 맞는지, 그리고 제한적으로 타입이 맞는지 검사한다. C/C++만큼 정밀하지는 않다.
- `Sub1 PROTO, p1:BYTE, p2:WORD, p3:PTR BYTE`가 있을 때 올바른 호출 `INVOKE Sub1, byte_1, word_1, ADDR byte_1`은 다음 코드를 만든다. EAX가 덮어써지고 `sub esp,2`로 다음 항목을 32비트로 맞춘다.

```
push 404000h                    ; ptr to byte_1
sub  esp,2                      ; pad stack with 2 bytes
push word ptr ds:[00404001h]    ; value of word_1
mov  al,byte ptr ds:[00404000h] ; value of byte_1
push eax
call 00401071
```

| 상황 | MASM 검출 여부 |
|---|---|
| 인자 크기가 선언된 매개변수보다 큼 (`INVOKE Sub1, word_1, ...`) | 에러 |
| 인자 개수가 너무 적거나 많음 | 에러 |
| 인자 크기가 매개변수보다 작음 (`INVOKE Sub1, byte_1, byte_1, ...`) | 검출 안 함. 매개변수 크기로 확장(movzx eax,al 후 push) |
| 포인터 자리에 더블워드 값 전달 (`INVOKE Sub1, byte_1, word_2, dword_1`) | 검출 안 함. 실행 중 포인터로 쓰다가 런타임 에러 |

#### ArraySum 예제
- 5장의 ArraySum을 레지스터 대신 PROC 스택 매개변수로 바꾼 버전이다.

```
ArraySum PROC USES esi ecx,
    ptrArray:PTR DWORD,     ; points to the array
    szArray:DWORD           ; array size
    mov  esi,ptrArray       ; address of the array
    mov  ecx,szArray        ; size of the array
    mov  eax,0              ; set the sum to zero
    cmp  ecx,0              ; length = zero?
    je   L2                 ; yes: quit
L1: add  eax,[esi]          ; add each integer to sum
    add  esi,4              ; point to next integer
    loop L1                 ; repeat for array size
L2: ret                     ; sum is in EAX
ArraySum ENDP

.data
array  DWORD 10000h,20000h,30000h,40000h,50000h
theSum DWORD ?
.code
main PROC
    INVOKE ArraySum,
        ADDR array,         ; address of the array
        LENGTHOF array      ; number of elements
    mov theSum,eax          ; store the sum
```

### 4.5 매개변수 분류 (Parameter Classifications, 8.4.5)
- 호출자와 프로시저 사이 데이터 이동 방향에 따라 분류한다.

| 분류 | 의미 | 언제 쓰나 |
|---|---|---|
| 입력 (Input) | 호출자가 프로시저에 넘기는 데이터. 프로시저가 바꿔도 그 변경은 프로시저 안에만 머문다 | 데이터를 프로시저가 바꾸면 안 될 때 |
| 출력 (Output) | 호출자가 변수 주소를 넘기고, 프로시저가 그 주소로 값을 써 넣는다 | 프로시저가 변수에 값을 대입해야 할 때 |
| 입출력 (Input-Output) | 출력과 같지만, 프로시저가 변수에 이미 데이터가 있다고 기대하고 읽은 뒤 수정한다 | 기존 데이터를 수정해야 할 때 |

- 출력 매개변수 예: Win32의 ReadConsole은 문자열 버퍼 포인터를 받아 사용자가 입력한 텍스트를 그 버퍼에 저장한다.

```
.data
buffer      BYTE 80 DUP(?)
inputHandle DWORD ?
.code
INVOKE ReadConsole, inputHandle, ADDR buffer, (etc.)
```

### 4.6 예제: 두 정수 교환 (Example: Exchanging Two Integers, 8.4.6)
- Swap은 두 32비트 정수를 교환한다. pValX, pValY는 입출력 매개변수다(기존 값을 읽고 새 값을 써 넣음).
- PROC에 매개변수가 있으므로 어셈블러가 RET을 RET 8로 바꾼다(STDCALL).

```
; Swap Procedure Example (Swap.asm)
INCLUDE Irvine32.inc
Swap PROTO, pValX:PTR DWORD, pValY:PTR DWORD
.data
Array DWORD 10000h,20000h
.code
main PROC
    ; Display the array before the exchange:
    mov  esi,OFFSET Array
    mov  ecx,2              ; count = 2
    mov  ebx,TYPE Array
    call DumpMem            ; dump the array values
    INVOKE Swap, ADDR Array, ADDR [Array+4]
    ; Display the array after the exchange:
    call DumpMem
    exit
main ENDP
;----------------------------------------------
Swap PROC USES eax esi edi,
    pValX:PTR DWORD,        ; pointer to first integer
    pValY:PTR DWORD         ; pointer to second integer
; Exchange the values of two 32-bit integers
;----------------------------------------------
    mov  esi,pValX          ; get pointers
    mov  edi,pValY
    mov  eax,[esi]          ; get first integer
    xchg eax,[edi]          ; exchange with second
    mov  [esi],eax          ; replace first integer
    ret                     ; PROC generates RET 8 here
Swap ENDP
END main
```

### 4.7 디버깅 팁 (Debugging Tips, 8.4.7)
- 인자 크기 불일치(Argument Size Mismatch): 배열 주소는 원소 크기를 기준으로 계산해야 한다. 더블워드 배열의 두 번째 원소는 +4다. +1로 잘못 계산하면 교환 결과가 엉망이 된다.

```
.data
DoubleArray DWORD 10000h,20000h
.code
INVOKE Swap, ADDR [DoubleArray + 0], ADDR [DoubleArray + 1]   ; 잘못된 주소
```

- 잘못된 포인터 타입 전달(Passing the Wrong Type of Pointer): INVOKE는 포인터 타입을 검사하지 않는다. Swap은 더블워드 포인터를 기대하는데 바이트 포인터를 넘기면 어셈블·실행은 되지만, ESI/EDI를 역참조할 때 32비트 값이 교환된다.

```
.data
ByteArray BYTE 10h,20h,30h,40h,50h,60h,70h,80h
.code
INVOKE Swap, ADDR [ByteArray + 0], ADDR [ByteArray + 1]
```

- 즉시값 전달(Passing Immediate Values): 참조 매개변수에 즉시값을 넘기면 안 된다. 아래 Sub2는 1000h를 포인터로 받아 메모리 1000h를 역참조하므로, 프로그램 데이터 영역 밖이라 일반 보호 오류(general protection fault) 같은 런타임 에러가 난다.

```
Sub2 PROC, dataPtr:PTR WORD
    mov  esi,dataPtr            ; get the address
    mov  WORD PTR [esi],0       ; dereference, assign zero
    ret
Sub2 ENDP

INVOKE Sub2, 1000h              ; 어셈블은 되지만 runtime error
```

### 4.8 WriteStackFrame 프로시저 (WriteStackFrame Procedure, 8.4.8)
- Irvine32 라이브러리의 WriteStackFrame은 현재 프로시저의 스택 프레임(매개변수, 복귀 주소, 지역 변수, 저장된 레지스터)을 화면에 보여 준다.

```
WriteStackFrame PROTO,
    numParam:DWORD,         ; number of passed parameters
    numLocalVal:DWORD,      ; number of DWord local variables
    numSavedReg:DWORD       ; number of saved registers
```

```
main PROC
    mov eax,0EAEAEAEAh
    mov ebx,0EBEBEBEBh
    INVOKE myProc, 1111h, 2222h     ; pass two integer arguments
    exit
main ENDP
myProc PROC USES eax ebx,
    x:DWORD, y:DWORD
    LOCAL a:DWORD, b:DWORD
    PARAMS = 2
    LOCALS = 2
    SAVED_REGS = 2
    mov a,0AAAAh
    mov b,0BBBBh
    INVOKE WriteStackFrame, PARAMS, LOCALS, SAVED_REGS
```

```
Stack Frame
00002222 ebp+12 (parameter)
00001111 ebp+8  (parameter)
00401083 ebp+4  (return address)
0012FFF0 ebp+0  (saved ebp)       <--- ebp
0000AAAA ebp-4  (local variable)
0000BBBB ebp-8  (local variable)
EAEAEAEA ebp-12 (saved register)
EBEBEBEB ebp-16 (saved register)  <--- esp
```

- 출력을 보면 스택 프레임 구조가 그대로 확인된다: 매개변수(EBP 위) → 복귀 주소 → 저장된 EBP → 지역 변수 → USES로 저장된 레지스터(EBP 아래).
- WriteStackFrameName은 프로시저 이름 문자열 포인터(procName:PTR BYTE)를 추가로 받는 버전이다.

## 5. 다중 모듈 프로그램 만들기 (Creating Multimodule Programs, 8.5)
- 큰 소스 파일은 관리가 어렵고 어셈블도 느리다. INCLUDE 파일로 나눠도 하나만 고치면 전체를 다시 어셈블해야 한다.
- 프로그램을 모듈(독립적으로 어셈블되는 단위)로 나누면, 한 모듈을 고쳤을 때 그 모듈만 다시 어셈블하면 된다. 링커가 OBJ 파일들을 하나의 실행 파일로 빠르게 합친다. 많은 OBJ를 링크하는 것이 같은 수의 소스를 어셈블하는 것보다 훨씬 빠르다.
- 방법은 두 가지다.

| 방식 | 특징 |
|---|---|
| 전통적 방식 (Traditional) | EXTERN 지시어 사용. 여러 x86 어셈블러 간 이식성이 좋음 |
| Microsoft 고급 방식 (Microsoft Advanced) | INVOKE, PROTO 사용. 호출이 간단하고 저수준 세부를 숨김 |

### 5.1 프로시저 이름 숨기기와 내보내기 (Hiding and Exporting Procedure Names, 8.5.1)
- MASM은 기본적으로 모든 프로시저를 public으로 만들어 다른 모듈에서 호출할 수 있게 한다. PRIVATE 한정자로 바꿀 수 있다: `mySub PROC PRIVATE`
- 프로시저를 private으로 만들면 캡슐화 원칙에 따라 모듈 내부에 숨기고, 다른 모듈의 같은 이름과 충돌하는 것을 막는다.
- OPTION PROC:PRIVATE 지시어를 파일 맨 위에 두면 모든 프로시저가 기본적으로 private이 된다. 내보낼 것만 PUBLIC으로 지정한다.

```
OPTION PROC:PRIVATE
PUBLIC mySub
PUBLIC sub1, sub2, sub3     ; 쉼표로 여러 개 지정 가능

mySub PROC PUBLIC           ; 개별 프로시저를 public으로 지정
...
mySub ENDP
```

- 시작 모듈에서 OPTION PROC:PRIVATE을 쓰면 시작 프로시저(보통 main)를 반드시 PUBLIC으로 지정해야 한다. 안 그러면 OS 로더가 main을 찾지 못한다: `main PROC PUBLIC`

### 5.2 외부 프로시저 호출 (Calling External Procedures, 8.5.2)
- EXTERN 지시어는 현재 모듈 밖의 프로시저를 호출할 때 쓰며, 프로시저 이름과 스택 프레임 크기를 알려 준다.

```
INCLUDE Irvine32.inc
EXTERN sub1@0:PROC
.code
main PROC
    call sub1@0
    exit
main ENDP
END main
```

- 어셈블러는 소스에 없는 프로시저를 CALL하면 원래 에러를 내지만, EXTERN이 있으면 빈 주소를 만들어 두고 링커가 실행 파일을 만들 때 실제 주소를 채운다.
- 이름 끝의 @n 접미사는 선언된 매개변수가 쓰는 스택 공간 총 바이트 수다. 매개변수 없는 기본 PROC는 @0, 확장 PROC은 매개변수 하나당 4바이트를 더한다.
  - 예: `AddTwo PROC, val1:DWORD, val2:DWORD` → `EXTERN AddTwo@8:PROC`
  - EXTERN 대신 `AddTwo PROTO, val1:DWORD, val2:DWORD`를 써도 된다.

### 5.3 모듈 경계를 넘는 변수와 기호 (Using Variables and Symbols across Module Boundaries, 8.5.3)
- 변수와 기호는 기본적으로 자기 모듈 안에서만 보인다(private). PUBLIC으로 내보낸다.

```
PUBLIC count, SYM1
SYM1 = 10
.data
count DWORD 0
```

- 다른 모듈의 변수·기호는 `EXTERN name : type`으로 접근한다. EQU나 =로 정의한 기호는 type을 ABS로, 변수는 BYTE, WORD, DWORD, SDWORD, PTR 등 데이터 정의 속성으로 쓴다.

```
EXTERN one:WORD, two:SDWORD, three:PTR BYTE, four:ABS
```

#### EXTERNDEF와 INCLUDE 파일 사용 (Using an INCLUDE File with EXTERNDEF)
- EXTERNDEF는 PUBLIC과 EXTERN을 한꺼번에 대신한다. 텍스트 파일에 넣어 두고 각 모듈에서 INCLUDE하면 된다. 정의한 모듈에서는 PUBLIC처럼, 쓰는 모듈에서는 EXTERN처럼 동작한다.

```
; vars.inc
EXTERNDEF count:DWORD, SYM1:ABS

; sub1.asm  (시작 모듈이 아니므로 END 뒤에 진입점 레이블이 없고, 스택 선언도 필요 없음)
.386
.model flat,STDCALL
INCLUDE vars.inc
SYM1 = 10
.data
count DWORD 0
END

; main.asm  (시작 모듈)
.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword
INCLUDE vars.inc
.code
main PROC
    mov  count,2000h
    mov  eax,SYM1
    INVOKE ExitProcess,0
main ENDP
END main
```

### 5.4 예제: ArraySum 프로그램 (Example: ArraySum Program, 8.5.4)
- 5장의 ArraySum 프로그램을 모듈로 나눈다. 구조도:
  - main → Clrscr, PromptForIntegers(→ WriteString, ReadInt), ArraySum, DisplaySum(→ WriteString, WriteInt)
  - 음영 표시된 Clrscr, WriteString, ReadInt, WriteInt는 라이브러리 프로시저다.
- 다중 모듈 프로그램은 파일들을 별도 디렉터리에 모아 두면 관리가 쉽다.

### 5.5 EXTERN으로 모듈 만들기 (Creating the Modules Using Extern, 8.5.5)
- 각 모듈은 명시적 스택 매개변수(EQU [ebp+n]), enter/leave, ret n을 직접 쓴다.
- _prompt.asm의 PromptForIntegers: 프롬프트를 띄우고 ReadInt로 정수를 읽어 배열에 넣는다.

```
; Prompt For Integers (_prompt.asm)
INCLUDE Irvine32.inc
.code
PromptForIntegers PROC
; Receives: ptrPrompt, ptrArray, arraySize
arraySize EQU [ebp+16]
ptrArray  EQU [ebp+12]
ptrPrompt EQU [ebp+8]
    enter 0,0
    pushad                  ; save all registers
    mov  ecx,arraySize
    cmp  ecx,0              ; array size = 0?
    jle  L2                 ; yes: quit
    mov  edx,ptrPrompt      ; address of the prompt
    mov  esi,ptrArray
L1: call WriteString        ; display string
    call ReadInt            ; read integer into EAX
    call Crlf
    mov  [esi],eax          ; store in array
    add  esi,4              ; next integer
    loop L1
L2: popad                   ; restore all registers
    leave
    ret  12                 ; restore the stack
PromptForIntegers ENDP
END
```

- _arrysum.asm의 ArraySum: 배열 합을 EAX로 반환한다. 반환값을 담는 EAX는 push하지 않는다.

```
; ArraySum Procedure (_arrysum.asm)
INCLUDE Irvine32.inc
.code
ArraySum PROC
ptrArray  EQU [ebp+8]
arraySize EQU [ebp+12]
    enter 0,0
    push ecx                ; don't push EAX
    push esi
    mov  eax,0              ; set the sum to zero
    mov  esi,ptrArray
    mov  ecx,arraySize
    cmp  ecx,0              ; array size = 0?
    jle  L2                 ; yes: quit
L1: add  eax,[esi]          ; add each integer to sum
    add  esi,4              ; point to next integer
    loop L1
L2: pop  esi
    pop  ecx                ; return sum in EAX
    leave
    ret  8                  ; restore the stack
ArraySum ENDP
END
```

- _display.asm의 DisplaySum: 레이블과 합계를 출력한다.

```
; DisplaySum Procedure (_display.asm)
INCLUDE Irvine32.inc
.code
DisplaySum PROC
theSum    EQU [ebp+12]
ptrPrompt EQU [ebp+8]
    enter 0,0
    push eax
    push edx
    mov  edx,ptrPrompt      ; pointer to prompt
    call WriteString
    mov  eax,theSum
    call WriteInt           ; display EAX
    call Crlf
    pop  edx
    pop  eax
    leave
    ret  8                  ; restore the stack
DisplaySum ENDP
END
```

- 시작 모듈 Sum_main.asm: EXTERN으로 세 프로시저를 선언하고, EQU로 @0 이름을 보기 좋게 재정의한다. 각 호출 앞 주석에 매개변수 순서를 적고, STDCALL에 맞게 역순으로 push한다.

```
; Integer Summation Program (Sum_main.asm)
INCLUDE Irvine32.inc
EXTERN PromptForIntegers@0:PROC
EXTERN ArraySum@0:PROC, DisplaySum@0:PROC
ArraySum          EQU ArraySum@0
PromptForIntegers EQU PromptForIntegers@0
DisplaySum        EQU DisplaySum@0
Count = 3                   ; modify Count to change the size of the array
.data
prompt1 BYTE "Enter a signed integer: ",0
prompt2 BYTE "The sum of the integers is: ",0
array   DWORD Count DUP(?)
sum     DWORD ?
.code
main PROC
    call Clrscr
; PromptForIntegers( addr prompt1, addr array, Count )
    push Count
    push OFFSET array
    push OFFSET prompt1
    call PromptForIntegers
; sum = ArraySum( addr array, Count )
    push Count
    push OFFSET array
    call ArraySum
    mov  sum,eax
; DisplaySum( addr prompt2, sum )
    push sum
    push OFFSET prompt2
    call DisplaySum
    call Crlf
    exit
main ENDP
END main
```

### 5.6 INVOKE와 PROTO로 모듈 만들기 (Creating the Modules Using INVOKE and PROTO, 8.5.6)
- INVOKE, PROTO, 확장 PROC을 쓰는 방식의 가장 큰 장점은 INVOKE의 인자 목록과 PROC의 매개변수 목록을 서로 맞춰 검사해 준다는 점이다.
- 먼저 모든 외부 프로시저의 PROTO를 모은 include 파일을 만든다. 각 모듈이 이것을 INCLUDE해도 코드 크기나 실행 오버헤드는 없다. 호출하지 않는 프로시저의 PROTO는 어셈블러가 무시한다.

```
; (sum.inc)
INCLUDE Irvine32.inc
PromptForIntegers PROTO,
    ptrPrompt:PTR BYTE,     ; prompt string
    ptrArray:PTR DWORD,     ; points to the array
    arraySize:DWORD         ; size of the array
ArraySum PROTO,
    ptrArray:PTR DWORD,
    arraySize:DWORD
DisplaySum PROTO,
    ptrPrompt:PTR BYTE,
    theSum:DWORD            ; sum of the array
```

- 각 모듈은 `INCLUDE sum.inc` 후 PROC에 매개변수를 선언한다. 이전 버전과 비교해 enter 0,0 / leave가 사라지고(PROC이 자동 생성), RET에 상수도 필요 없다.

```
; _prompt.asm
INCLUDE sum.inc
.code
PromptForIntegers PROC,
    ptrPrompt:PTR BYTE,
    ptrArray:PTR DWORD,
    arraySize:DWORD
    pushad
    mov  ecx,arraySize
    cmp  ecx,0
    jle  L2
    mov  edx,ptrPrompt
    mov  esi,ptrArray
L1: call WriteString
    call ReadInt
    call Crlf
    mov  [esi],eax
    add  esi,4
    loop L1
L2: popad
    ret
PromptForIntegers ENDP
END
```

- _arrysum.asm과 _display.asm도 같은 식으로 `ArraySum PROC, ptrArray:PTR DWORD, arraySize:DWORD`, `DisplaySum PROC, ptrPrompt:PTR BYTE, theSum:DWORD`로 선언하고 본문은 EQU/enter/leave/ret n 없이 동일하다.
- 시작 모듈은 INVOKE 한 줄로 호출한다.

```
; Integer Summation Program (Sum_main.asm)
INCLUDE sum.inc
Count = 3
.data
prompt1 BYTE "Enter a signed integer: ",0
prompt2 BYTE "The sum of the integers is: ",0
array   DWORD Count DUP(?)
sum     DWORD ?
.code
main PROC
    call Clrscr
    INVOKE PromptForIntegers, ADDR prompt1, ADDR array, Count
    INVOKE ArraySum, ADDR array, Count
    mov  sum,eax
    INVOKE DisplaySum, ADDR prompt2, sum
    call Crlf
    exit
main ENDP
END main
```

- 정리: EXTERN 방식은 전통적이고 세부가 다 드러난다. INVOKE/PROTO/PROC 방식은 세부를 단순화하고 Windows API 호출에 최적화돼 있지만 내부를 숨긴다. 명시적 스택 매개변수 + CALL + EXTERN을 선호해도 된다.

## 6. 매개변수의 고급 사용 (Advanced Use of Parameters, 8.6, 선택 주제)
- 32비트 모드에서 스택 매개변수를 넘길 때 자주 마주치지는 않지만, C/C++ 컴파일러가 만든 코드에서 볼 수 있는 기법들이다.

### 6.1 USES 연산자가 스택에 주는 영향 (Stack Affected by the USES Operator, 8.6.1)
- USES는 프로시저 시작에서 지정 레지스터를 push하고 끝에서 pop하는 코드를 자동 생성한다.
- [ebp+8]처럼 상수 오프셋으로 스택 매개변수에 접근하는 프로시저에는 USES를 쓰면 안 된다. USES의 push가 `push ebp`보다 먼저 들어가서 오프셋이 바뀌기 때문이다.

```
MySub2 PROC USES ecx edx        ; MASM이 생성한 코드
    push ebp                    ;   push ecx
    mov  ebp,esp                ;   push edx
    mov  eax,[ebp+8]            ;   push ebp
    pop  ebp                    ;   mov  ebp,esp
    ret  4                      ;   mov  eax,dword ptr [ebp+8]   ; wrong location!
MySub2 ENDP                     ;   pop  ebp
                                ;   pop  edx
                                ;   pop  ecx
                                ;   ret  4
```

- 실제 매개변수는 [EBP+16]에 있다(위에서부터 parameter, return address, ECX, EDX, EBP).
- 단, PROC의 고급 매개변수 선언 문법을 쓸 때는 MASM이 오프셋을 맞춰 주므로 USES를 써도 문제없다.

### 6.2 8비트·16비트 인자를 스택으로 전달 (Passing 8-Bit and 16-Bit Arguments on the Stack, 8.6.2)
- 32비트 모드에서는 32비트 피연산자를 push하는 것이 좋다. 16비트를 push하면 ESP가 더블워드 경계에서 어긋나 페이지 폴트나 성능 저하가 생길 수 있다. 작은 값은 32비트로 확장해서 push한다.
- 문자 리터럴(`push 'x'`)은 PUSH가 자동으로 32비트로 확장한다. 그러나 PUSH는 8비트 피연산자를 허용하지 않으므로 바이트 변수는 MOVZX로 확장 후 push한다.

```
Uppercase PROC
    push ebp
    mov  ebp,esp
    mov  al,[esp+8]         ; AL = character
    cmp  al,'a'             ; less than 'a'?
    jb   L1                 ; yes: do nothing
    cmp  al,'z'             ; greater than 'z'?
    ja   L1                 ; yes: do nothing
    sub  al,32              ; no: convert it
L1: pop  ebp
    ret  4                  ; clean up the stack
Uppercase ENDP

.data
charVal BYTE 'x'
.code
push charVal                ; syntax error!
movzx eax,charVal           ; move with extension
push eax
call Uppercase
```

- 16비트 정수도 마찬가지다. 32비트를 기대하는 AddTwo에 `push word1`, `push word2`를 하면 오류이고, 각각 `movzx eax,word1` / `push eax`처럼 확장해서 넘긴다.
- 스택 매개변수에서는 순서와 크기가 중요하다. 호출자가 프로시저가 기대하는 매개변수와 일치하게 인자를 넘겨야 한다.

### 6.3 64비트 인자 전달 (Passing 64-Bit Arguments, 8.6.3)
- 32비트 모드에서 64비트 정수를 스택으로 넘길 때는 상위 더블워드를 먼저, 하위 더블워드를 나중에 push한다. 그러면 스택에 리틀 엔디언 순서(하위 바이트가 낮은 주소)로 놓인다.

```
WriteHex64 PROC
    push ebp
    mov  ebp,esp
    mov  eax,[ebp+12]       ; high doubleword
    call WriteHex
    mov  eax,[ebp+8]        ; low doubleword
    call WriteHex
    pop  ebp
    ret  8
WriteHex64 ENDP

.data
longVal QWORD 1234567800ABCDEFh
.code
push DWORD PTR longVal + 4  ; high doubleword
push DWORD PTR longVal      ; low doubleword
call WriteHex64
```

| 내용 | 위치 |
|---|---|
| 12345678 (상위) | [EBP + 12] |
| 00ABCDEF (하위) | [EBP + 8] |
| return address | [EBP + 4] |
| EBP | ← EBP, ESP |

### 6.4 더블워드가 아닌 지역 변수 (Non-Doubleword Local Variables, 8.6.4)
- LOCAL은 크기별로 정렬해 배치한다. 8비트는 다음 빈 바이트, 16비트는 다음 짝수 주소(워드 정렬), 32비트는 다음 더블워드 경계에 놓는다.
- `LOCAL var1:BYTE` 하나면 EBP−4가 아니라 EBP−1에 놓이고, ESP는 4 감소한다. 그 아래 3바이트는 사용하지 않는다(nu).
- `LOCAL temp:DWORD, SwapFlag:BYTE`면 temp는 [EBP−4], SwapFlag는 [EBP−5]이고, ESP는 다음 더블워드 위치로 내려가 총 8바이트가 확보된다(`add esp,0FFFFFFF8h`). 나머지 3바이트는 미사용이다.

```
push ebp
mov  ebp,esp
add  esp,0FFFFFFF8h         ; add -8 to ESP
mov  eax,[ebp-4]            ; temp
mov  bl,[ebp-5]             ; SwapFlag
leave
ret
```

- 수백 바이트 이상의 지역 배열을 쓰려면 .STACK 지시어로 런타임 스택을 충분히 잡아야 한다. Irvine32는 `.stack 4096`을 쓴다.
- 호출이 중첩되면 그 시점에 살아 있는 모든 지역 변수의 합만큼 스택이 필요하다. 예: Sub1(array1[50]:DWORD = 200바이트) → Sub2(array2[80]:WORD = 160바이트) → Sub3(array3[300]:DWORD = 1200바이트). Sub3에 들어가면 지역 변수 1,560바이트 + 복귀 주소 2개 8바이트 + 저장한 레지스터만큼 필요하다.
- 재귀 프로시저라면 대략 (지역 변수 + 매개변수 크기) × 예상 재귀 깊이만큼 스택을 쓴다.

## 7. 자바 바이트코드 (Java Bytecodes, 8.7, 선택 주제)

### 7.1 자바 가상 머신 (Java Virtual Machine, 8.7.1)
- JVM은 컴파일된 자바 바이트코드를 실행하는 소프트웨어다. 자바 바이트코드는 컴파일된 자바 프로그램 안의 기계어를 말한다.
- JVM은 대표적인 스택 기반 머신이다. x86처럼 레지스터에 피연산자를 두지 않고, 데이터 이동·산술·비교·분기를 모두 스택으로 처리한다.
- 자바 소스(Account.java)는 .class 파일(Account.class)의 바이트코드로 컴파일되며, 자바 런타임이 있는 어떤 컴퓨터에서도 실행된다. JVM은 JIT(just-in-time) 컴파일로 바이트코드를 실행 직전에 네이티브 기계어로 바꿀 수 있다.
- 실행 중인 자바 메서드는 자기 스택 프레임(지역 변수, 피연산자 스택, 입력 매개변수, 복귀 주소, 반환값)을 갖는다. 피연산자 영역(operand stack)은 스택 맨 위에 있고, 지역 변수를 산술·비교에 쓰려면 먼저 이 피연산자 스택에 push해야 한다.
- 각 명령어는 1바이트 opcode와 0개 이상의 피연산자로 구성되고(iload, istore, imul, goto 등), 스택 항목은 4바이트(32비트)다.
- JDK의 javap.exe로 .class 파일의 바이트코드를 역어셈블해 볼 수 있다: `javap -c Account`

### 7.2 명령어 집합 (Instruction Set, 8.7.2)
- 기본 데이터 타입은 7가지다. 부호 있는 정수는 x86처럼 2의 보수지만, 빅 엔디언(상위 바이트가 시작 주소)으로 저장한다(x86은 리틀 엔디언).

| 타입 | 바이트 | 형식 |
|---|---|---|
| char | 2 | 유니코드 문자 |
| byte | 1 | 부호 있는 정수 |
| short | 2 | 부호 있는 정수 |
| int | 4 | 부호 있는 정수 |
| long | 8 | 부호 있는 정수 |
| float | 4 | IEEE 단정밀도 실수 |
| double | 8 | IEEE 배정밀도 실수 |

- 비교 명령어: 피연산자 스택에서 두 값을 pop해 비교하고 결과를 push한다(op1을 먼저, op2를 나중에 push했다고 할 때). dcmp는 double, fcmp는 float를 비교한다.

| 비교 결과 | push되는 값 |
|---|---|
| op1 > op2 | 1 |
| op1 = op2 | 0 |
| op1 < op2 | −1 |

- 분기 명령어:
  - 무조건 분기: `goto label`, 서브루틴 호출 `jsr label`
  - 조건 분기: 스택 top 값을 pop해서 판단. `ifle label`은 pop한 값이 0 이하면 분기, `ifgt label`은 0보다 크면 분기한다.

### 7.3 자바 역어셈블 예제 (Java Disassembly Examples, 8.7.3)
- 두 정수 더하기: `int A = 3; int B = 2; int sum = 0; sum = A + B;`
  - 지역 변수는 인덱스 0, 1, 2(A, B, sum)로 구분한다. 오프셋이 연속이라 각 명령어는 1바이트다.

```
0: iconst_3     // 상수 3을 피연산자 스택에 push
1: istore_0     // pop해서 지역 변수 0(A)에 저장
2: iconst_2     // 2 push
3: istore_1     // 지역 변수 1(B)
4: iconst_0     // 0 push
5: istore_2     // 지역 변수 2(sum)
6: iload_0      // A push
7: iload_1      // B push  → 스택: 2(B) 위, 3(A) 아래
8: iadd         // 두 값을 더해 5 push
9: istore_2     // pop해서 sum에 저장, 스택은 비게 됨
```

- 두 double 더하기: `double A = 3.1; double B = 2; double sum = A + B;`
  - ldc2_w는 상수 풀(constant pool)의 실수 상수를 push하며 2바이트 인덱스를 포함하므로 3바이트 명령어다(다음 오프셋이 3).
  - double은 8바이트라 지역 변수 두 칸을 차지한다. 그래서 인덱스가 0, 2, 4로 증가한다.

```
0:  ldc2_w #20;   // double 3.1d
3:  dstore_0      // A
4:  ldc2_w #22;   // double 2.0d
7:  dstore_2      // B
8:  dload_0
9:  dload_2
10: dadd          // 두 double을 더해 push
11: dstore_4      // sum
```

### 7.4 예제: 조건 분기 (Example: Conditional Branch, 8.7.4)
- 비교 연산은 스택 top 두 값을 pop해 비교하고 정수 결과를 push한다. 조건 분기 명령은 그 값을 보고 분기 여부를 정한다.

```
double A = 3.0;
boolean result = false;
if( A > 2.0 )
    result = false;
else
    result = true;
```

```
0:  ldc2_w #26;   // double 3.0d
3:  dstore_0      // pop into A
4:  iconst_0      // false = 0
5:  istore_2      // store in result
6:  dload_0       // A push
7:  ldc2_w #22;   // double 2.0d push
10: dcmpl         // 3.0 > 2.0 이므로 1 push
11: ifle 19       // pop한 값 <= 0 이면(A <= 2.0) 19로 분기
14: iconst_0      // false
15: istore_2      // result = false
16: goto 21       // 다음 두 문장 건너뜀
19: iconst_1      // true
20: istore_2      // result = true
```

- 바이트코드는 if 조건을 뒤집어서(A ≤ 2.0이면 19로 점프) 구현한다. 분기하지 않으면 false를 대입하고 goto로 true 대입 부분을 건너뛴다.
- 결론: JVM은 x86과 달리 계산·비교·분기를 스택 중심으로 처리한다. 각 연산이 한 가지 일만 하는 원자적 연산이라 컴파일러가 만들기 쉽고, JIT로 네이티브 코드로 번역된다는 점에서 RISC 계열 기계어와 공통점이 많다.

## 8. 챕터 요약 (Chapter Summary, 8.8)
- 프로시저 매개변수는 레지스터 매개변수와 스택 매개변수 두 종류다. Irvine32/Irvine64는 실행 속도를 위해 레지스터 매개변수를 쓰지만 호출 코드가 지저분해진다. 스택 매개변수는 호출자가 인자를 스택에 push한다.
- 스택 프레임(활성 레코드)은 복귀 주소, 전달된 매개변수, 지역 변수, 저장된 레지스터를 위한 스택 영역이며, 프로시저 실행을 시작할 때 만들어진다.
- 인자의 복사본을 push하면 값 전달, 주소를 push하면 참조 전달이다. 참조 전달이면 프로시저가 원래 변수를 수정할 수 있다. 배열은 원소를 모두 push하지 않도록 참조로 넘긴다.
- 매개변수는 EBP를 이용한 간접 주소 지정([ebp+8] 등)으로 접근한다. LEA는 어떤 간접 피연산자든 그 주소를 반환하므로 스택 매개변수와 잘 맞는다.
- ENTER는 EBP를 저장하고 지역 변수 공간을 확보해 스택 프레임을 완성하고, LEAVE는 그 동작을 되돌려 프레임을 끝낸다.
- 재귀 서브루틴은 직접 또는 간접적으로 자신을 호출하며, 반복 패턴이 있는 자료 구조에 강력하다.
- LOCAL은 PROC 바로 다음 줄에서 지역 변수를 선언한다. 지역 변수의 장점:
  - 이름과 내용에 접근할 수 있는 범위가 해당 프로시저로 제한되어 디버깅이 쉽다.
  - 수명이 프로시저 실행 동안뿐이라 같은 메모리를 다른 변수가 재사용할 수 있어 효율적이다.
  - 같은 이름을 여러 프로시저에서 써도 충돌하지 않는다.
  - 재귀 프로시저에서 값을 스택에 보관할 수 있다. 전역 변수면 호출마다 값이 덮어써진다.
- INVOKE(32비트 전용)는 여러 인자를 넘길 수 있는 CALL의 강력한 대체물이고, ADDR은 INVOKE에서 포인터를 넘길 때 쓴다.
- PROC은 이름 있는 매개변수 목록과 함께 프로시저를 선언하고, PROTO는 기존 프로시저의 프로토타입(이름 + 매개변수 목록)을 만든다.
- 큰 프로그램은 여러 소스 파일(모듈)로 나누면 보고 고치기 쉽다.
- 자바 바이트코드는 컴파일된 자바 프로그램의 기계어이고 JVM이 실행한다. 명령어는 1바이트 opcode + 0개 이상의 피연산자이며, JVM은 산술·데이터 이동·비교·분기를 스택 중심으로 처리한다. JDK의 javap.exe로 .class 파일을 역어셈블할 수 있다.
