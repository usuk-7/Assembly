# Ch7 Review Questions 풀이

## 7.9.1 Short Answer

**1.** In the following code sequence, show the value of AL after each shift or rotate instruction has executed:
```
mov al,0D4h
shr al,1    ; a.
mov al,0D4h
sar al,1    ; b.
mov al,0D4h
sar al,4    ; c.
mov al,0D4h
rol al,1    ; d.
```
D4h = 11010100b
a. 01101010b → **AL = 6Ah**
b. 11101010b (부호 비트 복제) → **AL = EAh**
c. 11111101b → **AL = FDh**
d. 10101001b (MSB 1이 LSB로) → **AL = A9h**

**2.** In the following code sequence, show the value of AL after each shift or rotate instruction has executed:
```
mov al,0D4h
ror al,3    ; a.
mov al,0D4h
rol al,7    ; b.
stc
mov al,0D4h
rcl al,1    ; c.
stc
mov al,0D4h
rcr al,3    ; d.
```
a. 하위 3비트 100이 위로 → 10011010b → **AL = 9Ah**
b. ROL 7 = ROR 1 → 01101010b → **AL = 6Ah**
c. CF(1)이 LSB로, MSB(1)이 CF로 → 10101001b → **AL = A9h, CF = 1**
d. 11101010(CF=0) → 01110101(CF=0) → 00111010(CF=1) → **AL = 3Ah, CF = 1**

**3.** What will be the contents of AX and DX after the following operation?
```
mov dx,0
mov ax,222h
mov cx,100h
mul cx
```
222h × 100h = 00022200h → **DX = 0002h, AX = 2200h**

**4.** What will be the contents of AX after the following operation?
```
mov ax,63h
mov bl,10h
div bl
```
63h / 10h = 6 나머지 3 → AL = 06h, AH = 03h → **AX = 0306h**

**5.** What will be the contents of EAX and EDX after the following operation?
```
mov eax,123400h
mov edx,0
mov ebx,10h
div ebx
```
**EAX = 00012340h, EDX = 00000000h**

**6.** What will be the contents of AX and DX after the following operation?
```
mov ax,4000h
mov dx,500h
mov bx,10h
div bx
```
피제수 DX:AX = 05004000h, 몫 = 00500400h → 16비트 AX에 안 들어감 → **divide overflow 발생 (프로세서 예외로 프로그램 중단, AX/DX에 결과 저장 안 됨)**

**7.** What will be the contents of BX after the following instructions execute?
```
mov bx,5
stc
mov ax,60h
adc bx,ax
```
5 + 60h + CF(1) → **BX = 0066h**

**8.** Describe the output when the following code executes in 64-bit mode:
```
.data
dividend_hi QWORD 00000108h
dividend_lo QWORD 33300020h
divisor QWORD 00000100h
.code
mov rdx,dividend_hi
mov rax,dividend_lo
div divisor
```
RDX:RAX = 0000000000000108 0000000033300020h, 100h로 나누면 16진수 2자리 오른쪽 이동 → 몫 = 1 0800000000333000h (65비트).
→ **몫이 RAX(64비트)에 안 들어가므로 divide overflow 예외 발생.** (나머지는 20h이 될 것이지만 저장되지 않음)

**9.** The following program is supposed to subtract val2 from val1. Find and correct all logic errors (CLC clears the Carry flag):
```
.data
val1 QWORD 20403004362047A1h
val2 QWORD 055210304A2630B2h
result QWORD 0
.code
mov cx,8            ; loop counter
mov esi,val1        ; set index to start
mov edi,val2
clc                 ; clear Carry flag
top:
mov al,BYTE PTR[esi]  ; get first number
sbb al,BYTE PTR[edi]  ; subtract second
mov BYTE PTR[esi],al  ; store the result
dec esi
dec edi
loop top
```
오류:
- `mov cx,8` → LOOP는 32비트 모드에서 ECX를 쓰므로 **`mov ecx,8`**
- `mov esi,val1`, `mov edi,val2` → 값이 아니라 주소가 필요 → **`OFFSET val1`, `OFFSET val2`**
- 리틀 엔디언이라 최하위 바이트가 시작 주소에 있음 → 낮은 주소부터 올라가야 함 → **`dec` → `inc`**
- 결과를 val1에 덮어씀 → **result에 저장**
```
mov ecx,8
mov esi,OFFSET val1
mov edi,OFFSET val2
mov ebx,OFFSET result
clc
top:
mov al,BYTE PTR [esi]
sbb al,BYTE PTR [edi]
mov BYTE PTR [ebx],al
inc esi            ; INC는 CF를 바꾸지 않음
inc edi
inc ebx
loop top
```

**10.** What will be the hexadecimal contents of RAX after the following instructions execute in 64-bit mode?
```
.data
multiplicand QWORD 0001020304050000h
.code
imul rax,multiplicand, 4
```
0001020304050000h × 4 → **RAX = 0004080C10140000h**

## 7.9.2 Algorithm Workbench

**1.** Write a sequence of shift instructions that cause AX to be sign-extended into EAX. In other words, the sign bit of AX is copied into the upper 16 bits of EAX. Do not use the CWD instruction.
```
shl eax,16
sar eax,16
```

**2.** Suppose the instruction set contained no rotate instructions. Show how you would use SHR and a conditional jump instruction to rotate the contents of the AL register 1 bit to the right.
```
    shr al,1        ; LSB → CF, MSB = 0
    jnc next        ; 밀려난 비트가 0이면 그대로
    or  al,80h      ; 1이면 MSB에 1 넣기
next:
```

**3.** Write a logical shift instruction that multiplies the contents of EAX by 16.
→ **`shl eax,4`**

**4.** Write a logical shift instruction that divides EBX by 4.
→ **`shr ebx,2`**

**5.** Write a single rotate instruction that exchanges the high and low halves of the DL register.
→ **`rol dl,4`** (ror dl,4도 가능)

**6.** Write a single SHLD instruction that shifts the highest bit of the AX register into the lowest bit position of DX and shifts DX one bit to the left.
→ **`shld dx,ax,1`**

**7.** Write a sequence of instructions that shift three memory bytes to the right by 1 bit position. Use the following test data:
`byteArray BYTE 81h,20h,33h`
최상위 바이트(byteArray+2)부터 SHR, 나머지는 RCR로 CF를 이어받음.
```
shr byteArray+2,1   ; 33h → 19h, CF = 1
rcr byteArray+1,1   ; 20h → 90h, CF = 0
rcr byteArray,1     ; 81h → 40h, CF = 1
```
→ **결과: 40h, 90h, 19h** (332081h >> 1 = 199040h)

**8.** Write a sequence of instructions that shift three memory words to the left by 1 bit position. Use the following test data:
`wordArray WORD 810Dh, 0C064h,93ABh`
왼쪽 시프트는 최하위 워드부터 SHL, 나머지는 RCL.
```
shl wordArray,1     ; 810Dh → 021Ah, CF = 1
rcl wordArray+2,1   ; C064h → 80C9h, CF = 1
rcl wordArray+4,1   ; 93ABh → 2757h, CF = 1
```
→ **결과: 021Ah, 80C9h, 2757h** (CF = 1)

**9.** Write instructions that multiply −5 by 3 and store the result in a 16-bit variable val1.
```
mov  ax,-5
mov  bx,3
imul bx             ; DX:AX = -15
mov  val1,ax        ; val1 = -15 (FFF1h)
```

**10.** Write instructions that divide −276 by 10 and store the result in a 16-bit variable val1.
```
mov  ax,-276
cwd                 ; AX → DX 부호 확장
mov  bx,10
idiv bx             ; AX = -27, DX = -6
mov  val1,ax        ; val1 = -27
```

**11.** Implement the following C++ expression in assembly language, using 32-bit unsigned operands:
`val1 = (val2 * val3) / (val4 - 3)`
```
mov eax,val2
mul val3            ; EDX:EAX = val2 * val3
mov ebx,val4
sub ebx,3           ; EBX = val4 - 3
div ebx             ; EAX = 몫
mov val1,eax
```

**12.** Implement the following C++ expression in assembly language, using 32-bit signed operands:
`val1 = (val2 / val3) * (val1 + val2)`
```
mov  eax,val2
cdq                 ; 부호 확장
idiv val3           ; EAX = val2 / val3
mov  ebx,val1
add  ebx,val2       ; EBX = val1 + val2
imul ebx            ; EDX:EAX = EAX * EBX
mov  val1,eax
```

**13.** Write a procedure that displays an unsigned 8-bit binary value in decimal format. Pass the binary value in AL. The input range is limited to 0 to 99, decimal. The only procedure you can call from the book's link library is WriteChar. The procedure should contain approximately eight instructions. Here is a sample call:
```
mov al,65    ; range limit: 0 to 99
call showDecimal8
```
AAM으로 AL을 AH(십의 자리), AL(일의 자리)로 분리.
```
showDecimal8 PROC
    aam             ; AH = AL / 10, AL = AL % 10
    or   ax,3030h   ; 두 자리를 ASCII로
    push eax
    mov  al,ah      ; 십의 자리
    call WriteChar
    pop  eax        ; 일의 자리
    call WriteChar
    ret
showDecimal8 ENDP
```
→ 65 입력 시 **"65"** 출력

**14.** Challenge: Suppose AX contains 0072h and the Auxiliary Carry flag is set as a result of adding two unknown ASCII decimal digits. Use the Intel 64 and IA-32 Instruction Set Reference to determine what output the AAA instruction would produce. Explain your answer.
Intel 규칙: (AL AND 0Fh) > 9 또는 AF = 1이면 AL = AL + 6, AH = AH + 1, AF = CF = 1. 마지막에 AL = AL AND 0Fh.
AL 하위 니블은 2(≤ 9)지만 AF = 1 → AL = 72h + 6 = 78h, AH = 01h → AL AND 0Fh = 08h.
→ **AX = 0108h, CF = AF = 1.** 즉 '9' + '9' (39h + 39h = 72h, 하위 니블에서 캐리 발생) = 18을 의미함.

**15.** Challenge: Using only SUB, MOV, and AND instructions, show how to calculate x = n mod y, assuming that you are given the values of n and y. You can assume that n is any 32-bit unsigned integer, and y is a power of 2.
y가 2^k이면 y − 1은 하위 k비트가 모두 1인 마스크 → n AND (y − 1) = n mod y.
```
mov eax,n
mov ebx,y
sub ebx,1           ; 마스크 = y - 1
and eax,ebx         ; n mod y
mov x,eax
```

**16.** Challenge: Using only SAR, ADD, and XOR instructions (but no conditional jumps), write code that calculates the absolute value of the signed integer in the EAX register. Hints: A number can be negated by adding −1 to it and then forming its one's complement. Also, if you XOR an integer with all 1s, its 1s are reversed. On the other hand, if you XOR an integer with all zeros, the integer is unchanged.
EDX = 부호 마스크(양수면 0, 음수면 FFFFFFFFh). 음수면 (x − 1)의 1의 보수 = −x, 양수면 그대로.
```
xor edx,edx         ; EDX = 0
add edx,eax         ; EDX = EAX (MOV 없이 복사)
sar edx,31          ; EDX = 0 또는 FFFFFFFFh
add eax,edx         ; 음수면 EAX - 1
xor eax,edx         ; 음수면 비트 반전 → |EAX|
```
