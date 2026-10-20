# 6장. Conditional Processing (어셈블리 프로그래밍)

## 1. 조건 분기 (Conditional Branching, 6.1)
- 조건 분기는 조건에 따라 프로그램의 실행 흐름을 바꾸는 기법이다. 고급 언어의 if문, switch문, 조건 반복문은 모두 내부적으로 조건 분기로 만들어진다.
- 어셈블리에는 if 같은 고급 구조가 없지만, 비교 명령어와 점프 명령어를 조합하면 같은 논리를 구현할 수 있다.
- 하드웨어 제어, 암호화, 압축 같은 일은 숫자의 개별 비트를 검사하고, 지우고, 세팅해야 한다. 이 장은 그런 비트 연산부터 시작해서(bottom-up) CMP와 플래그, 조건부 점프, 고급 언어식 구조 구현 순서로 쌓아 올린다.

## 2. 불리언 및 비교 명령어 (Boolean and Comparison Instructions, 6.2)
- 1장에서 배운 AND, OR, XOR, NOT 연산을 비트 단위로 수행하는 명령어가 있고, TEST는 결과를 저장하지 않는 AND이다.

| 명령어 | 동작 |
|---|---|
| AND | 소스와 목적지의 대응 비트끼리 AND |
| OR | 대응 비트끼리 OR |
| XOR | 대응 비트끼리 배타적 OR |
| NOT | 목적지 비트 전체 반전 |
| TEST | AND를 하되 결과는 버리고 플래그만 바꿈 |

### 2.1 CPU 상태 플래그 (The CPU Status Flags, 6.2.1)
- 불리언 명령어는 Zero, Carry, Sign, Overflow, Parity 플래그에 영향을 준다.

| 플래그 | 세트되는 조건 |
|---|---|
| Zero (ZF) | 연산 결과가 0 |
| Carry (CF) | 목적지 피연산자의 최상위 비트 밖으로 올림이 발생 |
| Sign (SF) | 목적지 최상위 비트의 복사본. 1이면 음수, 0이면 양수(0은 양수로 취급) |
| Overflow (OF) | 결과가 목적지의 부호 있는 범위를 벗어남 |
| Parity (PF) | 목적지의 하위 1바이트에 있는 1의 개수가 짝수 |

### 2.2 AND 명령어 (AND Instruction, 6.2.2)
- 문법은 `AND destination,source`. 허용 조합은 reg,reg / reg,mem / reg,imm / mem,reg / mem,imm이고, 두 피연산자 크기는 같아야 한다(8, 16, 32, 64비트). 즉시값은 최대 32비트이다.
- 대응 비트가 둘 다 1일 때만 결과 비트가 1이다.
- AND의 대표 용도는 비트 마스킹이다. 마스크에서 0인 위치의 비트는 지워지고, 1인 위치의 비트는 그대로 남는다.
- 예를 들어 비트 0과 3을 지워서 장치를 리셋하려면 다음과 같이 쓴다.

```
mov al,10101110b
and al,11110110b        ; AL = 10100110b (비트 0, 3 clear)
```

- 플래그: Overflow와 Carry는 항상 0으로 지운다. Sign, Zero, Parity는 결과에 맞게 바뀐다.
- 소문자를 대문자로 바꾸기: 'a'는 61h(01100001b), 'A'는 41h(01000001b)로 비트 5만 다르다. 비트 5를 지우면 대문자가 된다.

```
.data
array BYTE 50 DUP(?)
.code
    mov   ecx,LENGTHOF array
    mov   esi,OFFSET array
L1: and   BYTE PTR [esi],11011111b    ; 비트 5 clear
    inc   esi
    loop  L1
```

### 2.3 OR 명령어 (OR Instruction, 6.2.3)
- 문법은 `OR destination,source`. 피연산자 조합과 크기 규칙은 AND와 같다.
- 대응 비트 중 하나라도 1이면 결과 비트가 1이다. 그래서 다른 비트는 건드리지 않고 특정 비트만 1로 세팅할 때 쓴다.

```
mov al,11100011b
or  al,00000100b        ; AL = 11100111b (비트 2 set)
```

- 플래그: Carry와 Overflow는 항상 지우고, Sign, Zero, Parity는 결과에 맞게 바뀐다.
- 값을 자기 자신과 OR(`or al,al`)하면 값은 그대로 두고 플래그만 바꿀 수 있어서, AL의 부호와 0 여부를 알아내는 데 쓴다.

| ZF | SF | AL의 값 |
|---|---|---|
| 0 | 0 | 0보다 큼 |
| 1 | 0 | 0과 같음 |
| 0 | 1 | 0보다 작음 |

### 2.4 비트맵 집합 (Bit-Mapped Sets, 6.2.4)
- 원소 수가 정해진 전체집합에서 일부를 고르는 집합은, 비트 위치 하나가 원소 하나를 나타내는 비트 벡터(비트맵)로 표현할 수 있다. 포인터나 참조를 담는 컨테이너보다 훨씬 작고 빠르다.
- 예: 원소 0, 1, 2, 31이 속한 집합은 `SetX = 10000000 00000000 00000000 00000111`이다.
- 멤버십 검사: 확인할 원소 위치만 1인 마스크로 AND한 뒤 ZF가 0이면 그 원소가 집합에 속한다.

```
mov eax,SetX
and eax,10000b          ; element[4]가 SetX의 원소인가? (ZF=0이면 원소)
```

- 여집합(complement): NOT으로 모든 비트를 뒤집는다.

```
mov eax,SetX
not eax                 ; SetX의 여집합
```

- 교집합(intersection): AND를 쓴다.

```
mov eax,SetX
and eax,SetY

  1000000000000000000000000000111   (SetX)
AND 1000001010100000000011101100011   (SetY)
  ---------------------------------
  1000000000000000000000000000011   (교집합)
```

- 합집합(union): OR를 쓴다.

```
mov eax,SetX
or  eax,SetY

  1000000000000000000000000000111   (SetX)
OR  1000001010100000000011101100011   (SetY)
  ---------------------------------
  1000001010100000000011101100111   (합집합)
```

- 원소 수가 레지스터 하나(32비트)를 넘으면 루프를 돌면서 여러 워드를 AND/OR해야 한다.

### 2.5 XOR 명령어 (XOR Instruction, 6.2.5)
- 문법은 `XOR destination,source`. 두 비트가 같으면 0, 다르면 1이다.
- 0과 XOR하면 비트가 그대로이고, 1과 XOR하면 비트가 뒤집힌다(토글).
- 같은 값으로 두 번 XOR하면 원래 값으로 돌아온다. `(x ⊕ y) ⊕ y = x`. 이 가역성 때문에 간단한 대칭키 암호화에 쓰인다(3.4절의 암호화 예제 참고).
- 플래그: Overflow, Carry는 항상 0, Sign, Zero, Parity는 결과에 맞게 바뀐다.
- 패리티 검사: 1의 개수가 짝수면 even parity, 홀수면 odd parity이다. x86에서 PF는 결과의 하위 바이트가 even parity일 때 1이다. 값을 바꾸지 않고 패리티를 보려면 0과 XOR한다. (Visual Studio는 PE=1이면 짝수, PE=0이면 홀수로 표시한다.)

```
mov al,10110101b    ; 1이 5개 = odd parity
xor al,0            ; PF = 0
mov al,11001100b    ; 1이 4개 = even parity
xor al,0            ; PF = 1
```

- 16비트 값은 상위 바이트와 하위 바이트를 XOR한 결과의 패리티가 전체 16비트의 패리티와 같다. 두 바이트에서 같은 위치에 있는 1은 XOR로 사라지는데 1이 짝수 개씩 사라지므로 전체 패리티에는 영향이 없기 때문이다.

```
mov ax,64C1h        ; 0110 0100 1100 0001
xor ah,al           ; PF = 1 (even)
```

- 32비트 값은 바이트를 B0~B3이라 할 때 B0 XOR B1 XOR B2 XOR B3의 패리티를 보면 된다.

### 2.6 NOT 명령어 (NOT Instruction, 6.2.6)
- 피연산자의 모든 비트를 반전한다. 결과는 1의 보수(one's complement)이다. 허용 형식은 `NOT reg`, `NOT mem`.
- 어떤 플래그도 바뀌지 않는다.

```
mov al,11110000b
not al              ; AL = 00001111b
```

### 2.7 TEST 명령어 (TEST Instruction, 6.2.7)
- 암묵적인 AND를 수행해서 Sign, Zero, Parity 플래그를 바꾸지만, 목적지 값은 바꾸지 않는다. 피연산자 조합은 AND와 같다. Overflow, Carry는 항상 지운다.
- 특정 비트가 세트되어 있는지 확인할 때 가장 좋다. 비트 마스크로 여러 비트를 한 번에 검사할 수 있고, 검사한 비트가 모두 0일 때만 ZF가 1이 된다.

```
test al,00001001b       ; 비트 0과 3 검사

0 0 1 0 0 1 0 1   <- 입력값
0 0 0 0 1 0 0 1   <- 테스트값(마스크)
0 0 0 0 0 0 0 1   <- 결과: ZF = 0 (검사한 비트 중 세트된 것이 있음)

0 0 1 0 0 1 0 0   <- 입력값
0 0 0 0 1 0 0 1   <- 테스트값
0 0 0 0 0 0 0 0   <- 결과: ZF = 1 (검사한 비트가 모두 clear)
```

### 2.8 CMP 명령어 (CMP Instruction, 6.2.8)
- 비교는 대부분의 불리언 식의 핵심이다(`if A > B`, `while X > 0 and X < 200` 등). 정수(문자 코드 포함)는 CMP로 비교한다. 부동소수점은 12장의 전용 명령어를 쓴다.
- `CMP destination,source`는 목적지에서 소스를 빼는 연산을 암묵적으로 수행하되 두 피연산자는 바꾸지 않는다. 실제로 뺐다면 나왔을 결과에 따라 Overflow, Sign, Zero, Carry, Auxiliary Carry, Parity 플래그가 바뀐다.
- 부호 없는 비교는 ZF와 CF로 판단한다.

| CMP 결과 | ZF | CF |
|---|---|---|
| 목적지 < 소스 | 0 | 1 |
| 목적지 > 소스 | 0 | 0 |
| 목적지 = 소스 | 1 | 0 |

- 부호 있는 비교는 SF, OF, ZF로 판단한다.

| CMP 결과 | 플래그 |
|---|---|
| 목적지 < 소스 | SF ≠ OF |
| 목적지 > 소스 | SF = OF |
| 목적지 = 소스 | ZF = 1 |

- CMP 뒤에 조건부 점프를 붙이면 if문과 같은 구조가 된다.

```
mov ax,5
cmp ax,10           ; ZF = 0, CF = 1 (5 - 10은 빌림 발생)

mov ax,1000
mov cx,1000
cmp cx,ax           ; ZF = 1, CF = 0

mov si,105
cmp si,0            ; ZF = 0, CF = 0
```

### 2.9 개별 CPU 플래그 세트/클리어 (Setting and Clearing Individual CPU Flags, 6.2.9)
- Zero 플래그: TEST나 AND로 0과 연산하면 세트, OR로 1과 연산하면 클리어. TEST는 피연산자를 바꾸지 않고 AND는 바꾼다.
- Sign 플래그: 최상위 비트를 OR 1하면 세트, AND 0하면 클리어.
- Carry 플래그: 전용 명령어 STC(세트), CLC(클리어).
- Overflow 플래그: 두 양수를 더해 음수가 나오게 하면 세트, 0과 OR하면 클리어.

```
test al,0        ; ZF set
and  al,0        ; ZF set
or   al,1        ; ZF clear

or   al,80h      ; SF set
and  al,7Fh      ; SF clear

stc              ; CF set
clc              ; CF clear

mov al,7Fh       ; AL = +127
inc al           ; AL = 80h (-128), OF = 1
or  eax,0        ; OF clear
```

### 2.10 64비트 모드의 불리언 명령어 (Boolean Instructions in 64-Bit Mode, 6.2.10)
- 대부분 32비트 모드와 똑같이 동작한다. 소스가 32비트보다 작은 상수이고 목적지가 64비트면 목적지의 64비트 전체에 영향을 준다.
- 하지만 소스가 32비트 상수나 32비트 레지스터이면, 목적지의 하위 32비트에만 영향을 준다(상위 32비트는 그대로). 목적지가 메모리일 때도 같다. 즉 32비트 피연산자는 예외적인 경우라서 따로 생각해야 한다.

```
.data
allones QWORD 0FFFFFFFFFFFFFFFFh
.code
    mov rax,allones
    and rax,80h          ; RAX = 0000000000000080
    mov rax,allones
    and rax,8080h        ; RAX = 0000000000008080
    mov rax,allones
    and rax,808080h      ; RAX = 0000000000808080
    mov rax,allones
    and rax,80808080h    ; RAX = FFFFFFFF80808080  (32비트 상수: 하위 32비트만 영향)
```

## 3. 조건부 점프 (Conditional Jumps, 6.3)

### 3.1 조건 구조 (Conditional Structures, 6.3.1)
- x86에는 고급 논리 구조가 없다. 조건문은 두 단계로 실행된다. 1단계: CMP, AND, SUB 같은 명령이 CPU 상태 플래그를 바꾼다. 2단계: 조건부 점프 명령이 플래그를 보고 새 주소로 분기한다.

```
cmp eax,0
jz  L1                ; ZF = 1이면 L1으로 점프

and dl,10110000b
jnz L2                ; ZF = 0이면 L2로 점프
```

### 3.2 Jcond 명령어 (Jcond Instruction, 6.3.2)
- 문법은 `Jcond destination`. 플래그 조건이 참이면 목적지 레이블로 분기하고, 거짓이면 바로 다음 명령어가 실행된다. cond는 하나 이상의 플래그 상태를 가리킨다.
- JC / JNC / JZ / JNZ 같은 것이 기본 예이다.
- CPU 상태 플래그는 보통 산술, 비교, 불리언 명령어가 세팅하고, 조건부 점프가 그 플래그를 읽는다.
- 예: EAX가 5일 때 L1으로 가려면 CMP로 ZF를 세트하고 JE를 쓴다. (JE는 항상 ZF를 기준으로 점프한다.)

```
cmp eax,5
je  L1                ; 같으면 점프

mov ax,5
cmp ax,6
jl  L1                ; 5 < 6이라 점프

mov ax,5
cmp ax,4
jg  L1                ; 5 > 4라 점프
```

### 3.3 조건부 점프 명령어의 종류 (Types of Conditional Jump Instructions, 6.3.3)
- 조건부 점프는 네 그룹으로 나뉜다: 특정 플래그 값 기준, 피연산자 동등 여부 또는 (E)CX 값 기준, 부호 없는 비교 기준, 부호 있는 비교 기준.

플래그 값 기준 점프:

| 명령어 | 설명 | 조건 |
|---|---|---|
| JZ | zero면 점프 | ZF = 1 |
| JNZ | zero 아니면 점프 | ZF = 0 |
| JC | carry면 점프 | CF = 1 |
| JNC | carry 아니면 점프 | CF = 0 |
| JO | overflow면 점프 | OF = 1 |
| JNO | overflow 아니면 점프 | OF = 0 |
| JS | 부호 세트(음수)면 점프 | SF = 1 |
| JNS | 부호 클리어면 점프 | SF = 0 |
| JP | parity(짝수)면 점프 | PF = 1 |
| JNP | parity(홀수)면 점프 | PF = 0 |

동등 여부 기준 점프 (`CMP leftOp,rightOp`에서 leftOp은 목적지, rightOp은 소스. 대수식 `X < Y`에서 X가 leftOp):

| 명령어 | 설명 |
|---|---|
| JE | 같으면 점프 (leftOp = rightOp) |
| JNE | 다르면 점프 (leftOp ≠ rightOp) |
| JCXZ | CX = 0이면 점프 |
| JECXZ | ECX = 0이면 점프 |
| JRCXZ | RCX = 0이면 점프 (64비트 모드) |

- JE는 JZ와, JNE는 JNZ와 같은 명령이다. 두 피연산자를 비교하는 의도면 JE/JNE, 플래그 자체를 검사하는 의도면 JZ/JNZ처럼 의도가 드러나는 쪽을 고른다.

```
mov edx,0A523h
cmp edx,0A523h
jne L5               ; 점프 안 함
je  L1               ; 점프함

mov bx,1234h
sub bx,1234h
jne L5               ; 점프 안 함
je  L1               ; 점프함

mov cx,0FFFFh
inc cx
jcxz L2              ; 점프함 (CX = 0)

xor ecx,ecx
jecxz L2             ; 점프함
```

부호 없는 비교 점프 (이 점프들은 부호 없는 값을 비교할 때만 의미가 있다):

| 명령어 | 설명 |
|---|---|
| JA = JNBE | leftOp > rightOp |
| JAE = JNB | leftOp ≥ rightOp |
| JB = JNAE | leftOp < rightOp |
| JBE = JNA | leftOp ≤ rightOp |

부호 있는 비교 점프:

| 명령어 | 설명 |
|---|---|
| JG = JNLE | leftOp > rightOp |
| JGE = JNL | leftOp ≥ rightOp |
| JL = JNGE | leftOp < rightOp |
| JLE = JNG | leftOp ≤ rightOp |

- 같은 비트 패턴도 부호 있는/없는 비교에서 결과가 달라진다. 아래 예에서 JA는 부호 없는 7Fh < 80h라서 점프하지 않고, JG는 +127 > -128이라 점프한다.

```
mov al,+127          ; 7Fh
cmp al,-128          ; 80h
ja  IsAbove          ; 점프 안 함 (7Fh < 80h, 부호 없는 비교)
jg  IsGreater        ; 점프함 (+127 > -128, 부호 있는 비교)
```

- 부호 있는 점프 예제:

```
mov edx,-1
cmp edx,0
jnl  L5              ; 점프 안 함 (-1 >= 0 거짓)
jnle L5              ; 점프 안 함 (-1 > 0 거짓)
jl   L1              ; 점프함 (-1 < 0 참)

mov bx,+32
cmp bx,-35
jng  L5              ; 점프 안 함 (+32 <= -35 거짓)
jnge L5              ; 점프 안 함 (+32 < -35 거짓)
jge  L1              ; 점프함 (+32 >= -35 참)

mov ecx,0
cmp ecx,0
jg  L5               ; 점프 안 함 (0 > 0 거짓)
jnl L1               ; 점프함 (0 >= 0 참)

mov ecx,0
cmp ecx,0
jl  L5               ; 점프 안 함 (0 < 0 거짓)
jng L1               ; 점프함 (0 <= 0 참)
```

### 3.4 조건부 점프 응용 (Conditional Jump Applications, 6.3.4)
- 상태 비트 검사: 값을 바꾸지 않고 비트만 확인하려면 TEST를 쓴다.

```
mov  al,status
test al,00100000b        ; 비트 5 검사
jnz  DeviceOffline       ; 세트면 장치 오프라인

mov  al,status
test al,00010011b        ; 비트 0, 1, 4 중 하나라도 세트?
jnz  InputDataByte
```

- 여러 비트가 "모두" 세트인지 확인하려면 AND로 마스크한 뒤 CMP로 마스크와 같은지 비교한다. TEST만으로는 "하나라도 세트"만 알 수 있기 때문이다.

```
mov al,status
and al,10001100b         ; 비트 2, 3, 7만 남김
cmp al,10001100b         ; 모두 세트인가?
je  ResetMachine         ; 그렇다면 점프
```

- 두 정수 중 큰 값(부호 없음): 일단 EAX가 크다고 가정하고 EDX에 넣은 뒤, EAX < EBX일 때만 덮어쓴다.

```
    mov edx,eax          ; EAX가 크다고 가정
    cmp eax,ebx
    jae L1               ; EAX >= EBX면 점프
    mov edx,ebx          ; 아니면 EBX를 EDX로
L1:                      ; EDX = 더 큰 값
```

- 세 정수 중 가장 작은 값(부호 없는 16비트 V1, V2, V3):

```
.data
V1 WORD ?
V2 WORD ?
V3 WORD ?
.code
    mov ax,V1            ; V1이 가장 작다고 가정
    cmp ax,V2
    jbe L1               ; AX <= V2면 점프
    mov ax,V2
L1: cmp ax,V3
    jbe L2               ; AX <= V3면 점프
    mov ax,V3
L2:
```

- 키가 눌릴 때까지 반복: Irvine32의 ReadKey는 입력 버퍼에 키가 없으면 ZF를 세트한다. 루프에 10ms 지연을 넣는 이유는 MS-Windows가 이벤트 메시지를 처리할 시간을 주기 위해서이다. 지연이 없으면 키 입력이 무시될 수 있다.

```
.data
char BYTE ?
.code
L1: mov  eax,10          ; 10ms 지연
    call Delay
    call ReadKey         ; 키 확인
    jz   L1              ; 키 없으면 반복
    mov  char,AL         ; 문자 저장
```

- 배열 순차 탐색 (ArrayScan.asm): 16비트 정수 배열에서 첫 번째 0이 아닌 값을 찾아 출력하고, 없으면 메시지를 출력한다. 부호 있는 값을 출력하므로 `movsx`로 부호 확장해서 EAX에 넣고 WriteInt를 부른다.

```
; Scanning an Array                   (ArrayScan.asm)
; Scan an array for the first nonzero value.
INCLUDE Irvine32.inc
.data
intArray SWORD 0,0,0,0,1,20,35,-12,66,4,0
;intArray SWORD 1,0,0,0              ; alternate test data
;intArray SWORD 0,0,0,0              ; alternate test data
;intArray SWORD 0,0,0,1              ; alternate test data
noneMsg BYTE "A non-zero value was not found",0
.code
main PROC
    mov   ebx,OFFSET intArray            ; point to the array
    mov   ecx,LENGTHOF intArray          ; loop counter
L1: cmp   WORD PTR [ebx],0               ; compare value to zero
    jnz   found                          ; found a value
    add   ebx,2                          ; point to next
    loop  L1                             ; continue the loop
    jmp   notFound                       ; none found
found:                                   ; display the value
    movsx eax,WORD PTR[ebx]              ; sign-extend into EAX
    call  WriteInt
    jmp   quit
notFound:                                ; display "not found" message
    mov   edx,OFFSET noneMsg
    call  WriteString
quit:
    call  Crlf
    exit
main ENDP
END main
```

- 간단한 문자열 암호화: XOR의 가역성을 이용한다. 평문(plain text)의 각 문자를 키 문자와 XOR하면 암호문(cipher text)이 되고, 같은 키로 다시 XOR하면 평문으로 돌아온다. 암호화와 복호화에 같은 키를 쓰므로 대칭키 암호화이다.
- 프로그램 흐름: (1) 사용자가 평문을 입력 (2) 한 글자 키로 암호화해서 암호문을 출력 (3) 같은 루틴으로 복호화해서 원래 평문을 출력. TranslateBuffer를 두 번 호출하는 구조가 핵심이다.
- 한 글자 키는 쉽게 풀리므로 중요한 데이터에는 쓰면 안 된다. 실제로는 여러 글자 키를 써야 한다.

```
; Encryption Program                            (Encrypt.asm)
INCLUDE Irvine32.inc
KEY = 239                             ; any value between 1-255
BUFMAX = 128                          ; maximum buffer size

.data
sPrompt  BYTE "Enter the plain text:",0
sEncrypt BYTE "Cipher text:   ",0
sDecrypt BYTE "Decrypted:     ",0
buffer   BYTE BUFMAX+1 DUP(0)
bufSize  DWORD ?

.code
main PROC
    call  InputTheString          ; input the plain text
    call  TranslateBuffer         ; encrypt the buffer
    mov   edx,OFFSET sEncrypt     ; display encrypted message
    call  DisplayMessage
    call  TranslateBuffer         ; decrypt the buffer
    mov   edx,OFFSET sDecrypt     ; display decrypted message
    call  DisplayMessage
    exit
main ENDP

InputTheString PROC
; Prompts user for a plaintext string. Saves the string and its length.
    pushad                        ; save 32-bit registers
    mov   edx,OFFSET sPrompt      ; display a prompt
    call  WriteString
    mov   ecx,BUFMAX              ; maximum character count
    mov   edx,OFFSET buffer       ; point to the buffer
    call  ReadString              ; input the string
    mov   bufSize,eax             ; save the length
    call  Crlf
    popad
    ret
InputTheString ENDP

DisplayMessage PROC
; Displays the encrypted or decrypted message. EDX points to the message.
    pushad
    call  WriteString
    mov   edx,OFFSET buffer       ; display the buffer
    call  WriteString
    call  Crlf
    call  Crlf
    popad
    ret
DisplayMessage ENDP

TranslateBuffer PROC
; Translates the string by exclusive-ORing each byte with the key byte.
    pushad
    mov   ecx,bufSize             ; loop counter
    mov   esi,0                   ; index 0 in buffer
L1: xor   buffer[esi],KEY         ; translate a byte
    inc   esi                     ; point to next byte
    loop  L1
    popad
    ret
TranslateBuffer ENDP
END main
```

## 4. 조건부 루프 명령어 (Conditional Loop Instructions, 6.4)

### 4.1 LOOPZ와 LOOPE (LOOPZ and LOOPE Instructions, 6.4.1)
- LOOPZ(loop if zero)는 LOOP와 같지만 조건이 하나 더 붙는다. ZF가 세트되어 있어야 레이블로 분기한다. 문법은 `LOOPZ destination`.
- LOOPE(loop if equal)는 LOOPZ와 같은 명령(같은 opcode)이다.

```
ECX = ECX - 1
if ECX > 0 and ZF = 1, jump to destination
```

- 조건이 거짓이면 점프 없이 다음 명령으로 간다. LOOPZ/LOOPE는 상태 플래그를 바꾸지 않는다. 32비트 모드의 카운터는 ECX, 64비트 모드는 RCX이다.

### 4.2 LOOPNZ와 LOOPNE (LOOPNZ and LOOPNE Instructions, 6.4.2)
- LOOPNZ(loop if not zero)는 LOOPZ의 반대이다. ECX(감소 후)가 0보다 크고 ZF가 클리어일 때 계속 반복한다. LOOPNE는 같은 명령이다.

```
ECX = ECX - 1
if ECX > 0 and ZF = 0, jump to destination
```

- 예제(Loopnz.asm): 배열에서 처음으로 나오는 비음수(부호 비트가 0)를 찾는다. ADD가 플래그를 바꾸기 때문에 ADD 앞에서 PUSHFD로 플래그를 저장하고, LOOPNZ 직전에 POPFD로 복원한다.

```
.data
array    SWORD -3,-6,-1,-10,10,30,40,4
sentinel SWORD 0
.code
    mov    esi,OFFSET array
    mov    ecx,LENGTHOF array
L1: test   WORD PTR [esi],8000h     ; 부호 비트 검사
    pushfd                          ; 플래그 저장
    add    esi,TYPE array           ; 다음 원소로 이동
    popfd                           ; 플래그 복원
    loopnz L1                       ; 계속 반복
    jnz    quit                     ; 못 찾음
    sub    esi,TYPE array           ; ESI가 찾은 값을 가리킴
quit:
```

- 비음수를 찾으면 ESI가 그 값을 가리킨 채로 끝난다(루프를 빠져나올 때 이미 ESI를 하나 증가시켰으므로 SUB로 되돌린다). 끝까지 못 찾으면 ECX가 0이 되어 루프가 끝나고 JNZ가 quit으로 점프하는데, 이때 ESI는 배열 바로 뒤에 있는 sentinel(0) 위치를 가리킨다. sentinel은 "못 찾았을 때 ESI가 배열 밖 임의의 메모리를 가리키지 않게" 하는 안전장치이다.
- 슬라이드의 LOOPE 예제: 반대로 0이 아닌 값을 처음 찾을 때까지 반복한다. 값이 0인 동안 ZF=1이라 계속 돌고, 0이 아닌 값을 만나면 멈춘다. sentinel은 0FFFFh로 둔다.

```
.data
array    SWORD 50 DUP(?)
sentinel SWORD 0FFFFh
.code
    mov esi,OFFSET array
    mov ecx,LENGTHOF array
L1: cmp WORD PTR [esi],0
    pushfd
    add esi,TYPE array
    popfd
    loope L1
    jz  quit                 ; 못 찾음 (끝까지 전부 0)
    sub esi,TYPE array       ; ESI가 0이 아닌 값을 가리킴
quit:
```

## 5. 조건 구조 (Conditional Structures, 6.5)
- 조건 구조란 하나 이상의 조건식으로 서로 다른 논리 분기를 고르는 구조이다. 각 분기는 서로 다른 명령어 열을 실행한다. 컴파일러가 이런 구조를 기계어로 어떻게 바꾸는지 직접 해 본다.

### 5.1 블록 구조 IF문 (Block-Structured IF Statements, 6.5.1)
- IF 구조는 불리언 식 하나와 문장 목록 두 개(참일 때, 거짓일 때)로 이루어진다. else는 생략할 수 있다.
- 어셈블리로 옮기는 순서: (1) 불리언 식을 평가해서 CPU 플래그를 바꾼다. (2) 그 플래그에 따라 두 문장 목록 중 하나로 점프한다.
- 같은 구조도 여러 방식으로 번역할 수 있다. 책의 예제는 가상의 컴파일러가 만들 법한 한 가지 번역이다.

예 1: `if( op1 == op2 ) { X = 1; Y = 2; }` — op1, op2는 메모리 변수이므로 하나를 레지스터로 옮겨야 한다. 조건을 뒤집어(JNE) 거짓일 때 건너뛰게 하면, 참일 때는 그냥 아래로 "fall through"해서 5개 명령으로 끝난다. JE를 쓰면 JMP가 하나 더 필요해서 6개 명령이 된다.

```
    mov eax,op1
    cmp eax,op2              ; op1 == op2?
    jne L1                   ; 아니면 건너뜀
    mov X,1                  ; 맞으면 X, Y 대입
    mov Y,2
L1:

; JE로 구현하면 (6개 명령):
    mov eax,op1
    cmp eax,op2
    je  L1                   ; 맞으면 L1
    jmp L2                   ; 아니면 대입 건너뜀
L1: mov X,1
    mov Y,2
L2:
```

예 2: NTFS 클러스터 크기. 볼륨 크기(terrabytes)가 16TB 미만이면 4096, 아니면 8192이다. 먼저 큰 값을 넣어 두고, 조건이 참일 때만 덮어쓴다.

```
clusterSize = 8192;
if terrabytes < 16
    clusterSize = 4096;

    mov clusterSize,8192     ; 큰 클러스터로 가정
    cmp terrabytes,16        ; 16TB보다 작은가?
    jae next
    mov clusterSize,4096     ; 작은 클러스터로 변경
next:
```

예 3: 두 갈래(if-else). op1, op2는 부호 있는 DWORD라고 가정한다(그래서 JG).

```
if op1 > op2
    call Routine1
else
    call Routine2
end if

    mov eax,op1              ; 변수 하나를 레지스터로
    cmp eax,op2              ; op1 > op2?
    jg  A1                   ; 맞으면 Routine1
    call Routine2            ; 아니면 Routine2
    jmp A2                   ; IF문 탈출
A1: call Routine1
A2:
```

- 화이트 박스 테스트(White Box Testing): 소스 코드를 보면서 다양한 입력값에 대해 실행 경로와 출력을 직접 추적해서 검증하는 방법이다. 분기가 많은 중첩 IF문은 눈으로 읽기만 해서는 디버깅이 어렵기 때문에 쓴다.
- 중첩 IF 예제: 첫 조건(op1 == op2)을 뒤집어서(JNE) 바로 ELSE 쪽(Routine3)으로 점프하게 하고, 나머지는 안쪽 IF-ELSE만 번역한다. (줄 번호는 아래 테스트표에서 사용한다.)

```
if op1 == op2
    if X > Y
        call Routine1
    else
        call Routine2
    end if
else
    call Routine3
end if

1:      mov  eax,op1
2:      cmp  eax,op2        ; op1 == op2?
3:      jne  L2             ; 아니면 Routine3
        ; 안쪽 IF-ELSE
4:      mov  eax,X
5:      cmp  eax,Y          ; X > Y?
6:      jg   L1             ; 맞으면 Routine1
7:      call Routine2       ; 아니면 Routine2
8:      jmp  L3             ; 탈출
9: L1:  call Routine1
10:     jmp  L3             ; 탈출
11: L2: call Routine3
12: L3:
```

| op1 | op2 | X | Y | 실행된 줄 | 호출 |
|---|---|---|---|---|---|
| 10 | 20 | 30 | 40 | 1, 2, 3, 11, 12 | Routine3 |
| 10 | 20 | 40 | 30 | 1, 2, 3, 11, 12 | Routine3 |
| 10 | 10 | 30 | 40 | 1, 2, 3, 4, 5, 6, 7, 8, 12 | Routine2 |
| 10 | 10 | 40 | 30 | 1, 2, 3, 4, 5, 6, 9, 10, 12 | Routine1 |

### 5.2 복합식 (Compound Expressions, 6.5.2)
- 논리 AND: `if (al > bl) AND (bl > cl) then X = 1` (부호 없는 정수). 고급 언어의 표준인 단락 평가(short-circuit evaluation)를 쓰면, 첫 식이 거짓일 때 둘째 식은 평가하지 않는다.
- 처음 구현은 JA로 참일 때 점프해서 7개 명령이 필요하다. 첫 JA를 JBE(거짓이면 탈출)로 바꾸고 참이면 아래로 내려가게 하면 5개로 줄어든다(약 29% 감소).

```
; 단순 구현 (7개)
    cmp al,bl
    ja  L1
    jmp next
L1: cmp bl,cl
    ja  L2
    jmp next
L2: mov X,1
next:

; 최적화 (5개)
    cmp al,bl                ; 첫 번째 식
    jbe next                 ; 거짓이면 탈출
    cmp bl,cl                ; 두 번째 식
    jbe next                 ; 거짓이면 탈출
    mov X,1                  ; 둘 다 참
next:
```

- 논리 OR: `if (al > bl) OR (bl > cl) then X = 1`. 하나라도 참이면 전체가 참이다. 첫 식이 참이면 바로 L1(참 처리)으로 점프하고, 거짓이면 둘째 CMP로 넘어간다. 둘째 식은 부등호를 뒤집어 JBE로 거짓이면 탈출한다.

```
    cmp al,bl                ; 1: AL과 BL 비교
    ja  L1                   ; 참이면 두 번째 식 건너뜀
    cmp bl,cl                ; 2: BL과 CL 비교
    jbe next                 ; 거짓이면 다음 문장 건너뜀
L1: mov X,1                  ; 참: X = 1
next:
```

- 복합식도 여러 방식으로 구현할 수 있다.

### 5.3 WHILE 루프 (WHILE Loops, 6.5.3)
- WHILE은 조건을 먼저 검사하고 블록을 실행하며, 조건이 참인 동안 반복한다. 어셈블리에서는 조건을 뒤집어서 조건이 거짓이 되면 endwhile로 점프하게 만드는 것이 편하다.
- 변수 val1을 EAX로 대신 쓰고(프록시), 루프 안에서는 EAX로만 val1에 접근한다. 끝나면 EAX를 val1에 다시 저장한다. JNL을 썼으므로 부호 있는 정수라고 가정한 것이다.

```
while( val1 < val2 )
{
    val1++;
    val2--;
}

    mov eax,val1             ; 변수를 EAX로 복사
beginwhile:
    cmp eax,val2             ; val1 < val2가 아니면
    jnl endwhile             ;   루프 탈출
    inc eax                  ; val1++
    dec val2                 ; val2--
    jmp beginwhile           ; 반복
endwhile:
    mov val1,eax             ; 새 val1 값 저장
```

- WHILE 안에 IF가 들어간 예: 배열에서 sample(50)보다 큰 원소의 합을 구한다.

```
int array[] = {10,60,20,33,72,89,45,65,72,18};
int sample = 50;
int ArraySize = sizeof array / sizeof sample;
int index = 0;
int sum = 0;
while( index < ArraySize )
{
    if( array[index] > sample )
    {
        sum += array[index];
    }
    index++;
}
```

- 코드로 옮기기 전에 순서도(Fig. 6-1)로 논리를 그린다. 메모리 접근을 줄이려고 변수 대신 레지스터를 쓴다: EDX = sample, EAX = sum, ESI = index, ECX = ArraySize. 순서도의 각 도형마다 레이블(L1~L5)을 붙이고 같은 레이블을 소스에 쓰면 번역이 쉽다.
- 순서도 구조: L1(esi < ecx?) → 참이면 L2(array[esi] > edx?) → 참이면 L3(eax += array[esi]) → L4(inc esi) → L1로. L1이 거짓이면 L5(sum = eax)로 가서 끝난다.

```
.data
sum       DWORD 0
sample    DWORD 50
array     DWORD 10,60,20,33,72,89,45,65,72,18
ArraySize = ($ - Array) / TYPE array
.code
main PROC
    mov eax,0                ; sum
    mov edx,sample
    mov esi,0                ; index
    mov ecx,ArraySize
L1: cmp esi,ecx              ; if esi < ecx
    jl  L2
    jmp L5
L2: cmp array[esi*4],edx     ; if array[esi] > edx
    jg  L3
    jmp L4
L3: add eax,array[esi*4]
L4: inc esi
    jmp L1
L5: mov sum,eax
```

- 이 코드는 JMP가 많아서 개선할 여지가 있다(조건을 뒤집어 fall through하면 줄일 수 있다).

### 5.4 테이블 기반 선택 (Table-Driven Selection, 6.5.4)
- 여러 갈래 선택 구조(switch)를 표 조회로 대체하는 방법이다. 조회값과 레이블(프로시저) 주소를 담은 표를 만들고, 루프로 표를 훑어 일치하는 항목을 찾는다. 비교 횟수가 많을 때 효과적이다.
- 예: 문자 하나(1바이트)와 그 문자에 대응하는 프로시저 주소(4바이트 DWORD)를 한 항목으로 한다. 항목 크기는 5바이트다.
- 예제 프로그램(ProcTable.asm): 사용자가 키를 입력하면, 표를 순서대로 비교해서 처음 일치한 항목의 프로시저를 호출한다. 각 프로시저는 EDX에 서로 다른 문자열 오프셋을 넣고, 호출한 쪽이 WriteString으로 출력한다.
- `EntrySize = ($ - CaseTable)`로 첫 항목의 크기를 계산하고, `NumberOfEntries = ($ - CaseTable) / EntrySize`로 항목 수를 계산한다. 숫자 4를 직접 적지 않고 어셈블러가 계산하게 하면, 항목을 추가하거나 지워도 값이 자동으로 맞아서 안전하다.
- `call NEAR PTR [ebx + 1]`은 EBX+1 위치에 저장된 주소로 간접 호출한다. 간접 호출에는 NEAR PTR 연산자가 필요하다.

```
; Table of Procedure Offsets                (ProcTable.asm)
INCLUDE Irvine32.inc
.data
CaseTable BYTE 'A'                    ; lookup value
          DWORD Process_A             ; address of procedure
EntrySize = ($ - CaseTable)
          BYTE 'B'
          DWORD Process_B
          BYTE 'C'
          DWORD Process_C
          BYTE 'D'
          DWORD Process_D
NumberOfEntries = ($ - CaseTable) / EntrySize
prompt BYTE "Press capital A,B,C,or D: ",0
msgA BYTE "Process_A",0
msgB BYTE "Process_B",0
msgC BYTE "Process_C",0
msgD BYTE "Process_D",0

.code
main PROC
    mov  edx,OFFSET prompt        ; ask user for input
    call WriteString
    call ReadChar                 ; read character into AL
    mov  ebx,OFFSET CaseTable     ; point EBX to the table
    mov  ecx,NumberOfEntries      ; loop counter
L1: cmp  al,[ebx]                 ; match found?
    jne  L2                       ; no: continue
    call NEAR PTR [ebx + 1]       ; yes: call the procedure
    call WriteString              ; display message
    call Crlf
    jmp  L3                       ; exit the search
L2: add  ebx,EntrySize            ; point to the next entry
    loop L1                       ; repeat until ECX = 0
L3: exit
main ENDP

Process_A PROC
    mov edx,OFFSET msgA
    ret
Process_A ENDP
Process_B PROC
    mov edx,OFFSET msgB
    ret
Process_B ENDP
Process_C PROC
    mov edx,OFFSET msgC
    ret
Process_C ENDP
Process_D PROC
    mov edx,OFFSET msgD
    ret
Process_D ENDP
END main
```

- 처음 준비하는 데 약간의 오버헤드가 있지만, 비교-점프-CALL을 길게 나열하는 것보다 코드가 짧고 수정이 쉽다. 표는 실행 중에 재구성할 수도 있다.

## 6. 응용: 유한 상태 기계 (Application: Finite-State Machines, 6.6)
- 유한 상태 기계(FSM)는 입력에 따라 상태가 바뀌는 기계 또는 프로그램이다. 그래프로 표현하며, 노드(원/사각형)는 상태, 간선(edge, arc)은 한 상태에서 다른 상태로의 전이(transition)를 나타낸다.
- 시작 상태(initial state)는 들어오는 화살표로 표시하고, 종료 상태(terminal state)는 굵은 테두리로 표시한다. 종료 상태는 오류 없이 프로그램이 끝날 수 있는 상태를 뜻한다. FSM은 방향 그래프(directed graph, 방향이 있는 간선으로 연결된 노드 집합)의 한 종류이다.

### 6.1 입력 문자열 검증 (Validating an Input String, 6.6.1)
- 입력 스트림을 읽는 프로그램은 오류 검사를 해야 한다. 예를 들어 컴파일러는 FSM으로 소스를 훑어 단어와 기호를 토큰(키워드, 연산자, 식별자)으로 바꾼다.
- 문자열 검증은 문자를 하나씩 읽고, 각 문자가 간선(전이) 하나에 해당한다. FSM은 다음 두 경우 중 하나에 잘못된 입력을 감지한다.
  - 다음 입력 문자가 현재 상태에서 나가는 어떤 전이와도 맞지 않을 때
  - 입력이 끝났는데 현재 상태가 종료 상태가 아닐 때
- 문자열 예: 규칙 두 개. (1) 반드시 'x'로 시작해서 'z'로 끝난다. (2) 가운데에는 'a'~'y' 범위 문자가 0개 이상 온다.
  - A(시작) --'x'--> B, B --'a'..'y'--> B(자기 자신으로), B --'z'--> C(종료 상태).
  - 입력이 끝났을 때 상태가 A나 B이면 오류다. 인식되는 예: `xaabcdefgz`, `xz`, `xyyqqrrstuvz`.

### 6.2 부호 있는 정수 검증 (Validating a Signed Integer, 6.6.2)
- 입력은 선택적인 부호(+ 또는 -) 뒤에 숫자들이 오는 형태이다. 자릿수 제한은 없다.
  - A(시작): 부호 → B, 숫자 → C
  - B: 숫자 → C
  - C(종료 상태): 숫자 → C
- FSM은 어셈블리로 옮기기 쉽다. 각 상태를 레이블로 만들고, 각 레이블에서 다음을 한다.
  - 입력 프로시저를 호출해 다음 문자를 읽는다.
  - 종료 상태라면 Enter 키가 눌렸는지(입력 종료) 확인한다.
  - 그 상태에서 나가는 전이마다 CMP와 조건부 점프를 쓴다. 어느 전이에도 안 맞으면 오류 메시지를 출력하고 종료한다.
- 상태 A의 코드: '+'나 '-'면 StateB로, 숫자면 StateC로 가고, 그 외에는 오류이다. IsDigit는 ZF=1이면 AL이 숫자라는 뜻이다.

```
StateA:
    call Getnext             ; read next char into AL
    cmp  al,'+'              ; leading + sign?
    je   StateB
    cmp  al,'-'              ; leading - sign?
    je   StateB
    call IsDigit             ; ZF = 1 if AL contains a digit
    jz   StateC
    call DisplayErrorMsg     ; invalid input found
    jmp  Quit
```

- 전체 프로그램(Finite.asm):

```
; Finite State Machine                          (Finite.asm)
INCLUDE Irvine32.inc
ENTER_KEY = 13
.data
InvalidInputMsg BYTE "Invalid input",13,10,0
.code
main PROC
    call Clrscr
StateA:
    call Getnext             ; read next char into AL
    cmp  al,'+'              ; leading + sign?
    je   StateB
    cmp  al,'-'              ; leading - sign?
    je   StateB
    call IsDigit             ; ZF = 1 if AL contains a digit
    jz   StateC
    call DisplayErrorMsg     ; invalid input found
    jmp  Quit
StateB:
    call Getnext
    call IsDigit
    jz   StateC
    call DisplayErrorMsg
    jmp  Quit
StateC:
    call Getnext
    call IsDigit
    jz   StateC
    cmp  al,ENTER_KEY        ; Enter key pressed?
    je   Quit                ; yes: quit
    call DisplayErrorMsg     ; no: invalid input found
    jmp  Quit
Quit:
    call Crlf
    exit
main ENDP

Getnext PROC
; Reads a character from standard input. Returns AL = the character
    call ReadChar            ; input from keyboard
    call WriteChar           ; echo on screen
    ret
Getnext ENDP

DisplayErrorMsg PROC
    push edx
    mov  edx,OFFSET InvalidInputMsg
    call WriteString
    pop  edx
    ret
DisplayErrorMsg ENDP
END main
```

- IsDigit 프로시저(링크 라이브러리): 입력은 AL, 반환값은 ZF 설정이다. 숫자 '0'~'9'의 ASCII 코드는 30h~39h로 연속이므로 시작과 끝 범위만 비교하면 된다.

| 문자 | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' |
|---|---|---|---|---|---|---|---|---|---|---|
| ASCII(hex) | 30 | 31 | 32 | 33 | 34 | 35 | 36 | 37 | 38 | 39 |

```
IsDigit PROC
; Receives: AL = character
; Returns: ZF = 1 if AL contains a valid decimal digit; otherwise, ZF = 0.
    cmp  al,'0'
    jb   ID1                 ; ZF = 0 when jump taken
    cmp  al,'9'
    ja   ID1                 ; ZF = 0 when jump taken
    test ax,0                ; set ZF = 1
ID1: ret
IsDigit ENDP
```

- 왜 JB로 점프할 때 ZF가 0인가: CMP는 AL에서 '0'(30h)을 뺀 것처럼 플래그를 바꾼다. AL이 더 작으면 CF=1, ZF=0이 되고, JB는 바로 이 조합(CF=1)에서 점프한다. 마찬가지로 AL이 '9'(39h)보다 크면 CF=0, ZF=0이 되고 이 조합이 JA의 점프 조건이다. 두 점프가 모두 안 일어나면 숫자이므로, ZF를 확실히 1로 만들기 위해 `test ax,0`을 쓴다(0과의 AND는 항상 0). JB/JA가 점프하는 목적지 ID1은 TEST 뒤에 있어서, 점프한 경우에는 ZF가 0인 채로 유지된다.
- 이렇게 점프와 TEST의 플래그 설정을 이용해 불리언 결과를 반환하는 방식은 고성능이 필요한 프로그램에서 쓰는 최적화 기법이다.

## 7. 조건부 제어 흐름 지시어 (Conditional Control Flow Directives, 6.7)
- 32비트 모드에서 MASM은 조건문을 쉽게 쓰게 해 주는 고급 지시어를 제공한다. 단, 64비트 모드에서는 쓸 수 없다. 어셈블러가 코드를 어셈블하기 전에 전처리 단계에서 이 지시어를 인식한다.

| 지시어 | 설명 |
|---|---|
| .IF condition | 조건이 참이면 블록 실행 |
| .ELSEIF condition | 앞 조건이 거짓일 때 이 조건을 검사해서 참이면 실행 |
| .ELSE | .IF 조건이 거짓일 때 실행할 블록 시작 |
| .ENDIF | .IF/.ELSEIF/.ELSE 블록 종료 |
| .WHILE condition | 조건이 참인 동안 .ENDW까지 반복 |
| .ENDW | .WHILE 블록 종료 |
| .REPEAT | 블록을 먼저 한 번 실행 |
| .UNTIL condition | 조건이 참이 될 때까지 .REPEAT 블록 반복 |
| .UNTILCXZ | CX가 0이 될 때까지 .REPEAT 블록 반복 |
| .BREAK | .WHILE/.REPEAT 블록 탈출 |
| .CONTINUE | .WHILE/.REPEAT 블록의 맨 위로 점프 |

### 7.1 IF문 만들기 (Creating IF Statements, 6.7.1)
- `.IF`, `.ELSEIF`, `.ELSE`, `.ENDIF`를 쓰면 어셈블러가 CMP와 조건부 점프를 대신 만들어 준다. 생성된 코드는 리스팅 파일(progname.lst)에서 볼 수 있다. .IF와 .ENDIF는 필수이고 .ELSEIF와 .ELSE는 선택이다.

```
.IF condition1
    statements
[.ELSEIF condition2
    statements ]
[.ELSE
    statements ]
.ENDIF
```

- 조건은 C++/Java와 같은 연산자를 쓰는 불리언 식이고 실행 시간에 평가된다. 예: `eax > 10000h`, `val1 <= 100`, `val2 == eax`, `val3 != ebx`. 복합 조건 예: `(eax > 0) && (eax > 10000h)`, `(val1 <= 100) || (val2 <= 100)`, `(val2 != ebx) && !CARRY?`.

| 연산자 | 설명 |
|---|---|
| expr1 == expr2 | 같으면 참 |
| expr1 != expr2 | 다르면 참 |
| expr1 > expr2 | 크면 참 |
| expr1 >= expr2 | 크거나 같으면 참 |
| expr1 < expr2 | 작으면 참 |
| expr1 <= expr2 | 작거나 같으면 참 |
| !expr | expr이 거짓이면 참 |
| expr1 && expr2 | 논리 AND |
| expr1 \|\| expr2 | 논리 OR |
| expr1 & expr2 | 비트 AND |
| CARRY? | CF가 세트이면 참 |
| OVERFLOW? | OF가 세트이면 참 |
| PARITY? | PF가 세트이면 참 |
| SIGN? | SF가 세트이면 참 |
| ZERO? | ZF가 세트이면 참 |

- 이 지시어를 쓰기 전에 순수 어셈블리 조건 분기를 먼저 확실히 이해해야 한다. 어셈블한 뒤에는 리스팅 파일을 열어 어셈블러가 의도한 코드를 만들었는지 확인한다.
- 생성 코드 예: val1은 부호 없는 DWORD 5. 어셈블러가 조건을 뒤집은 JBE로 건너뛰는 코드를 만든다. `@C0001` 같은 레이블은 어셈블러가 만들며, 한 프로시저 안에서 유일하다.

```
mov eax,6
.IF eax > val1
    mov result,1
.ENDIF

; 어셈블러가 생성한 코드
    mov eax,6
    cmp eax,val1
    jbe @C0001               ; 부호 없는 비교용 점프
    mov result,1
@C0001:
```

### 7.2 부호 있는/없는 비교 (Signed and Unsigned Comparisons, 6.7.2)
- .IF로 값을 비교할 때, 어셈블러는 피연산자의 선언 타입에 따라 부호 없는 점프 또는 부호 있는 점프를 고른다.
- 부호 없는 변수(DWORD)와 비교하면 JBE(부호 없는 점프)가 생성된다.
- 부호 있는 변수(SDWORD)와 비교하면 JLE(부호 있는 점프)가 생성된다.

```
.data
val2 SDWORD -1
.code
    mov eax,6
    .IF eax > val2
        mov result,1
    .ENDIF

; 생성 코드
    mov eax,6
    cmp eax,val2
    jle @C0001               ; 부호 있는 비교용 점프
    mov result,1
@C0001:
```

- 두 레지스터를 비교하면 어셈블러가 부호 여부를 알 수 없어서 부호 없는 비교(JBE)로 기본 처리한다. 레지스터끼리 비교할 때 부호 있는 값을 쓰려면 주의해야 한다.

```
mov eax,6
mov ebx,val2
.IF eax > ebx
    mov result,1
.ENDIF
; 생성: cmp eax,ebx / jbe @C0001 (부호 없는 비교)
```

### 7.3 복합식 (Compound Expressions, 6.7.3)
- 논리 OR은 `||`, 논리 AND는 `&&`이다.

```
.IF expression1 || expression2
    statements
.ENDIF
```

- SetCursorPosition 예제(SetCur.asm): DH(Y좌표, 0~24)와 DL(X좌표, 0~79)의 범위를 검사하고, 벗어나면 오류 메시지를 출력한다. 범위 밖 조건을 `||`로 묶는다.

```
SetCursorPosition PROC
; Sets the cursor position.
; Receives: DL = X-coordinate, DH = Y-coordinate.
.data
BadXCoordMsg BYTE "X-Coordinate out of range!",0Dh,0Ah,0
BadYCoordMsg BYTE "Y-Coordinate out of range!",0Dh,0Ah,0
.code
    .IF (dl < 0) || (dl > 79)
        mov  edx,OFFSET BadXCoordMsg
        call WriteString
        jmp  quit
    .ENDIF
    .IF (dh < 0) || (dh > 24)
        mov  edx,OFFSET BadYCoordMsg
        call WriteString
        jmp  quit
    .ENDIF
    call Gotoxy
quit:
    ret
SetCursorPosition ENDP
```

- MASM이 생성하는 코드는 첫 번째 .IF에서 `cmp dl,000h / jb @C0002 / cmp dl,04Fh / jbe @C0001` 형태이다. 즉 첫 식이 참이면 바로 오류 처리(@C0002)로 가고, 아니면 둘째 식을 검사해서 범위 안이면(JBE) 건너뛴다.
- 대학 수강신청 예제(Regist.asm): 평점(0~400 스케일)과 신청 학점으로 등록 가능 여부를 정한다. .IF/.ELSEIF로 다중 분기를 만든다. 규칙: 평점 > 350이면 무조건 가능, 평점 > 250이고 학점 <= 16이면 가능, 학점 <= 12이면 가능.

```
.data
TRUE  = 1
FALSE = 0
gradeAverage WORD 275          ; test value
credits      WORD 12           ; test value
OkToRegister BYTE ?
.code
    mov OkToRegister,FALSE
    .IF gradeAverage > 350
        mov OkToRegister,TRUE
    .ELSEIF (gradeAverage > 250) && (credits <= 16)
        mov OkToRegister,TRUE
    .ELSEIF (credits <= 12)
        mov OkToRegister,TRUE
    .ENDIF
```

- 어셈블러가 만든 코드(디버거의 Disassembly 창 또는 리스팅 파일에서 확인, 리스팅에 넣으려면 /Sg 옵션). TRUE/FALSE 같은 상수는 32비트 크기라서, BYTE 변수에 대입할 때 어셈블러가 `byte ptr`를 붙인다.

```
    mov  byte ptr OkToRegister,FALSE
    cmp  word ptr gradeAverage,350
    jbe  @C0006
    mov  byte ptr OkToRegister,TRUE
    jmp  @C0008
@C0006:
    cmp  word ptr gradeAverage,250
    jbe  @C0009
    cmp  word ptr credits,16
    ja   @C0009
    mov  byte ptr OkToRegister,TRUE
    jmp  @C0008
@C0009:
    cmp  word ptr credits,12
    ja   @C0008
    mov  byte ptr OkToRegister,TRUE
@C0008:
```

### 7.4 .REPEAT와 .WHILE로 루프 만들기 (Creating Loops with .REPEAT and .WHILE, 6.7.4)
- 직접 CMP와 점프로 루프를 쓰는 대신 쓸 수 있고, 위 표의 조건식을 그대로 쓸 수 있다.
- `.REPEAT ... .UNTIL condition`은 본문을 먼저 실행하고 나서 조건을 검사한다(do-while). `.WHILE condition ... .ENDW`는 실행 전에 조건을 먼저 검사한다.

```
; 1부터 10 출력 (.WHILE)
mov eax,0
.WHILE eax < 10
    inc eax
    call WriteDec
    call Crlf
.ENDW

; 1부터 10 출력 (.REPEAT)
mov eax,0
.REPEAT
    inc eax
    call WriteDec
    call Crlf
.UNTIL eax == 10
```

- 루프 안의 IF 예: 5.3절의 구조를 지시어로 구현한다. op1, op2, op3는 변수이므로 한 명령에 메모리 피연산자가 두 개가 되지 않도록 레지스터로 옮겨서 쓴다.

```
while( op1 < op2 )
{
    op1++;
    if( op1 == op3 )
        X = 2;
    else
        X = 3;
}

.data
X   DWORD 0
op1 DWORD 2                  ; test data
op2 DWORD 4                  ; test data
op3 DWORD 5                  ; test data
.code
    mov eax,op1
    mov ebx,op2
    mov ecx,op3
    .WHILE eax < ebx
        inc eax
        .IF eax == ecx
            mov X,2
        .ELSE
            mov X,3
        .ENDIF
    .ENDW
```

## 8. 챕터 요약 (Chapter Summary, 6.8)
- AND, OR, XOR, NOT, TEST는 비트 단위로 동작하는 비트 연산 명령어이다. AND는 두 비트가 모두 1일 때 1, OR는 하나라도 1이면 1, XOR는 두 비트가 다를 때만 1이다. TEST는 결과를 저장하지 않고 플래그만 바꾸는 AND이고, NOT은 모든 비트를 반전한다.
- CMP는 목적지에서 소스를 뺀 것처럼 플래그를 바꾸고 피연산자는 그대로 둔다. 보통 뒤에 조건부 점프가 붙는다.
- 조건부 점프는 네 종류이다: 특정 플래그 값(JC, JZ, JO), 동등 여부(JE, JNE, JECXZ, JRCXZ), 부호 없는 비교(JA, JB, JAE), 부호 있는 비교(JL, JG).
- 32비트 모드에서 LOOPZ(LOOPE)는 ZF가 세트이고 ECX > 0일 때, LOOPNZ(LOOPNE)는 ZF가 클리어이고 ECX > 0일 때 반복한다. 64비트 모드에서는 RCX를 쓴다.
- 암호화는 데이터를 부호화하는 과정이고 복호화는 되돌리는 과정이다. XOR로 간단한 암호화와 복호화를 할 수 있다.
- 순서도는 프로그램 논리를 시각화하는 데 효과적이다. 도형마다 레이블을 붙이고 같은 레이블을 소스에 쓰면 어셈블리를 쉽게 짤 수 있다.
- FSM은 부호 있는 정수 같은 문자열을 검증하는 데 효과적인 도구이다. 각 상태를 레이블로 표현하면 어셈블리 구현이 쉽다.
- .IF, .ELSE, .ELSEIF, .ENDIF는 실행 시간 식을 평가해서 어셈블리 코딩을 크게 단순화하고, 특히 복잡한 복합 불리언 식에 유용하다. .WHILE과 .REPEAT로 조건 반복문도 만들 수 있다.
