# 4장. Data Transfers, Addressing, and Arithmetic (어셈블리 프로그래밍)

## 1. 데이터 전송 명령어 (Data Transfer Instructions, 4.1)

### 1.1 소개 (Introduction, 4.1.1)
- Java, C++ 컴파일러는 타입 검사를 엄격하게 해서 변수와 데이터가 안 맞으면 오류를 낸다. 반면 어셈블러는 CPU 명령어가 처리할 수 있는 일이면 거의 다 허용한다.
- 그래서 어셈블리에서는 데이터가 어디에 어떤 크기로 저장되는지, 프로세서의 제약이 무엇인지 프로그래머가 직접 신경 써야 한다.
- x86은 복합 명령어 집합(complex instruction set)이라 같은 일을 하는 방법이 많다. 이 장의 기본 도구들을 잘 익혀야 뒤 장이 쉬워진다.

### 1.2 피연산자 유형 (Operand Types, 4.1.2)
- 명령어 형식은 `[label:] mnemonic [operands] [; comment]`이고, 피연산자는 0~3개를 가질 수 있다.
  - `mnemonic`
  - `mnemonic [destination]`
  - `mnemonic [destination],[source]`
  - `mnemonic [destination],[source-1],[source-2]`
- 피연산자 종류는 세 가지다.
  - 즉시값(Immediate): 숫자 리터럴 표현식
  - 레지스터(Register): CPU의 이름 있는 레지스터
  - 메모리(Memory): 메모리 위치를 참조
- 교재가 쓰는 피연산자 표기법(32비트 모드)은 다음과 같다.

| 표기 | 의미 |
|---|---|
| reg8 | 8비트 범용 레지스터: AH, AL, BH, BL, CH, CL, DH, DL |
| reg16 | 16비트 범용 레지스터: AX, BX, CX, DX, SI, DI, SP, BP |
| reg32 | 32비트 범용 레지스터: EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP |
| reg | 임의의 범용 레지스터 |
| sreg | 16비트 세그먼트 레지스터: CS, DS, SS, ES, FS, GS |
| imm | 8, 16, 32비트 즉시값 |
| imm8 / imm16 / imm32 | 각각 8 / 16 / 32비트 즉시값 |
| reg/mem8, reg/mem16, reg/mem32 | 해당 크기의 레지스터 또는 메모리 |
| mem | 8, 16, 32비트 메모리 피연산자 |

### 1.3 직접 메모리 피연산자 (Direct Memory Operands, 4.1.3)
- 변수 이름은 데이터 세그먼트 안의 오프셋(주소)을 가리키는 이름이다. 예를 들어 `var1 BYTE 10h`에서 var1이 오프셋 10400h에 있다면, `mov al,var1`은 그 주소의 값을 AL로 읽어온다.
- 이 명령은 `A0 00010400`으로 어셈블된다. 첫 바이트 A0는 연산 코드(opcode)이고, 나머지는 var1의 32비트 주소다.
- `mov al,[var1]`처럼 대괄호를 쓰면 "주소를 따라가서 값을 읽는다"는 의미가 분명해진다. MASM은 둘 다 허용하지만, 교재는 산술식이 들어갈 때만 대괄호를 쓴다(예: `mov al,[var1 + 5]`, 직접 오프셋 피연산자).

### 1.4 MOV 명령어 (MOV Instruction, 4.1.4)
- MOV는 source의 값을 destination으로 복사한다. 형식은 `MOV destination,source`이고 C++의 `dest = source;`와 같은 오른쪽에서 왼쪽 방향이다. destination만 바뀌고 source는 그대로다.
- MOV 규칙은 세 가지다.
  - 두 피연산자의 크기가 같아야 한다.
  - 두 피연산자가 모두 메모리일 수 없다.
  - IP, EIP, RIP는 destination이 될 수 없다.
- 허용되는 형식은 `MOV reg,reg`, `MOV mem,reg`, `MOV reg,mem`, `MOV mem,imm`, `MOV reg,imm`이다.
- 메모리에서 메모리로 옮기려면 레지스터를 거쳐야 한다.

```
.data
var1 WORD ?
var2 WORD ?
.code
mov ax,var1
mov var2,ax
```

- 상수를 옮길 때는 그 상수가 필요로 하는 최소 바이트 수도 고려해야 한다.
- 겹치는 값(Overlapping Values): 같은 32비트 레지스터를 크기가 다른 데이터로 갱신하면 하위 부분이 덮어써진다. AX에 쓰면 AL이 덮어써지고, EAX에 쓰면 AX가 덮어써진다.

```
.data
oneByte BYTE 78h
oneWord WORD 1234h
oneDword DWORD 12345678h
.code
mov eax,0              ; EAX = 00000000h
mov al,oneByte         ; EAX = 00000078h
mov ax,oneWord         ; EAX = 00001234h
mov eax,oneDword       ; EAX = 12345678h
mov ax,0               ; EAX = 12340000h
```

### 1.5 정수의 제로/부호 확장 (Zero/Sign Extension of Integers, 4.1.5)
- MOV로는 작은 피연산자를 큰 피연산자로 직접 복사할 수 없다. 부호 없는 16비트 count를 ECX로 옮기려면 ECX를 0으로 만든 뒤 CX에 넣으면 된다.

```
.data
count WORD 1
.code
mov ecx,0
mov cx,count
```

- 하지만 부호 있는 값에는 이 방법이 틀린다. -16(FFF0h)을 같은 방식으로 옮기면 ECX가 0000FFF0h(+65,520)가 되어 값이 달라진다.

```
.data
signedVal SWORD -16          ; FFF0h (-16)
.code
mov ecx,0
mov cx,signedVal             ; ECX = 0000FFF0h (+65,520)
```

- 반대로 ECX를 먼저 FFFFFFFFh로 채우고 CX에 복사하면 FFFFFFF0h(-16)로 올바르게 된다. 원본의 최상위 비트(1)로 위쪽 비트를 채운 것이며, 이것이 부호 확장(sign extension)이다.

```
mov ecx,0FFFFFFFFh
mov cx,signedVal             ; ECX = FFFFFFF0h (-16)
```

- 원본의 최상위 비트가 항상 1이라는 보장이 없으므로, Intel은 두 가지 명령어를 제공한다: MOVZX, MOVSX.

#### MOVZX (Move with Zero-Extend)
- 원본을 목적지로 복사하고 위쪽 비트를 0으로 채워 16 또는 32비트로 확장한다. 부호 없는 정수에만 쓴다.
- 형식은 세 가지다: `MOVZX reg32,reg/mem8`, `MOVZX reg32,reg/mem16`, `MOVZX reg16,reg/mem8`. 첫 번째 피연산자가 목적지(레지스터)이고, 원본은 상수가 될 수 없다.
- 이진수 예: `byteVal BYTE 10001111b`를 `movzx ax,byteVal`하면 AX = 0000000010001111b가 된다. 아래 8비트는 그대로 복사되고 위 8비트는 0으로 채워진다.
- 레지스터 예:

```
mov bx,0A69Bh
movzx eax,bx        ; EAX = 0000A69Bh
movzx edx,bl        ; EDX = 0000009Bh
movzx cx,bl         ; CX = 009Bh
```

- 메모리 원본도 결과가 같다.

```
.data
byte1 BYTE 9Bh
word1 WORD 0A69Bh
.code
movzx eax,word1     ; EAX = 0000A69Bh
movzx edx,byte1     ; EDX = 0000009Bh
movzx cx,byte1      ; CX = 009Bh
```

#### MOVSX (Move with Sign-Extend)
- 원본의 최상위 비트를 위쪽 확장 비트에 전부 복제해서 채운다. 부호 있는 정수에만 쓰며, 형식은 MOVZX와 같다(`reg32,reg/mem8`, `reg32,reg/mem16`, `reg16,reg/mem8`).
- 예: `byteVal BYTE 10001111b`를 `movsx ax,byteVal`하면 AX = 1111111110001111b가 된다.
- 16진 상수의 최상위 비트는 가장 높은 16진 자릿수가 7보다 크면 1이다. 0A69Bh에서 맨 앞 0은 식별자 이름과 혼동되지 않게 붙이는 표기일 뿐이고, 실제 최상위 숫자 A는 최상위 비트가 1임을 알려준다.

```
mov bx,0A69Bh
movsx eax,bx        ; EAX = FFFFA69Bh
movsx edx,bl        ; EDX = FFFFFF9Bh
movsx cx,bl         ; CX = FF9Bh
```

### 1.6 LAHF와 SAHF 명령어 (LAHF and SAHF Instructions, 4.1.6)
- LAHF(Load status flags into AH)는 EFLAGS 하위 바이트를 AH로 복사한다. 복사되는 플래그는 Sign, Zero, Auxiliary Carry, Parity, Carry다. 플래그를 변수에 잠시 저장해 둘 때 쓴다.
- SAHF(Store AH into status flags)는 반대로 AH를 EFLAGS(또는 RFLAGS) 하위 바이트로 복사해서 이전에 저장한 플래그를 복원한다.

```
.data
saveflags BYTE ?
.code
lahf                     ; load flags into AH
mov saveflags,ah         ; save them in a variable

mov ah,saveflags         ; load saved flags into AH
sahf                     ; copy into Flags register
```

### 1.7 XCHG 명령어 (XCHG Instruction, 4.1.7)
- XCHG는 두 피연산자의 내용을 서로 바꾼다. 형식은 `XCHG reg,reg`, `XCHG reg,mem`, `XCHG mem,reg` 세 가지다.
- 규칙은 MOV와 같지만 즉시값 피연산자는 쓸 수 없다. 배열 정렬에서 두 원소를 맞바꿀 때 편리하다.

```
xchg ax,bx        ; exchange 16-bit regs
xchg ah,al        ; exchange 8-bit regs
xchg var1,bx      ; exchange 16-bit mem op with BX
xchg eax,ebx      ; exchange 32-bit regs
```

- 메모리 두 개를 맞바꾸려면 레지스터를 임시 저장소로 쓰고 MOV와 XCHG를 섞는다.

```
mov  ax,val1
xchg ax,val2
mov  val1,ax
```

### 1.8 직접 오프셋 피연산자 (Direct-Offset Operands, 4.1.8)
- 변수 이름에 상수(변위)를 더하면 레이블이 없는 메모리 위치에도 접근할 수 있다. 이렇게 이름에 상수를 더해 만든 주소를 유효 주소(effective address)라고 한다.

```
arrayB BYTE 10h,20h,30h,40h,50h
mov al,arrayB          ; AL = 10h
mov al,[arrayB+1]      ; AL = 20h
mov al,[arrayB+2]      ; AL = 30h
```

- 대괄호는 필수가 아니지만, 유효 주소를 역참조한다는 의미가 분명해지므로 쓰기를 권장한다.
- MASM은 범위 검사를 하지 않는다. 배열이 5바이트인데 `mov al,[arrayB+20]`을 쓰면 배열 밖 값을 읽는 논리 버그가 생긴다.
- 워드 배열은 원소 간격이 2바이트, 더블워드 배열은 4바이트다.

```
.data
arrayW WORD 100h,200h,300h
arrayD DWORD 10000h,20000h
.code
mov ax,arrayW             ; AX = 100h
mov ax,[arrayW+2]         ; AX = 200h
mov eax,arrayD            ; EAX = 10000h
mov eax,[arrayD+4]        ; EAX = 20000h
```

- 슬라이드에는 `mov eax,[arrayD+TYPE arrayD]`처럼 TYPE을 써서 원소 크기를 직접 적지 않는 방식도 나온다. 결과는 20000h로 같다.

### 1.9 예제 프로그램 (Example Program - Moves, 4.1.9)
- MOV, XCHG, MOVZX, MOVSX와 직접 오프셋 피연산자를 한 프로그램에 모은 예제다. 화면 출력은 없으므로 디버거로 실행하며 레지스터를 확인한다.

```
; Data Transfer Examples                        (Moves.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD
.data
val1 WORD 1000h
val2 WORD 2000h
arrayB BYTE 10h,20h,30h,40h,50h
arrayW WORD 100h,200h,300h
arrayD DWORD 10000h,20000h
.code
main PROC
; Demonstrating MOVZX instruction:
      mov   bx,0A69Bh
      movzx eax,bx                  ; EAX = 0000A69Bh
      movzx edx,bl                  ; EDX = 0000009Bh
      movzx cx,bl                   ; CX = 009Bh
; Demonstrating MOVSX instruction:
      mov   bx,0A69Bh
      movsx eax,bx                  ; EAX = FFFFA69Bh
      movsx edx,bl                  ; EDX = FFFFFF9Bh
      mov   bl,7Bh
      movsx cx,bl                   ; CX = 007Bh
; Memory-to-memory exchange:
      mov   ax,val1                 ; AX = 1000h
      xchg  ax,val2                 ; AX = 2000h, val2 = 1000h
      mov   val1,ax                 ; val1 = 2000h
; Direct-Offset Addressing (byte array):
      mov   al,arrayB               ; AL = 10h
      mov   al,[arrayB+1]           ; AL = 20h
      mov   al,[arrayB+2]           ; AL = 30h
; Direct-Offset Addressing (word array):
      mov   ax,arrayW               ; AX = 100h
      mov   ax,[arrayW+2]           ; AX = 200h
; Direct-Offset Addressing (doubleword array):
      mov   eax,arrayD              ; EAX = 10000h
      mov   eax,[arrayD+4]          ; EAX = 20000h
      INVOKE ExitProcess,0
main ENDP
END main
```

- 디버깅 중 CPU 플래그를 보려면 Registers 창에서 우클릭 후 Flags를 선택한다. 명령어가 플래그를 바꾸면 빨간색으로 표시되므로, 한 줄씩 실행하면서 명령어가 플래그에 주는 영향을 배울 수 있다.

| 플래그 | Overflow | Direction | Interrupt | Sign | Zero | Carry | Parity | Aux Carry |
|---|---|---|---|---|---|---|---|---|
| 기호 | OV | UP | EI | PL | ZR | CY | PE | AC |

## 2. 덧셈과 뺄셈 (Addition and Subtraction, 4.2)

### 2.1 INC와 DEC 명령어 (INC and DEC Instructions, 4.2.1)
- INC는 레지스터나 메모리 피연산자에 1을 더하고, DEC는 1을 뺀다. 형식은 `INC reg/mem`, `DEC reg/mem`이다.
- Overflow, Sign, Zero, Auxiliary Carry, Parity 플래그는 결과값에 따라 바뀌지만, Carry 플래그는 바뀌지 않는다.

```
.data
myWord WORD 1000h
.code
inc myWord          ; myWord = 1001h
mov bx,myWord
dec bx              ; BX = 1000h
```

### 2.2 ADD 명령어 (ADD Instruction, 4.2.2)
- `ADD dest,source`는 같은 크기의 source를 dest에 더해서 합을 dest에 저장한다. source는 변하지 않고, 쓸 수 있는 피연산자 조합은 MOV와 같다.
- Carry, Zero, Sign, Overflow, Auxiliary Carry, Parity 플래그가 모두 결과에 따라 바뀐다.

```
.data
var1 DWORD 10000h
var2 DWORD 20000h
.code
mov eax,var1        ; EAX = 10000h
add eax,var2        ; EAX = 30000h
```

### 2.3 SUB 명령어 (SUB Instruction, 4.2.3)
- `SUB dest,source`는 dest에서 source를 뺀 결과를 dest에 저장한다. 피연산자 조합과 영향받는 플래그는 ADD와 같다.

```
.data
var1 DWORD 30000h
var2 DWORD 10000h
.code
mov eax,var1        ; EAX = 30000h
sub eax,var2        ; EAX = 20000h
```

### 2.4 NEG 명령어 (NEG Instruction, 4.2.4)
- NEG는 피연산자를 2의 보수로 바꿔서 부호를 반대로 만든다. 2의 보수는 모든 비트를 뒤집고 1을 더한 값이다. 형식은 `NEG reg`, `NEG mem`이다.
- 영향받는 플래그는 ADD, SUB와 같다.

### 2.5 산술식 구현 (Implementing Arithmetic Expressions, 4.2.5)
- ADD, SUB, NEG로 덧셈, 뺄셈, 부호 반전이 들어간 식을 어셈블리로 옮길 수 있다. C++ 컴파일러가 하는 일을 직접 흉내 내는 셈이다. 식을 옮길 때는 항을 하나씩 따로 계산한 뒤 마지막에 합친다.
- 예제 식은 `Rval = -Xval + (Yval - Zval);`이고 변수는 아래와 같다.

```
Rval SDWORD ?
Xval SDWORD 26
Yval SDWORD 30
Zval SDWORD 40
```

```
; first term: -Xval
mov eax,Xval
neg eax                 ; EAX = -26

; second term: (Yval - Zval)
mov ebx,Yval
sub ebx,Zval            ; EBX = -10

; add the terms and store:
add eax,ebx
mov Rval,eax            ; -36
```

### 2.6 덧셈과 뺄셈이 바꾸는 플래그 (Flags Affected by Addition and Subtraction, 4.2.6)
- 산술 연산 후 결과가 음수인지, 0인지, 목적지에 담기엔 너무 큰지를 CPU 상태 플래그로 알 수 있다. 이 플래그들은 조건 분기 명령어를 실행하는 기준이 되기도 한다.

| 플래그 | 의미 |
|---|---|
| Carry (CF) | 부호 없는 정수 오버플로. 결과가 목적지 크기를 넘으면 1 |
| Overflow (OF) | 부호 있는 정수 오버플로. 결과가 목적지의 부호 있는 범위를 벗어나면 1 |
| Zero (ZF) | 연산 결과가 0이면 1 |
| Sign (SF) | 결과가 음수(목적지의 최상위 비트가 1)이면 1 |
| Parity (PF) | 목적지의 최하위 바이트에 1인 비트가 짝수 개이면 1 |
| Auxiliary Carry (AC) | 최하위 바이트의 비트 3에서 올림 또는 빌림이 생기면 1 |

#### 부호 없는 연산: Zero, Carry, Auxiliary Carry
- Zero 플래그: 결과가 0이면 설정된다.

```
mov ecx,1
sub ecx,1              ; ECX = 0, ZF = 1
mov eax,0FFFFFFFFh
inc eax                ; EAX = 0, ZF = 1
inc eax                ; EAX = 1, ZF = 0
dec eax                ; EAX = 0, ZF = 1
```

- 덧셈과 Carry: 부호 없는 덧셈에서 CF는 목적지 최상위 비트 밖으로 나간 올림 값의 복사본이다. 즉 합이 목적지 크기를 넘으면 CF = 1이다.

```
mov al,0FFh
add al,1               ; AL = 00, CF = 1

mov ax,00FFh
add ax,1               ; AX = 0100h, CF = 0 (16비트에는 들어감)

mov ax,0FFFFh
add ax,1               ; AX = 0000, CF = 1
```

- 뺄셈과 Carry: 작은 부호 없는 수에서 큰 수를 빼면 CF = 1이 된다.

```
mov al,1
sub al,2               ; AL = FFh, CF = 1
```

- INC, DEC는 Carry에 영향을 주지 않는다. 0이 아닌 값에 NEG를 쓰면 항상 Carry가 설정된다.
- Auxiliary Carry: 비트 3에서 올림이나 빌림이 나오면 설정된다. 주로 BCD(이진화 십진수) 연산에 쓰인다. 0Fh에 1을 더하면 10h가 되어 비트 4로 올림이 생긴다.

```
mov al,0Fh
add al,1               ; AC = 1
```

- Parity: 결과 최하위 바이트에 1이 짝수 개이면 PF = 1이다.

```
mov al,10001100b
add al,00000010b       ; AL = 10001110, PF = 1 (1이 4개)
sub al,10000000b       ; AL = 00001110, PF = 0 (1이 3개)
```

#### 부호 있는 연산: Sign, Overflow
- Sign 플래그: 결과가 음수이면 설정된다. 기계적으로는 목적지 최상위 비트의 복사본이다.

```
mov eax,4
sub eax,5              ; EAX = -1, SF = 1

mov bl,1
sub bl,2               ; BL = FFh (-1), SF = 1
```

- Overflow 플래그: 부호 있는 연산 결과가 목적지에 담을 수 있는 범위를 벗어나면(오버플로 또는 언더플로) 설정된다. 바이트의 최댓값은 +127, 최솟값은 -128이다.

```
mov al,+127
add al,1               ; OF = 1

mov al,-128
sub al,1               ; OF = 1
```

- 덧셈 판별법: 아래 두 경우에만 부호 있는 오버플로가 생긴다. 두 피연산자의 부호가 다르면 오버플로는 절대 없다.
  - 양수 + 양수 = 음수
  - 음수 + 음수 = 양수
- 하드웨어 판별 방식: 최상위 비트 밖으로 나가는 올림(carry out)과 최상위 비트로 들어오는 올림(carry in)을 XOR한 값이 OF에 들어간다. 10000000과 11111110을 더하면 CF = 1이고 bit7로 들어오는 올림은 0이므로 1 XOR 0 = 1, 즉 OF = 1이다.
- NEG 오버플로: 목적지에 올바르게 저장할 수 없을 때 OF가 설정된다. -128을 negate하면 +128이 되는데 바이트에 안 들어가므로 AL이 그대로 10000000b로 남고 OF = 1이다. +127은 정상이라 OF = 0이다.

```
mov al,-128            ; AL = 10000000b
neg al                 ; AL = 10000000b, OF = 1

mov al,+127            ; AL = 01111111b
neg al                 ; AL = 10000001b, OF = 0
```

- CPU는 연산이 부호 있는지 없는지 모른다. 항상 같은 규칙으로 모든 플래그를 계산하고, 어떤 플래그를 해석할지는 프로그래머가 연산 종류를 보고 정한다.

### 2.7 예제 프로그램 (Example Program - AddSubTest, 4.2.7)
- ADD, SUB, INC, DEC, NEG로 여러 산술식을 만들고 플래그가 바뀌는 모습을 보여 주는 프로그램이다.

```
; Addition and Subtraction            (AddSubTest.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
.data
Rval   SDWORD ?
Xval   SDWORD 26
Yval   SDWORD 30
Zval   SDWORD 40
.code
main PROC
    ; INC and DEC
    mov   ax,1000h
    inc   ax                  ; 1001h
    dec   ax                  ; 1000h

    ; Expression: Rval = -Xval + (Yval - Zval)
    mov   eax,Xval
    neg   eax                 ; -26
    mov   ebx,Yval
    sub   ebx,Zval            ; -10
    add   eax,ebx
    mov   Rval,eax            ; -36

    ; Zero flag example:
    mov   cx,1
    sub   cx,1                ; ZF = 1
    mov   ax,0FFFFh
    inc   ax                  ; ZF = 1

    ; Sign flag example:
    mov   cx,0
    sub   cx,1                ; SF = 1
    mov   ax,7FFFh
    add   ax,2                ; SF = 1

    ; Carry flag example:
    mov   al,0FFh
    add   al,1                ; CF = 1, AL = 00

    ; Overflow flag example:
    mov   al,+127
    add   al,1                ; OF = 1
    mov   al,-128
    sub   al,1                ; OF = 1
    INVOKE ExitProcess,0
main ENDP
END main
```

## 3. 데이터 관련 연산자와 지시어 (Data-Related Operators and Directives, 4.3)

- 연산자와 지시어는 실행되는 명령어가 아니라 어셈블러가 해석하는 것이다. 데이터의 주소와 크기 정보를 얻는 데 쓴다.
  - OFFSET: 세그먼트 시작부터 변수까지의 거리를 돌려준다.
  - PTR: 피연산자의 기본 크기를 덮어쓴다.
  - TYPE: 피연산자 하나(또는 배열 원소 하나)의 바이트 크기를 돌려준다.
  - LENGTHOF: 배열의 원소 개수를 센다.
  - SIZEOF: 배열 초기값이 차지하는 바이트 수를 돌려준다.
  - LABEL 지시어: 저장 공간을 만들지 않고 같은 위치에 다른 크기 속성의 이름을 붙인다.

### 3.1 OFFSET 연산자 (OFFSET Operator, 4.3.1)
- 데이터 레이블의 오프셋, 즉 데이터 세그먼트 시작에서 그 레이블까지의 바이트 거리를 돌려준다.
- 변수를 순서대로 선언했을 때 bVal이 00404000h에 있다면 각 변수의 오프셋은 이렇다.

```
.data
bVal  BYTE ?
wVal  WORD ?
dVal  DWORD ?
dVal2 DWORD ?

mov esi,OFFSET bVal      ; ESI = 00404000h
mov esi,OFFSET wVal      ; ESI = 00404001h
mov esi,OFFSET dVal      ; ESI = 00404003h
mov esi,OFFSET dVal2     ; ESI = 00404007h
```

- 직접 오프셋 피연산자에도 쓸 수 있다. 아래는 myArray의 오프셋에 4를 더해 ESI에 넣는 예로, ESI가 세 번째 정수를 가리키게 된다.

```
.data
myArray WORD 1,2,3,4,5
.code
mov esi,OFFSET myArray + 4
```

- 더블워드 변수를 다른 변수의 오프셋으로 초기화하면 포인터가 된다. 아래에서 pArray는 bigArray의 시작을 가리킨다.

```
.data
bigArray DWORD 500 DUP(?)
pArray   DWORD bigArray
.code
mov esi,pArray            ; ESI가 배열 시작을 가리킴
```

### 3.2 ALIGN 지시어 (ALIGN Directive, 4.3.2)
- 변수를 바이트, 워드, 더블워드, 패러그래프 경계에 맞춘다. 형식은 `ALIGN bound`이고 bound는 1, 2, 4, 8, 16 중 하나다.
  - 1: 1바이트 경계(기본값)
  - 2: 다음 변수를 짝수 주소에 배치
  - 4: 다음 주소가 4의 배수
  - 16: 다음 주소가 16의 배수(패러그래프 경계)
- 경계를 맞추기 위해 어셈블러가 변수 앞에 빈 바이트를 끼워 넣을 수 있다. 정렬하는 이유는 CPU가 짝수 주소의 데이터를 홀수 주소보다 빠르게 처리하기 때문이다.

```
bVal  BYTE ?             ; 00404000h
ALIGN 2
wVal  WORD ?             ; 00404002h
bVal2 BYTE ?             ; 00404004h
ALIGN 4
dVal  DWORD ?            ; 00404008h
dVal2 DWORD ?            ; 0040400Ch
```

- ALIGN 4가 없었다면 dVal은 00404005h에 놓였을 것인데, 지시어 때문에 00404008h로 밀렸다.

### 3.3 PTR 연산자 (PTR Operator, 4.3.3)
- 선언된 크기와 다른 크기로 피연산자에 접근해야 할 때 크기를 덮어쓴다. 예를 들어 더블워드 변수의 하위 16비트만 AX로 옮기려 할 때 크기가 맞지 않아 오류가 난다.

```
.data
myDouble DWORD 12345678h
.code
mov ax,myDouble                 ; error
mov ax,WORD PTR myDouble        ; AX = 5678h
```

- 1234h가 아니라 5678h가 들어가는 이유는 x86이 리틀 엔디안이기 때문이다. 낮은 바이트가 변수의 시작 주소에 저장된다. myDouble의 메모리 배치는 다음과 같다.

| 오프셋 | 바이트 | 워드 | 더블워드 |
|---|---|---|---|
| myDouble+0 | 78h | 5678h | 12345678h |
| myDouble+1 | 56h | | |
| myDouble+2 | 34h | 1234h | |
| myDouble+3 | 12h | | |

- 변수를 어떻게 정의했든 위 세 가지 방식으로 접근할 수 있다.

```
mov ax,WORD PTR [myDouble+2]    ; AX = 1234h
mov bl,BYTE PTR myDouble        ; BL = 78h
```

- PTR은 BYTE, SBYTE, WORD, SWORD, DWORD, SDWORD, FWORD, QWORD, TBYTE 같은 표준 데이터 타입과 함께 써야 한다.
- 작은 값 두 개를 큰 목적지로 옮기는 데도 쓴다. 첫 워드는 EAX 하위 절반으로, 둘째 워드는 상위 절반으로 들어간다.

```
.data
wordList WORD 5678h,1234h
.code
mov eax,DWORD PTR wordList      ; EAX = 12345678h
```

### 3.4 TYPE 연산자 (TYPE Operator, 4.3.4)
- 변수의 원소 하나의 크기를 바이트로 돌려준다. BYTE는 1, WORD는 2, DWORD는 4, QWORD는 8이다.

| 표현식 | 값 |
|---|---|
| TYPE var1 (BYTE) | 1 |
| TYPE var2 (WORD) | 2 |
| TYPE var3 (DWORD) | 4 |
| TYPE var4 (QWORD) | 8 |

### 3.5 LENGTHOF 연산자 (LENGTHOF Operator, 4.3.5)
- 배열의 원소 개수를 센다. 레이블과 같은 줄에 나온 초기값만 대상으로 한다.

```
.data
byte1    BYTE 10,20,30
array1   WORD 30 DUP(?),0,0
array2   WORD 5 DUP(3 DUP(?))
array3   DWORD 1,2,3,4
digitStr BYTE "12345678",0
```

| 표현식 | 값 |
|---|---|
| LENGTHOF byte1 | 3 |
| LENGTHOF array1 | 30 + 2 = 32 |
| LENGTHOF array2 | 5 * 3 = 15 (중첩 DUP는 곱) |
| LENGTHOF array3 | 4 |
| LENGTHOF digitStr | 9 (문자 8개 + 널) |

- 배열 정의가 여러 줄에 걸치면 첫 줄만 배열로 본다. 아래는 LENGTHOF myArray = 5다.

```
myArray BYTE 10,20,30,40,50
        BYTE 60,70,80,90,100
```

- 첫 줄 끝에 쉼표를 붙여 초기값 목록을 이어 가면 한 배열이 되어 LENGTHOF = 10이다.

```
myArray BYTE 10,20,30,40,50,
             60,70,80,90,100
```

### 3.6 SIZEOF 연산자 (SIZEOF Operator, 4.3.6)
- LENGTHOF * TYPE과 같은 값, 즉 배열이 차지하는 전체 바이트 수를 돌려준다. 아래 intArray는 TYPE = 2, LENGTHOF = 32이므로 SIZEOF = 64다.

```
.data
intArray WORD 32 DUP(0)
.code
mov eax,SIZEOF intArray         ; EAX = 64
```

### 3.7 LABEL 지시어 (LABEL Directive, 4.3.7)
- 저장 공간을 할당하지 않고 레이블과 크기 속성만 붙인다. BYTE, WORD, DWORD, QWORD, TBYTE 같은 표준 크기 속성을 쓸 수 있다.
- 흔한 용도는 바로 다음에 선언되는 변수에 다른 이름과 크기 속성을 주는 것이다. val16은 val32와 같은 저장 위치의 별칭이다.

```
.data
val16 LABEL WORD
val32 DWORD 12345678h
.code
mov ax,val16               ; AX = 5678h
mov dx,[val16+2]           ; DX = 1234h
```

- 작은 정수 둘로 큰 정수를 만들 때도 쓴다. 아래는 16비트 변수 두 개를 32비트로 읽는 예다.

```
.data
LongValue LABEL DWORD
val1 WORD 5678h
val2 WORD 1234h
.code
mov eax,LongValue          ; EAX = 12345678h
```

## 4. 간접 주소 지정 (Indirect Addressing, 4.4)

- 직접 주소 지정은 상수 오프셋으로 접근하므로 원소가 몇 개 넘으면 비현실적이다. 그래서 배열 처리에서는 레지스터를 포인터처럼 쓰고 그 값을 바꿔 가며 접근한다. 이를 간접 주소 지정(indirect addressing)이라 하고, 이렇게 쓴 피연산자가 간접 피연산자(indirect operand)다.

### 4.1 간접 피연산자 (Indirect Operands, 4.4.1)
- 보호 모드에서 간접 피연산자는 대괄호로 감싼 32비트 범용 레지스터(EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP)다. 그 레지스터에 데이터 주소가 들어 있다고 보고 역참조한다.
- 아래는 ESI에 byteVal의 오프셋을 넣고 `[esi]`를 역참조해서 AL에 바이트를 가져온다.

```
.data
byteVal BYTE 10h
.code
mov esi,OFFSET byteVal
mov al,[esi]               ; AL = 10h
```

- 목적지가 간접 피연산자이면 레지스터가 가리키는 메모리에 새 값이 쓰인다.

```
mov [esi],bl               ; BL을 ESI가 가리키는 메모리에 복사
```

- 크기가 문맥에서 분명하지 않으면 PTR을 써야 한다. `inc [esi]`는 ESI가 바이트, 워드, 더블워드 중 무엇을 가리키는지 몰라서 "operand must have size" 오류가 난다.

```
inc [esi]                  ; error: operand must have size
inc BYTE PTR [esi]         ; OK
```

### 4.2 배열 (Arrays, 4.4.2)
- 간접 피연산자는 배열을 차례로 훑는 데 알맞다. 바이트 배열은 ESI를 1씩 증가시킨다.

```
.data
arrayB BYTE 10h,20h,30h
.code
mov esi,OFFSET arrayB
mov al,[esi]               ; AL = 10h
inc esi
mov al,[esi]               ; AL = 20h
inc esi
mov al,[esi]               ; AL = 30h
```

- 16비트 배열은 다음 원소로 가려면 ESI에 2를 더한다.

```
.data
arrayW WORD 1000h,2000h,3000h
.code
mov esi,OFFSET arrayW
mov ax,[esi]               ; AX = 1000h
add esi,2
mov ax,[esi]               ; AX = 2000h
add esi,2
mov ax,[esi]               ; AX = 3000h
```

- 32비트 정수 세 개를 더하는 예다. 더블워드는 4바이트이므로 ESI에 4씩 더한다. arrayD가 10200h에 있다면 원소는 10200h, 10204h, 10208h에 놓인다.

```
.data
arrayD DWORD 10000h,20000h,30000h
.code
mov esi,OFFSET arrayD
mov eax,[esi]              ; first number
add esi,4
add eax,[esi]              ; second number
add esi,4
add eax,[esi]              ; third number
```

### 4.3 인덱스 피연산자 (Indexed Operands, 4.4.3)
- 인덱스 피연산자는 레지스터에 상수를 더해 유효 주소를 만든다. 32비트 범용 레지스터는 모두 인덱스 레지스터로 쓸 수 있다. 표기법은 두 가지다(대괄호는 표기의 일부).
  - `constant[reg]`
  - `[constant + reg]`
- 변수 이름은 어셈블러가 그 변수의 오프셋 상수로 바꾼다. 예: `arrayB[esi]`, `[arrayB + esi]`, `arrayD[ebx]`, `[arrayD + ebx]`.
- 첫 원소에 접근하기 전에 인덱스 레지스터를 0으로 초기화한다. `[arrayB + ESI]`로 만든 주소를 역참조해서 그 바이트를 AL에 복사한다.

```
.data
arrayB BYTE 10h,20h,30h
.code
mov esi,0
mov al,arrayB[esi]         ; AL = 10h
```

- 변위 더하기: 레지스터가 배열이나 구조체의 시작 주소를 갖고, 상수가 각 원소의 위치를 나타내는 방식이다.

```
.data
arrayW WORD 1000h,2000h,3000h
.code
mov esi,OFFSET arrayW
mov ax,[esi]               ; AX = 1000h
mov ax,[esi+2]             ; AX = 2000h
mov ax,[esi+4]             ; AX = 3000h
```

- 16비트 레지스터 사용: 실제 주소 모드에서는 SI, DI, BX, BP만 인덱스로 쓸 수 있다. BP는 스택 데이터를 다룰 때만 쓰는 것이 좋다.

```
mov al,arrayB[si]
mov ax,arrayW[di]
mov eax,arrayD[bx]
```

#### 인덱스 피연산자의 배율 (Scale Factors in Indexed Operands)
- 인덱스는 원소 크기를 고려해서 오프셋을 계산해야 한다. 더블워드 배열에서 400h(인덱스 3)를 읽으려면 첨자 3에 4를 곱한다.

```
.data
arrayD DWORD 100h, 200h, 300h, 400h
.code
mov esi,3 * TYPE arrayD    ; offset of arrayD[3]
mov eax,arrayD[esi]        ; EAX = 400h
```

- Intel은 컴파일러 작성을 쉽게 하려고 배율(scale factor)을 지원한다. 배율은 원소 크기(워드 2, 더블워드 4, 쿼드워드 8)이고, ESI에는 첨자만 넣으면 된다.

```
.data
arrayD DWORD 1,2,3,4
.code
mov esi,3                          ; subscript
mov eax,arrayD[esi*4]              ; EAX = 4
```

- 나중에 배열 타입이 바뀌어도 되도록 TYPE을 쓰면 더 유연하다.

```
mov esi,3
mov eax,arrayD[esi*TYPE arrayD]    ; EAX = 4
```

### 4.4 포인터 (Pointers, 4.4.4)
- 다른 변수의 주소를 담는 변수를 포인터(pointer)라 한다. 포인터가 가진 주소는 실행 중에 바꿀 수 있어서 배열이나 자료구조를 다룰 때 유용하다. 예를 들어 시스템 호출로 메모리 블록을 할당하고 그 주소를 변수에 저장할 수 있다.
- 포인터의 크기는 프로세서 모드(32비트 / 64비트)에 따라 달라진다. 32비트에서는 near 포인터를 쓰므로 더블워드 변수에 저장한다.

```
.data
arrayB byte 10h,20h,30h,40h
ptrB   dword arrayB                 ; 또는 ptrB dword OFFSET arrayB
```

```
arrayB BYTE  10h,20h,30h,40h
arrayW WORD  1000h,2000h,3000h
ptrB   DWORD arrayB
ptrW   DWORD arrayW
```

- 고급 언어는 포인터의 물리적 세부를 일부러 감추지만, 어셈블리에서는 한 가지 구현만 다루므로 포인터를 물리 수준에서 직접 보고 쓰게 된다. 이 과정에서 포인터에 대한 막연한 느낌이 많이 사라진다.

#### TYPEDEF 연산자
- TYPEDEF는 내장 타입과 똑같은 지위를 갖는 사용자 정의 타입을 만든다. 특히 포인터 변수 만들기에 적합하다. 보통 프로그램 맨 앞(데이터 세그먼트 앞)에 둔다.

```
PBYTE TYPEDEF PTR BYTE

.data
arrayB BYTE 10h,20h,30h,40h
ptr1   PBYTE ?                      ; uninitialized
ptr2   PBYTE arrayB                 ; points to an array
```

- Pointers 예제는 PBYTE, PWORD, PDWORD 세 타입을 만들고, 각 배열의 오프셋을 가진 포인터를 역참조한다.

```
TITLE Pointers                                    (Pointers.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
; Create user-defined types.
PBYTE  TYPEDEF PTR BYTE                 ; pointer to bytes
PWORD  TYPEDEF PTR WORD                 ; pointer to words
PDWORD TYPEDEF PTR DWORD                ; pointer to doublewords
.data
arrayB BYTE 10h,20h,30h
arrayW WORD 1,2,3
arrayD DWORD 4,5,6
; Create some pointer variables.
ptr1 PBYTE arrayB
ptr2 PWORD arrayW
ptr3 PDWORD arrayD
.code
main PROC
; Use the pointers to access data.
      mov esi,ptr1
      mov al,[esi]                      ; 10h
      mov esi,ptr2
      mov ax,[esi]                      ; 1
      mov esi,ptr3
      mov eax,[esi]                     ; 4
      invoke ExitProcess,0
main ENDP
END main
```

## 5. JMP와 LOOP 명령어 (JMP and LOOP Instructions, 4.5)

- CPU는 기본적으로 프로그램을 순서대로 실행한다. 제어 이동(분기, branch)은 실행 순서를 바꾸는 방법이고 두 종류가 있다.
  - 무조건 이동(unconditional transfer): 항상 새 위치로 이동한다. 새 주소가 명령 포인터에 로드되어 그곳에서 계속 실행한다. JMP가 이에 해당한다.
  - 조건부 이동(conditional transfer): 조건이 참일 때만 분기한다. ECX와 플래그 레지스터의 내용으로 참/거짓을 판단하며, IF문이나 반복문 같은 고급 구문의 기반이 된다.

### 5.1 JMP 명령어 (JMP Instruction, 4.5.1)
- `JMP destination`은 코드 레이블(어셈블러가 오프셋으로 바꿈)로 무조건 이동한다. CPU는 destination의 오프셋을 명령 포인터에 넣어서 새 위치에서 계속 실행한다.
- 맨 위 레이블로 뛰어서 루프를 만들 수 있지만, 무조건 이동이므로 다른 탈출 방법이 없으면 무한 루프가 된다.

```
top:
    .
    .
    jmp top                 ; repeat the endless loop
```

### 5.2 LOOP 명령어 (LOOP Instruction, 4.5.2)
- LOOP(Loop According to ECX Counter)는 블록을 정해진 횟수만큼 반복한다. ECX가 자동으로 카운터로 쓰이고 반복할 때마다 감소한다. 형식은 `LOOP destination`이다.
- destination은 현재 위치에서 -128 ~ +127바이트 범위 안에 있어야 한다.
- 실행은 두 단계다. 먼저 ECX에서 1을 뺀다. 그다음 ECX를 0과 비교해서 0이 아니면 destination으로 뛰고, 0이면 뛰지 않고 다음 명령어로 넘어간다.
- 실제 주소 모드에서는 CX가 기본 카운터다. LOOPD는 ECX를, LOOPW는 CX를 카운터로 쓴다.
- 예: AX에 1씩 5번 더하는 루프. 끝나면 AX = 5, ECX = 0이다.

```
mov ax,0
mov ecx,5
L1:
    inc ax
    loop L1
```

- 흔한 실수: 루프 시작 전에 ECX를 0으로 초기화하면 LOOP가 ECX를 FFFFFFFFh로 줄여서 4,294,967,296번 반복한다. CX가 카운터이면 65,536번이다.
- 루프가 너무 커서 상대 점프 범위를 넘으면 MASM이 `error A2075: jump destination too far : by 14 byte(s)` 같은 오류를 낸다.
- 루프 안에서 ECX를 직접 바꾸는 일은 드물다. 예를 들어 루프 안에서 `inc ecx`를 하면 ECX가 영영 0이 되지 않아 루프가 끝나지 않는다.

```
top:
    .
    .
    inc ecx
    loop top
```

- ECX를 꼭 바꿔야 하면 루프 시작에서 변수에 저장해 두고 LOOP 직전에 복원한다.

```
.data
count DWORD ?
.code
    mov  ecx,100               ; set loop count
top:
    mov  count,ecx             ; save the count
    .
    mov  ecx,20                ; modify ECX
    .
    mov  ecx,count             ; restore loop count
    loop top
```

- 중첩 루프: 안쪽 루프가 ECX를 쓰므로 바깥 루프 카운터를 변수에 저장했다가 복원한다.

```
.data
count DWORD ?
.code
    mov   ecx,100              ; set outer loop count
L1:
    mov   count,ecx            ; save outer loop count
    mov   ecx,20               ; set inner loop count
L2:
    .
    .
    loop L2                    ; repeat the inner loop

    mov   ecx,count            ; restore outer loop count
    loop  L1                   ; repeat the outer loop
```

- 중첩이 2단계보다 깊으면 작성이 어렵다. 알고리즘상 깊은 중첩이 필요하면 안쪽 루프를 서브루틴으로 옮기는 편이 낫다.

### 5.3 정수 배열의 합 구하기 (Summing an Integer Array, 4.5.4)
- 어셈블리에서 배열 합은 아래 순서로 만든다. 1~3단계는 순서를 바꿔도 된다.
  - 배열 주소를 인덱스 역할 레지스터에 넣는다.
  - 루프 카운터를 배열 길이로 초기화한다.
  - 합을 누적할 레지스터를 0으로 만든다.
  - 루프 시작을 표시하는 레이블을 둔다.
  - 루프 몸체에서 원소 하나를 합에 더한다.
  - 다음 원소를 가리키게 한다.
  - LOOP로 반복한다.

```
; Summing an Array                           (SumArray.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
.data
intarray DWORD 10000h,20000h,30000h,40000h
.code
main PROC
      mov  edi,OFFSET intarray        ; 1: EDI = address of intarray
      mov  ecx,LENGTHOF intarray      ; 2: initialize loop counter
      mov  eax,0                      ; 3: sum = 0
L1:                                   ; 4: mark beginning of loop
      add  eax,[edi]                  ; 5: add an integer
      add  edi,TYPE intarray          ; 6: point to next element
      loop L1                         ; 7: repeat until ECX = 0
      invoke ExitProcess,0
main ENDP
END main
```

### 5.4 문자열 복사 (Copying a String, 4.5.5)
- 큰 데이터 블록 복사도 루프로 한다. 문자열은 널 종료 값을 가진 바이트 배열로 본다. 같은 인덱스 레지스터로 두 문자열을 가리킬 수 있으므로 인덱스 주소 지정이 잘 맞는다.
- 목적 문자열은 마지막 널 바이트까지 담을 공간이 충분해야 한다.
- MOV는 메모리 두 개를 피연산자로 가질 수 없으므로, 문자를 source에서 AL로 읽고 AL에서 target으로 쓴다.

```
; Copying a String                                 (CopyStr.asm)
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
.data
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP(0)
.code
main PROC
      mov  esi,0                      ; index register
      mov  ecx,SIZEOF source          ; loop counter
L1:
      mov  al,source[esi]             ; get a character from source
      mov  target[esi],al             ; store it in the target
      inc  esi                        ; move to next character
      loop L1                         ; repeat for entire string
      invoke ExitProcess,0
main ENDP
END main
```

## 6. 64비트 프로그래밍 (64-Bit Programming, 4.6)

### 6.1 MOV 명령어 (MOV Instruction, 4.6.1)
- 64비트 모드의 MOV는 32비트 모드와 대체로 같고 몇 가지만 다르다. 즉시값은 8, 16, 32, 64비트가 가능하다.

```
mov rax,0ABCDEF0AFFFFFFFFh       ; 64-bit immediate operand
```

- 상수를 64비트 레지스터에 옮길 때는 32, 16, 8비트 상수 모두 위쪽 비트가 0으로 지워진다.

```
mov rax,0FFFFFFFFh               ; rax = 00000000FFFFFFFF
mov rax,06666h                   ; clears bits 16-63
mov rax,055h                     ; clears bits 8-63
```

- 메모리 피연산자를 64비트 레지스터로 옮길 때는 결과가 크기에 따라 다르다.
  - 32비트 메모리를 EAX에 옮기면 RAX의 위쪽 32비트가 지워진다.
  - 8비트나 16비트 메모리를 RAX 하위에 옮기면 위쪽 비트는 영향을 받지 않는다.

```
.data
myDword DWORD 80000000h
.code
mov rax,0FFFFFFFFFFFFFFFFh
mov eax,myDword                  ; RAX = 0000000080000000

.data
myByte BYTE 55h
myWord WORD 6666h
.code
mov ax,myWord                    ; bits 16-63 are not affected
mov al,myByte                    ; bits 8-63 are not affected
```

- MOVSXD는 32비트 레지스터나 메모리를 원본으로 부호 확장해서 64비트에 옮긴다. 아래는 RAX가 FFFFFFFFFFFFFFFFh가 된다.

```
mov    ebx,0FFFFFFFFh
movsxd rax,ebx
```

- OFFSET은 64비트 주소를 만들므로 64비트 레지스터나 변수에 담아야 한다.

```
.data
myArray WORD 10,20,30,40
.code
mov rsi,OFFSET myArray
```

- 64비트 모드에서 LOOP의 카운터는 RCX다.
- 가능하면 64비트 정수 변수와 64비트 레지스터를 일관되게 쓰면 프로그래밍이 쉽다. ASCII 문자열은 항상 바이트로 되어 있어서 예외이며, 보통 간접이나 인덱스 주소 지정으로 처리한다.

### 6.2 SumArray의 64비트 버전 (64-Bit Version of SumArray, 4.6.2)
- 쿼드워드 배열의 합을 구하는 프로그램이다. 데이터는 QWORD로 만들고 32비트 레지스터 이름을 모두 64비트 이름으로 바꾼다.

```
; Summing an Array                        (SumArray_64.asm)
ExitProcess PROTO
.data
intarray QWORD 1000000000000h,2000000000000h
         QWORD 3000000000000h,4000000000000h
.code
main PROC
    mov rdi,OFFSET intarray       ; RDI = address of intarray
    mov rcx,LENGTHOF intarray     ; initialize loop counter
    mov rax,0                     ; sum = 0
L1:                               ; mark beginning of loop
    add rax,[rdi]                 ; add an integer
    add rdi,TYPE intarray         ; point to next element
    loop L1                       ; repeat until RCX = 0
    mov ecx,0                     ; ExitProcess return value
    call ExitProcess
main ENDP
END
```

### 6.3 덧셈과 뺄셈 (Addition and Subtraction, 4.6.3)
- ADD, SUB, INC, DEC가 CPU 플래그에 미치는 영향은 64비트 모드에서도 32비트 모드와 같다.
- 하위 32비트를 FFFFFFFFh로 채우고 1을 더하면 올림이 왼쪽으로 전파되어 비트 32에 1이 생긴다.

```
mov rax,0FFFFFFFFh               ; fill the lower 32 bits
add rax,1                        ; RAX = 100000000h
```

- 부분 레지스터를 쓰면 나머지 부분은 바뀌지 않는다. AX에서 16비트 합이 0으로 돌아가도 RAX의 위쪽 비트에는 영향이 없다. AL도 마찬가지로 다른 비트로 올림이 가지 않는다.

```
mov rax,0FFFFh                   ; RAX = 000000000000FFFF
mov bx,1
add ax,bx                        ; RAX = 0000000000000000

mov rax,0FFh                     ; RAX = 00000000000000FF
mov bl,1
add al,bl                        ; RAX = 0000000000000000
```

- 뺄셈도 같다. EAX에서 0 - 1을 하면 RAX 하위 32비트가 FFFFFFFFh(-1)가 되고, AX에서 하면 하위 16비트가 FFFFh가 된다.

```
mov rax,0
mov ebx,1
sub eax,ebx                      ; RAX = 00000000FFFFFFFF

mov rax,0
mov bx,1
sub ax,bx                        ; RAX = 000000000000FFFF
```

- 간접 피연산자에는 반드시 64비트 범용 레지스터를 써야 하고, 대상 크기는 PTR로 명시한다.

```
dec BYTE PTR [rdi]               ; 8-bit target
inc WORD PTR [rbx]               ; 16-bit target
inc QWORD PTR [rsi]              ; 64-bit target
```

- 64비트에서도 인덱스 피연산자에 배율을 쓸 수 있다. 64비트 정수 배열이면 배율은 8이다.

```
.data
array QWORD 1,2,3,4
.code
mov esi,3                        ; subscript
mov eax,array[rsi*8]             ; EAX = 4
```

- 64비트 모드의 포인터 변수는 64비트 오프셋을 가진다.

```
.data
arrayB BYTE 10h,20h,30h,40h
ptrB QWORD arrayB                ; 또는 ptrB QWORD OFFSET arrayB
```
