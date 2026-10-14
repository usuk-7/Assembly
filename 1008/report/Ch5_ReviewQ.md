# Ch5 Review Questions 풀이

## 5.8.1 Short Answer

**1.** Which instruction pushes all of the 32-bit general-purpose registers on the stack?
→ **PUSHAD**

**2.** Which instruction pushes the 32-bit EFLAGS register on the stack?
→ **PUSHFD**

**3.** Which instruction pops the stack into the EFLAGS register?
→ **POPFD**

**4.** *Challenge:* Another assembler (called NASM) permits the PUSH instruction to list multiple specific registers. Why might this approach be better than the PUSHAD instruction in MASM? Here is a NASM example: `PUSH EAX EBX ECX`
PUSHAD는 8개 레지스터를 무조건 다 넣음(32바이트).
→ **필요한 레지스터만 골라 넣으니 스택 공간·시간 절약. 반환값 담을 EAX 같은 레지스터를 덮어쓰지 않게 뺄 수도 있음.**

**5.** *Challenge:* Suppose there were no PUSH instruction. Write a sequence of two other instructions that would accomplish the same as push eax.
```asm
sub esp,4          ; 스택 포인터를 4바이트 내림
mov [esp],eax      ; 그 자리에 EAX 저장
```

**6.** *(True/False):* The RET instruction pops the top of the stack into the instruction pointer.
→ **True**

**7.** *(True/False):* Nested procedure calls are not permitted by the Microsoft assembler unless the NESTED operator is used in the procedure definition.
→ **False** (NESTED 연산자 없음. 중첩 호출은 그냥 됨)

**8.** *(True/False):* In protected mode, each procedure call uses a minimum of 4 bytes of stack space.
→ **True** (CALL이 32비트 반환 주소를 push)

**9.** *(True/False):* The ESI and EDI registers cannot be used when passing 32-bit parameters to procedures.
→ **False** (ArraySum도 ESI로 전달함)

**10.** *(True/False):* The ArraySum procedure (Section 5.2.5) receives a pointer to any array of doublewords.
→ **True** (ESI = 배열 주소, ECX = 개수)

**11.** *(True/False):* The USES operator lets you name all registers that are modified within a procedure.
→ **True**

**12.** *(True/False):* The USES operator only generates PUSH instructions, so you must code POP instructions yourself.
→ **False** (RET 앞에 POP도 자동 생성)

**13.** *(True/False):* The register list in the USES directive must use commas to separate the register names.
→ **False** (공백/탭으로 구분. 콤마 쓰면 오류)

**14.** Which statement(s) in the ArraySum procedure (Section 5.2.5) would have to be modified so it could accumulate an array of 16-bit words? Create such a version of ArraySum and test it.
바꿀 곳 → **`add eax,[esi]`** 와 **`add esi,TYPE DWORD`** 두 줄.
16비트 값을 32비트로 0확장해 더하고, 포인터는 2씩 증가.
```asm
INCLUDE Irvine32.inc
.data
array WORD 1000h,2000h,3000h,4000h
.code
main PROC
    mov  esi,OFFSET array
    mov  ecx,LENGTHOF array
    call ArraySumW
    call WriteHex            ; 0000A000
    call Crlf
    exit
main ENDP

;---------------------------------------
; ArraySumW: 16비트 WORD 배열의 합
; Receives: ESI = 배열 주소, ECX = 원소 개수
; Returns:  EAX = 합
;---------------------------------------
ArraySumW PROC USES esi ecx edx
    mov  eax,0
L1: movzx edx,WORD PTR [esi]  ; 바뀐 줄: WORD를 32비트로 확장
    add  eax,edx
    add  esi,TYPE WORD        ; 바뀐 줄: 2바이트씩 이동
    loop L1
    ret
ArraySumW ENDP
END main
```

**15.** What will be the final value in EAX after these instructions execute?
`push 5 / push 6 / pop eax / pop eax`
첫 pop → 6, 두 번째 pop → 5.
→ **EAX = 5**

**16.** Which statement is true about what will happen when the example code runs? (main: push 10, push 20, call Ex2Sub, pop eax / Ex2Sub: pop eax, ret)
a. EAX will equal 10 on line 6
b. The program will halt with a runtime error on Line 10
c. EAX will equal 20 on line 6
d. The program will halt with a runtime error on Line 11
Line 10의 pop이 반환 주소를 꺼냄. RET은 20을 주소로 보고 점프.
→ **d**

**17.** Which statement is true about what will happen when the example code runs? (main: mov eax,30, push eax, push 40, call Ex3Sub / Ex3Sub: pusha, mov eax,80, popa, ret)
a. EAX will equal 40 on line 6
b. The program will halt with a runtime error on Line 6
c. EAX will equal 30 on line 6
d. The program will halt with a runtime error on Line 13
pusha/popa는 짝이 맞아 스택 균형 유지 → RET이 정상 반환 주소로 감. popa가 AX를 30으로 복원(상위 16비트는 mov eax,80 때 이미 0).
→ **c** (EAX = 30 on line 6)

**18.** Which statement is true about what will happen when the example code runs? (main: mov eax,40, push offset Here, jmp Ex4Sub, Here: mov eax,30 / Ex4Sub: ret)
a. EAX will equal 30 on line 7
b. The program will halt with a runtime error on Line 4
c. EAX will equal 30 on line 6
d. The program will halt with a runtime error on Line 11
Here 주소를 직접 push 후 jmp → RET이 Here로 돌아감 → line 6 실행 후 line 7에서 EAX=30.
→ **a**

**19.** Which statement is true about what will happen when the example code runs? (main: mov edx,0, mov eax,40, push eax, call Ex5Sub / Ex5Sub: pop eax, pop edx, push eax, ret)
a. EDX will equal 40 on line 6
b. The program will halt with a runtime error on Line 13
c. EDX will equal 0 on line 6
d. The program will halt with a runtime error on Line 11
pop eax = 반환 주소, pop edx = 40, push eax로 반환 주소 복구 → 정상 반환.
→ **a**

**20.** What values will be written to the array when the following code executes?
호출 순서: main → proc_1 → proc_2 → proc_3. 가장 안쪽부터 기록됨.
proc_3: array[0]=10 → proc_2: array[4]=20 → proc_1: array[8]=30 → main: array[12]=40
→ **array = 10, 20, 30, 40**

## 5.8.2 Algorithm Workbench

**1.** Write a sequence of statements that use only PUSH and POP instructions to exchange the values in the EAX and EBX registers (or RAX and RBX in 64-bit mode).
```asm
push eax
push ebx
pop  eax      ; EAX ← 원래 EBX
pop  ebx      ; EBX ← 원래 EAX
```

**2.** Suppose you wanted a subroutine to return to an address that was 3 bytes higher in memory than the return address currently on the stack. Write a sequence of instructions that would be inserted just before the subroutine's RET instruction that accomplish this task.
```asm
add DWORD PTR [esp],3    ; 스택 맨 위 반환 주소 +3
ret
```

**3.** Functions in high-level languages often declare local variables just below the return address on the stack. Write an instruction that you could put at the beginning of an assembly language subroutine that would reserve space for two integer doubleword variables. Then, assign the values 1000h and 2000h to the two local variables.
```asm
sub esp,8                      ; DWORD 2개 공간 확보
mov DWORD PTR [esp],1000h      ; 지역변수 1
mov DWORD PTR [esp+4],2000h    ; 지역변수 2
; ... RET 전에 add esp,8 로 해제
```

**4.** Write a sequence of statements using indexed addressing that copies an element in a doubleword array to the previous position in the same array.
```asm
mov esi,index                  ; 복사할 원소 인덱스 (1 이상)
mov eax,array[esi*4]           ; array[i]
mov array[esi*4-4],eax         ; → array[i-1]
```

**5.** Write a sequence of statements that display a subroutine's return address. Be sure that whatever modifications you make to the stack do not prevent the subroutine from returning to its caller.
```asm
MySub PROC
    push eax
    mov  eax,[esp+4]    ; push eax 때문에 반환 주소는 ESP+4
    call WriteHex
    call Crlf
    pop  eax            ; 스택 원상복구
    ret
MySub ENDP
```
