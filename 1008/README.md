# 5장. Procedures (어셈블리 프로그래밍)

## 1. 스택 연산 (Stack Operations, 5.1)

- 스택은 접시를 쌓는 것처럼 맨 위에만 넣고 맨 위에서만 꺼내는 구조다. 마지막에 넣은 값이 가장 먼저 나오므로 LIFO(Last-In, First-Out) 구조라고 한다.
- 이 장에서 다루는 스택은 CPU 하드웨어가 직접 지원하는 런타임 스택(runtime stack)이다. 프로시저를 호출하고 돌아오는 메커니즘의 핵심이며, 보통 그냥 "스택"이라고 부른다.

### 1.1 런타임 스택 (Runtime Stack (32-Bit Mode), 5.1.1)
- 런타임 스택은 CPU가 ESP(스택 포인터 레지스터)로 직접 관리하는 메모리 배열이다. 32비트 모드에서 ESP는 스택 안의 어떤 위치를 가리키는 32비트 오프셋을 담는다.
- ESP는 직접 바꾸는 경우가 드물고, CALL, RET, PUSH, POP 같은 명령어가 간접적으로 바꾼다.
- ESP는 항상 마지막으로 넣은(push한) 값, 즉 스택의 top을 가리킨다. 32비트 모드에서는 스택의 각 칸이 32비트(4바이트)다.
- 런타임 스택은 높은 주소에서 낮은 주소 방향으로 자란다. 그래서 그림을 그릴 때 평소(위 = 낮은 주소)와 반대로, 위쪽에 높은 주소를 두고 아래로 내려가며 그린다(슬라이드 강조).
- 런타임 스택은 자료구조 수업의 스택 ADT와 다르다. 런타임 스택은 시스템 수준에서 서브루틴 호출을 처리하는 것이고, 스택 ADT는 C++이나 Java 같은 고급 언어로 구현하는 프로그래밍 구조다.

Push 연산
- 32비트 push는 ESP를 4 줄인 다음, ESP가 가리키는 위치에 값을 복사한다.
- 예: ESP = 00001000h이고 그 자리에 00000006이 있을 때 000000A5를 push하면 ESP = 00000FFCh가 되고 그 자리에 000000A5가 들어간다.

```
Offset      값
00001000    00000006
00000FFC    000000A5
00000FF8    00000001
00000FF4    00000002   <- ESP (4개를 push한 뒤)
00000FF0
```

Pop 연산
- pop은 ESP가 가리키는 값을 꺼낸 뒤, ESP를 원소 크기만큼 늘려서 다음으로 높은 위치를 가리키게 한다.
- 위 그림에서 00000002를 pop하면 ESP는 00000FF8로 올라간다.
- ESP 아래 영역은 논리적으로 비어 있는 공간이다. 값이 실제로 지워지진 않지만, 다음 push 때 덮어써진다.

스택의 용도 (Stack Applications)
- 레지스터 저장: 레지스터를 여러 용도로 쓸 때 임시로 저장해 두었다가 원래 값으로 복구한다.
- 반환 주소 저장: CALL이 실행되면 CPU가 현재 서브루틴의 반환 주소를 스택에 저장한다.
- 인자 전달: 서브루틴을 호출할 때 인자(argument)라는 입력값을 스택에 push해서 넘긴다.
- 지역 변수 저장: 서브루틴 안의 지역 변수를 위한 임시 저장 공간을 제공한다.

### 1.2 PUSH와 POP 명령어 (PUSH and POP Instructions, 5.1.2)
- PUSH는 먼저 ESP를 줄이고, 그 다음 source 피연산자를 스택에 복사한다. 16비트 피연산자면 ESP가 2 줄고, 32비트면 4 준다.
- POP은 먼저 ESP가 가리키는 값을 16비트 또는 32비트 destination으로 복사하고, 그 다음 ESP를 늘린다(16비트면 +2, 32비트면 +4).
- 순서가 반대라는 점이 중요하다. PUSH는 "감소 → 복사", POP은 "복사 → 증가"다.

```
PUSH reg/mem16
PUSH reg/mem32
PUSH imm32

POP  reg/mem16
POP  reg/mem32
```

PUSHFD와 POPFD
- PUSHFD는 32비트 EFLAGS 레지스터를 스택에 push하고, POPFD는 스택에서 꺼내 EFLAGS에 넣는다. 16비트 FLAGS에는 PUSHF, POPF를 쓴다.
- MOV로는 플래그를 변수에 복사할 수 없으므로, 플래그를 백업하려면 PUSHFD가 가장 좋은 방법이다.
- 코드 블록을 PUSHFD와 POPFD로 감싸는 방식은 실행 흐름이 POPFD를 건너뛰지 않도록 주의해야 한다.
- 실수가 덜한 방법은 push하자마자 변수로 pop해서 보관하는 것이다.

```
.data
saveFlags DWORD ?
.code
pushfd              ; 플래그를 스택에 push
pop saveFlags       ; 변수로 복사

push saveFlags      ; 저장한 플래그를 push
popfd               ; 플래그로 복원
```

PUSHAD, PUSHA, POPAD, POPA
- PUSHAD는 32비트 범용 레지스터를 EAX, ECX, EDX, EBX, ESP(PUSHAD 실행 전 값), EBP, ESI, EDI 순서로 push한다. POPAD는 같은 레지스터를 역순으로 pop한다.
- PUSHA/POPA는 16비트 레지스터(AX, CX, DX, BX, SP, BP, SI, DI)에 대해 같은 일을 한다. 16비트 모드 프로그래밍에서만 쓴다.
- 여러 32비트 레지스터를 바꾸는 프로시저라면 시작에 PUSHAD, 끝에 POPAD를 두어 레지스터를 저장·복원할 수 있다.
- 예외: 레지스터로 결과를 반환하는 프로시저에서는 PUSHAD/POPAD를 쓰면 안 된다. POPAD가 반환값이 든 EAX를 원래 값으로 덮어쓰기 때문이다.

```
MySub PROC
    pushad              ; 범용 레지스터 저장
    mov eax,...
    mov edx,...
    mov ecx,...
    popad               ; 범용 레지스터 복원
    ret
MySub ENDP

ReadValue PROC
    pushad
    mov eax,return_value
    popad               ; EAX를 덮어씀! 반환값 사라짐
    ret
ReadValue ENDP
```

PUSH/POP 활용 예 (슬라이드)
- 프로시저 호출 전에 레지스터를 push하고 호출 후 역순으로 pop하면 원래 값을 지킬 수 있다. pop 순서는 push의 역순이어야 한다.
- 중첩 루프에서 바깥 루프의 ECX를 push로 저장해 두고 안쪽 루프가 ECX를 따로 쓴 뒤 pop으로 복원하는 패턴이 자주 쓰인다.

```
push esi                    ; 레지스터 저장
push ecx
push ebx
mov esi,OFFSET dwordVal     ; 메모리 표시
mov ecx,LENGTHOF dwordVal
mov ebx,TYPE dwordVal
call DumpMem
pop ebx                     ; 역순으로 복원
pop ecx
pop esi

    mov ecx,100             ; 바깥 루프 횟수
L1: push ecx                ; 바깥 루프 카운트 저장
    mov ecx,20              ; 안쪽 루프 횟수
L2: ;
    loop L2                 ; 안쪽 루프 반복
    pop ecx                 ; 바깥 루프 카운트 복원
    loop L1                 ; 바깥 루프 반복
```

예제: 문자열 뒤집기 (Reversing a String)
- 문자열의 각 문자를 차례로 스택에 push한 다음, pop하면서 같은 문자열 변수에 다시 저장한다. 스택이 LIFO이므로 문자 순서가 뒤집힌다.
- push는 32비트 단위로 해야 하므로 MOVZX로 문자를 EAX에 확장해서 push하고, pop할 때는 AL만 저장한다.
- nameSize = ($ - aName) - 1에서 -1은 끝의 null 바이트를 빼기 위한 것이다. 슬라이드에서는 같은 코드에 "I like StarII"라는 문자열을 넣어 설명했다.

```
; Reversing a String (RevStr.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD
.data
aName BYTE "Abraham Lincoln",0
nameSize = ($ - aName) - 1
.code
main PROC
; 문자열을 스택에 push
    mov   ecx,nameSize
    mov   esi,0
L1: movzx eax,aName[esi]    ; 문자 가져오기
    push  eax               ; 스택에 push
    inc   esi
    loop  L1
; 역순으로 pop해서 aName에 저장
    mov   ecx,nameSize
    mov   esi,0
L2: pop   eax               ; 문자 가져오기
    mov   aName[esi],al     ; 문자열에 저장
    inc   esi
    loop  L2
    INVOKE ExitProcess,0
main ENDP
END main
```

## 2. 프로시저 정의와 사용 (Defining and Using Procedures, 5.2)

- 복잡한 문제는 여러 작업으로 나눠야 이해·구현·테스트가 쉽다. 어셈블리에서는 서브루틴을 프로시저(procedure)라고 하고, 다른 언어의 메서드나 함수에 해당한다.
- 객체지향 관점에서 보면 한 클래스의 메서드 묶음은 어셈블리 모듈 안의 프로시저와 데이터 묶음과 비슷하다. 다만 어셈블리에는 형식적인 구조가 없으므로 프로그래머가 스스로 구조를 잡아야 한다.

### 2.1 PROC 지시어 (PROC Directive, 5.2.1)
- 프로시저는 이름이 붙은 명령문 블록이며 return 문으로 끝난다. PROC와 ENDP 지시어로 선언하고, 유효한 식별자로 이름을 붙여야 한다.
- 지금까지 쓴 main도 프로시저이며 프로그램의 시작 프로시저(startup procedure)다.
- main이 아닌 프로시저는 RET 명령어로 끝내야 한다. RET는 CPU를 프로시저가 호출된 위치로 돌려보낸다.

```
sample PROC
    .
    .
    ret
sample ENDP
```

프로시저 안의 레이블 (Labels in Procedures)
- 기본적으로 레이블은 선언된 프로시저 안에서만 보인다. 그래서 JMP나 LOOP의 목적지 레이블은 같은 프로시저 안에 있어야 한다.
- 레이블 이름 뒤에 콜론 두 개(::)를 붙이면 전역 레이블(global label)이 되어 같은 소스 파일 어디서든 접근할 수 있다. 예: `Destination::`
- 하지만 프로시저 밖으로 점프하거나 루프하는 것은 좋은 설계가 아니다. 프로시저는 반환과 스택 정리를 자동으로 하는데, 밖으로 직접 빠져나가면 런타임 스택이 망가지기 쉽다.

예제: 세 정수의 합 (SumOf)
- EAX, EBX, ECX에 세 정수가 들어 있다고 가정하고 합을 EAX로 반환한다.

```
SumOf PROC
    add eax,ebx
    add eax,ecx
    ret
SumOf ENDP
```

프로시저 문서화 (Documenting Procedures)
- 각 프로시저 앞에 다음 정보를 주석으로 적는 습관을 들인다.
  - 프로시저가 하는 모든 작업에 대한 설명
  - Receives: 입력 매개변수 목록과 용도, 입력값의 특별한 요구 조건
  - Returns: 프로시저가 반환하는 값 설명
  - Requires: 호출 전에 만족되어야 하는 사전 조건(precondition). 예: 선을 그리는 프로시저라면 비디오 어댑터가 그래픽 모드여야 한다.
- 이 레이블 이름은 절대적인 것이 아니고 다른 이름을 써도 된다.
- C/C++ 같은 고급 언어 함수는 보통 8비트 값은 AL, 16비트 값은 AX, 32비트 값은 EAX로 반환한다.

```
;---------------------------------------------------------
; sumof
;
; Calculates and returns the sum of three 32-bit integers.
; Receives: EAX, EBX, ECX, the three integers. May be
;           signed or unsigned.
; Returns:  EAX = sum
;---------------------------------------------------------
SumOf PROC
    add eax,ebx
    add eax,ecx
    ret
SumOf ENDP
```

### 2.2 CALL과 RET 명령어 (CALL and RET Instructions, 5.2.2)
- CALL은 프로세서가 새 메모리 위치에서 실행을 시작하게 해서 프로시저를 호출한다. 동작으로 보면 반환 주소(CALL 다음 명령어의 주소)를 스택에 push하고, 호출할 프로시저의 주소를 명령어 포인터(EIP)에 복사한다.
- RET는 스택에서 반환 주소를 pop해서 EIP에 넣는다. 그래서 프로시저가 호출된 지점 바로 다음부터 실행이 이어진다.
- 32비트 모드에서 CPU는 EIP가 가리키는 명령어를 실행하고, 16비트 모드에서는 IP가 그 역할을 한다.
- 슬라이드의 흐름 정리: CALL 실행 → 반환 주소 push → 프로시저 주소를 EIP에 복사 → 프로시저 실행 → RET 실행 → 반환 주소를 pop해서 EIP로 → 반환 주소부터 실행 계속.

호출과 반환 예 (Call and Return Example)
- main의 CALL이 오프셋 00000020에 있고 CALL은 보통 5바이트이므로 다음 명령어는 00000025에 있다. MySub의 첫 명령어는 00000040에 있다.

```
         main PROC
00000020    call MySub
00000025    mov  eax,ebx

         MySub PROC
00000040    mov eax,edx
            .
            ret
         MySub ENDP
```

- CALL 실행 시: 00000025가 스택에 push되고(ESP가 그곳을 가리킴), EIP에 00000040이 들어간다.
- RET 실행 시: 1단계에서 ESP가 가리키는 00000025가 EIP로 pop되고, 2단계에서 ESP가 증가해 스택의 이전 값을 가리킨다.

### 2.3 중첩 프로시저 호출 (Nested Procedure Calls, 5.2.3)
- 호출된 프로시저가 반환하기 전에 다른 프로시저를 호출하는 것을 중첩 프로시저 호출이라고 한다.
- 예: main → Sub1 → Sub2 → Sub3 순서로 호출하면 스택에는 반환 주소가 차례로 쌓인다.

```
Sub3의 RET 직전 스택:
(ret to main)
(ret to Sub1)
(ret to Sub2)   <- ESP

Sub2의 RET 직전:
(ret to main)
(ret to Sub1)   <- ESP

Sub1의 RET 직전:
(ret to main)   <- ESP
```

- Sub3의 RET는 stack[ESP]를 EIP로 pop해서 Sub2의 `call Sub3` 다음으로 돌아간다. 이후 Sub2, Sub1도 같은 방식으로 반환하고 마지막에 main으로 돌아온다.
- 이처럼 스택은 정해진 순서를 거꾸로 되짚어 가야 하는 상황에 유용하다.

### 2.4 레지스터로 인자 전달 (Passing Register Arguments to Procedures, 5.2.4)
- 배열 합 같은 범용 작업을 하는 프로시저 안에 특정 변수 이름을 쓰면 그 배열에만 쓸 수 있다. 대신 배열의 오프셋과 원소 개수를 인자(argument, 입력 매개변수)로 넘기는 것이 좋다.
- 어셈블리에서는 범용 레지스터로 인자를 넘기는 것이 일반적이다.

```
.data
theSum DWORD ?
.code
main PROC
    mov  eax,10000h     ; 인자
    mov  ebx,20000h     ; 인자
    mov  ecx,30000h     ; 인자
    call Sumof          ; EAX = (EAX + EBX + ECX)
    mov  theSum,eax     ; 합 저장
```

### 2.5 예제: 정수 배열 합 (Example: Summing an Integer Array, 5.2.5)
- ArraySum은 32비트 정수 배열의 포인터(ESI)와 원소 개수(ECX)를 받아 합을 EAX로 반환한다.
- 루프 안에서 변수 대신 레지스터를 써서 빠르게 동작한다.
- 특정 배열 이름이나 크기에 묶여 있지 않으므로 32비트 정수 배열 합이 필요한 어느 프로그램에서나 쓸 수 있다. 가능한 한 이렇게 유연한 프로시저를 만들어야 한다.

```
; Testing the ArraySum procedure (TestArraySum.asm)
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
.data
array  DWORD 10000h,20000h,30000h,40000h,50000h
theSum DWORD ?
.code
main PROC
    mov  esi,OFFSET array       ; ESI가 배열을 가리킴
    mov  ecx,LENGTHOF array     ; ECX = 원소 개수
    call ArraySum               ; 합 계산
    mov  theSum,eax             ; EAX로 반환됨
    INVOKE ExitProcess,0
main ENDP
;-----------------------------------------------------
; ArraySum
; Calculates the sum of an array of 32-bit integers.
; Receives: ESI = the array offset
;           ECX = number of elements in the array
; Returns:  EAX = sum of the array elements
;-----------------------------------------------------
ArraySum PROC
    push esi                ; ESI, ECX 저장
    push ecx
    mov  eax,0              ; 합 = 0
L1: add  eax,[esi]          ; 각 정수를 더함
    add  esi,TYPE DWORD     ; 다음 정수로
    loop L1                 ; 배열 크기만큼 반복
    pop  ecx                ; ECX, ESI 복원
    pop  esi
    ret                     ; 합은 EAX에
ArraySum ENDP
END main
```

### 2.6 레지스터 저장과 복원 (Saving and Restoring Registers, 5.2.6)
- ArraySum처럼 프로시저가 바꾸는 레지스터는 시작할 때 push하고 끝날 때 pop해야 한다. 그래야 호출한 쪽의 레지스터 값이 덮어써지지 않는다.
- 예외: 반환값으로 쓰는 레지스터(보통 EAX)는 push/pop하면 안 된다.

USES 연산자
- PROC 바로 뒤에 USES와 레지스터 목록을 쓰면, 어셈블러가 프로시저 시작에 PUSH를, 끝(RET 앞)에 POP을 자동으로 만들어 준다.
- 레지스터 목록은 쉼표가 아니라 공백이나 탭으로 구분한다.

```
ArraySum PROC USES esi ecx
    mov  eax,0              ; 합 = 0
L1: add  eax,[esi]
    add  esi,TYPE DWORD
    loop L1
    ret                     ; 합은 EAX에
ArraySum ENDP

; 어셈블러가 실제로 만드는 코드
ArraySum PROC
    push esi
    push ecx
    mov  eax,0
L1: add  eax,[esi]
    add  esi,TYPE DWORD
    loop L1
    pop  ecx
    pop  esi
    ret
ArraySum ENDP
```

반환 레지스터 예외 예
- 아래 SumOf는 EAX를 push/pop해서 계산한 합이 사라진다.

```
SumOf PROC          ; 세 정수의 합
    push eax        ; EAX 저장
    add  eax,ebx
    add  eax,ecx
    pop  eax        ; 합을 잃어버림!
    ret
SumOf ENDP
```

## 3. 외부 라이브러리 링크 (Linking to an External Library, 5.3)

- 입출력 코드를 어셈블리로 직접 다 짜는 것은 자동차를 처음부터 만드는 것과 비슷하다. 기초를 배우는 동안은 교재의 링크 라이브러리 Irvine32.lib(32비트)와 Irvine64.obj(64비트)를 호출해서 입출력을 쉽게 처리한다.
- Irvine32는 32비트 모드에서만 쓸 수 있고, 입출력 시 MS-Windows API를 호출한다. Irvine64는 화면 출력과 문자열 처리 정도만 있는 작은 라이브러리다.

### 3.1 배경 지식 (Background Information, 5.3.1)
- 링크 라이브러리(link library)는 이미 기계어로 어셈블된 프로시저들을 담은 파일이다. 하나 이상의 소스 파일을 어셈블해 오브젝트 파일을 만들고, 이를 링커가 인식하는 특별한 형식의 파일에 넣어 만든다.
- 외부 프로시저를 쓰려면 소스에 PROTO 지시어로 선언하고 CALL로 호출한다.

```
WriteString proto
call WriteString
```

- 어셈블할 때 어셈블러는 CALL의 목적지 주소를 비워 둔다. 링커가 라이브러리에서 WriteString을 찾아 기계어를 실행 파일에 복사하고, 그 주소를 CALL에 채워 넣는다. 라이브러리에 없으면 링커가 오류를 내고 실행 파일을 만들지 않는다.
- 링커 명령 예: `link hello.obj irvine32.lib kernel32.lib`
- kernel32.lib는 Windows Platform SDK의 일부로, kernel32.dll에 있는 시스템 함수의 링크 정보를 담고 있다. kernel32.dll은 MS-Windows의 핵심 구성 요소인 동적 링크 라이브러리(DLL)로, 문자 기반 입출력 함수를 실제로 실행한다.

```
내 프로그램 --links to--> Irvine32.lib --links to--> kernel32.lib
     └──────────can link to──────────────────────────┘
kernel32.lib --executes--> kernel32.dll
```

- 1~10장은 Irvine32.lib 또는 Irvine64.obj를 링크하고, 11장에서 kernel32.lib에 직접 링크하는 방법을 다룬다.

## 4. Irvine32 라이브러리 (The Irvine32 Library, 5.4)

### 4.1 라이브러리를 만든 이유 (Motivation for Creating the Library, 5.4.1)
- 어셈블리 언어에는 마이크로소프트가 정한 표준 라이브러리가 없다.
- MS-DOS 시절 16비트 프로그램은 INT 21h 서비스로 간단한 입출력을 했지만, 정수 하나를 화면에 출력하려 해도 이진수를 ASCII 문자열로 바꾸는 복잡한 프로시저(WriteInt)를 직접 짜야 했다.
- WriteInt의 로직: 10으로 나눈 나머지를 ASCII로 바꿔 버퍼 뒤에서부터 채우고(숫자가 거꾸로 나오므로), 음수면 앞에 '-'를 붙인 뒤 앞에서부터 출력한다.

```
i = size - 1                ; 버퍼의 마지막 위치
repeat
    r = n mod 10            ; 나머지
    n = n / 10              ; 정수 나눗셈
    digit = r OR 30h        ; ASCII 숫자로 변환
    buffer[i--] = digit     ; 버퍼에 저장
until n = 0
if n is negative
    buffer[i] = "-"         ; 음수 부호
while i > 0
    print buffer[i]
    i++
```

- Windows 32비트 모드에서는 입출력 라이브러리가 운영체제를 직접 호출해야 해서 초보자에게 어렵다. 그래서 Irvine32는 초보자용 간단한 입출력 인터페이스로 설계되었다. 출처를 밝히면 수정·재사용이 가능하다.

### 4.2 Irvine32 프로시저 목록 (Table 5-1)

| 프로시저 | 설명 |
|---|---|
| CloseFile | 열었던 디스크 파일을 닫음 |
| Clrscr | 콘솔 화면을 지우고 커서를 왼쪽 위로 이동 |
| CreateOutputFile | 쓰기용 새 디스크 파일 생성 |
| Crlf | 줄바꿈(end-of-line) 출력 |
| Delay | n밀리초 동안 실행 정지 |
| DumpMem | 메모리 블록을 16진수로 출력 |
| DumpRegs | EAX~EDI, EBP, ESP, EFLAGS, EIP와 주요 플래그를 16진수로 출력 |
| GetCommandTail | 명령줄 인자(command tail)를 바이트 배열로 복사 |
| GetDateTime | 현재 날짜와 시간 가져오기 |
| GetMaxXY | 콘솔 버퍼의 열·행 수 가져오기 |
| GetMseconds | 자정 이후 경과 밀리초 반환 |
| GetTextColor | 현재 전경·배경 색 반환 |
| Gotoxy | 커서를 지정한 행·열로 이동 |
| IsDigit | AL이 ASCII 숫자(0~9)면 ZF 설정 |
| MsgBox | 팝업 메시지 박스 표시 |
| MsgBoxAsk | 예/아니오 질문 팝업 표시 |
| OpenInputFile | 기존 파일을 입력용으로 열기 |
| ParseDecimal32 | 부호 없는 10진 문자열을 32비트 이진수로 변환 |
| ParseInteger32 | 부호 있는 10진 문자열을 32비트 이진수로 변환 |
| Random32 | 0~FFFFFFFFh 범위의 32비트 의사난수 생성 |
| Randomize | 난수 생성기 시드를 고유한 값으로 설정 |
| RandomRange | 지정 범위 안의 의사난수 생성 |
| ReadChar | 키 하나를 입력받을 때까지 기다렸다가 반환 |
| ReadDec | 부호 없는 32비트 10진 정수 입력(Enter로 종료) |
| ReadFromFile | 입력 파일을 버퍼로 읽기 |
| ReadHex | 32비트 16진 정수 입력 |
| ReadInt | 부호 있는 32비트 10진 정수 입력 |
| ReadKey | 기다리지 않고 키보드 입력 버퍼 확인 |
| ReadString | 문자열 입력(Enter로 종료) |
| SetTextColor | 이후 출력할 텍스트의 전경·배경 색 설정 |
| Str_compare | 두 문자열 비교 |
| Str_copy | 문자열 복사 |
| Str_length | 문자열 길이를 EAX로 반환 |
| Str_trim | 문자열에서 불필요한 문자 제거 |
| Str_ucase | 문자열을 대문자로 변환 |
| WaitMsg | 메시지를 표시하고 키 입력 대기 |
| WriteBin | 부호 없는 32비트 정수를 2진수로 출력 |
| WriteBinB | 정수를 byte/word/dword 형식의 2진수로 출력 |
| WriteChar | 문자 하나 출력 |
| WriteDec | 부호 없는 32비트 정수를 10진수로 출력 |
| WriteHex | 32비트 정수를 16진수로 출력 |
| WriteHexB | byte/word/dword 정수를 16진수로 출력 |
| WriteInt | 부호 있는 32비트 정수를 10진수로 출력 |
| WriteStackFrame | 현재 프로시저의 스택 프레임 출력 |
| WriteStackFrameName | 현재 프로시저 이름과 스택 프레임 출력 |
| WriteString | null로 끝나는 문자열 출력 |
| WriteToFile | 버퍼를 출력 파일에 쓰기 |
| WriteWindowsMsg | MS-Windows가 낸 최근 오류 메시지 출력 |

### 4.3 개요 (Overview, 5.4.2)
- 콘솔 창(console window)은 명령 프롬프트를 띄울 때 Windows가 만드는 텍스트 전용 창이다. 기본 크기는 25행 × 80열이고, `mode con cols=40 lines=30`처럼 mode 명령으로 바꿀 수 있다.
- 파일 핸들(file handle)은 Windows가 열린 파일을 식별하는 32비트 정수다. 파일을 열거나 만들면 OS가 핸들을 주고, 이후 읽기·쓰기 때마다 같은 핸들을 넘겨야 한다.
- Irvine32 프로시저를 호출하는 프로그램은 항상 32비트 값을 스택에 push해야 한다. 그렇지 않으면 라이브러리가 호출하는 Win32 콘솔 함수가 제대로 동작하지 않는다.

### 4.4 개별 프로시저 설명 (Individual Procedure Descriptions, 5.4.3)

입력·반환 레지스터 정리

| 프로시저 | 입력 | 반환/결과 |
|---|---|---|
| CloseFile | EAX = 파일 핸들 | 성공 시 EAX ≠ 0 |
| Clrscr | 없음 | 화면 지움 |
| CreateOutputFile | EDX = 파일명 오프셋 | EAX = 핸들 또는 INVALID_HANDLE_VALUE |
| Crlf | 없음 | 0Dh, 0Ah 출력 |
| Delay | EAX = 밀리초 | 정지 |
| DumpMem | ESI = 시작 주소, ECX = 개수, EBX = 단위 크기(1/2/4) | 16진 출력 |
| DumpRegs | 없음 | 레지스터와 CF, SF, ZF, OF, AF, PF 출력 |
| GetCommandTail | EDX = 129바이트 이상 배열 | 명령줄이 비면 CF = 1, 아니면 CF = 0 |
| GetMaxXY | 없음 | DX = 열 수, AX = 행 수 |
| GetMseconds | 없음 | EAX = 자정 이후 밀리초 |
| GetTextColor | 없음 | AL 상위 4비트 = 배경, 하위 4비트 = 전경 |
| Gotoxy | DH = 행(Y), DL = 열(X) | 커서 이동 |
| IsDigit | AL = 문자 | 숫자면 ZF = 1 |
| MsgBox | EDX = 내용, EBX = 제목(0이면 제목 없음) | 팝업 |
| MsgBoxAsk | EDX = 질문, EBX = 제목 | EAX = IDYES(6) 또는 IDNO(7) |
| OpenInputFile | EDX = 파일명 오프셋 | EAX = 핸들 또는 INVALID_HANDLE_VALUE |
| ParseDecimal32 / ParseInteger32 | EDX = 문자열 오프셋, ECX = 길이 | EAX = 변환 값 |
| Random32 | 없음 | EAX = 난수 |
| RandomRange | EAX = n | EAX = 0 ~ n-1 난수 |
| ReadChar | 없음 | AL = 문자(확장키면 AL = 0, AH = 스캔 코드) |
| ReadDec / ReadHex / ReadInt | 없음 | EAX = 입력 값 |
| ReadFromFile | EAX = 핸들, EDX = 버퍼, ECX = 최대 바이트 | CF = 0이면 EAX = 읽은 바이트 수, CF = 1이면 EAX = 오류 코드 |
| ReadKey | 없음 | 입력 없으면 ZF = 1, 있으면 ZF = 0이고 AL = ASCII |
| ReadString | EDX = 버퍼, ECX = 최대 문자 수 + 1 | EAX = 입력한 문자 수 |
| SetTextColor | EAX = 색 속성 | 이후 출력 색 변경 |
| Str_length | EDX = 문자열 오프셋 | EAX = 길이 |
| WriteBin / WriteDec / WriteHex / WriteInt | EAX = 값 | 출력 |
| WriteBinB / WriteHexB | EAX = 값, EBX = 크기(1/2/4) | 출력 |
| WriteChar | AL = 문자 | 출력 |
| WriteString | EDX = 문자열 오프셋 | 출력 |
| WriteToFile | EAX = 핸들, EDX = 버퍼, ECX = 바이트 수 | EAX > 0이면 쓴 바이트 수, 0이면 오류 |

파일 관련 (CloseFile, CreateOutputFile, OpenInputFile, ReadFromFile, WriteToFile, WriteWindowsMsg)
- 파일을 만들거나 열면 EAX에 핸들이 들어오고, 실패하면 EAX = INVALID_HANDLE_VALUE(미리 정의된 상수)다.
- ReadFromFile 후에는 CF를 확인한다. CF가 0이면 EAX가 읽은 바이트 수이고, 1이면 오류 코드이므로 WriteWindowsMsg로 오류 내용을 볼 수 있다.
- WriteWindowsMsg는 "Error 2: The system cannot find the file specified." 같은 메시지를 출력한다.

```
.data
filename BYTE "newfile.txt",0
.code
mov  edx,OFFSET filename
call CreateOutputFile
; if EAX = INVALID_HANDLE_VALUE → 생성 실패
; else EAX = 열린 파일의 핸들

.data
BUFFER_SIZE = 5000
buffer    BYTE BUFFER_SIZE DUP(?)
bytesRead DWORD ?
.code
mov  edx,OFFSET buffer      ; 버퍼 주소
mov  ecx,BUFFER_SIZE        ; 최대 바이트 수
call ReadFromFile           ; 파일 읽기
mov  bytesRead,eax          ; CF = 0일 때: 실제 읽은 바이트 수
```

화면 제어 (Clrscr, Crlf, Delay, WaitMsg, Gotoxy, GetMaxXY)
- Clrscr는 보통 프로그램의 시작과 끝에 호출한다. 중간에 쓸 경우 먼저 WaitMsg를 호출해서 사용자가 화면 내용을 볼 시간을 준다.
- Crlf는 0Dh(CR), 0Ah(LF)를 출력해 커서를 다음 줄 맨 앞으로 옮긴다.
- Gotoxy의 기본 범위는 X(열) 0~79, Y(행) 0~24다. 사용자가 창 크기를 바꿨을 수 있으니 GetMaxXY로 현재 크기를 확인할 수 있다. GetMaxXY의 값은 최대 255까지만 나온다.

```
call WaitMsg        ; "Press any key..."
call Clrscr

mov  eax,1000       ; 1초
call Delay

mov  dh,10          ; 10행
mov  dl,20          ; 20열
call Gotoxy         ; 커서 이동

.data
rows BYTE ?
cols BYTE ?
.code
call GetMaxXY
mov  rows,al
mov  cols,dl
```

디버깅용 (DumpMem, DumpRegs)
- DumpMem은 메모리 범위를 16진수로 출력한다. ESI에 시작 주소, ECX에 단위 개수, EBX에 단위 크기(1 = byte, 2 = word, 4 = doubleword)를 넣는다.
- DumpRegs는 CPU 상태 스냅샷을 보여 준다. 표시되는 EIP는 DumpRegs 호출 다음 명령어의 오프셋이다. 입력도 반환값도 없다.

```
.data
array DWORD 1,2,3,4,5,6,7,8,9,0Ah,0Bh
.code
mov  esi,OFFSET array       ; 시작 오프셋
mov  ecx,LENGTHOF array     ; 단위 개수
mov  ebx,TYPE array         ; doubleword 형식
call DumpMem
; 출력: 00000001 00000002 ... 0000000A 0000000B

call DumpRegs
; EAX=00000613 EBX=00000000 ECX=000000FF EDX=00000000
; ESI=00000000 EDI=00000100 EBP=0000091E ESP=000000F6
; EIP=00401026 EFL=00000286 CF=0 SF=1 ZF=0 OF=0 AF=0 PF=1
```

기타 (GetCommandTail, GetMseconds, GetTextColor, IsDigit, MsgBox, MsgBoxAsk)
- GetCommandTail은 프로그램의 명령줄을 null로 끝나는 문자열로 복사한다. 예를 들어 `Encrypt file1.txt file2.txt`처럼 실행하면 두 파일명을 받아올 수 있다. EDX는 129바이트 이상의 배열을 가리켜야 한다.
- GetMseconds는 이벤트 사이 시간을 재는 데 유용하다. 루프 전후에 호출해 빼면 루프 실행 시간(밀리초)이 나온다.
- MsgBox와 MsgBoxAsk는 콘솔 프로그램에서도 그래픽 팝업 창을 띄운다.

```
.data
cmdTail BYTE 129 DUP(0)     ; 빈 버퍼
.code
mov  edx,OFFSET cmdTail
call GetCommandTail         ; 버퍼 채우기

.data
startTime DWORD ?
.code
call GetMseconds
mov  startTime,eax
L1: ; (루프 본문)
    loop L1
call GetMseconds
sub  eax,startTime          ; EAX = 루프 시간(밀리초)

.data
caption  BYTE "Survey Completed",0
question BYTE "Thank you for completing the survey."
         BYTE 0dh,0ah
         BYTE "Would you like to receive the results?",0
.code
mov  ebx,OFFSET caption
mov  edx,OFFSET question
call MsgBoxAsk              ; EAX = IDYES(6) 또는 IDNO(7)
```

문자열→정수 변환 (ParseDecimal32, ParseInteger32)
- 앞쪽 공백은 무시하고, 숫자가 아닌 문자가 나오기 전까지의 유효한 숫자만 변환한다.
- ParseDecimal32는 부호 없는 정수용이다. 문자열이 비었거나 공백뿐이거나 2^32-1보다 크면 EAX = 0, CF = 1이고, 정상이면 CF = 0이다.
- ParseInteger32는 부호 있는 정수용이며 앞에 +나 -가 올 수 있다. 32비트 부호 있는 범위(-2,147,483,648 ~ 2,147,483,647)를 벗어나면 OF를 설정하고 오류 메시지를 출력한다.

```
.data
buffer BYTE "8193"
bufSize = ($ - buffer)
.code
mov  edx,OFFSET buffer
mov  ecx,bufSize
call ParseDecimal32         ; EAX에 반환
```

난수 (Random32, Randomize, RandomRange)
- Random32는 시드(seed)를 공식에 넣어 난수를 만들고, 다음 난수는 이전 난수를 시드로 써서 만든다. 그래서 진짜 난수가 아니라 흉내 낸 의사난수 수열이다.
- Randomize는 시드를 현재 시각(1/100초 단위)으로 초기화한다. 프로그램 시작에서 한 번만 호출하면 실행할 때마다 다른 수열이 나온다.
- RandomRange는 EAX = n을 받아 0 ~ n-1 범위의 난수를 EAX로 반환한다.

```
    call Randomize
    mov  ecx,10
L1: call Random32
    ; EAX의 난수를 사용하거나 출력
    loop L1

.data
randVal DWORD ?
.code
mov  eax,5000
call RandomRange            ; 0 ~ 4999
mov  randVal,eax
```

키보드 입력 (ReadChar, ReadDec, ReadHex, ReadInt, ReadKey, ReadString)
- ReadChar는 키 하나를 읽어 AL로 반환하며 화면에 표시(echo)하지 않는다. 기능키·화살표·Ins·Del 같은 확장키는 AL = 0, AH = 키보드 스캔 코드가 된다. EAX의 상위 절반은 보존되지 않는다.
- ReadDec은 부호 없는 32비트 정수를 읽는다. 숫자가 아닌 문자 전까지만 변환하므로 "123ABC"를 입력하면 123이 된다. CF 규칙은 ParseDecimal32와 같다(빈 입력, 공백만, 2^32-1 초과면 EAX = 0, CF = 1).
- ReadHex는 오류 검사를 하지 않으며, A~F는 대소문자 모두 허용하고 최대 8자리까지 읽는다.
- ReadInt는 부호 있는 32비트 정수를 읽는다. 범위를 벗어나면 OF를 설정하고 오류 메시지를 출력한다.
- ReadKey는 기다리지 않고 키 입력을 확인한다. 입력이 없으면 ZF = 1, 있으면 ZF = 0이고 AL = ASCII 코드다. AL = 0이면 확장키이며 AH = 가상 스캔 코드, DX = 가상 키 코드, EBX = 키보드 플래그 비트다. EAX와 EDX의 상위 절반이 덮어써진다.
- ReadString은 EDX에 버퍼 주소, ECX에 최대 입력 문자 수 + 1(null 자리)을 넣는다. 입력한 문자 수를 EAX로 반환하고 끝에 null을 자동으로 붙인다.

```
.data
buffer    BYTE 21 DUP(0)        ; 입력 버퍼
byteCount DWORD ?
.code
mov  edx,OFFSET buffer          ; 버퍼 주소
mov  ecx,SIZEOF buffer          ; 최대 문자 수
call ReadString                 ; 문자열 입력
mov  byteCount,eax              ; 입력한 문자 수
; "ABCDEFG" 입력 시 버퍼: 41 42 43 44 45 46 47 00, byteCount = 7
```

텍스트 색 (SetTextColor)
- EAX에 색 속성을 넣고 호출하면 이후 출력되는 텍스트의 전경·배경 색이 바뀐다(Irvine32 전용).
- 색 바이트는 상위 4비트가 배경, 하위 4비트가 전경이다. 그래서 배경 색에 16을 곱하고 전경 색을 더한다. `yellow + (blue SHL 4)`처럼 SHL로 4비트 왼쪽 이동해도 같다. 이 계산은 어셈블 시점에 하므로 상수만 쓸 수 있다.
- 색 상수는 Irvine32.inc에 정의되어 있다.

| 값 | 색 | 값 | 색 | 값 | 색 | 값 | 색 |
|---|---|---|---|---|---|---|---|
| 0 | black | 4 | red | 8 | gray | 12 | lightRed |
| 1 | blue | 5 | magenta | 9 | lightBlue | 13 | lightMagenta |
| 2 | green | 6 | brown | 10 | lightGreen | 14 | yellow |
| 3 | cyan | 7 | lightGray | 11 | lightCyan | 15 | white |

```
mov  eax,white + (blue * 16)    ; 파란 배경에 흰 글자
call SetTextColor
```

출력 (Str_length, WriteBin, WriteBinB, WriteChar, WriteDec, WriteHex, WriteHexB, WriteInt, WriteString)
- WriteBin은 2진수를 4비트씩 묶어 보기 쉽게 출력한다.
- WriteDec은 앞자리 0 없이 부호 없는 10진수로, WriteInt는 부호(+/-)를 붙여 부호 있는 10진수로 출력한다.
- WriteHex는 항상 8자리 16진수로 출력하고 필요하면 앞에 0을 채운다. WriteHexB와 WriteBinB는 EBX로 표시 크기(1, 2, 4바이트)를 정한다.

```
.data
buffer    BYTE "abcde",0
bufLength DWORD ?
.code
mov  edx,OFFSET buffer
call Str_length             ; EAX = 5
mov  bufLength,eax

mov  eax,12346AF9h
call WriteBin               ; 0001 0010 0011 0100 0110 1010 1111 1001

mov  eax,00001234h
mov  ebx,TYPE WORD          ; 2바이트
call WriteBinB              ; 0001 0010 0011 0100

mov  al,'A'
call WriteChar              ; A

mov  eax,295
call WriteDec               ; 295

mov  eax,7FFFh
call WriteHex               ; 00007FFF

mov  eax,7FFFh
mov  ebx,TYPE WORD
call WriteHexB              ; 7FFF

mov  eax,216543
call WriteInt               ; +216543

.data
prompt BYTE "Enter your name: ",0
.code
mov  edx,OFFSET prompt
call WriteString
```

라이브러리 사용 예 (슬라이드)
- 화면을 지우고 500밀리초 쉰 뒤 레지스터와 플래그를 출력한다.
- 문자열 출력 후 줄바꿈은 Crlf를 따로 호출하거나, 문자열 끝에 0Dh, 0Ah를 넣어도 된다.
- ReadString에서 ECX를 SIZEOF - 1로 주면 끝에 붙는 null 자리를 남겨 둔다.

```
call Clrscr
mov  eax,500
call Delay
call DumpRegs

; 방법 1                                  ; 방법 2
.data                                      .data
str1 BYTE "Assembly language is easy!",0   str1 BYTE "Assembly language is easy!",0Dh,0Ah,0
.code                                      .code
mov  edx,OFFSET str1                       mov  edx,OFFSET str1
call WriteString                           call WriteString
call Crlf

.data
fileName BYTE 80 DUP(0)
.code
mov  edx,OFFSET fileName
mov  ecx,SIZEOF fileName - 1    ; 0이 붙을 자리 남김
call ReadString

; 0~99 범위 난수 10개를 한 줄씩 출력
    mov  ecx,10                 ; 루프 카운터
L1: mov  eax,100                ; 상한값
    call RandomRange
    call WriteInt               ; 부호 있는 정수 출력
    call Crlf
    loop L1

; 파란 배경에 노란 글자로 출력
.data
str1 BYTE "Color output is easy!",0
.code
mov  eax,yellow + (blue * 16)
call SetTextColor
mov  edx,OFFSET str1
call WriteString
call Crlf
```

### 4.5 라이브러리 테스트 프로그램 (Library Test Programs, 5.4.4)

Library Test #1: 정수 입출력 (InputLoop.asm)
- 색을 바꾸고, DumpMem으로 배열을 출력한 뒤, 사용자에게 부호 있는 정수 4개를 입력받아 각각 10진수·16진수·2진수로 출력한다.
- 색 바이트 상수는 배경 색 × 16 + 전경 색으로 만든다. 화면 배경까지 새 색으로 바꾸려면 SetTextColor 다음에 Clrscr를 호출해야 한다.
- ReadInt가 입력값을 EAX에 넣으므로, 이어서 WriteInt, WriteHex, WriteBin이 같은 EAX 값을 그대로 출력한다.

```
; Library Test #1: Integer I/O (InputLoop.asm)
; Tests the Clrscr, Crlf, DumpMem, ReadInt, SetTextColor,
; WaitMsg, WriteBin, WriteHex, and WriteString procedures.
include Irvine32.inc
.data
COUNT = 4
BlueTextOnGray = blue + (lightGray * 16)
DefaultColor   = lightGray + (black * 16)
arrayD SDWORD 12345678h,1A4B2000h,3434h,7AB9h
prompt BYTE "Enter a 32-bit signed integer: ",0
.code
main PROC
; 밝은 회색 배경에 파란 글자 선택
    mov  eax,BlueTextOnGray
    call SetTextColor
    call Clrscr                 ; 화면 지우기
; DumpMem으로 배열 출력
    mov  esi,OFFSET arrayD      ; 시작 오프셋
    mov  ebx,TYPE arrayD        ; doubleword = 4바이트
    mov  ecx,LENGTHOF arrayD    ; arrayD의 원소 수
    call DumpMem                ; 메모리 출력
; 부호 있는 정수를 차례로 입력받음
    call Crlf
    mov  ecx,COUNT
L1: mov  edx,OFFSET prompt
    call WriteString
    call ReadInt                ; 정수를 EAX로 입력
    call Crlf
; 10진, 16진, 2진으로 출력
    call WriteInt               ; 부호 있는 10진수
    call Crlf
    call WriteHex               ; 16진수
    call Crlf
    call WriteBin               ; 2진수
    call Crlf
    call Crlf
    loop L1                     ; 반복
; 콘솔 색을 기본값으로 되돌림
    call WaitMsg                ; "Press any key..."
    mov  eax,DefaultColor
    call SetTextColor
    call Clrscr
    exit
main ENDP
END main
```

```
출력 예:
Dump of offset 00405000
-------------------------------
12345678 1A4B2000 00003434 00007AB9

Enter a 32-bit signed integer: -42
-42
FFFFFFD6
1111 1111 1111 1111 1111 1111 1101 0110
Enter a 32-bit signed integer: 36
+36
00000024
0000 0000 0000 0000 0000 0000 0010 0100
```

Library Test #2: 난수 (TestLib2.asm)
- 먼저 0 ~ 4,294,967,294 범위의 부호 없는 난수 10개를 만들고, 다음으로 -50 ~ +49 범위의 부호 있는 난수 10개를 만든다.
- RandomRange로 0~99를 만든 뒤 50을 빼면 -50 ~ +49 범위가 된다. TAB(ASCII 9)를 WriteChar로 출력해서 값을 구분한다.

```
; Link Library Test #2 (TestLib2.asm)
include Irvine32.inc
TAB = 9                         ; Tab의 ASCII 코드
.code
main PROC
    call Randomize              ; 난수 생성기 초기화
    call Rand1
    call Rand2
    exit
main ENDP

Rand1 PROC
; 의사난수 10개 생성
    mov  ecx,10                 ; 10번 반복
L1: call Random32               ; 난수 생성
    call WriteDec               ; 부호 없는 10진수 출력
    mov  al,TAB                 ; 탭
    call WriteChar
    loop L1
    call Crlf
    ret
Rand1 ENDP

Rand2 PROC
; -50 ~ +49 범위 의사난수 10개 생성
    mov  ecx,10
L1: mov  eax,100                ; 0~99
    call RandomRange
    sub  eax,50                 ; -50 ~ +49
    call WriteInt               ; 부호 있는 10진수 출력
    mov  al,TAB
    call WriteChar
    loop L1
    call Crlf
    ret
Rand2 ENDP
END main
```

Library Test #3: 실행 시간 측정 (TestLib3.asm)
- 어셈블리는 성능이 중요한 코드를 최적화하는 데 자주 쓰인다. GetMseconds를 중첩 루프 전후로 호출하고 두 값을 빼서 경과 시간을 구한다.
- innerLoop는 ECX를 자기 루프 카운터로 다시 쓰기 때문에, 시작할 때 push ecx로 바깥(main) 루프의 ECX를 저장하고 끝날 때 pop ecx로 복원한다. 이 push/pop이 없으면 main의 LOOP가 망가진다.
- 교재의 실행 예(Intel Core Duo)에서는 약 4974밀리초가 나왔다.

```
; Link Library Test #3 (TestLib3.asm)
; Calculate the elapsed execution time of a nested loop
include Irvine32.inc
.data
OUTER_LOOP_COUNT = 3
startTime DWORD ?
msg1 BYTE "Please wait...",0dh,0ah,0
msg2 BYTE "Elapsed milliseconds: ",0
.code
main PROC
    mov  edx,OFFSET msg1        ; "Please wait..."
    call WriteString
; 시작 시간 저장
    call GetMSeconds
    mov  startTime,eax
; 바깥 루프 시작
    mov  ecx,OUTER_LOOP_COUNT
L1: call innerLoop
    loop L1
; 경과 시간 계산
    call GetMSeconds
    sub  eax,startTime
; 경과 시간 출력
    mov  edx,OFFSET msg2        ; "Elapsed milliseconds: "
    call WriteString
    call WriteDec               ; 밀리초 출력
    call Crlf
    exit
main ENDP

innerLoop PROC
    push ecx                    ; 현재 ECX 저장
    mov  ecx,0FFFFFFFh          ; 루프 카운터 설정
L1: mul  eax                    ; 사이클 소모
    mul  eax
    mul  eax
    loop L1                     ; 안쪽 루프 반복
    pop  ecx                    ; 저장한 ECX 복원
    ret
innerLoop ENDP
END main
```

## 5. 64비트 어셈블리 프로그래밍 (64-Bit Assembly Programming, 5.5)

### 5.1 Irvine64 라이브러리 (The Irvine64 Library, 5.5.1)
- 64비트 프로그래밍을 돕는 최소한의 라이브러리로, 다음 프로시저를 제공한다.

| 프로시저 | 설명 |
|---|---|
| Crlf | 줄바꿈 출력 |
| Random64 | 0 ~ 2^64-1 범위의 64비트 의사난수를 RAX로 반환 |
| Randomize | 난수 생성기 시드를 고유한 값으로 설정 |
| ReadInt64 | 64비트 부호 있는 정수를 입력받아 RAX로 반환 |
| ReadString | RDX = 버퍼 오프셋, RCX = 최대 문자 수 + 1, RAX = 입력한 문자 수 |
| Str_compare | RSI = 원본, RDI = 대상 문자열 비교. CMP처럼 ZF, CF 설정 |
| Str_copy | RSI의 원본 문자열을 RDI 위치로 복사 |
| Str_length | RCX = 문자열 오프셋, RAX = 길이 |
| WriteInt64 | RAX를 부호 붙은 64비트 10진수로 출력 |
| WriteHex64 | RAX를 64비트 16진수로 출력 |
| WriteHexB | RAX를 1, 2, 4, 8바이트 형식 16진수로 출력(RBX = 크기) |
| WriteString | RDX = 64비트 오프셋의 null 종료 문자열 출력 |

- Irvine64는 RBX, RBP, RDI, RSI, R12~R15의 값을 보존한다. 반면 RAX, RCX, RDX, R8~R11은 보통 보존하지 않는다.

### 5.2 64비트 서브루틴 호출 (Calling 64-Bit Subroutines, 5.5.2)
- 입력 매개변수를 레지스터에 넣고 CALL을 실행하면 된다.
- 내 프로그램 밖에 있는 프로시저는 프로그램 위쪽에 PROTO 지시어로 선언해야 한다.

```
ExitProcess PROTO       ; Windows API에 있음
WriteHex64  PROTO       ; Irvine64 라이브러리에 있음

mov  rax,12345678h
call WriteHex64
```

### 5.3 x64 호출 규약 (The x64 Calling Convention, 5.5.3)
- 마이크로소프트가 64비트 프로그램에서 매개변수 전달과 프로시저 호출에 쓰는 일관된 규칙이다. C/C++ 컴파일러와 Windows API가 이 규약을 따른다.
- Windows API 함수나 C/C++ 함수를 호출할 때만 이 규약을 지키면 되고, Irvine64 라이브러리를 호출할 때는 필요 없다.
- 주요 특징은 다음과 같다.
  - 주소가 64비트이므로 CALL은 RSP에서 8을 뺀다.
  - 처음 네 매개변수는 순서대로 RCX, RDX, R8, R9에 넣는다. 그 이상은 왼쪽에서 오른쪽 순서로 스택에 push한다.
  - 호출하는 쪽이 런타임 스택에 최소 32바이트의 섀도 공간(shadow space)을 확보해야 한다. 호출된 프로시저가 레지스터 매개변수를 이곳에 저장할 수 있다.
  - 서브루틴을 호출할 때 RSP는 16바이트 경계(16의 배수)에 정렬되어 있어야 한다. CALL이 8바이트 반환 주소를 push하므로, 호출하는 쪽은 섀도 공간 32바이트 외에 8을 더 빼야 한다.

### 5.4 프로시저를 호출하는 예제 (Sample Program that Calls a Procedure, 5.5.4)
- AddFour는 RCX, RDX, R8, R9의 네 값을 더해 RAX로 반환한다. 네 입력을 받아 하나의 출력을 결정적으로 만들므로 함수라고 볼 수 있다.

```
 1: ; Calling a subroutine in 64-bit mode (CallProc_64.asm)
 2: ; Chapter 5 example
 3:
 4: ExitProcess PROTO
 5: WriteInt64 PROTO        ; Irvine64 라이브러리
 6: Crlf PROTO              ; Irvine64 라이브러리
 7:
 8: .code
 9: main PROC
10:    sub rsp,8            ; 스택 포인터 정렬
11:    sub rsp,20h          ; 섀도 매개변수용 32바이트 확보
12:
13:    mov rcx,1            ; 네 매개변수를 순서대로 전달
14:    mov rdx,2
15:    mov r8,3
16:    mov r9,4
17:    call AddFour         ; 반환값은 RAX에
18:    call WriteInt64      ; 숫자 출력
19:    call Crlf            ; 줄바꿈
20:
21:    mov ecx,0
22:    call ExitProcess
23: main ENDP
24:
25: AddFour PROC
26:    mov rax,rcx
27:    add rax,rdx
28:    add rax,r8
29:    add rax,r9           ; 합은 RAX에
30:    ret
31: AddFour ENDP
32:
33: END
```

- 10행이 정렬되는 이유: OS가 main을 호출하기 전 RSP는 16바이트 경계에 있었다고 가정한다. OS의 CALL이 8바이트 반환 주소를 push해서 8이 어긋났으므로, 8을 더 빼면 다시 16의 배수가 된다.
- 디버거로 본 RSP 변화(하위 32비트만 표시)는 다음과 같다.

| 시점 | RSP | 의미 |
|---|---|---|
| OS가 main 호출 전 | 01AFE50 | 16바이트 정렬 상태 |
| 10행 실행 전 | 01AFE48 | OS의 CALL이 반환 주소 push |
| 10행 실행 후 | 01AFE40 | 16바이트 경계로 정렬 |
| 11행 실행 후 | 01AFE20 | 01AFE20~01AFE3F에 섀도 공간 32바이트 확보 |
| AddFour 내부 | 01AFE18 | main으로의 반환 주소 push |
| AddFour 반환 후 | 01AFE20 | 호출 전과 같은 값 |

```
(return to OS)      01AFE48
                    01AFE40
shadow p1           01AFE38
shadow p2           01AFE30
shadow p3           01AFE28
shadow p4           01AFE20
(return to main)    01AFE18
```

- ExitProcess 대신 RET로 OS에 돌아가려면, main이 시작될 때의 스택 포인터로 되돌려야 한다. 21~22행을 다음으로 바꾼다.

```
21: add rsp,28      ; 스택 포인터 복원 (28h = 8 + 20h)
22: mov ecx,0       ; 프로세스 반환 코드
23: ret             ; OS로 반환
```

## 6. 장 요약 (Chapter Summary, 5.6)
- 런타임 스택은 주소와 데이터를 임시로 보관하는 특별한 배열이다. ESP가 스택 안의 32비트 오프셋을 가리키며, LIFO 구조다. 스택에는 보통 반환 주소, 매개변수, 지역 변수, 프로시저가 내부적으로 쓰는 레지스터가 저장된다.
- PUSH는 ESP를 줄인 뒤 값을 복사하고, POP은 값을 복사한 뒤 ESP를 늘린다.
- PUSHAD/POPAD는 32비트 범용 레지스터, PUSHA/POPA는 16비트 범용 레지스터(16비트 전용)를 저장·복원한다. PUSHFD/POPFD는 32비트 EFLAGS, PUSHF/POPF는 16비트 FLAGS를 다룬다.
- 프로시저는 PROC와 ENDP로 선언하고 RET로 끝낸다. CALL은 반환 주소를 push하고 프로시저 주소를 EIP에 넣으며, RET는 반환 주소를 pop해서 호출 지점으로 돌아간다.
- 콜론 하나인 레이블은 해당 프로시저 안에서만 보이고, 콜론 두 개(::)인 레이블은 같은 소스 파일 어디서든 보이는 전역 레이블이다.
- USES 연산자는 프로시저가 바꾸는 레지스터를 나열하면 시작에 PUSH, 끝에 POP을 자동 생성한다.
- 슬라이드의 발표 주제: interrupt, library, DLL, DLL 만드는 방법 (Github 업로드).
