; Ch3 Programming Exercise 5: Listing File for AddTwoSum
; Generate a listing file for the AddTwoSum program and write a description
; of the machine code bytes generated for each instruction. You might have
; to guess at some of the meanings of the byte values.
;
; 빌드 시 /Fl 옵션(예: ml /c /coff /Fl AddTwoSum.asm)을 주면 AddTwoSum.lst
; 리스팅 파일이 생성된다. 아래는 각 명령어에 대해 일반적으로 생성되는
; 기계어 바이트 구성을 설명한 것이다 (실제 값은 사용 레지스터/오퍼랜드에 따라 달라짐).

INCLUDE Irvine32.inc

.data
sum DWORD ?           ; 두 값의 합을 저장할 변수

.code
main PROC
    mov eax, 10000h        ; B8 00 00 01 00        -> B8: "MOV EAX, imm32" 축약 인코딩, 뒤 4바이트가 리틀엔디안 즉시값 00010000h
    add eax, 40000h        ; 05 00 00 04 00         -> 05: EAX 전용 "ADD EAX, imm32" 축약 인코딩, 뒤 4바이트가 즉시값 00040000h
    mov sum, eax            ; A3 xx xx xx xx          -> A3: "MOV moffs32, EAX" 축약 인코딩, 뒤 4바이트는 sum 변수의 오프셋 주소
                             ;                            (직접 주소를 쓰는 형태라서 ModR/M 바이트가 없음)

    call WriteDec            ; E8 xx xx xx xx          -> E8: near CALL, 뒤 4바이트는 WriteDec까지의 상대 오프셋(relative offset)
    call Crlf                 ; E8 xx xx xx xx          -> 위와 동일한 형태, 오프셋 값만 다름

    invoke ExitProcess, 0     ; 6A 00                   -> 6A: "PUSH imm8" (인자 0을 스택에 push)
                              ; FF 15 xx xx xx xx        -> FF /2: "CALL [mem32]", ExitProcess의 IAT(가져오기 주소 테이블) 항목을 간접 호출
main ENDP
END main

; 정리:
; - EAX를 목적지로 쓰는 명령(MOV EAX,imm32 / ADD EAX,imm32 / MOV moffs,EAX)은
;   ModR/M 바이트 없이 opcode 하나로 축약되는 "짧은 인코딩"을 쓰는 경우가 많다.
; - CALL 명령은 목적지가 상대 오프셋(직접 호출)인지, IAT를 거치는 간접 호출(FF 15)인지에
;   따라 바이트 구성이 달라진다.
; - 실제 바이트 값은 조립기 버전, 변수 주소, 함수 위치에 따라 달라지므로
;   생성된 AddTwoSum.lst 파일과 대조하여 확인해야 한다.
