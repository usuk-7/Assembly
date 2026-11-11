# Ch8 Review Questions 풀이

## 8.10.1 Short Answer

**1.** Which statements belong in a procedure's epilogue when the procedure has stack parameters and local variables?
저장한 레지스터 pop → `mov esp,ebp`(지역 변수 해제) → `pop ebp` → `ret n`(STDCALL이면 매개변수 바이트 수만큼 정리)
```
pop  edx            ; (저장한 레지스터가 있으면 복원)
mov  esp,ebp        ; remove locals
pop  ebp            ; restore EBP
ret  8              ; return + clean up parameters
```
→ **`mov esp,ebp` / `pop ebp` (= LEAVE) + `ret n`**

**2.** When a C function returns a 32-bit integer, where is the return value stored?
→ **EAX 레지스터**

**3.** How does a program using the STDCALL calling convention clean up the stack after a procedure call?
호출된 프로시저가 RET에 정수 피연산자를 붙여 복귀하면서 ESP에 그 값을 더한다.
→ **피호출자가 `ret n`(n = 매개변수 총 바이트 수)으로 정리**

**4.** How is the LEA instruction more powerful than the OFFSET operator?
OFFSET은 어셈블 시점에 알려진 주소(전역 변수)만 구할 수 있다. LEA는 실행 중에 계산되는 간접 피연산자의 주소도 구할 수 있다.
→ **`lea esi,[ebp-30]`처럼 스택 위 지역 변수·매개변수의 주소를 구할 수 있음** (`mov esi,OFFSET [ebp-30]`은 에러)

**5.** In the C++ example shown in Section 8.2.3, how much stack space is used by a variable of type int?
→ **4바이트** (스택 항목은 32비트 단위)

**6.** What advantages might the C calling convention have over the STDCALL calling convention?
호출자가 스택을 정리하므로 함수가 RET에 고정 상수를 넣을 필요가 없다.
→ **가변 개수 인자를 받는 함수(printf 등)를 만들 수 있음**

**7.** (True/False): When using the PROC directive, all parameters must be listed on the same line.
→ **False** (쉼표로 구분해 여러 줄에 나눠 쓸 수 있음)

**8.** (True/False): If you pass a variable containing the offset of an array of bytes to a procedure that expects a pointer to an array of words, the assembler will flag this as an error.
→ **False** (어셈블러는 포인터 타입을 검사하지 않음)

**9.** (True/False): If you pass an immediate value to a procedure that expects a reference parameter, you can generate a general-protection fault.
→ **True** (즉시값이 주소로 역참조되어 데이터 영역 밖을 접근함, 예: `INVOKE Sub2, 1000h`)

## 8.10.2 Algorithm Workbench

**1.** Here is a calling sequence for a procedure named AddThree that adds three doublewords (assume that the STDCALL calling convention is used):
```
push 10h
push 20h
push 30h
call AddThree
```
Draw a picture of the procedure's stack frame immediately after EBP has been pushed on the runtime stack.
`push ebp` 직후(아직 `mov ebp,esp` 전) 스택. `mov ebp,esp`를 하면 오른쪽 EBP 오프셋이 그대로 적용된다.

| 내용 | ESP 기준 | (mov ebp,esp 후) EBP 기준 |
|---|---|---|
| 10h | [ESP + 16] | [EBP + 16] |
| 20h | [ESP + 12] | [EBP + 12] |
| 30h | [ESP + 8] | [EBP + 8] |
| return address | [ESP + 4] | [EBP + 4] |
| saved EBP | [ESP] ← ESP | [EBP] ← EBP |

**2.** Create a procedure named AddThree that receives three integer parameters and calculates and returns their sum in the EAX register.
```
AddThree PROC
    push ebp
    mov  ebp,esp
    mov  eax,[ebp+8]        ; 첫 번째 매개변수 (마지막에 push된 값)
    add  eax,[ebp+12]       ; 두 번째
    add  eax,[ebp+16]       ; 세 번째
    pop  ebp
    ret  12                 ; STDCALL: 매개변수 3개 × 4바이트 정리
AddThree ENDP
```
→ 위 호출이면 **EAX = 30h + 20h + 10h = 60h**

**3.** Declare a local variable named pArray that is a pointer to an array of doublewords.
→ **`LOCAL pArray:PTR DWORD`**

**4.** Declare a local variable named buffer that is an array of 20 bytes.
→ **`LOCAL buffer[20]:BYTE`**

**5.** Declare a local variable named pwArray that points to a 16-bit unsigned integer.
→ **`LOCAL pwArray:PTR WORD`**

**6.** Declare a local variable named myByte that holds an 8-bit signed integer.
→ **`LOCAL myByte:SBYTE`**

**7.** Declare a local variable named myArray that is an array of 20 doublewords.
→ **`LOCAL myArray[20]:DWORD`**

**8.** Create a procedure named SetColor that receives two stack parameters: forecolor and backcolor, and calls the SetTextColor procedure from the Irvine32 library.
SetTextColor는 EAX = forecolor + backcolor × 16을 받는다.
```
SetColor PROC USES eax,
    forecolor:DWORD,
    backcolor:DWORD
    mov  eax,backcolor
    shl  eax,4              ; backcolor * 16
    add  eax,forecolor      ; + forecolor
    call SetTextColor
    ret                     ; PROC가 ret 8 생성
SetColor ENDP
```

**9.** Create a procedure named WriteColorChar that receives three stack parameters: char, forecolor, and backcolor. It displays a single character, using the color attributes specified in forecolor and backcolor.
```
WriteColorChar PROC USES eax,
    char:DWORD,
    forecolor:DWORD,
    backcolor:DWORD
    mov  eax,backcolor
    shl  eax,4
    add  eax,forecolor
    call SetTextColor       ; 색 설정
    mov  eax,char           ; AL = 문자
    call WriteChar          ; 문자 출력
    ret                     ; ret 12
WriteColorChar ENDP
```

**10.** Write a procedure named DumpMemory that encapsulates the DumpMem procedure in the Irvine32 library. Use declared parameters and the USES directive. The following is an example of how it should be called: INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array.
DumpMem은 ESI = 시작 주소, ECX = 개수, EBX = 원소 크기를 받는다.
```
DumpMemory PROC USES esi ecx ebx,
    address:DWORD,          ; 시작 주소
    itemCount:DWORD,        ; 원소 개수
    componentSize:DWORD     ; 원소 크기
    mov  esi,address
    mov  ecx,itemCount
    mov  ebx,componentSize
    call DumpMem
    ret
DumpMemory ENDP
```

**11.** Declare a procedure named MultArray that receives two pointers to arrays of doublewords, and a third parameter indicating the number of array elements. Also, create a PROTO declaration for this procedure.
```
MultArray PROTO,
    pArray1:PTR DWORD,
    pArray2:PTR DWORD,
    count:DWORD

MultArray PROC USES eax ecx edx esi edi,
    pArray1:PTR DWORD,
    pArray2:PTR DWORD,
    count:DWORD
    ; 예: pArray1[i] = pArray1[i] * pArray2[i]
    mov  esi,pArray1
    mov  edi,pArray2
    mov  ecx,count
    jecxz L2
L1: mov  eax,[esi]
    mul  DWORD PTR [edi]    ; EDX:EAX = EAX * [EDI]
    mov  [esi],eax
    add  esi,4
    add  edi,4
    loop L1
L2: ret
MultArray ENDP
```
