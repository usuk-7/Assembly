# Ch10 Review Questions 풀이

## 10.7.1 Short Answer

**1.** What is the purpose of the STRUCT directive?
구조체(관련 필드를 묶은 사용자 정의 타입)의 틀을 정의한다. 정의 자체는 메모리를 차지하지 않고, 그 타입으로 선언한 변수가 메모리를 쓴다.
→ **구조체 템플릿(필드 구성) 정의 — `name STRUCT ... name ENDS`**

**2.** Assume that the following structure has been defined:
```
RentalInvoice STRUCT
    invoiceNum BYTE 5 DUP(' ')
    dailyPrice WORD ?
    daysRented WORD ?
RentalInvoice ENDS
```
State whether or not each of the following declarations is valid:
a. `rentals RentalInvoice <>` → **유효** (기본값으로 선언)
b. `RentalInvoice rentals <>` → **무효** (변수 이름이 타입 이름보다 앞에 와야 함)
c. `march RentalInvoice <'12345',10,0>` → **유효** (5글자가 5바이트 필드에 딱 맞음)
d. `RentalInvoice <,10,0>` → **유효** (이름 없는 구조체 변수. 첫 필드는 기본값)
e. `current RentalInvoice <,15,0,0>` → **무효** (필드는 3개인데 초기값이 4개)

**3.** (True/False): A macro cannot contain data definitions.
→ **False** — 예: mWrite는 `.data`에 문자열을 정의함

**4.** What is the purpose of the LOCAL directive?
매크로 안의 라벨을 확장할 때마다 `??nnnn` 형태의 고유 이름으로 바꾼다.
→ **매크로를 여러 번 호출해도 라벨 이름 중복(재정의) 오류가 나지 않게 함**

**5.** Which directive displays a message on the console during the assembly step?
→ **ECHO**

**6.** Which directive marks the end of a conditional block of statements?
→ **ENDIF**

**7.** List all the relational operators that can be used in constant boolean expressions.
→ **LT, GT, EQ, NE, LE, GE**

**8.** What is the purpose of the & operator in a macro definition?
→ **치환 연산자** — 매개변수 이름이 문자열 리터럴 등에 묻혀 있어도 인자 값으로 치환되게 함 (예: `" &regName=",0`)

**9.** What is the purpose of the ! operator in a macro definition?
→ **리터럴 문자 연산자** — `>`, `<` 같은 미리 정의된 연산자 문자를 일반 문자로 취급하게 함 (예: `<... is !> 24>`)

**10.** What is the purpose of the % operator in a macro definition?
→ **확장 연산자** — 텍스트 매크로를 펼치거나 상수식을 계산해 텍스트로 바꿈 (예: `%(5 + count)` → "15", 줄 맨 앞 `%`는 그 줄 전체 확장)

## 10.7.2 Algorithm Workbench

**1.** Create a structure named SampleStruct containing two fields: field1, a single 16-bit WORD, and field2, an array of 20 32-bit DWORDs. The initial values of the fields may be left undefined.
```
SampleStruct STRUCT
    field1 WORD ?
    field2 DWORD 20 DUP(?)
SampleStruct ENDS
```

**2.** Write a statement that retrieves the wHour field of a SYSTEMTIME structure.
```
.data
sysTime SYSTEMTIME <>
.code
movzx eax,sysTime.wHour      ; 또는 mov ax,sysTime.wHour
```

**3.** Using the following Triangle structure, declare a structure variable and initialize its vertices to (0,0), (5, 0), and (7,6):
```
Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS
```
→
```
myTriangle Triangle < <0,0>, <5,0>, <7,6> >
```

**4.** Declare an array of Triangle structures. Write a loop that initializes Vertex1 of each triangle to random coordinates in the range (0...10, 0...10).
```
NumTriangles = 10
.data
triangles Triangle NumTriangles DUP(<>)
.code
    call Randomize
    mov  esi,OFFSET triangles
    mov  ecx,NumTriangles
L1: mov  eax,11                                  ; 0~10
    call RandomRange
    mov  (Triangle PTR [esi]).Vertex1.X,ax
    mov  eax,11
    call RandomRange
    mov  (Triangle PTR [esi]).Vertex1.Y,ax
    add  esi,TYPE Triangle                       ; 다음 삼각형 (12바이트)
    loop L1
```

**5.** Write a macro named mPrintChar that displays a single character on the screen. It should have two parameters: this first specifies the character to be displayed and the second specifies how many times the character should be repeated. Here is a sample call: `mPrintChar 'X',20`
```
mPrintChar MACRO char:REQ, count:REQ
    LOCAL L1
    push eax
    push ecx
    mov  al,char
    mov  ecx,count
L1: call WriteChar
    loop L1
    pop  ecx
    pop  eax
ENDM
```

**6.** Write a macro named mGenRandom that generates a random integer between 0 and n − 1. Let n be the only parameter.
```
mGenRandom MACRO n:REQ
    mov  eax,n
    call RandomRange          ; EAX = 0 ~ n-1
ENDM
```

**7.** Write a macro named mPromptInteger that displays a prompt and inputs an integer from the user. Pass it a string literal and the name of a doubleword variable. Sample call: `mPromptInteger "Enter the minimum value", minVal`
```
mPromptInteger MACRO prompt:REQ, intVar:REQ
    push eax
    mWrite prompt
    call ReadInt
    mov  intVar,eax
    pop  eax
ENDM
```

**8.** Write a macro named mWriteAt that locates the cursor and writes a string literal to the console window. Suggestion: Invoke the mGotoxy and mWrite macros from the book's macro library.
```
mWriteAt MACRO X:REQ, Y:REQ, literal:REQ
    mGotoxy X,Y
    mWrite literal
ENDM
```

**9.** Show the expanded code produced by the following statement that invokes the mWriteString macro from Section 10.2.5: `mWriteStr namePrompt`
```
push edx
mov  edx,OFFSET namePrompt
call WriteString
pop  edx
```

**10.** Show the expanded code produced by the following statement that invokes the mReadString macro from Section 10.2.5: `mReadStr customerName`
```
push ecx
push edx
mov  edx,OFFSET customerName
mov  ecx,SIZEOF customerName
call ReadString
pop  edx
pop  ecx
```

**11.** Write a macro named mDumpMemx that receives a single parameter, the name of a variable. Your macro must call the mDumpMem macro from the book's library, passing it the variable's offset, number of units, and unit size. Demonstrate a call to the mDumpMemx macro.
```
mDumpMemx MACRO varName:REQ
    mDumpMem OFFSET varName, LENGTHOF varName, TYPE varName
ENDM

.data
array DWORD 1000h,2000h,3000h,4000h
.code
mDumpMemx array
```

**12.** Show an example of a macro parameter having a default argument initializer.
```
mWriteln MACRO text:=<" ">
    mWrite text
    call Crlf
ENDM
```

**13.** Write a short example that uses the IF, ELSE, and ENDIF directives.
```
DEBUG_MODE = 1
IF DEBUG_MODE EQ 1
    call DumpRegs
ELSE
    nop
ENDIF
```

**14.** Write a statement using the IF directive that checks the value of the constant macro parameter Z; if Z is less than zero, display a message during assembly indicating that Z is invalid.
```
IF Z LT 0
    ECHO Warning: Z is invalid (less than zero)
ENDIF
```

**15.** Write a short macro that demonstrates the use of the & operator when the macro parameter is embedded in a literal string.
```
mShowName MACRO name
    mWrite "Hello, &name!"
ENDM
; mShowName Bob  → "Hello, Bob!" 출력
```

**16.** Assume the following mLocate macro definition:
```
mLocate MACRO xval,yval
    IF xval LT 0          ;; xval < 0?
        EXITM             ;; if so, exit
    ENDIF
    IF yval LT 0          ;; yval < 0?
        EXITM             ;; if so, exit
    ENDIF
    mov bx,0              ;; video page 0
    mov ah,2              ;; locate cursor
    mov dh,yval
    mov dl,xval
    int 10h               ;; call the BIOS
ENDM
```
Show the source code generated by the preprocessor when the macro is expanded by each of the following statements:
`mLocate -2,20`
xval = -2 < 0이라 첫 IF에서 EXITM.
→ **코드 생성 없음**
`mLocate 10,20`
```
mov bx,0
mov ah,2
mov dh,20
mov dl,10
int 10h
```
`mLocate col,row`
col, row는 변수라 IF의 상수식에 쓸 수 없다(MASM은 "constant expected" 오류). IF 검사를 통과한다고 보면 생성 코드는 아래와 같다.
```
mov bx,0
mov ah,2
mov dh,row
mov dl,col
int 10h
```
