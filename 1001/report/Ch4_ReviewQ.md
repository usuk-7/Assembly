# Ch4 Review Questions 풀이

## 4.9.1 Short Answer

**1.** What will be the value in EDX after each of the lines marked (a) and (b) execute?
```asm
.data
one WORD 8002h
two WORD 4321h
.code
mov   edx,21348041h
movsx edx,one        ; (a)
movsx edx,two        ; (b)
```
(a) 8002h는 MSB=1(음수) → 상위 16비트를 1로 부호 확장 → **EDX = FFFF8002h**
(b) 4321h는 MSB=0(양수) → 상위 16비트를 0으로 채움 → **EDX = 00004321h**

**2.** What will be the value in EAX after the following lines execute?
```asm
mov eax,1002FFFFh
inc ax
```
AX = FFFFh + 1 = 0000h (AX만 바뀌고 상위 16비트는 그대로)
→ **EAX = 10020000h**

**3.** What will be the value in EAX after the following lines execute?
```asm
mov eax,30020000h
dec ax
```
AX = 0000h − 1 = FFFFh
→ **EAX = 3002FFFFh**

**4.** What will be the value in EAX after the following lines execute?
```asm
mov eax,1002FFFFh
neg ax
```
AX = FFFFh(−1) → NEG → 0001h
→ **EAX = 10020001h**

**5.** What will be the value of the Parity flag after the following lines execute?
```asm
mov al,1
add al,3
```
AL = 4 = 00000100b → 1의 개수 1개(홀수)
→ **PF = 0**

**6.** What will be the value of EAX and the Sign flag after the following lines execute?
```asm
mov eax,5
sub eax,6
```
5 − 6 = −1
→ **EAX = FFFFFFFFh, SF = 1**

**7.** In the following code, the value in AL is intended to be a signed byte. Explain how the Overflow flag helps, or does not help you, to determine whether the final value in AL falls within a valid signed range.
```asm
mov al,-1
add al,130
```
130은 부호 있는 바이트 범위(−128~+127)를 벗어나서 82h(= −126)로 저장된다. CPU는 −1 + (−126) = −127(81h)로 계산하므로 범위 안 → OF = 0.
실제로 의도한 값 −1 + 130 = 129는 범위 밖인데 OF가 이를 알려주지 못한다.
→ **AL = 81h, OF = 0 → 피연산자 자체가 범위를 벗어나면 OF는 도움이 안 됨**

**8.** What value will RAX contain after the following instruction executes?
```asm
mov rax,44445555h
```
32비트 즉시값은 64비트로 부호 확장됨(양수라 상위는 0)
→ **RAX = 0000000044445555h**

**9.** What value will RAX contain after the following instructions execute?
```asm
.data
dwordVal DWORD 84326732h
.code
mov rax,0FFFFFFFF00000000h
mov rax,dwordVal
```
`mov rax,dwordVal`은 크기 불일치(64비트 ↔ 32비트)로 어셈블 에러. 의도대로 32비트를 64비트 레지스터에 넣으려면 `mov eax,dwordVal`을 써야 하고, 32비트 레지스터에 쓰면 상위 32비트는 0으로 지워진다.
→ **크기 불일치 에러 / `mov eax,dwordVal`이면 RAX = 0000000084326732h**

**10.** What value will EAX contain after the following instructions execute?
```asm
.data
dVal DWORD 12345678h
.code
mov ax,3
mov WORD PTR dVal+2,ax
mov eax,dVal
```
리틀 엔디안이라 dVal+2는 상위 워드(1234h) 위치 → 0003h로 바뀜
→ **EAX = 00035678h**

**11.** What will EAX contain after the following instructions execute?
```asm
.data
dVal DWORD ?
.code
mov dVal,12345678h
mov ax,WORD PTR dVal+2
add ax,3
mov WORD PTR dVal,ax
mov eax,dVal
```
AX = 1234h(상위 워드) → +3 = 1237h → 하위 워드에 저장 → dVal = 12341237h
→ **EAX = 12341237h**

**12.** *(Yes/No):* Is it possible to set the Overflow flag if you add a positive integer to a negative integer?
부호가 다른 두 수의 합은 항상 범위 안에 있다.
→ **No**

**13.** *(Yes/No):* Will the Overflow flag be set if you add a negative integer to a negative integer and produce a positive result?
→ **Yes**

**14.** *(Yes/No):* Is it possible for the NEG instruction to set the Overflow flag?
예: `mov al,-128 / neg al` → +128은 표현 불가, 결과 80h 그대로 → OF = 1
→ **Yes**

**15.** *(Yes/No):* Is it possible for both the Sign and Zero flags to be set at the same time?
ZF=1이면 결과가 0이라 MSB도 0 → SF=0.
→ **No**

Use the following variable definitions for Questions 16–19:
```asm
.data
var1 SBYTE -4,-2,3,1
var2 WORD 1000h,2000h,3000h,4000h
var3 SWORD -16,-42
var4 DWORD 1,2,3,4,5
```

**16.** For each of the following statements, state whether or not the instruction is valid:
a. `mov ax,var1` → **Invalid** (16비트 ↔ 8비트 크기 불일치)
b. `mov ax,var2` → **Valid**
c. `mov eax,var3` → **Invalid** (32비트 ↔ 16비트 크기 불일치)
d. `mov var2,var3` → **Invalid** (메모리 → 메모리 직접 이동 불가)
e. `movzx ax,var2` → **Invalid** (MOVZX는 소스가 목적지보다 작아야 함)
f. `movzx var2,al` → **Invalid** (MOVZX 목적지는 레지스터만 가능)
g. `mov ds,ax` → **Valid**
h. `mov ds,1000h` → **Invalid** (세그먼트 레지스터에 즉시값 직접 이동 불가)

**17.** What will be the hexadecimal value of the destination operand after each of the following instructions execute in sequence?
a. `mov al,var1` → var1[0] = −4 → **AL = FCh**
b. `mov ah,[var1+3]` → var1[3] = 1 → **AH = 01h**

**18.** What will be the value of the destination operand after each of the following instructions execute in sequence?
a. `mov ax,var2` → **AX = 1000h**
b. `mov ax,[var2+4]` → 4바이트 = 워드 2개 뒤 → **AX = 3000h**
c. `mov ax,var3` → −16 → **AX = FFF0h**
d. `mov ax,[var3-2]` → var3 바로 앞 워드 = var2의 마지막 원소 → **AX = 4000h**

**19.** What will be the value of the destination operand after each of the following instructions execute in sequence?
a. `mov edx,var4` → **EDX = 00000001h**
b. `movzx edx,var2` → **EDX = 00001000h**
c. `mov edx,[var4+4]` → 두 번째 DWORD → **EDX = 00000002h**
d. `movsx edx,var1` → −4 부호 확장 → **EDX = FFFFFFFCh**

## 4.9.2 Algorithm Workbench

**1.** Write a sequence of MOV instructions that will exchange the upper and lower words in a doubleword variable named **three**.
```asm
mov ax,WORD PTR three        ; 하위 워드
mov dx,WORD PTR three+2      ; 상위 워드
mov WORD PTR three,dx
mov WORD PTR three+2,ax
```

**2.** Using the XCHG instruction no more than three times, reorder the values in four 8-bit registers from the order A,B,C,D to B,C,D,A.
AL=A, BL=B, CL=C, DL=D라 하면:
```asm
xchg al,bl     ; B,A,C,D
xchg bl,cl     ; B,C,A,D
xchg cl,dl     ; B,C,D,A
```

**3.** Transmitted messages often include a parity bit whose value is combined with a data byte to produce an even number of 1 bits. Suppose a message byte in the AL register contains 01110101. Show how you could use the Parity flag combined with an arithmetic instruction to determine if this message byte has even or odd parity.
값을 바꾸지 않는 산술 연산으로 플래그만 갱신한 뒤 PF 확인. 01110101은 1이 5개 → PF = 0(홀수).
```asm
mov al,01110101b
add al,0        ; AL 그대로, PF만 갱신
                ; PF=1 → 짝수 패리티, PF=0 → 홀수 패리티 (여기선 PF=0)
```
→ **PF = 0 → 홀수 패리티 → 패리티 비트를 1로 설정해야 함**

**4.** Write code using byte operands that adds two negative integers and causes the Overflow flag to be set.
```asm
mov al,-128
add al,-1       ; -129는 범위 밖 → AL=7Fh, OF=1
```

**5.** Write a sequence of two instructions that use addition to set the Zero and Carry flags at the same time.
```asm
mov al,0FFh
add al,1        ; AL=00h → ZF=1, CF=1
```

**6.** Write a sequence of two instructions that set the Carry flag using subtraction.
```asm
mov al,1
sub al,2        ; 작은 수 - 큰 수 → 빌림 발생 → CF=1
```

**7.** Implement the following arithmetic expression in assembly language: EAX = –val2 + 7 – val3 + val1. Assume that val1, val2, and val3 are 32-bit integer variables.
```asm
mov eax,val2
neg eax         ; -val2
add eax,7       ; -val2 + 7
sub eax,val3    ; -val2 + 7 - val3
add eax,val1    ; -val2 + 7 - val3 + val1
```

**8.** Write a loop that iterates through a doubleword array and calculates the sum of its elements using a scale factor with indexed addressing.
```asm
.data
arrayD DWORD 10,20,30,40,50
.code
mov eax,0                  ; 합계
mov esi,0                  ; 인덱스
mov ecx,LENGTHOF arrayD    ; 반복 횟수
L1:
    add eax,arrayD[esi*TYPE arrayD]   ; 스케일 팩터 4
    inc esi
    loop L1
```

**9.** Implement the following expression in assembly language: AX = (val2 + BX) –val4. Assume that val2 and val4 are 16-bit integer variables.
```asm
mov ax,val2
add ax,bx
sub ax,val4
```

**10.** Write a sequence of two instructions that set both the Carry and Overflow flags at the same time.
```asm
mov al,80h
add al,80h      ; 결과 00h, 자리올림 → CF=1, (-128)+(-128) 범위 초과 → OF=1
```

**11.** Write a sequence of instructions showing how the Zero flag could be used to indicate unsigned overflow after executing INC and DEC instructions.
INC/DEC는 CF를 바꾸지 않으므로 ZF로 판단한다.
```asm
mov al,0FFh
inc al          ; FFh → 00h로 넘침 → ZF=1 (INC 후 ZF=1이면 unsigned overflow)

mov al,1
dec al          ; AL=0 → ZF=1 (다음 DEC에서 00h → FFh로 넘친다는 신호)
dec al          ; AL=FFh (unsigned underflow)
```
→ **INC 후 ZF=1 → 넘침 발생 / DEC 후 ZF=1 → 다음 DEC에서 넘침**

Use the following data definitions for Questions 12–18:
```asm
.data
myBytes  BYTE 10h,20h,30h,40h
myWords  WORD 3 DUP(?),2000h
myString BYTE "ABCDE"
```

**12.** Insert a directive in the given data that aligns **myBytes** to an even-numbered address.
```asm
.data
ALIGN 2
myBytes BYTE 10h,20h,30h,40h
```

**13.** What will be the value of EAX after each of the following instructions execute?
a. `mov eax,TYPE myBytes` → **1**
b. `mov eax,LENGTHOF myBytes` → **4**
c. `mov eax,SIZEOF myBytes` → **4**
d. `mov eax,TYPE myWords` → **2**
e. `mov eax,LENGTHOF myWords` → **4**
f. `mov eax,SIZEOF myWords` → **8**
g. `mov eax,SIZEOF myString` → **5**

**14.** Write a single instruction that moves the first two bytes in **myBytes** to the DX register. The resulting value will be 2010h.
```asm
mov dx,WORD PTR myBytes
```

**15.** Write an instruction that moves the second byte in **myWords** to the AL register.
```asm
mov al,BYTE PTR myWords+1
```

**16.** Write an instruction that moves all four bytes in **myBytes** to the EAX register.
```asm
mov eax,DWORD PTR myBytes     ; EAX = 40302010h
```

**17.** Insert a LABEL directive in the given data that permits **myWords** to be moved directly to a 32-bit register.
```asm
myWordsD LABEL DWORD
myWords  WORD 3 DUP(?),2000h
...
mov eax,myWordsD
```

**18.** Insert a LABEL directive in the given data that permits **myBytes** to be moved directly to a 16-bit register.
```asm
myBytesW LABEL WORD
myBytes  BYTE 10h,20h,30h,40h
...
mov ax,myBytesW               ; AX = 2010h
```
