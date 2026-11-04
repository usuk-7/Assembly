# 7장. Integer Arithmetic (어셈블리 프로그래밍)

## 1. 시프트와 회전 명령어 (Shift and Rotate Instructions, 7.1)
- 비트 시프트는 피연산자 안의 비트들을 왼쪽이나 오른쪽으로 옮기는 것이다. 6장의 비트 연산 명령어와 함께 어셈블리 언어의 가장 특징적인 기능이며, 그래픽·암호화·하드웨어 제어 등에서 많이 쓰인다.
- x86은 시프트/회전 명령어를 풍부하게 제공하며, 모두 Overflow 플래그와 Carry 플래그에 영향을 준다.

| 명령어 | 의미 |
|---|---|
| SHL | Shift left (논리 왼쪽 시프트) |
| SHR | Shift right (논리 오른쪽 시프트) |
| SAL | Shift arithmetic left (산술 왼쪽 시프트) |
| SAR | Shift arithmetic right (산술 오른쪽 시프트) |
| ROL | Rotate left |
| ROR | Rotate right |
| RCL | Rotate carry left |
| RCR | Rotate carry right |
| SHLD | Double-precision shift left |
| SHRD | Double-precision shift right |

### 1.1 논리 시프트와 산술 시프트 (Logical Shifts and Arithmetic Shifts, 7.1.1)
- 논리 시프트(logical shift)는 시프트로 새로 비는 비트 자리를 0으로 채운다. 밀려나는 비트는 Carry 플래그(CF)로 들어간다.
  - 예: 11001111을 오른쪽으로 1비트 논리 시프트 → 01100111, CF = 1
- 산술 시프트(arithmetic shift)는 새로 비는 자리를 원래 수의 부호 비트 복사본으로 채운다. 그래서 부호 있는 수의 부호가 유지된다.
  - 예: 11001111(부호 비트 1)을 오른쪽으로 1비트 산술 시프트 → 11100111

### 1.2 SHL 명령어 (SHL Instruction, 7.1.2)
- SHL은 목적지 피연산자를 왼쪽으로 논리 시프트한다. 최하위 비트는 0으로 채워지고, 최상위 비트는 CF로 이동하며, 원래 CF에 있던 값은 버려진다.
- 형식은 `SHL destination,count`이며, 허용되는 피연산자는 다음과 같다. 이 형식은 SHR, SAL, SAR, ROL, ROR, RCL, RCR에도 똑같이 적용된다.
  - `SHL reg,imm8` / `SHL mem,imm8` / `SHL reg,CL` / `SHL mem,CL`
  - imm8은 0~255 사이 정수이고, 시프트 횟수를 CL 레지스터에 넣어서 줄 수도 있다.
- 여러 번 시프트하면 CF에는 MSB에서 마지막으로 밀려난 비트가 남는다. 처음 MSB였던 비트가 남는 게 아님에 주의한다.

```
mov bl,8Fh        ; BL = 10001111b
shl bl,1          ; CF = 1, BL = 00011110b

mov al,10000000b
shl al,2          ; CF = 0, AL = 00000000b  (bit 7은 bit 6(0)에 밀려 CF에 남지 않음)
```

- 비트 곱셈(bitwise multiplication): 왼쪽으로 n비트 시프트하면 값에 2^n을 곱한 것과 같다.

```
mov dl,5
shl dl,1          ; 00000101 → 00001010 = 10 (5 × 2)
mov dl,10
shl dl,2          ; 00001010 → 00101000 = 40 (10 × 4)
```

### 1.3 SHR 명령어 (SHR Instruction, 7.1.3)
- SHR은 오른쪽으로 논리 시프트한다. 최상위 비트는 0으로 채워지고, 최하위 비트는 CF로 복사되며, 이전 CF 값은 사라진다. 형식은 SHL과 같다.
- 여러 번 시프트하면 LSB에서 마지막으로 밀려난 비트가 CF에 남는다.
- 비트 나눗셈(bitwise division): 부호 없는 정수를 오른쪽으로 n비트 시프트하면 2^n으로 나눈 몫이 된다. 부호 있는 수의 나눗셈은 부호 비트를 보존하는 SAR을 써야 한다.

```
mov al,0D0h       ; AL = 11010000b
shr al,1          ; AL = 01101000b, CF = 0

mov al,00000010b
shr al,2          ; AL = 00000000b, CF = 1

mov dl,32
shr dl,1          ; 32 / 2 = 16
mov al,01000000b  ; AL = 64
shr al,3          ; 64 / 8 = 8, AL = 00001000b
```

### 1.4 SAL과 SAR 명령어 (SAL and SAR Instructions, 7.1.4)
- SAL은 SHL과 완전히 똑같이 동작한다. 최하위 비트를 0으로 채우고, 최상위 비트를 CF로 보낸다.
- SAR은 오른쪽 산술 시프트로, 최상위(부호) 비트를 그대로 복제해 채운다. 그래서 음수는 시프트 후에도 음수다. 피연산자 형식은 SHL/SHR과 같다.
- 부호 있는 나눗셈: SAR로 부호 있는 수를 2의 거듭제곱으로 나눌 수 있다.
- AX → EAX 부호 확장: EAX를 왼쪽으로 16비트 밀었다가 산술로 16비트 오른쪽 밀면 AX의 부호가 상위 16비트로 확장된다.

```
mov al,0F0h       ; AL = 11110000b (-16)
sar al,1          ; AL = 11111000b (-8), CF = 0

mov dl,-128       ; DL = 10000000b
sar dl,3          ; DL = 11110000b (-16) = -128 / 8

mov ax,-128       ; EAX = ????FF80h
shl eax,16        ; EAX = FF800000h
sar eax,16        ; EAX = FFFFFF80h
```

### 1.5 ROL 명령어 (ROL Instruction, 7.1.5)
- 회전(rotation)은 비트를 원형으로 이동시키는 것이다. 한쪽 끝에서 빠진 비트가 바로 반대쪽 끝으로 들어가는 방식과, CF를 중간 경유지로 쓰는 방식(RCL/RCR)이 있다.
- ROL은 각 비트를 왼쪽으로 옮기고, 최상위 비트를 CF와 최하위 비트 자리 둘 다에 복사한다. 회전은 시프트와 달리 비트를 잃지 않는다.
- 회전 횟수가 1보다 크면 CF에는 MSB에서 마지막으로 회전되어 나간 비트가 남는다.
- 비트 그룹 교환: 바이트를 4비트 회전하면 상위 니블(4~7비트)과 하위 니블(0~3비트)이 서로 바뀐다. 여러 바이트 정수를 4비트씩 회전하면 16진수 한 자리씩 회전하는 효과가 난다.

```
mov al,40h        ; AL = 01000000b
rol al,1          ; AL = 10000000b, CF = 0
rol al,1          ; AL = 00000001b, CF = 1
rol al,1          ; AL = 00000010b, CF = 0

mov al,00100000b
rol al,3          ; CF = 1, AL = 00000001b

mov al,26h
rol al,4          ; AL = 62h (니블 교환)

mov ax,6A4Bh
rol ax,4          ; AX = A4B6h
rol ax,4          ; AX = 4B6Ah
rol ax,4          ; AX = B6A4h
rol ax,4          ; AX = 6A4Bh (원래 값으로 복귀)
```

### 1.6 ROR 명령어 (ROR Instruction, 7.1.6)
- ROR은 각 비트를 오른쪽으로 옮기고, 최하위 비트를 CF와 최상위 비트 자리 둘 다에 복사한다. 형식은 SHL과 같다.
- 회전 횟수가 1보다 크면 CF에는 LSB에서 마지막으로 회전되어 나간 비트가 남는다.

```
mov al,01h        ; AL = 00000001b
ror al,1          ; AL = 10000000b, CF = 1
ror al,1          ; AL = 01000000b, CF = 0

mov al,00000100b
ror al,3          ; AL = 10000000b, CF = 1
```

### 1.7 RCL과 RCR 명령어 (RCL and RCR Instructions, 7.1.7)
- RCL은 각 비트를 왼쪽으로 옮기면서 CF를 LSB로 넣고, MSB를 CF로 보낸다. CF를 피연산자 위쪽에 붙은 1비트로 보면 9비트(바이트의 경우) 값을 왼쪽으로 회전하는 것과 같다.
- RCR은 각 비트를 오른쪽으로 옮기면서 CF를 MSB로 넣고, LSB를 CF로 보낸다. CF가 LSB 오른쪽에 붙은 9비트 값으로 생각하면 된다.
- CLC는 CF를 0으로, STC는 CF를 1로 만든다.
- CF에서 비트 복원: SHR로 LSB를 CF에 뺐다가, 조건이 맞지 않으면 RCL로 다시 넣어 원래 값으로 돌려놓을 수 있다.

```
clc               ; CF = 0
mov bl,88h        ; CF,BL = 0 10001000b
rcl bl,1          ; CF,BL = 1 00010000b
rcl bl,1          ; CF,BL = 0 00100001b

; 최하위 비트 검사 후 복원
.data
testval BYTE 01101010b
.code
shr testval,1     ; LSB를 CF로
jc  exit          ; CF = 1이면 종료
rcl testval,1     ; 아니면 원래 값으로 복원

stc               ; CF = 1
mov ah,10h        ; AH,CF = 00010000 1
rcr ah,1          ; AH,CF = 10001000 0
```

### 1.8 부호 있는 오버플로 (Signed Overflow, 7.1.8)
- 부호 있는 정수를 1비트 시프트/회전했을 때 결과가 목적지의 부호 있는 범위를 벗어나면, 즉 부호가 뒤집히면 Overflow 플래그(OF)가 세트된다.
- 시프트/회전 횟수가 1보다 크면 OF 값은 정의되지 않는다(undefined).

```
mov al,+127       ; AL = 01111111b
rol al,1          ; OF = 1, AL = 11111110b (-2)

mov al,-128       ; AL = 10000000b
shr al,1          ; OF = 1, AL = 01000000b (+64)
```

### 1.9 SHLD/SHRD 명령어 (SHLD/SHRD Instructions, 7.1.9)
- SHLD(shift left double)는 목적지를 왼쪽으로 지정 횟수만큼 시프트하고, 비게 된 하위 비트 자리를 소스 피연산자의 최상위 비트들로 채운다.
- SHRD(shift right double)는 목적지를 오른쪽으로 시프트하고, 비게 된 상위 비트 자리를 소스 피연산자의 최하위 비트들로 채운다.
- 소스 피연산자 자체는 바뀌지 않는다. SF, ZF, AF, PF, CF가 영향을 받는다.
- 형식: `SHLD dest, source, count` / `SHRD dest, source, count`
  - 목적지는 레지스터나 메모리, 소스는 반드시 레지스터, count는 CL 또는 imm8이다.
  - `SHLD reg16,reg16,CL/imm8`, `SHLD mem16,reg16,CL/imm8`, `SHLD reg32,reg32,CL/imm8`, `SHLD mem32,reg32,CL/imm8` (SHRD도 동일)
- 활용: 비트맵 이미지 위치 이동, 비트 시프트를 쓰는 암호화, 매우 긴 정수의 빠른 곱셈·나눗셈.

```
; Example 1: wval을 왼쪽으로 4비트 밀고, AX의 상위 4비트를 wval 하위에 채움
.data
wval WORD 9BA6h
.code
mov  ax,0AC36h
shld wval,ax,4    ; wval = BA6Ah (AX의 상위 니블 A가 들어옴)

; Example 2: AX를 오른쪽으로 4비트 밀고, DX의 하위 4비트를 AX 상위에 채움
mov  ax,234Bh
mov  dx,7654h
shrd ax,dx,4      ; AX = 4234h (DX의 하위 니블 4가 들어옴)
```

#### SHRD로 더블워드 배열 전체를 4비트 오른쪽 시프트 (슬라이드 "Explain the program below")

```
.data
array DWORD 648B2165h,8C943A29h,6DFA4B86h,91F76C04h,8BAF9857h
.code
    mov  bl,4                        ; shift count
    mov  esi,OFFSET array            ; 배열 시작 주소
    mov  ecx,(LENGTHOF array) - 1    ; 반복 횟수 = 원소 수 - 1 = 4
L1: push ecx                         ; 루프 카운터 저장 (CL을 시프트 횟수로 쓰기 위해)
    mov  eax,[esi + TYPE DWORD]      ; 다음 원소를 EAX로
    mov  cl,bl                       ; CL = 4
    shrd [esi],eax,cl                ; 현재 원소를 4비트 오른쪽으로, 빈 상위 4비트는 다음 원소의 하위 4비트로 채움
    add  esi,TYPE DWORD              ; 다음 원소로
    pop  ecx                         ; 루프 카운터 복원
    loop L1
    shr  DWORD PTR [esi],COUNT       ; 마지막 원소는 위에서 채워줄 게 없으므로 그냥 SHR (COUNT = 4)
```

- 배열 전체를 하나의 160비트 리틀 엔디언 정수로 보고 4비트 오른쪽으로 시프트하는 프로그램이다.
  - 각 원소는 자기보다 상위에 있는 다음 원소의 하위 4비트를 받아와야 하므로, 낮은 주소부터 SHRD를 수행한다.
  - ECX는 LOOP 카운터이면서 CL이 시프트 횟수로도 쓰이므로, push/pop으로 보존한다.
  - 예: 첫 원소 648B2165h는 다음 원소 8C943A29h의 하위 니블 9를 받아 9648B216h가 된다.
  - 마지막 원소(최상위)는 위에서 넘어올 비트가 없으므로 SHR로 0을 채운다.

## 2. 시프트와 회전의 활용 (Shift and Rotate Applications, 7.2)
- 정수의 일부 비트를 다른 위치로 옮기거나, 원하는 비트들을 0번 위치로 내려 값을 쉽게 분리할 때 시프트/회전이 유용하다.

### 2.1 여러 더블워드 시프트 (Shifting Multiple Doublewords, 7.2.1)
- 바이트/워드/더블워드 배열로 나눠 저장한 확장 정밀도 정수도 시프트할 수 있다. 먼저 저장 순서를 알아야 한다.
- 흔한 방식은 리틀 엔디언(little-endian) 순서다. 가장 낮은 자리 바이트를 배열 시작 주소에 두고, 위쪽 자리 바이트를 차례로 다음 주소에 둔다. 워드/더블워드 배열로 저장해도 x86은 각 워드/더블워드를 리틀 엔디언으로 저장하므로 바이트 순서는 동일하다.
- 3바이트 배열을 1비트 오른쪽으로 시프트하는 단계:
  - Step 1: 최상위 바이트 [ESI+2]를 SHR → 최하위 비트가 CF로 들어감
  - Step 2: [ESI+1]을 RCR → CF가 최상위 비트로 들어가고, 최하위 비트가 CF로
  - Step 3: [ESI]를 RCR → 같은 방식으로 처리
  - 결과: 10011001 10011001 10011001 → 01001100 11001100 11001100

```
.data
ArraySize = 3
array BYTE ArraySize DUP(99h)    ; 각 니블이 1001 패턴
.code
main PROC
    mov esi,0
    shr array[esi+2],1           ; 상위 바이트
    rcr array[esi+1],1           ; 중간 바이트, CF 포함
    rcr array[esi],1             ; 하위 바이트, CF 포함
```

- 워드/더블워드 배열로도 쉽게 바꿀 수 있고, 루프를 쓰면 임의 크기 배열을 시프트할 수 있다.

### 2.2 이진 곱셈 (Binary Multiplication, 7.2.2)
- MUL 대신 시프트로 곱셈을 해서 성능을 높이는 기법이다. 곱하는 수가 2의 거듭제곱이면 SHL만으로 부호 없는 곱셈이 된다.
- 다른 수는 2의 거듭제곱의 합으로 쪼개고 분배법칙을 쓴다.
  - EAX × 36 = EAX × (2^5 + 2^2) = (EAX × 32) + (EAX × 4)
  - 36의 이진수 00100100에서 2번, 5번 비트가 1이고, 바로 이 2와 5가 필요한 시프트 횟수다.

```
; 123 × 36 = 4428
mov eax,123
mov ebx,eax
shl eax,5         ; × 2^5
shl ebx,2         ; × 2^2
add eax,ebx       ; 두 곱을 더함
```

### 2.3 이진 비트 출력 (Displaying Binary Bits, 7.2.3)
- 이진 정수를 화면에 출력할 수 있는 ASCII 이진 문자열로 바꾸는 작업이다. SHL은 시프트할 때마다 최상위 비트를 CF로 보내므로, CF를 보고 '0'/'1'을 결정하면 된다.

```
;---------------------------------------------------------
BinToAsc PROC
;
; Converts 32-bit binary integer to ASCII binary.
; Receives: EAX = binary integer, ESI points to buffer
; Returns: buffer filled with ASCII binary digits
;---------------------------------------------------------
    push ecx
    push esi
    mov  ecx,32                ; EAX의 비트 수
L1: shl  eax,1                 ; 최상위 비트를 CF로
    mov  BYTE PTR [esi],'0'    ; 기본값 '0'
    jnc  L2                    ; CF = 0이면 L2로
    mov  BYTE PTR [esi],'1'    ; 아니면 '1'
L2: inc  esi                   ; 다음 버퍼 위치
    loop L1                    ; 다음 비트
    pop  esi
    pop  ecx
    ret
BinToAsc ENDP
```

### 2.4 파일 날짜 필드 추출 (Extracting File Date Fields, 7.2.4)
- 저장 공간을 아끼기 위해 여러 데이터 필드를 정수 하나에 묶어 두는 경우가 많고, 이 값을 꺼내려면 비트 문자열(bit string)을 추출해야 한다.
- MS-DOS 함수 57h는 파일 날짜 스탬프를 DX에 돌려준다.

| 필드 | 비트 | 내용 |
|---|---|---|
| Day | 0~4 | 1~31 |
| Month | 5~8 | 1~12 |
| Year | 9~15 | 1980년 기준 상대값 |

- 예: 1999년 3월 10일 → DX = 0010011 0011 01010 (Year = 19, Month = 3, Day = 10)
- 필드 추출 방법: 해당 비트들을 레지스터 하위로 시프트한 뒤, 관련 없는 비트를 AND로 지운다.

```
; Day (bits 0-4)
mov al,dl             ; DL 복사
and al,00011111b      ; bits 5-7 지움
mov day,al

; Month (bits 5-8)
mov ax,dx             ; DX 복사
shr ax,5              ; 오른쪽으로 5비트
and al,00001111b      ; bits 4-7 지움
mov month,al

; Year (bits 9-15, 모두 DH 안에 있음)
mov al,dh             ; DH 복사
shr al,1              ; 1비트 오른쪽
mov ah,0              ; AH = 0
add ax,1980           ; 1980 기준값 더함
mov year,ax
```

## 3. 곱셈과 나눗셈 명령어 (Multiplication and Division Instructions, 7.3)
- 32비트 모드에서 정수 곱셈은 8/16/32비트 연산으로, 64비트 모드에서는 64비트 연산도 가능하다.
- MUL은 부호 없는 곱셈, IMUL은 부호 있는 곱셈, DIV는 부호 없는 나눗셈, IDIV는 부호 있는 나눗셈이다.

### 3.1 MUL 명령어 (MUL Instruction, 7.3.1)
- MUL은 8비트 피연산자 × AL, 16비트 × AX, 32비트 × EAX의 세 가지 버전이 있다. 곱해지는 두 수는 크기가 같아야 하고, 곱은 그 두 배 크기다.
- 레지스터/메모리 피연산자만 가능하고 즉시값은 안 된다: `MUL reg/mem8`, `MUL reg/mem16`, `MUL reg/mem32`
- 단일 피연산자가 승수(multiplier)이고, 피승수와 곱의 위치는 크기에 따라 정해진다.

| 피승수 | 승수 | 곱 |
|---|---|---|
| AL | reg/mem8 | AX |
| AX | reg/mem16 | DX:AX |
| EAX | reg/mem32 | EDX:EAX |

- 곱의 자리가 두 배라서 오버플로는 일어나지 않는다. 대신 곱의 상위 절반이 0이 아니면 CF와 OF가 세트된다.
  - MUL 뒤에 CF를 확인하는 이유는 곱의 상위 절반을 무시해도 되는지 알기 위해서다.

```
mov al,5h
mov bl,10h
mul bl            ; AX = 0050h, CF = 0 (AH = 0)

.data
val1 WORD 2000h
val2 WORD 0100h
.code
mov ax,val1       ; AX = 2000h
mul val2          ; DX:AX = 00200000h, CF = 1 (DX ≠ 0)

mov eax,12345h
mov ebx,1000h
mul ebx           ; EDX:EAX = 0000000012345000h, CF = 0
```

- 64비트 모드의 MUL: 64비트 레지스터/메모리 피연산자를 RAX와 곱해 128비트 곱을 RDX:RAX에 저장한다.

```
mov rax,0FFFF0000FFFF0000h
mov rbx,2
mul rbx           ; RDX:RAX = 0000000000000001 FFFE0001FFFE0000 (최상위 비트가 RDX로 넘어감)

.data
multiplier QWORD 10h
.code
mov rax,0AABBBBCCCCDDDDh
mul multiplier    ; RDX:RAX = 0000000000000000 0AABBBBCCCCDDDD0h (16을 곱하면 16진수 한 자리 왼쪽 이동)
```

### 3.2 IMUL 명령어 (IMUL Instruction, 7.3.2)
- IMUL은 부호 있는 곱셈이다. MUL과 달리 곱의 하위 절반의 최상위 비트를 상위 비트들로 부호 확장해 곱의 부호를 유지한다.
- 1-피연산자, 2-피연산자, 3-피연산자 세 가지 형식이 있다.

| 형식 | 예 | 결과 위치 | 플래그 |
|---|---|---|---|
| 1-피연산자 | `IMUL reg/mem8` / `16` / `32` | AX / DX:AX / EDX:EAX | 상위 절반이 하위 절반의 부호 확장이 아니면 CF=OF=1. 오버플로 불가 |
| 2-피연산자 | `IMUL reg16,reg/mem16` / `reg16,imm8` / `reg16,imm16`, `IMUL reg32,reg/mem32` / `reg32,imm8` / `reg32,imm32` | 첫 피연산자(레지스터) | 목적지 길이로 잘림. 유효 자리 손실 시 CF=OF=1 |
| 3-피연산자 | `IMUL reg16,reg/mem16,imm8/imm16`, `IMUL reg32,reg/mem32,imm8/imm32` | 첫 피연산자 | 유효 자리 손실 시 CF=OF=1 |

- 2·3-피연산자 형식은 목적지가 승수와 같은 크기라서 부호 있는 오버플로가 생길 수 있다. 실행 후 항상 OF를 확인해야 한다.
- 부호 없는 곱셈에도 2·3-피연산자 IMUL을 쓸 수 있다. 곱의 하위 절반은 부호 유무와 관계없이 같기 때문이다. 단, CF/OF가 상위 절반이 0인지 알려주지는 못한다.
- 64비트 모드: 1-피연산자 형식은 64비트 피연산자를 RAX와 곱해 128비트 부호 확장 곱을 RDX:RAX에 저장한다. 3-피연산자 형식도 쓸 수 있다.

```
mov rax,-4
mov rbx,4
imul rbx          ; RDX = 0FFFFFFFFFFFFFFFFh, RAX = -16 (FFFFFFFFFFFFFFF0h)

.data
multiplicand QWORD -16
.code
imul rax,multiplicand,4   ; RAX = FFFFFFFFFFFFFFC0h (-64)
```

- IMUL 예제 (1-피연산자):

```
mov al,48
mov bl,4
imul bl           ; AX = 00C0h (192), OF = 1  → AH가 AL의 부호 확장이 아님

mov al,-4
mov bl,4
imul bl           ; AX = FFF0h (-16), OF = 0

mov ax,48
mov bx,4
imul bx           ; DX:AX = 000000C0h (192), OF = 0 → DX가 AX의 부호 확장

mov eax,+4823424
mov ebx,-423
imul ebx          ; EDX:EAX = FFFFFFFF86635D80h (-2,040,308,352), OF = 0
```

- IMUL 예제 (2·3-피연산자):

```
.data
word1  SWORD 4
dword1 SDWORD 4
.code
mov  ax,-16
mov  bx,2
imul bx,ax        ; BX = -32
imul bx,2         ; BX = -64
imul bx,word1     ; BX = -256

mov  eax,-16
mov  ebx,2
imul ebx,eax      ; EBX = -32
imul ebx,2        ; EBX = -64
imul ebx,dword1   ; EBX = -256

mov  ax,-32000
imul ax,2         ; OF = 1 (-64000은 16비트에 안 들어감)

imul bx,word1,-16            ; BX = word1 * -16
imul ebx,dword1,-16          ; EBX = dword1 * -16
imul ebx,dword1,-2000000000  ; signed overflow!
```

### 3.3 프로그램 실행 시간 측정 (Measuring Program Execution Times, 7.3.3)
- 두 구현의 성능을 비교할 때 실행 시간을 잰다. Irvine32의 GetMseconds는 자정 이후 경과한 밀리초를 EAX에 돌려준다.
- 방법: 시작 전 GetMseconds → 측정할 프로시저 호출 → 다시 GetMseconds → 차이 계산. GetMseconds 호출 자체의 시간은 두 구현의 비율을 볼 때는 무시할 만하다.

```
.data
startTime DWORD ?
procTime1 DWORD ?
.code
call GetMseconds          ; 시작 시간
mov  startTime,eax
call FirstProcedureToTest
call GetMseconds          ; 종료 시간
sub  eax,startTime        ; 경과 시간
mov  procTime1,eax
```

- MUL vs 시프트 비교: EAX × 36을 시프트(shl 5, shl 2, add)와 MUL로 각각 LOOP_COUNT(0FFFFFFFFh)번 반복했다.

```
mult_by_shifting PROC
    mov ecx,LOOP_COUNT
L1: push eax
    mov  ebx,eax
    shl  eax,5
    shl  ebx,2
    add  eax,ebx
    pop  eax
    loop L1
    ret
mult_by_shifting ENDP

mult_by_MUL PROC
    mov ecx,LOOP_COUNT
L1: push eax
    mov  ebx,36
    mul  ebx
    pop  eax
    loop L1
    ret
mult_by_MUL ENDP
```

- 구형 4GHz Pentium 4에서는 SHL 방식 6.078초, MUL 방식 20.718초로 MUL이 241% 느렸다. 하지만 최신 프로세서에서는 두 방식의 시간이 똑같았다. 즉 최신 Intel CPU는 MUL/IMUL을 크게 최적화했다.

### 3.4 DIV 명령어 (DIV Instruction, 7.3.4)
- DIV는 8/16/32비트 부호 없는 나눗셈을 한다. 단일 레지스터/메모리 피연산자가 제수(divisor)다: `DIV reg/mem8`, `DIV reg/mem16`, `DIV reg/mem32`

| 피제수 | 제수 | 몫 | 나머지 |
|---|---|---|---|
| AX | reg/mem8 | AL | AH |
| DX:AX | reg/mem16 | AX | DX |
| EDX:EAX | reg/mem32 | EAX | EDX |
| RDX:RAX (64비트 모드) | reg/mem64 | RAX | RDX |

- 16/32비트 나눗셈에서 DX/EDX는 피제수의 상위 부분이므로, 나누기 전에 반드시 알맞게 설정(보통 0으로 클리어)해야 한다.

```
mov ax,0083h      ; 피제수
mov bl,2          ; 제수
div bl            ; AL = 41h (몫), AH = 01h (나머지)

mov dx,0          ; 피제수 상위 클리어
mov ax,8003h      ; 피제수 하위
mov cx,100h       ; 제수
div cx            ; AX = 0080h, DX = 0003h

.data
dividend QWORD 0000000800300020h
divisor  DWORD 00000100h
.code
mov edx,DWORD PTR dividend + 4   ; 상위 더블워드
mov eax,DWORD PTR dividend       ; 하위 더블워드
div divisor                      ; EAX = 08003000h, EDX = 00000020h

; 64비트 나눗셈
.data
dividend_hi QWORD 0000000000000108h
dividend_lo QWORD 0000000033300020h
divisor     QWORD 0000000000010000h
.code
mov rdx,dividend_hi
mov rax,dividend_lo
div divisor       ; RAX = 0108000000003330h, RDX = 0000000000000020h
```

- 마지막 예에서 10000h(=16^4)로 나눴으므로 피제수의 16진수 각 자리가 4자리씩 오른쪽으로 이동했다. (16으로 나누면 한 자리만 이동)

### 3.5 부호 있는 정수 나눗셈 (Signed Integer Division, 7.3.5)
- 부호 없는 나눗셈과 거의 같지만, 나누기 전에 피제수를 반드시 부호 확장(sign extension)해야 한다. 부호 확장은 수의 최상위 비트를 그것을 담는 레지스터/변수의 상위 비트 전체에 복사하는 것이다.
- 부호 확장을 안 하면 틀린 결과가 나온다.
  - 예: -101(SWORD, FF9Bh)을 AX에 넣고 상위를 0으로 둔 채 나누면, 피제수가 +155처럼 해석되어 몫이 +77이 된다. CWD로 AX를 부호 확장해야 -101로 제대로 계산된다.

#### 부호 확장 명령어 (CBW, CWD, CDQ)

| 명령어 | 의미 | 동작 |
|---|---|---|
| CBW | convert byte to word | AL의 부호 비트를 AH로 확장 |
| CWD | convert word to doubleword | AX의 부호 비트를 DX로 확장 |
| CDQ | convert doubleword to quadword | EAX의 부호 비트를 EDX로 확장 |

```
.data
byteVal  SBYTE  -101   ; 9Bh
wordVal  SWORD  -101   ; FF9Bh
dwordVal SDWORD -101   ; FFFFFF9Bh
.code
mov al,byteVal         ; AL = 9Bh
cbw                    ; AX = FF9Bh

mov ax,wordVal         ; AX = FF9Bh
cwd                    ; DX:AX = FFFFFF9Bh

mov eax,dwordVal
cdq                    ; EDX:EAX = FFFFFFFFFFFFFF9Bh
```

#### IDIV 명령어
- IDIV는 부호 있는 나눗셈으로, DIV와 같은 피연산자 형식을 쓴다. 8비트 나눗셈 전에 피제수 AX를 완전히 부호 확장해야 한다.
- 나머지의 부호는 항상 피제수의 부호와 같다.

```
; Example 1: -48 / 5
.data
byteVal SBYTE -48      ; D0h
.code
mov  al,byteVal        ; 피제수 하위
cbw                    ; AL → AH 부호 확장 (AX = FFD0h)
mov  bl,+5
idiv bl                ; AL = -9, AH = -3

; 부호 확장을 안 했을 때 (잘못된 예)
mov  ah,0
mov  al,byteVal        ; AX = 00D0h = 208
mov  bl,+5
idiv bl                ; AL = 41, AH = 3  → 틀린 답

; Example 2: -5000 / 256 (16비트)
.data
wordVal SWORD -5000
.code
mov  ax,wordVal
cwd                    ; AX → DX
mov  bx,+256
idiv bx                ; 몫 AX = -19, 나머지 DX = -136

; Example 3: 50000 / -256 (32비트)
.data
dwordVal SDWORD +50000
.code
mov  eax,dwordVal
cdq                    ; EAX → EDX
mov  ebx,-256
idiv ebx               ; 몫 EAX = -195, 나머지 EDX = +80
```

- DIV, IDIV 실행 후 모든 산술 상태 플래그 값은 정의되지 않는다(undefined).

#### 나눗셈 오버플로 (Divide Overflow)
- 몫이 목적지 피연산자에 들어가지 않으면 divide overflow가 발생한다. 이는 프로세서 예외를 일으켜 프로그램이 중단된다. 0으로 나눌 때도 같은 일이 생긴다.

```
mov ax,1000h
mov bl,10h
div bl            ; 몫 100h는 AL(8비트)에 안 들어감 → divide overflow
```

- 해결책 1: 32비트 제수와 64비트 피제수(EDX:EAX)를 쓰면 오버플로 가능성이 줄어든다.
- 해결책 2: 0으로 나누기를 막으려면 나누기 전에 제수를 검사한다.

```
mov eax,1000h
cdq
mov ebx,10h
div ebx           ; EAX = 00000100h (정상)

mov ax,dividend
mov bl,divisor
cmp bl,0          ; 제수 검사
je  NoDivideZero  ; 0이면 에러 처리
div bl
...
NoDivideZero:     ; "Attempt to divide by zero" 출력
```

### 3.6 산술식 구현 (Implementing Arithmetic Expressions, 7.3.6)
- 직접 산술식을 구현해 보면 컴파일러의 최적화 방식을 이해할 수 있고, 곱 크기 확인 등 컴파일러보다 더 나은 오류 검사를 할 수 있다. 대부분의 고급 언어 컴파일러는 32비트 × 32비트 곱의 상위 32비트를 무시하지만, 어셈블리에서는 CF/OF로 곱이 32비트를 넘는지 알 수 있다.

```
; Example 1: var4 = (var1 + var2) * var3;  (unsigned 32-bit)
mov eax,var1
add eax,var2
mul var3          ; EAX = EAX * var3
jc  tooBig        ; 곱이 32비트 초과?
mov var4,eax
jmp next
tooBig:           ; 에러 메시지 출력

; Example 2: var4 = (var1 * 5) / (var2 - 3);  (unsigned 32-bit)
mov eax,var1      ; 왼쪽
mov ebx,5
mul ebx           ; EDX:EAX = 곱 (64비트라 오버플로 검사 불필요)
mov ebx,var2      ; 오른쪽
sub ebx,3
div ebx           ; 최종 나눗셈
mov var4,eax

; Example 3: var4 = (var1 * -5) / (-var2 % var3);  (signed 32-bit)
mov  eax,var2     ; 오른쪽부터
neg  eax
cdq               ; 피제수 부호 확장
idiv var3         ; EDX = 나머지
mov  ebx,edx      ; EBX = 오른쪽 값
mov  eax,-5       ; 왼쪽
imul var1         ; EDX:EAX = 왼쪽 값
idiv ebx          ; 최종 나눗셈
mov  var4,eax     ; 몫
```

- Example 3처럼 오른쪽 식을 먼저 계산해 EBX에 넣어두면, 왼쪽 곱을 EDX:EAX에 그대로 두고 바로 IDIV할 수 있다. 부호 있는 연산이므로 CDQ로 부호 확장하고 IDIV를 쓴다.

## 4. 확장 덧셈과 뺄셈 (Extended Addition and Subtraction, 7.4)
- 확장 정밀도 덧셈/뺄셈은 거의 무제한 크기의 수를 더하고 빼는 기법이다. C++에는 1024비트 정수를 더하는 표준 연산자가 없지만, 어셈블리에서는 ADC와 SBB로 쉽게 구현할 수 있다.

### 4.1 ADC 명령어 (ADC Instruction, 7.4.1)
- ADC(add with carry)는 소스 피연산자와 CF 값을 함께 목적지에 더한다. 형식은 ADD와 같고 두 피연산자 크기가 같아야 한다.
  - `ADC reg,reg` / `ADC mem,reg` / `ADC reg,mem` / `ADC mem,imm` / `ADC reg,imm`
- 하위 부분을 ADD로 더해 생긴 캐리를, 상위 부분을 ADC로 더할 때 반영하는 방식이다.

```
; FFh + FFh = 01FEh (DL:AL)
mov dl,0
mov al,0FFh
add al,0FFh       ; AL = FEh, CF = 1
adc dl,0          ; DL = 0 + 0 + CF = 01h → DL:AL = 01FEh

; FFFFFFFFh + FFFFFFFFh = 00000001FFFFFFFEh (EDX:EAX)
mov edx,0
mov eax,0FFFFFFFFh
add eax,0FFFFFFFFh
adc edx,0
```

### 4.2 확장 덧셈 예제 (Extended Addition Example, 7.4.2)
- Extended_Add는 같은 크기의 두 확장 정수를 병렬 배열처럼 루프로 더하며, 매 반복마다 이전 반복의 캐리를 포함한다.
  - ESI, EDI: 두 정수를 가리킴 / EBX: 합을 저장할 버퍼(피연산자보다 1바이트 길어야 함) / ECX: 더할 바이트 수
  - 수는 리틀 엔디언으로 저장되어 있어야 한다(최하위 바이트가 시작 주소).

```
;--------------------------------------------------------
Extended_Add PROC
;
; Calculates the sum of two extended integers stored
; as arrays of bytes.
; Receives: ESI and EDI point to the two integers,
; EBX points to a variable that will hold the sum,
; and ECX indicates the number of bytes to be added.
; Storage for the sum must be one byte longer than the
; input operands.
; Returns: nothing
;--------------------------------------------------------
    pushad
    clc                     ; CF = 0
L1: mov  al,[esi]           ; 첫 번째 정수 바이트
    adc  al,[edi]           ; 두 번째 정수 바이트 + CF
    pushfd                  ; CF 저장
    mov  [ebx],al           ; 부분합 저장
    add  esi,1              ; 세 포인터 모두 증가
    add  edi,1
    add  ebx,1
    popfd                   ; CF 복원
    loop L1                 ; 반복
    mov  byte ptr [ebx],0   ; 합의 최상위 바이트 클리어
    adc  byte ptr [ebx],0   ; 남은 캐리 더하기
    popad
    ret
Extended_Add ENDP
```

- 포인터를 증가시키는 ADD 명령이 CF를 바꾸므로, PUSHFD/POPFD로 CF를 저장·복원해야 한다. LOOP 명령은 플래그를 바꾸지 않는다.
- 루프가 끝난 뒤 최상위 바이트끼리 더할 때 생긴 캐리를 합의 여분 바이트에 넣는다.

```
.data
op1 BYTE 34h,12h,98h,74h,06h,0A4h,0B2h,0A2h
op2 BYTE 02h,45h,23h,00h,00h,87h,10h,80h
sum BYTE 9 dup(0)              ; 1바이트 여유
.code
main PROC
    mov  esi,OFFSET op1
    mov  edi,OFFSET op2
    mov  ebx,OFFSET sum
    mov  ecx,LENGTHOF op1
    call Extended_Add
    mov  esi,OFFSET sum        ; 합 출력
    mov  ecx,LENGTHOF sum
    call Display_Sum
    call Crlf
; 출력: 0122C32B0674BB5736 (캐리 발생)

Display_Sum PROC               ; 최상위 바이트부터 역순 출력
    pushad
    add  esi,ecx               ; 마지막 원소를 가리키게
    sub  esi,TYPE BYTE
    mov  ebx,TYPE BYTE
L1: mov  al,[esi]
    call WriteHexB
    sub  esi,TYPE BYTE         ; 이전 바이트
    loop L1
    popad
    ret
Display_Sum ENDP
```

### 4.3 SBB 명령어 (SBB Instruction, 7.4.3)
- SBB(subtract with borrow)는 소스 피연산자와 CF 값을 함께 목적지에서 뺀다. 피연산자 형식은 ADC와 같다.
- 하위 부분을 SUB로 빼서 빌림(borrow)이 생기면 CF = 1이 되고, 상위 부분을 SBB로 뺄 때 그 1을 추가로 뺀다.

```
; 64비트 값 0000000700000001h - 2
mov edx,7         ; 상위
mov eax,1         ; 하위
sub eax,2         ; EAX = FFFFFFFFh, CF = 1 (작은 수에서 큰 수를 빼서 빌림 발생)
sbb edx,0         ; EDX = 7 - 0 - 1 = 6
; 결과 EDX:EAX = 00000006FFFFFFFFh
```

## 5. ASCII와 언팩 십진 산술 (ASCII and Unpacked Decimal Arithmetic, 7.5)
- 7.5절의 명령어들은 32비트 모드에서만 쓸 수 있다.
- CPU는 이진수로 계산하지만, ASCII 십진 문자열에 대해서도 산술을 할 수 있다. 사용자가 입력한 문자열을 이진수로 변환하지 않고 바로 계산하고 출력할 수 있다.
- 예: 3402 + 1256 = 4658을 계산하는 두 방법
  - 방법 1: 두 수를 이진수로 변환 → 더함 → 결과를 ASCII 문자열로 변환
  - 방법 2: ASCII 숫자 쌍을 자리별로 바로 더함(2+6, 0+5, 4+2, 3+1). 결과가 ASCII 문자열이라 바로 출력 가능. 단, 자리마다 결과를 조정하는 특수 명령어가 필요하다.

| 명령어 | 의미 |
|---|---|
| AAA | ASCII adjust after addition |
| AAS | ASCII adjust after subtraction |
| AAM | ASCII adjust after multiplication |
| AAD | ASCII adjust before division |

- ASCII 십진수와 언팩(unpacked) 십진수는 둘 다 한 바이트에 한 자리를 저장한다. 차이는 상위 4비트다.
  - 언팩 십진수: 상위 4비트가 항상 0000
  - ASCII 십진수: 상위 4비트가 0011 (30h)

| 형식 | 3402 저장 (16진수) |
|---|---|
| ASCII | 33 34 30 32 |
| Unpacked | 03 04 00 02 |

- ASCII 산술은 이진 산술보다 느리지만 장점이 두 가지 있다.
  - 계산 전에 문자열 형식을 변환할 필요가 없다.
  - 가정된 소수점(assumed decimal point)을 쓰면 부동소수점의 반올림 오차 없이 실수 연산을 할 수 있다.
- 덧셈·뺄셈은 ASCII 형식과 언팩 형식 모두 가능하지만, 곱셈·나눗셈은 언팩 십진수만 가능하다.

### 5.1 AAA 명령어 (AAA Instruction, 7.5.1)
- AAA는 ADD/ADC의 이진 결과를 조정한다. AL에 두 ASCII 숫자를 더한 이진값이 있을 때, 이를 언팩 십진수 두 자리로 바꿔 AH(십의 자리/캐리)와 AL(일의 자리)에 저장한다.
- 언팩 형식이 되면 30h와 OR해서 쉽게 ASCII로 바꿀 수 있다.
- 덧셈 전에 AH를 0으로 클리어해야 한다. 안 그러면 AH 값이 AAA 결과에 영향을 준다.

```
mov ah,0
mov al,'8'        ; AX = 0038h
add al,'2'        ; AX = 006Ah
aaa               ; AX = 0100h (ASCII 조정 결과)
or  ax,3030h      ; AX = 3130h = '10' (ASCII 변환)
```

#### AAA를 이용한 여러 바이트 덧셈 (Multibyte Addition Using AAA)
- 가정된 소수점을 가진 ASCII 십진수 문자열을 더하는 프로그램이다. 각 자리 덧셈의 캐리를 다음 자리로 전달해야 해서 생각보다 복잡하다.
- 의사코드 (acc는 8비트 누산기):

```
esi (index) = length of first_number - 1
edi (index) = length of first_number
ecx = length of first_number
set carry value to 0
Loop
    acc = first_number[esi]
    add previous carry to acc
    save carry in carry1
    acc += second_number[esi]
    OR the carry with carry1
    sum[edi] = acc
    dec edi
Until ecx == 0
Store last carry digit in sum
```

- 캐리 숫자는 항상 ASCII로 변환해야 하고, 캐리를 첫 번째 피연산자에 더한 뒤에도 AAA로 조정해야 한다.

```
; ASCII Addition (ASCII_add.asm)
; Perform ASCII arithmetic on strings having
; an implied fixed decimal point.
INCLUDE Irvine32.inc
DECIMAL_OFFSET = 5                    ; 오른쪽에서 소수점까지 거리
.data
decimal_one BYTE "100123456789765"    ; 1001234567.89765
decimal_two BYTE "900402076502015"    ; 9004020765.02015
sum BYTE (SIZEOF decimal_one + 1) DUP(0),0
.code
main PROC
; 마지막 자리부터 시작
    mov esi,SIZEOF decimal_one - 1
    mov edi,SIZEOF decimal_one
    mov ecx,SIZEOF decimal_one
    mov bh,0                          ; 캐리 = 0
L1: mov ah,0                          ; 덧셈 전 AH 클리어
    mov al,decimal_one[esi]           ; 첫 번째 숫자
    add al,bh                         ; 이전 캐리 더함
    aaa                               ; 조정 (AH = 캐리)
    mov bh,ah                         ; 캐리를 carry1에 저장
    or  bh,30h                        ; ASCII로
    add al,decimal_two[esi]           ; 두 번째 숫자 더함
    aaa                               ; 조정 (AH = 캐리)
    or  bh,ah                         ; 캐리를 carry1과 OR
    or  bh,30h                        ; ASCII로
    or  al,30h                        ; AL을 ASCII로
    mov sum[edi],al                   ; 합에 저장
    dec esi                           ; 한 자리 앞으로
    dec edi
    loop L1
    mov sum[edi],bh                   ; 마지막 캐리 저장
; 합 출력
    mov edx,OFFSET sum
    call WriteString
    call Crlf
    exit
main ENDP
END main
; 출력 (소수점 없이): 1000525533291780
```

### 5.2 AAS 명령어 (AAS Instruction, 7.5.2)
- AAS는 SUB/SBB로 언팩 십진수끼리 뺀 결과(AL)를 ASCII 숫자 표현에 맞게 조정한다. 조정은 뺄셈 결과가 음수일 때만 필요하다.
- 결과가 음수면 AL을 올바른 자리 값으로 바꾸고 AH에서 1을 빼며 CF를 세트한다.

```
.data
val1 BYTE '8'
val2 BYTE '9'
.code
mov  ah,0
mov  al,val1      ; AX = 0038h
sub  al,val2      ; AX = 00FFh
aas               ; AX = FF09h (AL = 09h, AH = FFh, CF = 1)
pushf             ; CF 저장
or   al,30h       ; AX = FF39h
popf              ; CF 복원
```

### 5.3 AAM 명령어 (AAM Instruction, 7.5.3)
- AAM은 MUL이 만든 이진 곱을 언팩 십진수로 바꾼다. 곱셈은 언팩 십진수만 사용할 수 있다.

```
.data
AscVal BYTE 05h,06h
.code
mov bl,ascVal         ; 첫 번째 피연산자 (5)
mov al,[ascVal+1]     ; 두 번째 피연산자 (6)
mul bl                ; AX = 001Eh (30)
aam                   ; AX = 0300h (언팩 십진수 30)
```

### 5.4 AAD 명령어 (AAD Instruction, 7.5.4)
- AAD는 나눗셈 전에 AX의 언팩 십진 피제수를 이진수로 바꿔 DIV를 준비한다. 다른 조정 명령어와 달리 연산 "전에" 실행한다.

```
.data
quotient  BYTE ?
remainder BYTE ?
.code
mov ax,0307h          ; 피제수 (언팩 37)
aad                   ; AX = 0025h (이진 37)
mov bl,5              ; 제수
div bl                ; AX = 0207h → AL = 07h (몫), AH = 02h (나머지)
mov quotient,al
mov remainder,ah
```

## 6. 팩 십진 산술 (Packed Decimal Arithmetic, 7.6)
- 7.6절의 명령어들도 32비트 모드에서만 쓸 수 있다.
- 팩(packed) 십진수는 한 바이트에 십진수 두 자리를 저장한다. 각 자리는 4비트로 표현되고, 자리 수가 홀수면 최상위 니블을 0으로 채운다.

```
bcd1 QWORD 2345673928737285h   ; 2,345,673,928,737,285
bcd2 DWORD 12345678h           ; 12,345,678
bcd3 DWORD 08723654h           ; 8,723,654
bcd4 WORD  9345h               ; 9,345
bcd5 WORD  0237h               ; 237
bcd6 BYTE  34h                 ; 34
```

- 장점:
  - 거의 무제한의 유효 자리를 가질 수 있어 매우 정확한 계산이 가능하다.
  - ASCII와의 상호 변환이 비교적 간단하다.
- DAA와 DAS는 덧셈·뺄셈 결과를 조정한다. 곱셈·나눗셈용 조정 명령어는 없으므로, 그 경우엔 언팩 → 곱셈/나눗셈 → 다시 팩 해야 한다.

### 6.1 DAA 명령어 (DAA Instruction, 7.6.1)
- DAA는 ADD/ADC가 AL에 만든 이진 합을 팩 십진 형식으로 바꾼다. 내부 로직은 Intel Instruction Set Reference Manual에 있다.

```
mov al,35h
add al,48h        ; AL = 7Dh (이진 합)
daa               ; AL = 83h (35 + 48 = 83, 조정된 결과)
```

- 예제: 16비트 팩 십진수 두 개를 더해 팩 더블워드에 저장한다. 합은 피연산자보다 한 자리 더 큰 공간이 필요하다.

```
; Packed Decimal Example (AddPacked.asm)
; Demonstrate packed decimal addition.
INCLUDE Irvine32.inc
.data
packed_1 WORD 4536h
packed_2 WORD 7207h
sum      DWORD ?
.code
main PROC
; sum과 인덱스 초기화
    mov sum,0
    mov esi,0
; 하위 바이트 더하기
    mov al,BYTE PTR packed_1[esi]
    add al,BYTE PTR packed_2[esi]
    daa
    mov BYTE PTR sum[esi],al
; 상위 바이트 더하기 (캐리 포함)
    inc esi
    mov al,BYTE PTR packed_1[esi]
    adc al,BYTE PTR packed_2[esi]
    daa
    mov BYTE PTR sum[esi],al
; 마지막 캐리 더하기
    inc esi
    mov al,0
    adc al,0
    mov BYTE PTR sum[esi],al
; 합을 16진수로 출력
    mov eax,sum
    call WriteHex             ; 00011743 (4536 + 7207 = 11743)
    call Crlf
    exit
main ENDP
END main
```

- 반복되는 코드가 많으므로 루프로 바꾸면 임의 크기의 팩 십진수를 더하는 프로시저를 만들 수 있다.

### 6.2 DAS 명령어 (DAS Instruction, 7.6.2)
- DAS는 SUB/SBB가 AL에 만든 이진 결과를 팩 십진 형식으로 바꾼다.

```
mov bl,48h
mov al,85h
sub al,bl         ; AL = 3Dh
das               ; AL = 37h (85 - 48 = 37, 조정된 결과)
```

## 7. 챕터 요약 (Chapter Summary, 7.7)
- 시프트 명령어는 6장의 비트 연산 명령어와 함께 어셈블리 언어의 가장 특징적인 명령어다.
- SHL은 왼쪽으로 밀고 최하위 비트를 0으로 채운다. n비트 왼쪽 시프트는 2^n 곱셈이라 고속 곱셈에 쓰인다. SHR은 오른쪽으로 밀고 최상위 비트를 0으로 채우며, n비트 시프트는 2^n 나눗셈이다.
- SAL과 SAR은 부호 있는 수를 시프트하기 위한 산술 시프트 명령어다.
- ROL은 최상위 비트를 CF와 최하위 비트로, ROR은 최하위 비트를 CF와 최상위 비트로 복사하며 회전한다.
- RCL은 CF를 최하위 비트로 넣고 최상위 비트를 CF로 보내며, RCR은 CF를 최상위 비트로 넣고 최하위 비트를 CF로 보낸다.
- SHLD와 SHRD는 큰 정수의 비트 시프트에 특히 효과적이다.
- MUL은 8/16/32비트 피연산자를 AL/AX/EAX와 곱한다(64비트 모드에서는 RAX). IMUL은 부호 있는 곱셈으로 1·2·3-피연산자 형식이 있다.
- DIV는 8/16/32비트(64비트 모드에서는 64비트까지) 부호 없는 나눗셈, IDIV는 같은 피연산자 형식의 부호 있는 나눗셈이다.
- CBW는 AL → AH, CWD는 AX → DX, CDQ는 EAX → EDX로 부호 비트를 확장한다.
- ADC와 SBB로 임의 크기 정수의 확장 덧셈/뺄셈을 구현한다. ADC는 소스 + CF를, SBB는 소스 + CF를 목적지에서 뺀다.
- ASCII 십진수는 한 바이트에 한 자리를 ASCII 문자로 저장한다. AAA는 ADD/ADC 결과를, AAS는 SUB/SBB 결과를 ASCII 십진수로 조정한다.
- 언팩 십진수는 한 바이트에 한 자리를 이진값으로 저장한다. AAM은 MUL 결과를 언팩 십진수로, AAD는 DIV 전에 언팩 피제수를 이진수로 바꾼다.
- 팩 십진수는 한 바이트에 두 자리를 저장한다. DAA는 ADD/ADC 결과를, DAS는 SUB/SBB 결과를 팩 십진수로 조정한다.
- ASCII·언팩·팩 십진 조정 명령어(AAA, AAS, AAM, AAD, DAA, DAS)는 모두 32비트 모드에서만 사용 가능하다.
