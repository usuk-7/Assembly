# Ch9 Review Questions 풀이

## 9.9.1 Short Answer

**1.** Which Direction flag setting causes index registers to move backward through memory when executing string primitives?
→ **DF = 1 (Set, `STD`)** — ESI/EDI가 감소함

**2.** When a repeat prefix is used with STOSW, what value is added to or subtracted from the index register?
→ **2** (워드 단위)

**3.** In what way is the CMPS instruction ambiguous?
CMPS는 피연산자를 적지 않고 [ESI]와 [EDI]를 암묵적으로 쓴다. 일반 CMP(dest, src)는 dest − src인데, CMPS는 [ESI] − [EDI], 즉 source에서 destination을 뺀다. 그래서 어느 쪽이 "큰지" 판단할 때 순서가 헷갈리기 쉽다. 접미사 없는 `CMPS`만 쓰면 비교 크기도 알 수 없다.
→ **비교 순서가 CMP와 반대(source[ESI] − dest[EDI])라서 플래그 해석이 헷갈림**

**4.** When the Direction flag is clear and SCASB has found a matching character, where does EDI point?
→ **일치한 문자의 바로 다음 바이트** (그래서 `dec edi`로 되돌림)

**5.** When scanning an array for the first occurrence of a particular character, which repeat prefix would be best?
→ **REPNE (REPNZ)** — 같은 값을 만날 때까지 반복

**6.** What Direction flag setting is used in the Str_trim procedure from Section 9.3?
Str_trim은 문자열 기본 명령어를 쓰지 않고 `dec edi`로 직접 포인터를 뒤로 옮긴다.
→ **DF를 쓰지 않음(설정 안 함)**. 문자열 끝에서 앞쪽으로(역방향) 훑지만 수동으로 이동함

**7.** Why does the Str_trim procedure from Section 9.3 use the JNE instruction?
현재 문자가 제거할 문자(delimiter)가 아니면 더 뒤로 갈 필요가 없다.
→ **제거 대상이 아닌 첫 문자를 찾으면 루프를 빠져나가 그 뒤에 널을 넣기 위해(L2로 점프)**

**8.** What happens in the Str_ucase procedure from Section 9.3 if the target string contains a digit?
숫자는 'a'보다 작으므로 `jb L2`로 건너뛴다.
→ **변환하지 않고 그대로 둠**

**9.** If the Str_length procedure from Section 9.3 used SCASB, which repeat prefix would be most appropriate?
→ **REPNE (REPNZ)** — AL = 0으로 두고 널 바이트를 만날 때까지 스캔

**10.** If the Str_length procedure from Section 9.3 used SCASB, how would it calculate and return the string length?
AL = 0, ECX = 큰 값(0FFFFFFFFh), EDI = 문자열 시작으로 두고 `repne scasb` 실행. 끝나면 EDI는 널 바로 다음을 가리킨다.
→ **길이 = EDI − 시작주소 − 1** (또는 ECX 감소량 − 1 = `not ecx` 후 `dec ecx`), 결과를 EAX에 넣어 반환
```
mov   edi,pString
mov   esi,edi            ; 시작 주소 보관
mov   al,0               ; 찾을 값 = null
mov   ecx,0FFFFFFFFh     ; 충분히 큰 카운트
cld
repne scasb              ; null 찾을 때까지
mov   eax,edi
sub   eax,esi
dec   eax                ; null 자리 제외
```

**11.** What is the maximum number of comparisons needed by the binary search algorithm when an array contains 1,024 elements?
1024 = 2¹⁰ → 매번 절반씩 줄어듦
→ **10번** (Table 9-6 기준)

**12.** In the FillArray procedure from the Binary Search example in Section 9.5, why must the Direction flag be cleared by the CLD instruction?
STOSD는 DF에 따라 EDI를 증가/감소시킨다. DF가 다른 코드에서 1로 남아 있을 수 있다.
→ **STOSD가 EDI를 증가(정방향)시켜 배열 앞에서부터 채우도록 보장하기 위해**

**13.** In the BinarySearch procedure from Section 9.5, why could the statement at label L2 be removed without affecting the outcome?
L2의 `cmp edx,edi`는 바로 앞의 `cmp edx,edi`와 똑같은 비교다. 그 사이의 `jge L2`는 플래그를 바꾸지 않는다.
→ **플래그가 이미 같은 비교 결과로 남아 있으므로 `jle L3`가 그대로 올바르게 동작함**

**14.** In the BinarySearch procedure from Section 9.5, how might the statement at label L4 be eliminated?
L4는 `jmp L1`만 하는 중간 점프다.
→ **`jmp L4`를 모두 `jmp L1`로 바꾸면 L4 문장을 없앨 수 있음**

## 9.9.2 Algorithm Workbench

**1.** Show an example of a base-index operand in 32-bit mode.
```
mov eax,[ebx + esi]
```

**2.** Show an example of a base-index-displacement operand in 32-bit mode.
```
mov eax,array[ebx + esi]
```

**3.** Suppose a two-dimensional array of doublewords has three logical rows and four logical columns. Write an expression using ESI and EDI that addresses the third column in the second row. (Numbering for rows and columns starts at zero.)
"두 번째 행" = 행 인덱스 1, "세 번째 열" = 열 인덱스 2(0부터 세는 경우 문제 표현 그대로 row 2·col 3으로 볼 수도 있음). 한 행 크기 = 4 × 4 = 16바이트. ESI = 행 오프셋, EDI = 열 인덱스.
```
RowSize = 16                       ; 4 columns * 4 bytes
mov  esi,RowSize * 1               ; second row
mov  edi,2                         ; third column
mov  eax,array[esi + edi*4]        ; 오프셋 16 + 8 = 24
```
→ **`array[esi + edi*TYPE array]`** (ESI = 16, EDI = 2)

**4.** Write instructions using CMPSW that compare two arrays of 16-bit values named sourcew and targetw.
```
    mov   esi,OFFSET sourcew
    mov   edi,OFFSET targetw
    mov   ecx,LENGTHOF sourcew     ; 비교할 워드 개수
    cld                            ; 정방향
    repe  cmpsw                    ; 같은 동안 반복
    jne   NotEqual                 ; 다른 쌍이 있으면 분기
    ; (여기 도달하면 두 배열이 모두 같음)
```

**5.** Write instructions that use SCASW to scan for the 16-bit value 0100h in an array named wordArray, and copy the offset of the matching member into the EAX register.
```
    mov   edi,OFFSET wordArray
    mov   ax,0100h                 ; 찾을 값
    mov   ecx,LENGTHOF wordArray
    cld
    repne scasw                    ; 같은 값을 만날 때까지
    jnz   NotFound                 ; 끝까지 못 찾음
    sub   edi,TYPE wordArray       ; EDI는 일치 원소 다음을 가리키므로 2 감소
    mov   eax,edi                  ; EAX = 일치 원소의 오프셋
```

**6.** Write a sequence of instructions that use the Str_compare procedure to determine the larger of two input strings and write it to the console window.
```
    INVOKE Str_compare, ADDR string1, ADDR string2
    ja    S1Larger                 ; string1 > string2 (CF=0, ZF=0)
    mov   edx,OFFSET string2       ; string2가 크거나 같음
    jmp   Show
S1Larger:
    mov   edx,OFFSET string1
Show:
    call  WriteString
    call  Crlf
```

**7.** Show how to call the Str_trim procedure and remove all trailing "@" characters from a string.
```
INVOKE Str_trim, ADDR myString, '@'
```

**8.** Show how to modify the Str_ucase procedure from the Irvine32 library so it changes all characters to lower case.
비교 범위를 'A'~'Z'로 바꾸고, AND 대신 OR로 비트 5를 켠다.
```
Str_lcase PROC USES eax esi,
    pString:PTR BYTE
    mov  esi,pString
L1: mov  al,[esi]
    cmp  al,0                       ; end of string?
    je   L3
    cmp  al,'A'                     ; below "A"?
    jb   L2
    cmp  al,'Z'                     ; above "Z"?
    ja   L2
    or   BYTE PTR [esi],00100000b   ; 비트 5를 켜서 소문자로
L2: inc  esi
    jmp  L1
L3: ret
Str_lcase ENDP
```

**9.** Create a 64-bit version of the Str_trim procedure.
Irvine64 방식대로 레지스터로 받는다: RCX = 문자열 주소, DL = 제거할 문자. Str_length(64비트, RCX 입력 → RAX 길이)를 사용.
```
;------------------------------------------------------
; Str_trim (64-bit)
; Receives: RCX points to the string, DL = char to trim
; Returns:  nothing
;------------------------------------------------------
Str_trim PROC USES rax rcx rdi
    mov  rdi,rcx                    ; RDI = 문자열 시작
    call Str_length                 ; RAX = length (RCX 입력)
    cmp  rax,0                      ; 빈 문자열?
    je   L3
    mov  rcx,rax                    ; RCX = 루프 카운터
    dec  rax
    add  rdi,rax                    ; RDI = 마지막 문자
L1: mov  al,[rdi]
    cmp  al,dl                      ; 제거 문자인가?
    jne  L2                         ; 아니면 그 뒤에 null
    dec  rdi                        ; 맞으면 뒤로
    loop L1
L2: mov  BYTE PTR [rdi+1],0         ; null 삽입
L3: ret
Str_trim ENDP
```

**10.** Show an example of a base-index operand in 64-bit mode.
```
mov rax,[rbx + rsi]
```

**11.** Assuming that EBX contains a row index into a two-dimensional array of 32-bit integers named myArray and EDI contains the index of a column, write a single statement that moves the content of the given array element into the EAX register.
EBX가 행의 바이트 오프셋(행 번호 × 행 크기)을 담고 있다고 보면:
```
mov eax,myArray[ebx + edi*TYPE myArray]
```

**12.** Assuming that RBX contains a row index into a two-dimensional array of 64-bit integers named myArray and RDI contains the index of a column, write a single statement that moves the content of the given array element into the RAX register.
```
mov rax,myArray[rbx + rdi*TYPE myArray]
```
