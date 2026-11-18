# 9장. Strings and Arrays (어셈블리 프로그래밍)

## 1. 개요 (Introduction, 9.1)
- 프로그램은 실행 시간의 약 90%를 전체 코드의 10%에서 쓴다. 그 10%는 대부분 루프이고, 루프는 문자열·배열 처리에서 주로 나온다. 그래서 문자열·배열을 효율적으로 다루는 법이 코드 최적화의 핵심이다.
- 이 장의 흐름:
  - 블록 데이터를 이동·비교·적재·저장하는 최적화된 문자열 기본 명령어(string primitive)
  - Irvine32/Irvine64 라이브러리의 문자열 처리 프로시저(C 표준 문자열 함수와 비슷한 구현)
  - base-index, base-index-displacement 주소 지정을 이용한 2차원 배열 처리
  - 버블 정렬과 이진 탐색 구현

## 2. 문자열 기본 명령어 (String Primitive Instructions, 9.2)
- x86에는 바이트·워드·더블워드 배열을 처리하는 5가지 명령어 그룹이 있다. 이름은 "문자열" 명령어지만 문자 배열에만 쓰는 것이 아니라 모든 배열에 쓸 수 있다.
- 32비트 모드에서 이 명령어들은 메모리 주소로 ESI, EDI 중 하나 또는 둘 다를 암묵적으로 사용한다. 누산기(accumulator)는 데이터 크기에 따라 AL, AX, EAX를 뜻한다.
- 반복과 인덱스 증가를 CPU가 자동으로 해 주므로 빠르게 실행된다.

| 명령어 | 이름 | 동작 |
|---|---|---|
| MOVSB / MOVSW / MOVSD | Move string data | [ESI]의 데이터를 [EDI]로 복사 |
| CMPSB / CMPSW / CMPSD | Compare strings | [ESI]와 [EDI]의 메모리 값을 비교 |
| SCASB / SCASW / SCASD | Scan string | 누산기(AL/AX/EAX)와 [EDI]를 비교 |
| STOSB / STOSW / STOSD | Store string data | 누산기 값을 [EDI]에 저장 |
| LODSB / LODSW / LODSD | Load accumulator | [ESI]의 값을 누산기로 적재 |

- 접미사 B, W, D는 각각 바이트(1), 워드(2), 더블워드(4) 단위를 뜻한다.

### 2.1 반복 접두사 (Using a Repeat Prefix)
- 문자열 명령어 하나는 원래 값 하나(또는 한 쌍)만 처리한다. 앞에 반복 접두사를 붙이면 ECX를 카운터로 써서 배열 전체를 명령어 하나로 처리할 수 있다.

| 접두사 | 반복 조건 |
|---|---|
| REP | ECX > 0 인 동안 |
| REPZ, REPE | ZF = 1(같음) 이고 ECX > 0 인 동안 |
| REPNZ, REPNE | ZF = 0(다름) 이고 ECX > 0 인 동안 |

- 반복 접두사는 실행 전에 먼저 ECX > 0을 검사한다. ECX = 0이면 명령어를 건너뛰고 다음 줄로 간다. ECX > 0이면 ECX를 1 감소시키고 명령어를 반복한다.
- 예: string1에서 string2로 10바이트 복사

```
cld                         ; clear direction flag
mov  esi,OFFSET string1     ; ESI points to source
mov  edi,OFFSET string2     ; EDI points to target
mov  ecx,10                 ; set counter to 10
rep  movsb                  ; move 10 bytes
```

### 2.2 방향 플래그 (Direction Flag)
- 문자열 명령어가 ESI/EDI를 증가시킬지 감소시킬지는 방향 플래그(DF)가 결정한다.
- `CLD`는 DF를 0으로(정방향), `STD`는 DF를 1로(역방향) 설정한다.
- 문자열 명령어 전에 DF를 설정하지 않으면 ESI/EDI가 의도와 반대로 움직일 수 있으므로 습관적으로 CLD/STD를 써 주는 것이 좋다.

| DF 값 | ESI, EDI 변화 | 주소 순서 |
|---|---|---|
| Clear (0) | 증가 | 낮은 주소 → 높은 주소 |
| Set (1) | 감소 | 높은 주소 → 낮은 주소 |

### 2.3 MOVSB, MOVSW, MOVSD (9.2.1)
- [ESI]가 가리키는 데이터를 [EDI]가 가리키는 곳으로 복사하고, DF에 따라 두 레지스터를 자동으로 증가/감소시킨다.
- 증감 크기는 데이터 크기와 같다.

| 명령어 | ESI/EDI 증감값 |
|---|---|
| MOVSB | 1 |
| MOVSW | 2 |
| MOVSD | 4 |

- 예: 더블워드 20개 복사. 복사가 끝나면 ESI, EDI는 각 배열 끝에서 한 칸(4바이트) 뒤를 가리킨다.

```
.data
source DWORD 20 DUP(0FFFFFFFFh)
target DWORD 20 DUP(?)
.code
cld                          ; direction = forward
mov  ecx,LENGTHOF source     ; set REP counter
mov  esi,OFFSET source       ; ESI points to source
mov  edi,OFFSET target       ; EDI points to target
rep  movsd                   ; copy doublewords
```

### 2.4 CMPSB, CMPSW, CMPSD (9.2.2)
- [ESI]의 메모리 피연산자와 [EDI]의 메모리 피연산자를 비교한다. 결과는 CMP처럼 플래그로만 남는다(CMP [ESI],[EDI]와 같은 의미).
- 예: 더블워드 한 쌍 비교. source(1234h)가 target(5678h)보다 작으므로 JA는 점프하지 않는다.

```
.data
source DWORD 1234h
target DWORD 5678h
.code
mov  esi,OFFSET source
mov  edi,OFFSET target
cmpsd                        ; compare doublewords
ja   L1                      ; jump if source > target
```

- 여러 개를 비교할 때는 DF를 지우고, ECX에 개수를 넣고, REPE를 붙인다. ECX가 0이 되거나 서로 다른 쌍을 만날 때까지 비교가 계속된다.

```
mov  esi,OFFSET source
mov  edi,OFFSET target
cld                          ; direction = forward
mov  ecx,LENGTHOF source     ; repetition counter
repe cmpsd                   ; repeat while equal
```

### 2.5 SCASB, SCASW, SCASD (9.2.3)
- AL/AX/EAX 값을 [EDI]의 바이트/워드/더블워드와 비교한다. 배열에서 특정 값 하나를 찾을 때 유용하다.
- REPE(REPZ): 누산기 값과 메모리 값이 계속 "같은" 동안 스캔 → 처음으로 다른 값을 찾을 때 사용.
- REPNE(REPNZ): 누산기 값과 "같은" 값을 만나거나 ECX = 0이 될 때까지 스캔 → 특정 값을 찾을 때 사용.
- 예: 문자열 alpha에서 'F' 찾기. 찾으면 EDI는 일치한 문자 바로 다음을 가리키므로 `dec edi`로 한 칸 되돌린다. 루프가 ECX = 0으로 끝났는데 못 찾은 경우를 구분하려고 JNZ를 둔다.

```
.data
alpha BYTE "ABCDEFGH",0
.code
mov   edi,OFFSET alpha       ; EDI points to the string
mov   al,'F'                 ; search for the letter F
mov   ecx,LENGTHOF alpha     ; set the search count
cld                          ; direction = forward
repne scasb                  ; repeat while not equal
jnz   quit                   ; quit if letter not found
dec   edi                    ; found: back up EDI
```

### 2.6 STOSB, STOSW, STOSD (9.2.4)
- AL/AX/EAX 값을 [EDI]에 저장하고 EDI를 DF에 따라 증감시킨다.
- REP와 함께 쓰면 배열·문자열 전체를 같은 값으로 채울 수 있다.

```
.data
Count = 100
string1 BYTE Count DUP(?)
.code
mov  al,0FFh                 ; value to be stored
mov  edi,OFFSET string1      ; EDI points to target
mov  ecx,Count               ; character count
cld                          ; direction = forward
rep  stosb                   ; fill with contents of AL
```

### 2.7 LODSB, LODSW, LODSD (9.2.5)
- [ESI]의 값을 AL/AX/EAX로 읽고 ESI를 DF에 따라 증감시킨다.
- 반복할 때마다 누산기 값이 덮어써지므로 REP는 거의 쓰지 않는다. 값 하나씩 읽어 처리하는 루프에서 쓴다.
- DF = 0일 때 `lodsb`는 아래 두 명령어를 대신한다.

```
mov al,[esi]                 ; move byte into AL
inc esi                      ; point to next byte
```

- 예: LODSD와 STOSD를 함께 써서 배열의 각 원소에 상수를 곱하기(Mult.asm). ESI와 EDI가 같은 배열을 가리키므로 결과를 제자리에 덮어쓴다.

```
INCLUDE Irvine32.inc
.data
array DWORD 1,2,3,4,5,6,7,8,9,10     ; test data
multiplier DWORD 10                  ; test data
.code
main PROC
    cld                              ; direction = forward
    mov  esi,OFFSET array            ; source index
    mov  edi,esi                     ; destination index
    mov  ecx,LENGTHOF array          ; loop counter
L1: lodsd                            ; load [ESI] into EAX
    mul  multiplier                  ; multiply by a value
    stosd                            ; store EAX into [EDI]
    loop L1
    exit
main ENDP
END main
```

## 3. 주요 문자열 프로시저 (Selected String Procedures, 9.3)
- Irvine32 라이브러리에는 널 종료(null-terminated) 문자열을 다루는 프로시저가 있고, C 표준 라이브러리 함수와 비슷하다.

| 프로시저 | 하는 일 | 호출 형식 |
|---|---|---|
| Str_copy | source 문자열을 target으로 복사 | `INVOKE Str_copy, ADDR source, ADDR target` |
| Str_length | 널 바이트를 뺀 길이를 EAX로 반환 | `INVOKE Str_length, ADDR myString` |
| Str_compare | 두 문자열 비교, CMP처럼 ZF·CF 설정 | `INVOKE Str_compare, ADDR string1, ADDR string2` |
| Str_trim | 끝에 붙은 특정 문자를 모두 제거 | `INVOKE Str_trim, ADDR string, char_to_trim` |
| Str_ucase | 문자열을 대문자로 변환 | `INVOKE Str_ucase, ADDR myString` |

### 3.1 Str_compare 프로시저 (Str_compare Procedure, 9.3.1)
- 첫 바이트부터 앞으로 비교한다. 대문자와 소문자는 ASCII 코드가 다르므로 대소문자를 구분한다.
- 반환값은 없고, CMP와 똑같이 CF, ZF가 설정된다.

| 관계 | CF | ZF | 참일 때 분기 |
|---|---|---|---|
| string1 < string2 | 1 | 0 | JB |
| string1 = string2 | 0 | 1 | JE |
| string1 > string2 | 0 | 0 | JA |

```
Str_compare PROC USES eax edx esi edi,
    string1:PTR BYTE,
    string2:PTR BYTE
    mov  esi,string1
    mov  edi,string2
L1: mov  al,[esi]
    mov  dl,[edi]
    cmp  al,0            ; end of string1?
    jne  L2              ; no
    cmp  dl,0            ; yes: end of string2?
    jne  L2              ; no
    jmp  L3              ; yes, exit with ZF = 1
L2: inc  esi             ; point to next
    inc  edi
    cmp  al,dl           ; characters equal?
    je   L1              ; yes: continue loop
                         ; no: exit with flags set
L3: ret
Str_compare ENDP
```

- 두 문자열이 모두 널에 도달하면 ZF = 1로 끝난다. 다른 문자를 만나면 그 `cmp al,dl` 결과의 플래그를 그대로 가지고 복귀한다. 한쪽만 먼저 끝나면 널(0)과 다른 문자를 비교하게 되므로 짧은 쪽이 작다고 판정된다.
- CMPSB를 쓰지 않은 이유: CMPSB는 반복 횟수(긴 문자열의 길이)를 알아야 하므로 Str_length를 두 번 호출해야 한다. 한 루프 안에서 두 문자열의 널을 같이 검사하는 편이 간단하다. CMPSB는 길이를 알고 있는 큰 문자열·배열에 가장 효과적이다.

### 3.2 Str_length 프로시저 (Str_length Procedure, 9.3.2)
- 문자열 주소를 받아 널 바이트를 만날 때까지 세고, 길이를 EAX에 반환한다.

```
Str_length PROC USES edi,
    pString:PTR BYTE         ; pointer to string
    mov edi,pString
    mov eax,0                ; character count
L1: cmp BYTE PTR [edi],0     ; end of string?
    je  L2                   ; yes: quit
    inc edi                  ; no: point to next
    inc eax                  ; add 1 to count
    jmp L1
L2: ret
Str_length ENDP
```

### 3.3 Str_copy 프로시저 (Str_copy Procedure, 9.3.3)
- 널 종료 문자열을 source에서 target으로 복사한다. 반환값은 없다.
- target이 복사될 문자열을 담을 만큼 충분히 커야 하며, 프로시저가 이를 검사하지 않는다(호출하는 쪽 책임).
- Str_length로 길이를 구한 뒤 널 바이트까지 포함하도록 +1 해서 `rep movsb`로 복사한다.

```
Str_copy PROC USES eax ecx esi edi,
    source:PTR BYTE,         ; source string
    target:PTR BYTE          ; target string
    INVOKE Str_length,source ; EAX = length source
    mov  ecx,eax             ; REP count
    inc  ecx                 ; add 1 for null byte
    mov  esi,source
    mov  edi,target
    cld                      ; direction = forward
    rep  movsb               ; copy the string
    ret
Str_copy ENDP
```

### 3.4 Str_trim 프로시저 (Str_trim Procedure, 9.3.4)
- 문자열 끝에 붙은 특정 문자(구분 문자, delimiter)를 모두 제거한다. 예: 뒤쪽 공백 제거.
- 문자열을 자르는 가장 쉬운 방법은 남길 문자 바로 뒤에 널 바이트를 넣는 것이다. 널 뒤의 문자는 모든 문자열 함수가 무시한다.
- 고려해야 할 경우(# 를 제거 문자로 가정):
  1. 빈 문자열
  2. 다른 문자 뒤에 제거 문자가 1개 이상 붙음: "Hello##"
  3. 제거 문자 하나만 있음: "#"
  4. 제거 문자가 없음: "Hello", "H"
  5. 제거 문자가 앞에 있고 뒤에는 다른 문자: "#H", "###Hello"

| 입력 | 기대 결과 |
|---|---|
| "Hello##" | "Hello" |
| "#" | "" (빈 문자열) |
| "Hello" | "Hello" |
| "H" | "H" |
| "#H" | "#H" |

- 알고리즘: 문자열 끝에서부터 거꾸로 훑으며 제거 문자가 아닌 첫 문자를 찾고, 그 바로 뒤에 널을 넣는다.

```
ecx = length(str)
if length(str) > 0 then
    edi = length - 1
    do while ecx > 0
        if str[edi] ≠ delimiter then
            str[edi+1] = null
            break
        else
            edi = edi - 1
        end if
        ecx = ecx - 1
    end do
```

```
Str_trim PROC USES eax ecx edi,
    pString:PTR BYTE,        ; points to string
    char:BYTE                ; character to remove
    mov  edi,pString         ; prepare to call Str_length
    INVOKE Str_length,edi    ; returns the length in EAX
    cmp  eax,0               ; is the length equal to zero?
    je   L3                  ; yes: exit now
    mov  ecx,eax             ; no: ECX = string length
    dec  eax
    add  edi,eax             ; point to last character
L1: mov  al,[edi]            ; get a character
    cmp  al,char             ; is it the delimiter?
    jne  L2                  ; no: insert null byte
    dec  edi                 ; yes: keep backing up
    loop L1                  ; until beginning reached
L2: mov  BYTE PTR [edi+1],0  ; insert a null byte
L3: ret
Str_trim ENDP
```

- 코드 흐름:
  - 길이가 0이면 바로 L3로 가서 끝난다.
  - ECX = 길이, EDI = 마지막 문자 주소로 맞춘다(길이-1을 더함).
  - 현재 문자가 제거 문자가 아니면(JNE) L2로 가서 그 뒤에 널을 넣는다.
  - 제거 문자면 EDI를 한 칸 뒤로 옮기고 LOOP로 반복한다.
- L2에는 두 경로로 도달한다: 제거 대상이 아닌 문자를 찾았을 때, 또는 문자열 전체가 제거 문자라서 ECX가 0이 됐을 때. 후자의 경우 EDI는 문자열 시작보다 한 칸 앞을 가리키므로 [edi+1]은 문자열의 첫 위치가 되어 빈 문자열이 된다.

### 3.5 Str_ucase 프로시저 (Str_ucase Procedure, 9.3.5)
- 문자열을 모두 대문자로 바꾼다. 반환값은 없다.
- 'a'~'z' 범위인 문자만 비트 5를 지워(AND 11011111b) 대문자로 만든다. 소문자와 대문자의 ASCII 코드 차이가 20h(비트 5)이기 때문이다. 범위 밖 문자(숫자, 기호 등)는 그대로 둔다.

```
Str_ucase PROC USES eax esi,
    pString:PTR BYTE
    mov  esi,pString
L1: mov  al,[esi]                    ; get char
    cmp  al,0                        ; end of string?
    je   L3                          ; yes: quit
    cmp  al,'a'                      ; below "a"?
    jb   L2
    cmp  al,'z'                      ; above "z"?
    ja   L2
    and  BYTE PTR [esi],11011111b    ; convert the char
L2: inc  esi                         ; next char
    jmp  L1
L3: ret
Str_ucase ENDP
```

### 3.6 문자열 라이브러리 데모 프로그램 (String Library Demo Program, 9.3.6)
- StringDemo.asm은 Str_trim, Str_ucase, Str_compare, Str_length를 차례로 호출한다.

```
INCLUDE Irvine32.inc
.data
string_1 BYTE "abcde////",0
string_2 BYTE "ABCDE",0
msg0 BYTE "string_1 in upper case: ",0
msg1 BYTE "string_1 and string_2 are equal",0
msg2 BYTE "string_1 is less than string_2",0
msg3 BYTE "string_2 is less than string_1",0
msg4 BYTE "Length of string_2 is ",0
msg5 BYTE "string_1 after trimming: ",0
.code
main PROC
    call trim_string
    call upper_case
    call compare_strings
    call print_length
    exit
main ENDP

trim_string PROC                        ; Remove trailing characters from string_1.
    INVOKE Str_trim, ADDR string_1, '/'
    mov  edx,OFFSET msg5
    call WriteString
    mov  edx,OFFSET string_1
    call WriteString
    call Crlf
    ret
trim_string ENDP

upper_case PROC                         ; Convert string_1 to upper case.
    mov  edx,OFFSET msg0
    call WriteString
    INVOKE Str_ucase, ADDR string_1
    mov  edx,OFFSET string_1
    call WriteString
    call Crlf
    ret
upper_case ENDP

compare_strings PROC                    ; Compare string_1 to string_2.
    INVOKE Str_compare, ADDR string_1, ADDR string_2
    .IF ZERO?
      mov edx,OFFSET msg1
    .ELSEIF CARRY?
      mov edx,OFFSET msg2               ; string 1 is less than...
    .ELSE
      mov edx,OFFSET msg3               ; string 2 is less than...
    .ENDIF
    call WriteString
    call Crlf
    ret
compare_strings ENDP

print_length PROC                       ; Display the length of string_2.
    mov  edx,OFFSET msg4
    call WriteString
    INVOKE Str_length, ADDR string_2
    call WriteDec
    call Crlf
    ret
print_length ENDP
END main
```

- 실행 결과: "abcde////"에서 '/'가 제거되어 "abcde", 대문자로 바뀌어 "ABCDE"가 되므로 string_2와 같다고 판정된다.

```
string_1 after trimming: abcde
string_1 in upper case: ABCDE
string1 and string2 are equal
Length of string_2 is 5
```

### 3.7 Irvine64 라이브러리의 문자열 프로시저 (String Procedures in the Irvine64 Library, 9.3.7)
- 32비트 버전을 64비트로 바꾸는 방법은 간단하다: 스택 매개변수를 없애고 레지스터로 받으며, 32비트 레지스터를 64비트 레지스터로 바꾼다.

| 프로시저 | 입력 | 반환 |
|---|---|---|
| Str_compare | RSI = source, RDI = target | source < target이면 CF = 1, 같으면 ZF = 1, source > target이면 CF = 0, ZF = 0 |
| Str_copy | RSI = source, RDI = 복사될 위치 | 없음 |
| Str_length | RCX = 문자열 주소 | RAX = 길이 |

- Str_compare는 비교 루프에서 어차피 RSI, RDI를 쓰므로 입력 레지스터로 그대로 받으면 시작 부분에서 복사할 필요가 없다. USES로 사용하는 레지스터를 지정하면 진입 시 push, 복귀 직전 pop이 자동으로 들어간다.

```
Str_copy PROC USES rax rcx rsi rdi
    mov  rcx,rsi             ; get length of source string
    call Str_length          ; returns length in RAX
    mov  rcx,rax             ; loop counter
    inc  rcx                 ; add 1 for null byte
    cld                      ; direction = up
    rep  movsb               ; copy the string
    ret
Str_copy ENDP

Str_length PROC USES rdi
    mov  rdi,rcx             ; get pointer
    mov  eax,0               ; character count
L1: cmp  BYTE PTR [rdi],0    ; end of string?
    je   L2                  ; yes: quit
    inc  rdi                 ; no: point to next
    inc  rax                 ; add 1 to count
    jmp  L1
L2: ret                      ; return count in RAX
Str_length ENDP
```

- 테스트 프로그램(StringLib64Test.asm) 흐름: source를 target에 복사한 직후 Str_compare를 호출하면 ZF = 1(같음). target의 첫 문자를 'B'로 바꾼 뒤 다시 비교하면 source("AAB…")가 더 작으므로 CF = 1.

## 4. 2차원 배열 (Two-Dimensional Arrays, 9.4)

### 4.1 행과 열의 배치 순서 (Ordering of Rows and Columns, 9.4.1)
- 어셈블리 입장에서 2차원 배열은 1차원 배열을 높은 수준에서 본 추상화일 뿐이다. 메모리에 놓는 방법은 두 가지다.
  - 행 우선(row-major, 가장 흔함): 첫 행이 메모리 앞에 오고, 첫 행의 마지막 원소 다음에 둘째 행의 첫 원소가 온다.
  - 열 우선(column-major): 첫 열이 메모리 앞에 오고, 첫 열의 마지막 원소 다음에 둘째 열의 첫 원소가 온다.
- 직접 구현할 때는 아무 방식이나 골라도 되지만, 이 장은 행 우선을 쓴다. 고급 언어용 서브루틴을 짤 때는 그 언어 문서의 방식을 따른다.

```
논리적 배치:   10 20 30 40 50
               60 70 80 90 A0
               B0 C0 D0 E0 F0

행 우선: 10 20 30 40 50 60 70 80 90 A0 B0 C0 D0 E0 F0
열 우선: 10 60 B0 20 70 C0 30 80 D0 40 90 E0 50 A0 F0
```

- 배열 처리에 적합한 피연산자 형식으로 base-index와 base-index-displacement가 있다.

### 4.2 Base-Index 피연산자 (Base-Index Operands, 9.4.2)
- 두 레지스터(base와 index)의 값을 더해 오프셋 주소를 만든다. 형식은 `[base + index]`이고 대괄호는 필수다.
- 32비트 모드에서는 어떤 32비트 범용 레지스터든 base, index로 쓸 수 있다. 다만 EBP는 보통 스택 주소 지정용이므로 배열에는 피한다.

```
.data
array WORD 1000h,2000h,3000h
.code
mov  ebx,OFFSET array
mov  esi,2
mov  ax,[ebx+esi]            ; AX = 2000h
mov  edi,OFFSET array
mov  ecx,4
mov  ax,[edi+ecx]            ; AX = 3000h
mov  ebp,OFFSET array
mov  esi,0
mov  ax,[ebp+esi]            ; AX = 1000h
```

- 2차원 배열(행 우선)에 접근할 때는 base 레지스터에 행 오프셋, index 레지스터에 열 오프셋을 둔다.
- 예: 3행 5열 바이트 표. `Rowsize = ($ - tableB)`로 한 행의 바이트 수(5)를 어셈블러가 계산한다. 0부터 세는 좌표로 [1, 2]의 값은 80h다.

```
tableB  BYTE  10h,  20h,  30h,  40h,  50h
Rowsize = ($ - tableB)
        BYTE  60h,  70h,  80h,  90h, 0A0h
        BYTE 0B0h, 0C0h, 0D0h, 0E0h, 0F0h

row_index = 1
column_index = 2
mov  ebx,OFFSET tableB              ; table offset
add  ebx,RowSize * row_index        ; row offset
mov  esi,column_index
mov  al,[ebx + esi]                 ; AL = 80h
```

- tableB가 0150h에 있다면 EBX = 0155h(둘째 행 시작), EBX + ESI = 0157h가 되어 80h를 가리킨다. 실효 주소가 프로그램 데이터 영역 밖이면 런타임 오류가 난다.

### 4.3 행 합계 계산 (Calculating a Row Sum)
- base-index 주소 지정으로 행렬의 한 행 합을 쉽게 구할 수 있다(RowSum.asm). 행 번호 × 행 크기로 행 시작 주소를 만들고, ESI를 열 인덱스로 증가시킨다.
- MOVZX에서 메모리 피연산자의 크기를 알려 주려면 BYTE PTR이 필요하다.

```
;-----------------------------------------------------------
; calc_row_sum
; Calculates the sum of a row in a byte matrix.
; Receives: EBX = table offset, EAX = row index,
;           ECX = row size, in bytes.
; Returns: EAX holds the sum.
;-----------------------------------------------------------
calc_row_sum PROC USES ebx ecx edx esi
    mul  ecx                         ; row index * row size
    add  ebx,eax                     ; row offset
    mov  eax,0                       ; accumulator
    mov  esi,0                       ; column index
L1: movzx edx,BYTE PTR [ebx + esi]   ; get a byte
    add  eax,edx                     ; add to accumulator
    inc  esi                         ; next byte in row
    loop L1
    ret
calc_row_sum ENDP
```

### 4.4 배율 (Scale Factors)
- WORD 배열이면 index에 배율 2를, DWORD 배열이면 배율 4를 곱해야 한다. `TYPE 배열이름`을 배율로 쓰면 자료형이 바뀌어도 코드를 고칠 필요가 없다.

```
tableW  WORD  10h,  20h,  30h,  40h,  50h
RowsizeW = ($ - tableW)
        WORD  60h,  70h,  80h,  90h, 0A0h
        WORD 0B0h, 0C0h, 0D0h, 0E0h, 0F0h
.code
row_index = 1
column_index = 2
mov  ebx,OFFSET tableW               ; table offset
add  ebx,RowSizeW * row_index        ; row offset
mov  esi,column_index
mov  ax,[ebx + esi*TYPE tableW]      ; AX = 0080h

; doubleword 배열이면 배율 4
mov  eax,[ebx + esi*TYPE tableD]
```

### 4.5 Base-Index-Displacement 피연산자 (Base-Index-Displacement Operands, 9.4.3)
- 변위(displacement), base 레지스터, index 레지스터, 선택적 배율을 합쳐 실효 주소를 만든다.

```
[base + index + displacement]
displacement[base + index]
```

- 변위는 변수 이름이나 상수식이다. 2차원 배열에서는 변위 = 배열 이름, base = 행 오프셋(바이트), index = 열 번호로 두면 편하다.
- 예: 3행 5열 더블워드 표. Rowsize = 20(14h). [1, 2]의 값 80h에 접근하려면 EBX에 행 오프셋(Rowsize × 1), ESI에 열 번호 2를 넣는다.

```
tableD DWORD  10h,  20h,  30h,  40h,  50h
Rowsize = ($ - tableD)
       DWORD  60h,  70h,  80h,  90h, 0A0h
       DWORD 0B0h, 0C0h, 0D0h, 0E0h, 0F0h

mov  ebx,Rowsize                     ; row index
mov  esi,2                           ; column index
mov  eax,tableD[ebx + esi*TYPE tableD]
```

- tableD가 0150h에 있으면 tableD[ebx] = 0164h(둘째 행 시작), tableD[ebx + esi*4] = 016Ch가 된다.

### 4.6 64비트 모드의 Base-Index 피연산자 (Base-Index Operands in 64-Bit Mode, 9.4.4)
- 64비트 모드에서 레지스터를 인덱스로 쓰는 피연산자는 반드시 64비트 레지스터를 써야 한다. base-index와 base-index-displacement 모두 사용 가능하다.
- 예: QWORD 2차원 표에서 행·열로 값을 꺼내는 get_tableVal. 32비트 코드의 ESI, EAX, EBX가 RSI, RAX, RBX로 바뀐 것뿐이다.

```
.data
table QWORD 1,2,3,4,5
RowSize = ($ - table)
      QWORD 6,7,8,9,10
      QWORD 11,12,13,14,15
.code
main PROC
    mov  rax,1                ; row index (zero-based)
    mov  rsi,4                ; column index (zero based)
    call get_tableVal         ; returns the value in RAX (= 10)
    call WriteInt64
    ...
main ENDP

;---------------------------------------------------
; Receives: RAX = row number, RSI = column number
; Returns: value in RAX
;---------------------------------------------------
get_tableVal PROC USES rbx
    mov  rbx,RowSize
    mul  rbx                          ; product(low) = RAX
    mov  rax,table[rax + rsi*TYPE table]
    ret
get_tableVal ENDP
```

## 5. 정수 배열의 탐색과 정렬 (Searching and Sorting Integer Arrays, 9.5)
- 특정 응용에 맞는 좋은 알고리즘을 고르는 것이 더 빠른 컴퓨터를 사는 것보다 훨씬 효과가 크다. 어셈블리로 구현해 보면 알고리즘의 저수준 동작을 직접 볼 수 있다.
- base-indexed 주소 지정이 특히 유용하다: 한 레지스터(EBX)는 배열 시작을, 다른 레지스터(ESI)는 인덱스를 가리키게 한다.

### 5.1 버블 정렬 (Bubble Sort, 9.5.1)
- 위치 0과 1부터 인접한 두 값을 비교하고, 순서가 반대면 교환한다. 한 번 훑고 나면(한 pass) 아직 정렬되지는 않았지만 가장 큰 값이 맨 끝으로 간다.
- 바깥 루프가 pass를 반복하며, n개 원소면 n-1번 pass 후 반드시 정렬된다.
- 첫 pass 예(3 1 7 5 2 9 4 3): 교환이 일어나며 진행되고, pass가 끝나면 1 3 5 2 7 4 3 9가 되어 최댓값 9가 맨 뒤로 간다.
- 시간 복잡도는 O(n²)이다. 원소 수가 10배가 되면 시간은 100배가 된다. 1000개에 0.1초 걸린다고 하면:

| 배열 크기 | 시간(초) |
|---|---|
| 1,000 | 0.1 |
| 10,000 | 10.0 |
| 100,000 | 1000 |
| 1,000,000 | 100,000 (27.78시간) |

- 수백 개 정도 정렬에는 충분하지만 100만 개처럼 큰 배열에는 부적합하다.
- 의사코드(N = 배열 크기, cx1 = 바깥 카운터, cx2 = 안쪽 카운터). 안쪽 반복 횟수는 바깥 카운터 값에 따라 pass마다 줄어든다.

```
cx1 = N - 1
while( cx1 > 0 )
{
  esi = addr(array)
  cx2 = cx1
  while( cx2 > 0 )
  {
    if( array[esi] > array[esi+4] )
      exchange( array[esi], array[esi+4] )
    add esi,4
    dec cx2
  }
  dec cx1
}
```

- 어셈블리 구현: 두 루프가 모두 LOOP(ECX)를 쓰므로 바깥 카운터를 push/pop으로 보존한다.

```
;-------------------------------------------------------
; BubbleSort
; Sort an array of 32-bit signed integers in ascending
; order, using the bubble sort algorithm.
; Receives: pointer to array, array size
; Returns: nothing
;-------------------------------------------------------
BubbleSort PROC USES eax ecx esi,
    pArray:PTR DWORD,        ; pointer to array
    Count:DWORD              ; array size
    mov  ecx,Count
    dec  ecx                 ; decrement count by 1
L1: push ecx                 ; save outer loop count
    mov  esi,pArray          ; point to first value
L2: mov  eax,[esi]           ; get array value
    cmp  [esi+4],eax         ; compare a pair of values
    jg   L3                  ; if [ESI] <= [ESI+4], no exchange
    xchg eax,[esi+4]         ; exchange the pair
    mov  [esi],eax
L3: add  esi,4               ; move both pointers forward
    loop L2                  ; inner loop
    pop  ecx                 ; retrieve outer loop count
    loop L1                  ; else repeat outer loop
L4: ret
BubbleSort ENDP
```

### 5.2 이진 탐색 (Binary Search, 9.5.2)
- 작은 배열(1000개 이하)은 처음부터 하나씩 보는 순차 탐색으로 충분하다. n개 배열에서 평균 n/2번 비교한다.
- 이진 탐색은 큰 배열에서 값 하나를 찾을 때 매우 효율적이다. 전제 조건: 배열이 오름차순 또는 내림차순으로 정렬되어 있어야 한다.
- 알고리즘(오름차순, 찾을 값 = searchVal):
  1. 탐색 범위를 first, last로 나타낸다. first > last면 탐색 실패로 끝낸다.
  2. first와 last 사이의 중간점 mid를 구한다.
  3. searchVal과 values[mid]를 비교한다.
     - 같으면 mid를 EAX에 넣고 복귀한다(찾음).
     - searchVal이 크면 first = mid + 1.
     - searchVal이 작으면 last = mid - 1.
  4. 1단계로 돌아간다.
- 분할 정복(divide and conquer) 방식으로 반복마다 범위가 절반으로 준다. O(log n) 알고리즘이며, 최악의 경우 비교 횟수는 다음과 같다.

| 배열 크기 | 순차 탐색 | 이진 탐색 |
|---|---|---|
| 64 | 64 | 6 |
| 1,024 | 1,024 | 10 |
| 65,536 | 65,536 | 17 |
| 1,048,576 | 1,048,576 | 21 |
| 4,294,967,296 | 4,294,967,296 | 33 |

- C++ 구현:

```
int BinSearch( int values[], const int searchVal, int count )
{
  int first = 0;
  int last = count - 1;
  while( first <= last )
  {
    int mid = (last + first) / 2;
    if( values[mid] < searchVal )
      first = mid + 1;
    else if( values[mid] > searchVal )
      last = mid - 1;
    else
      return mid;        // success
  }
  return -1;             // not found
}
```

- 어셈블리 구현: first, last, mid를 LOCAL 지역 변수로 두고, mid에 4를 곱해(shl esi,2) 바이트 오프셋으로 만든 뒤 [ebx+esi]로 값을 읽는다. 부호 있는 정수이므로 JG/JGE/JLE를 쓴다.

```
BinarySearch PROC USES ebx edx esi edi,
    pArray:PTR DWORD,        ; pointer to array
    Count:DWORD,             ; array size
    searchVal:DWORD          ; search value
    LOCAL first:DWORD,       ; first position
    last:DWORD,              ; last position
    mid:DWORD                ; midpoint
    mov  first,0             ; first = 0
    mov  eax,Count           ; last = (count - 1)
    dec  eax
    mov  last,eax
    mov  edi,searchVal       ; EDI = searchVal
    mov  ebx,pArray          ; EBX points to the array
L1: ; while first <= last
    mov  eax,first
    cmp  eax,last
    jg   L5                  ; exit search
; mid = (last + first) / 2
    mov  eax,last
    add  eax,first
    shr  eax,1
    mov  mid,eax
; EDX = values[mid]
    mov  esi,mid
    shl  esi,2               ; scale mid value by 4
    mov  edx,[ebx+esi]       ; EDX = values[mid]
; if ( EDX < searchval(EDI) )
    cmp  edx,edi
    jge  L2
;   first = mid + 1
    mov  eax,mid
    inc  eax
    mov  first,eax
    jmp  L4
; else if( EDX > searchVal(EDI) )
L2: cmp  edx,edi             ; optional
    jle  L3
;   last = mid - 1
    mov  eax,mid
    dec  eax
    mov  last,eax
    jmp  L4
; else return mid
L3: mov  eax,mid             ; value found
    jmp  L9                  ; return (mid)
L4: jmp  L1                  ; continue the loop
L5: mov  eax,-1              ; search failed
L9: ret
BinarySearch ENDP
```

### 5.3 테스트 프로그램 (Test Program)
- 버블 정렬과 이진 탐색을 함께 시험하는 프로그램의 순서:
  - 배열을 무작위 정수로 채운다.
  - 배열을 출력한다.
  - 버블 정렬로 정렬한다.
  - 다시 출력한다.
  - 사용자에게 정수를 입력받는다.
  - 그 정수를 이진 탐색한다.
  - 탐색 결과를 출력한다.
- 각 프로시저를 별도 소스 파일(모듈)로 나눴다. main 모듈을 제외한 모듈은 다른 프로그램에서 수정 없이 재사용할 수 있게 작성되었다. 전문적인 프로그램은 대개 이렇게 모듈로 나눈다.

| 모듈 | 내용 |
|---|---|
| BinarySearchTest.asm | main, ShowResults, AskForSearchVal. 진입점과 전체 순서 관리 |
| BubbleSort.asm | 32비트 부호 있는 정수 배열 버블 정렬 |
| BinarySearch.asm | 32비트 부호 있는 정수 배열 이진 탐색 |
| FillArray.asm | 지정 범위의 난수로 배열 채우기 |
| PrintArray.asm | 배열 내용을 표준 출력에 쓰기 |

- 프로시저 원형은 BinarySearch.inc에 모아 두고 main 모듈에서 INCLUDE한다.

```
BinarySearch PROTO, pArray:PTR DWORD, Count:DWORD, searchVal:DWORD
FillArray PROTO, pArray:PTR DWORD, Count:DWORD,
          LowerRange:SDWORD, UpperRange:SDWORD
PrintArray PROTO, pArray:PTR DWORD, Count:DWORD
BubbleSort PROTO, pArray:PTR DWORD, Count:DWORD
```

- main 모듈: -5000 ~ +5000 범위의 난수 50개로 시험한다.

```
INCLUDE Irvine32.inc
INCLUDE BinarySearch.inc         ; procedure prototypes
LOWVAL = -5000                   ; minimum value
HIGHVAL = +5000                  ; maximum value
ARRAY_SIZE = 50                  ; size of the array
.data
array DWORD ARRAY_SIZE DUP(?)
.code
main PROC
    call Randomize
    INVOKE FillArray, ADDR array, ARRAY_SIZE, LOWVAL, HIGHVAL
    INVOKE PrintArray, ADDR array, ARRAY_SIZE
    call WaitMsg
    INVOKE BubbleSort, ADDR array, ARRAY_SIZE
    INVOKE PrintArray, ADDR array, ARRAY_SIZE
    call AskForSearchVal         ; returned in EAX
    INVOKE BinarySearch, ADDR array, ARRAY_SIZE, eax
    call ShowResults
    exit
main ENDP
```

- AskForSearchVal은 프롬프트를 출력하고 ReadInt로 받은 값을 EAX로 돌려준다. ShowResults는 EAX가 -1이면 "The value was not found.", 아니면 "The value was found at position " 뒤에 위치를 출력한다.
- PrintArray는 LODSD로 원소를 하나씩 읽어 WriteInt로 출력하고 ", "로 구분한다.

```
PrintArray PROC USES eax ecx edx esi,
    pArray:PTR DWORD, Count:DWORD
.data
comma BYTE ", ",0
.code
    mov  esi,pArray
    mov  ecx,Count
    cld                      ; direction = forward
L1: lodsd                    ; load [ESI] into EAX
    call WriteInt            ; send to output
    mov  edx,OFFSET comma
    call WriteString         ; display comma
    loop L1
    call Crlf
    ret
PrintArray ENDP
```

- FillArray는 LowerRange ~ (UpperRange-1) 범위의 난수를 STOSD로 저장한다. RandomRange는 0 ~ (n-1)을 돌려주므로 범위 폭(Upper - Lower)을 넘기고 결과에 LowerRange를 더해 범위를 옮긴다.

```
FillArray PROC USES eax edi ecx edx,
    pArray:PTR DWORD, Count:DWORD,
    LowerRange:SDWORD, UpperRange:SDWORD
    mov  edi,pArray          ; EDI points to the array
    mov  ecx,Count           ; loop counter
    mov  edx,UpperRange
    sub  edx,LowerRange      ; EDX = absolute range (0..n)
    cld                      ; clear direction flag
L1: mov  eax,edx             ; get absolute range
    call RandomRange
    add  eax,LowerRange      ; bias the result
    stosd                    ; store EAX into [edi]
    loop L1
    ret
FillArray ENDP
```

## 6. Java 바이트코드: 문자열 처리 (Java Bytecodes: String Processing, 9.6, 선택 주제)
- Java에서 문자열과 문자열 메서드가 바이트코드로 어떻게 처리되는지 보는 예다.

```
String empInfo = "10034Smith";
String id = empInfo.substring(0,5);
```

```
0: ldc #32;              // load literal string: 10034Smith
2: astore_0              // store into empInfo (index 0)
3: aload_0               // load empInfo onto the stack
4: iconst_0              // 인자 0
5: iconst_5              // 인자 5
6: invokevirtual #34;    // Method java/lang/String.substring
9: astore_1              // store into id (index 1)
```

- ldc는 상수 풀에서 문자열 리터럴의 참조를 피연산자 스택에 올리고, astore_0은 그것을 지역 변수 0번(empInfo)에 저장한다.
- substring을 호출하기 전에 객체 참조(aload_0)와 두 인자(iconst_0, iconst_5)를 스택에 올린다. invokevirtual은 인자를 꺼내 새 문자열을 만들고 그 참조를 스택에 올리며, astore_1이 이를 지역 변수 1번(id)에 저장한다.

## 7. 장 요약 (Chapter Summary, 9.7)
- 문자열 기본 명령어는 고속 메모리 접근에 최적화되어 있다: MOVS(이동), CMPS(비교), SCAS(스캔), STOS(저장), LODS(적재). 접미사 B, W, D로 크기를 정한다.
- 반복 접두사 REP는 인덱스 레지스터를 자동 증감하며 명령어를 반복한다. 예를 들어 REPNE SCASB는 [EDI]의 바이트가 AL과 같아질 때까지 스캔한다. 증가/감소 방향은 방향 플래그가 정한다.
- 문자열과 배열은 사실상 같다. 전통적으로 문자열은 1바이트 ASCII 배열이지만 지금은 16비트 유니코드도 쓴다. 차이는 문자열이 보통 널 바이트로 끝난다는 점뿐이다.
- 배열 처리는 루프 때문에 계산량이 많다. 루프 안의 명령어 수와 복잡도를 줄이면 속도가 좋아진다. 메모리 변수 대신 레지스터를 쓰거나, MOV/CMP 대신 문자열 명령어를 쓰는 방식으로 최적화할 수 있다.
- 문자열 프로시저: Str_copy(복사), Str_length(길이), Str_compare(비교), Str_trim(끝 문자 제거), Str_ucase(대문자 변환).
- base-index 피연산자는 2차원 배열에 유용하다: base에 행 주소, index에 열 오프셋. base-index-displacement는 여기에 배열 이름(변위)이 추가된 형태다.

```
[ebx + esi]          ; base-index
array[ebx + esi]     ; base-index-displacement
```

- 버블 정렬은 수백 개 이하 배열에 적합하고 큰 배열에는 비효율적이다. 이진 탐색은 정렬된 배열에서 값 하나를 빠르게 찾으며 어셈블리로 쉽게 구현된다.
