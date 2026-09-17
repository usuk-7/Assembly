# Ch3 Review Questions 풀이

## 3.9.1 Short Answer

**1.** Provide examples of three different instruction mnemonics.

명령어 니모닉(mnemonic)은 기계어 명령을 사람이 읽기 쉽게 표현한 이름이다.
→ **MOV, ADD, SUB** (예: MOV, ADD, SUB, CALL, JMP 등)

**2.** What is a calling convention, and how is it used in assembly language declarations?

호출 규약(calling convention)은 프로시저를 호출할 때 매개변수를 전달하는 방법, 순서, 스택 정리 책임 등을 정해놓은 규칙이다. PROTO, INVOKE 선언에서 매개변수 전달 방식과 스택 정리 주체를 결정하는 데 사용된다.
→ **매개변수 전달 방식과 스택 정리 규칙을 정의하는 약속**

**3.** How do you reserve space for the stack in a program?

`.STACK` 디렉티브에 예약할 바이트 수를 지정해 스택 공간을 확보한다.
→ **`.STACK` 디렉티브 사용 (예: `.STACK 400h`)**

**4.** Explain why the term *assembler language* is not quite correct.

프로그램을 작성하는 데 쓰는 언어는 "어셈블리 언어(assembly language)"이고, 그 언어를 기계어로 번역하는 프로그램이 "어셈블러(assembler)"다. "assembler language"라고 하면 번역기(어셈블러) 자체가 언어인 것처럼 잘못 표현하는 것이다.
→ **어셈블러는 번역 프로그램이고, 언어 이름은 assembly language이기 때문**

**5.** Explain the difference between big endian and little endian. Also, look up the origins of this term on the Web.

빅 엔디안은 최상위 바이트(MSB)를 가장 낮은 메모리 주소에 저장하고, 리틀 엔디안은 최하위 바이트(LSB)를 가장 낮은 메모리 주소에 저장한다. 용어의 유래는 조나단 스위프트의 소설 『걸리버 여행기』에서 달걀을 어느 쪽 끝(big end/little end)부터 깨야 하는지를 두고 다투는 이야기에서 따왔다.
→ **저장 순서 차이 + 유래는 걸리버 여행기의 달걀 깨는 방향 논쟁**

**6.** Why might you use a symbolic constant rather than an integer literal in your code?

기호 상수를 쓰면 값의 의미를 이름으로 알 수 있어 가독성이 좋아지고, 값을 바꿀 때 한 곳만 수정하면 되어 유지보수가 쉬워진다.
→ **가독성과 유지보수 편의성**

**7.** How is a source file different from a listing file?

소스 파일(.asm)은 프로그래머가 직접 작성하는 원본 코드이고, 리스팅 파일(.lst)은 어셈블러가 어셈블 과정에서 생성하는 파일로 주소, 기계어 바이트, 원본 소스 줄을 함께 보여준다.
→ **소스 파일은 원본 코드, 리스팅 파일은 어셈블러가 생성하는 참고용 결과물**

**8.** How are data labels and code labels different?

데이터 레이블은 메모리 상의 데이터 위치를 가리키며 콜론(:)이 붙지 않는다. 코드 레이블은 명령어 위치를 가리키며 반드시 콜론(:)이 붙는다.
→ **콜론 유무와 가리키는 대상(데이터 vs 명령어)이 다름**

**9.** *(True/False):* An identifier cannot begin with a numeric digit.

→ **True**

**10.** *(True/False):* A hexadecimal literal may be written as 0x3A.

MASM에서 16진수는 `3Ah`처럼 접미사 h를 붙여 표기한다. `0x3A`는 C 언어 표기법이다.
→ **False**

**11.** *(True/False):* Assembly language directives execute at runtime.

디렉티브는 실행 코드가 아니라 어셈블 시점(assemble time)에 어셈블러에게 지시를 내리는 명령이다.
→ **False**

**12.** *(True/False):* Assembly language directives can be written in any combination of uppercase and lowercase letters.

→ **True**

**13.** Name the four basic parts of an assembly language instruction.

→ **레이블(label), 니모닉(mnemonic), 피연산자(operand(s)), 주석(comment)**

**14.** *(True/False):* MOV is an example of an instruction mnemonic.

→ **True**

**15.** *(True/False):* A code label is followed by a colon (:), but a data label does not end with a colon.

→ **True**

**16.** Show an example of a block comment.

블록 주석은 `COMMENT` 디렉티브 뒤에 구분 문자를 지정하고, 같은 문자가 다시 나올 때까지의 모든 내용을 주석으로 처리한다.
```asm
COMMENT !
이 부분은 여러 줄에 걸친 블록 주석입니다.
프로그램 설명을 자유롭게 작성할 수 있습니다.
!
```
→ **`COMMENT` 디렉티브로 여러 줄을 한 번에 주석 처리**

**17.** Why is it not a good idea to use numeric addresses when writing instructions that access variables?

숫자 주소는 프로그램이나 데이터가 재배치되면 값이 바뀔 수 있어 이식성이 없고, 코드만 봐서는 어떤 데이터를 가리키는지 알기 어려워 가독성과 유지보수성이 떨어진다. 대신 기호(레이블) 이름을 사용해야 한다.
→ **주소는 재배치될 수 있고 가독성이 떨어지므로 기호 이름을 사용해야 함**

**18.** What type of argument must be passed to the ExitProcess procedure?

ExitProcess는 프로그램 종료 코드를 나타내는 32비트 부호 없는 정수(doubleword)를 인자로 받는다.
→ **32비트(doubleword) 정수 종료 코드**

**19.** Which directive ends a procedure?

→ **`ENDP`**

**20.** In 32-bit mode, what is the purpose of the identifier in the END directive?

END 디렉티브 뒤에 오는 식별자는 프로그램의 시작점(진입점, entry point)이 되는 프로시저 이름을 나타낸다.
→ **프로그램의 진입점(시작 프로시저 이름)을 지정**

**21.** What is the purpose of the PROTO directive?

PROTO는 프로시저를 실제로 정의하기 전에 이름, 매개변수 목록 등을 미리 선언(프로토타입)하여, 정의 전에 호출하거나 매개변수 타입을 검사할 수 있게 한다.
→ **프로시저 원형(이름, 매개변수)을 미리 선언**

**22.** *(True/False):* An Object file is produced by the Linker.

오브젝트 파일(.obj)은 링커가 아니라 어셈블러가 생성한다.
→ **False**

**23.** *(True/False):* A Listing file is produced by the Assembler.

→ **True**

**24.** *(True/False):* A link library is added to a program just before producing an Executable file.

링크 라이브러리는 링킹 단계에서, 즉 실행 파일을 만들기 직전에 결합된다.
→ **True**

**25.** Which data directive creates a 32-bit signed integer variable?

→ **`SDWORD`**

**26.** Which data directive creates a 16-bit signed integer variable?

→ **`SWORD`**

**27.** Which data directive creates a 64-bit unsigned integer variable?

→ **`QWORD`**

**28.** Which data directive creates an 8-bit signed integer variable?

→ **`SBYTE`**

**29.** Which data directive creates a 10-byte packed BCD variable?

→ **`TBYTE`**

## 3.9.2 Algorithm Workbench

**1.** Define four symbolic constants that represent integer 25 in decimal, binary, octal, and hexadecimal formats.

```asm
dec25 = 25
bin25 = 00011001b
oct25 = 31o
hex25 = 19h
```
→ **`=` 디렉티브로 네 가지 진법을 각각 기호 상수로 정의**

**2.** Find out, by trial and error, if a program can have multiple code and data segments.

MASM에서는 `.data`와 `.code` 섹션을 프로그램 안에서 여러 번 선언할 수 있다. 어셈블러/링커가 같은 종류의 섹션들을 하나로 합쳐준다.
→ **가능함 (같은 종류끼리 링커가 자동으로 병합)**

**3.** Create a data definition for a doubleword that stored it in memory in big endian format.

x86은 기본적으로 리틀 엔디안이므로, 빅 엔디안으로 저장하려면 바이트를 직접 역순으로 나열해야 한다. 예를 들어 12345678h를 빅 엔디안으로 저장하려면:
```asm
val3 BYTE 12h, 34h, 56h, 78h   ; 메모리에 12h,34h,56h,78h 순서로 저장 (big endian)
```
→ **BYTE 단위로 상위 바이트부터 직접 나열**

**4.** Find out if you can declare a variable of type DWORD and assign it a negative value. What does this tell you about the assembler's type checking?

```asm
myVal DWORD -5
```
이 코드는 정상적으로 어셈블된다(2의 보수로 저장됨). 이는 어셈블러가 DWORD를 "부호 없는" 타입으로 엄격히 강제하지 않고, 값이 표현 범위 안에만 있으면 부호에 상관없이 허용한다는 뜻이다.
→ **가능함 → 어셈블러의 부호 타입 검사가 느슨함을 보여줌**

**5.** Write a program that contains two instructions: (1) add the number 5 to the EAX register, and (2) add 5 to the EDX register. Generate a listing file and examine the machine code generated by the assembler. What differences, if any, did you find between the two instructions?

```asm
.code
main PROC
    add eax, 5          ; EAX는 누산기 전용 짧은 인코딩(05h + imm32) 사용 가능
    add edx, 5           ; EDX는 ModR/M 바이트가 포함된 일반형(83h /2 + imm8) 인코딩
    invoke ExitProcess, 0
main ENDP
END main
```
리스팅 파일을 보면 EAX에 대한 ADD는 특별히 짧은 인코딩(opcode 05h)을 쓸 수 있는 반면, EDX는 ModR/M 바이트로 목적 레지스터를 지정하는 일반적인 형태(opcode 83h)를 사용해 바이트 수가 다르게 나온다.
→ **EAX는 전용 축약 인코딩, EDX는 ModR/M 포함 일반 인코딩으로 바이트 구성이 다름**

**6.** Given the number 456789ABh, list out its byte values in little-endian order.

→ **`ABh, 89h, 67h, 45h`**

**7.** Declare an array of 120 uninitialized unsigned doubleword values.

```asm
myArray DWORD 120 DUP(?)
```

**8.** Declare an array of byte and initialize it to the first 5 letters of the alphabet.

```asm
myBytes BYTE 'A','B','C','D','E'
```

**9.** Declare a 32-bit signed integer variable and initialize it with the smallest possible negative decimal value.

```asm
myInt SDWORD -2147483648
```

**10.** Declare an unsigned 16-bit integer variable named **wArray** that uses three initializers.

```asm
wArray WORD 10, 20, 30
```

**11.** Declare a string variable containing the name of your favorite color. Initialize it as a null-terminated string.

```asm
color BYTE "Blue", 0
```

**12.** Declare an uninitialized array of 50 signed doublewords named **dArray**.

```asm
dArray SDWORD 50 DUP(?)
```

**13.** Declare a string variable containing the word "TEST" repeated 500 times.

```asm
myStr BYTE 500 DUP("TEST")
```

**14.** Declare an array of 20 unsigned bytes named **bArray** and initialize all elements to zero.

```asm
bArray BYTE 20 DUP(0)
```

**15.** Show the order of individual bytes in memory (lowest to highest) for the following doubleword variable:

```
val1 DWORD 87654321h
```

x86은 리틀 엔디안이므로 최하위 바이트가 가장 낮은 주소에 저장된다.
→ **`21h, 43h, 65h, 87h`** (낮은 주소 → 높은 주소 순)
