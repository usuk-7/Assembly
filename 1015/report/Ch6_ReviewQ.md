# Ch6 Review Questions 풀이

## 6.10.1 Short Answer

**1.** What will be the value of BX after the following instructions execute?
```
mov   bx,0FFFFh
and   bx,6Bh
```
AND는 마스크의 1인 비트만 남긴다. → **BX = 006Bh**

**2.** What will be the value of BX after the following instructions execute?
```
mov   bx,91BAh
and   bx,92h
```
하위 바이트 BA(1011 1010) AND 92(1001 0010) = 1001 0010, 상위 바이트는 00. → **BX = 0092h**

**3.** What will be the value of BX after the following instructions execute?
```
mov   bx,0649Bh
or    bx,3Ah
```
하위 바이트 9B(1001 1011) OR 3A(0011 1010) = 1011 1011(BB), 상위 바이트 64는 그대로. → **BX = 64BBh**

**4.** What will be the value of BX after the following instructions execute?
```
mov   bx,029D6h
xor   bx,8181h
```
29 XOR 81 = A8, D6 XOR 81 = 57. → **BX = A857h**

**5.** What will be the value of EBX after the following instructions execute?
```
mov   ebx,0AFAF649Bh
or    ebx,3A219604h
```
바이트별 OR: AF|3A=BF, AF|21=AF, 64|96=F6, 9B|04=9F. → **EBX = BFAFF69Fh**

**6.** What will be the value of RBX after the following instructions execute?
```
mov   rbx,0AFAF649Bh
xor   rbx,0FFFFFFFFh
```
교재 6.2.10 규칙: 소스가 32비트 상수면 목적지의 하위 32비트만 영향을 받는다. 상위 32비트는 0 그대로. AFAF649B XOR FFFFFFFF = 50509B64. → **RBX = 0000000050509B64h**

**7.** In the following instruction sequence, show the resulting value of AL where indicated, in binary:
```
mov   al,01101111b
and   al,00101101b                        ; a.
mov   al,6Dh
and   al,4Ah                              ; b.
mov   al,00001111b
or    al,61h                              ; c.
mov   al,94h
xor   al,37h                              ; d.
```
a. 01101111 AND 00101101 → **00101101b**
b. 6Dh(01101101) AND 4Ah(01001010) → **01001000b**
c. 00001111 OR 61h(01100001) → **01101111b**
d. 94h(10010100) XOR 37h(00110111) → **10100011b**

**8.** In the following instruction sequence, show the resulting value of AL where indicated, in hexadecimal:
```
mov   al,7Ah
not   al                                  ; a.
mov   al,3Dh
and   al,74h                              ; b.
mov   al,9Bh
or    al,35h                              ; c.
mov   al,72h
xor   al,0DCh                             ; d.
```
a. NOT 7Ah → **85h**
b. 3Dh AND 74h → **34h**
c. 9Bh OR 35h → **BFh**
d. 72h XOR DCh → **AEh**

**9.** In the following instruction sequence, show the values of the Carry, Zero, and Sign flags where indicated:
```
mov al,00001111b
test al,00000010b                          ; a. CF=        ZF=     SF=
mov al,00000110b
cmp al,00000101b                           ; b. CF=        ZF=     SF=
mov al,00000101b
cmp al,00000111b                           ; c. CF=        ZF=     SF=
```
a. TEST 결과 00000010(0이 아님), CF는 항상 0 → **CF=0, ZF=0, SF=0**
b. 6 − 5 = 1 → **CF=0, ZF=0, SF=0**
c. 5 − 7 = −2(빌림 발생, 최상위 비트 1) → **CF=1, ZF=0, SF=1**

**10.** Which conditional jump instruction executes a branch based on the contents of ECX?
→ **JECXZ** (ECX = 0이면 점프. CX는 JCXZ, RCX는 JRCXZ)

**11.** How are JA and JNBE affected by the Zero and Carry flags?
JA와 JNBE는 같은 명령이다. → **CF = 0 그리고 ZF = 0일 때 점프**

**12.** What will be the final value in EDX after this code executes?
```
mov   edx,1
mov   eax,7FFFh
cmp   eax,8000h
jl    L1
mov   edx,0
L1:
```
32비트 부호 있는 비교로 7FFFh(32767) < 8000h(32768)이라 JL이 점프한다. → **EDX = 1**

**13.** What will be the final value in EDX after this code executes?
```
mov   edx,1
mov   eax,7FFFh
cmp   eax,8000h
jb    L1
mov   edx,0
L1:
```
부호 없는 비교로 7FFFh < 8000h라 JB가 점프한다. → **EDX = 1**

**14.** What will be the final value in EDX after this code executes?
```
mov   edx,1
mov   eax,7FFFh
cmp   eax,0FFFF8000h
jl    L2
mov   edx,0
L2:
```
0FFFF8000h는 부호 있는 값으로 −32768이다. 32767 < −32768은 거짓이라 점프하지 않는다. → **EDX = 0**

**15.** (True/False): The following code will jump to the label named Target.
```
mov    eax,-30
cmp    eax,-50
jg     Target
```
부호 있는 비교로 −30 > −50이다. → **True**

**16.** (True/False): The following code will jump to the label named Target.
```
mov    eax,-42
cmp    eax,26
ja     Target
```
JA는 부호 없는 비교이고 −42는 FFFFFFD6h로 매우 큰 수라 26보다 크다. → **True**

**17.** What will be the value of RBX after the following instructions execute?
```
mov    rbx,0FFFFFFFFFFFFFFFFh
and    rbx,80h
```
→ **RBX = 0000000000000080h**

**18.** What will be the value of RBX after the following instructions execute?
```
mov    rbx,0FFFFFFFFFFFFFFFFh
and    rbx,808080h
```
→ **RBX = 0000000000808080h**

**19.** What will be the value of RBX after the following instructions execute?
```
mov    rbx,0FFFFFFFFFFFFFFFFh
and    rbx,80808080h
```
32비트 상수이므로 하위 32비트만 영향을 받고 상위 32비트는 그대로. → **RBX = FFFFFFFF80808080h**

## 6.10.2 Algorithm Workbench

**1.** Write a single instruction that converts an ASCII digit in AL to its corresponding binary value. If AL already contains a binary value (00h to 09h), leave it unchanged.
ASCII '0'~'9'는 30h~39h이므로 상위 니블만 지우면 된다. 00h~09h는 이미 상위 니블이 0이라 변하지 않는다.
→ `and al,0Fh`

**2.** Write instructions that calculate the parity of a 32-bit memory operand. Hint: Use the formula presented earlier in this section: B0 XOR B1 XOR B2 XOR B3.
```
.data
val32 DWORD ?
.code
    mov al,BYTE PTR val32        ; B0
    xor al,BYTE PTR val32+1      ; B1
    xor al,BYTE PTR val32+2      ; B2
    xor al,BYTE PTR val32+3      ; B3 (마지막 XOR의 PF가 전체 패리티)
```
→ 마지막 XOR 뒤 **PF = 1이면 짝수 패리티, PF = 0이면 홀수 패리티** (JP / JNP로 분기)

**3.** Given two bit-mapped sets named SetX and SetY, write a sequence of instructions that generate a bit string in EAX that represents members in SetX that are not members of SetY.
SetX AND (NOT SetY) 이다.
```
mov eax,SetY
not eax              ; SetY의 여집합
and eax,SetX         ; SetX에만 있는 원소
```

**4.** Write instructions that jump to label L1 when the unsigned integer in DX is less than or equal to the integer in CX.
```
cmp dx,cx
jbe L1               ; 부호 없는 비교이므로 JBE
```

**5.** Write instructions that jump to label L2 when the signed integer in AX is greater than the integer in CX.
```
cmp ax,cx
jg  L2               ; 부호 있는 비교이므로 JG
```

**6.** Write instructions that first clear bits 0 and 1 in AL. Then, if the destination operand is equal to zero, the code should jump to label L3. Otherwise, it should jump to label L4.
```
and al,11111100b     ; 비트 0, 1 clear (ZF 갱신)
jz  L3               ; 결과가 0이면 L3
jmp L4               ; 아니면 L4
```

**7.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that val1 and X are 32-bit variables.
```
if( val1 > ecx ) AND ( ecx > edx )
   X = 1
else
   X = 2;
```
부호 있는 정수라고 가정했다(부호 없는 경우 JLE → JBE로 바꾼다).
```
    mov eax,val1
    cmp eax,ecx          ; val1 > ecx ?
    jle ELSE_PART        ; 거짓이면 바로 else
    cmp ecx,edx          ; ecx > edx ?
    jle ELSE_PART
    mov X,1              ; 둘 다 참
    jmp NEXT
ELSE_PART:
    mov X,2
NEXT:
```

**8.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.
```
if( ebx > ecx ) OR ( ebx > val1 )
   X = 1
else
   X = 2
```
부호 있는 정수라고 가정했다.
```
    cmp ebx,ecx          ; ebx > ecx ?
    jg  THEN_PART        ; 참이면 둘째 식은 검사하지 않음
    cmp ebx,val1         ; ebx > val1 ?
    jle ELSE_PART
THEN_PART:
    mov X,1
    jmp NEXT
ELSE_PART:
    mov X,2
NEXT:
```

**9.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.
```
if( ebx > ecx AND ebx > edx) OR ( edx > eax )
   X = 1
else
   X = 2
```
부호 있는 정수라고 가정했다.
```
    cmp ebx,ecx          ; ebx > ecx ?
    jle CHECK_OR         ; AND의 앞 항이 거짓이면 OR의 뒤 항으로
    cmp ebx,edx          ; ebx > edx ?
    jg  THEN_PART        ; AND가 참이므로 전체 참
CHECK_OR:
    cmp edx,eax          ; edx > eax ?
    jle ELSE_PART
THEN_PART:
    mov X,1
    jmp NEXT
ELSE_PART:
    mov X,2
NEXT:
```

**10.** Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that A, B, and N are 32-bit signed integers.
```
while N > 0
  if N != 3 AND (N < A OR N > B)
       N = N – 2
  else
     N = N – 1
end whle
```
```
BEGINWHILE:
    cmp N,0
    jle ENDWHILE         ; N > 0이 거짓이면 루프 탈출
    cmp N,3
    je  ELSE_PART        ; N != 3이 거짓이면 else
    mov eax,N
    cmp eax,A
    jl  THEN_PART        ; N < A 이면 참 (OR 단락 평가)
    cmp eax,B
    jg  THEN_PART        ; N > B 이면 참
    jmp ELSE_PART
THEN_PART:
    sub N,2              ; N = N - 2
    jmp BEGINWHILE
ELSE_PART:
    dec N                ; N = N - 1
    jmp BEGINWHILE
ENDWHILE:
```
