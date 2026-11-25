; Ch10 Programming Exercise 7. The Professor's Lost Phone
;
; When the professor took the drunkard's walk around campus in Section 10.1.6, we discovered that
; he lost his cell phone somewhere along the path. When you simulate the drunken walk, your pro-
; gram must drop the phone wherever the professor is standing at some random time interval. Each
; time you run the program, the cell phone will be lost at a different time interval (and location).

INCLUDE Irvine32.inc
INCLUDE Macros.inc

WalkMax = 50
StartX  = 25
StartY  = 25

DrunkardWalk STRUCT
    path      COORD WalkMax DUP(<0,0>)   ; 걸음별 위치
    pathsUsed WORD 0                     ; 걸은 횟수
    phoneStep WORD 0                     ; 폰을 떨어뜨린 걸음 번호(1부터)
    phoneLoc  COORD <0,0>                ; 폰을 떨어뜨린 위치
DrunkardWalk ENDS

DisplayPosition PROTO stepNum:DWORD, currX:WORD, currY:WORD

.data
aWalk DrunkardWalk <>

.code
main PROC
    call Randomize                  ; 실행할 때마다 다른 난수
    mov  esi,OFFSET aWalk
    call TakeDrunkenWalk

    ; 결과: 폰을 잃어버린 시점과 위치 출력
    call Crlf
    mWrite "The phone was dropped at step "
    movzx eax,aWalk.phoneStep
    call WriteDec
    mWrite ", location ("
    movzx eax,aWalk.phoneLoc.X
    call WriteDec
    mWrite ","
    movzx eax,aWalk.phoneLoc.Y
    call WriteDec
    mWrite ")"
    call Crlf
    exit
main ENDP

;-------------------------------------------------------
TakeDrunkenWalk PROC
    LOCAL currX:WORD, currY:WORD, dropAt:DWORD
;
; 무작위 방향으로 WalkMax 걸음 걷고, 무작위로 고른
; 한 걸음에서 그 자리에 폰을 떨어뜨린다.
; Receives: ESI = DrunkardWalk 구조체 주소
;-------------------------------------------------------
    pushad
    mov  edi,esi
    add  edi,OFFSET DrunkardWalk.path   ; EDI = path 배열 시작
    mov  currX,StartX
    mov  currY,StartY

    ; 폰을 떨어뜨릴 걸음 번호: 1 ~ WalkMax 중 무작위
    mov  eax,WalkMax
    call RandomRange                    ; 0 ~ WalkMax-1
    inc  eax
    mov  dropAt,eax

    mov  ebx,1                          ; 현재 걸음 번호
    mov  ecx,WalkMax
Again:
    ; 현재 위치를 배열에 기록
    mov  ax,currX
    mov  (COORD PTR [edi]).X,ax
    mov  ax,currY
    mov  (COORD PTR [edi]).Y,ax
    INVOKE DisplayPosition, ebx, currX, currY

    ; 지금이 폰을 떨어뜨릴 걸음이면 위치 저장
    .IF ebx == dropAt
      mov  (DrunkardWalk PTR [esi]).phoneStep,bx
      mov  ax,currX
      mov  (DrunkardWalk PTR [esi]).phoneLoc.X,ax
      mov  ax,currY
      mov  (DrunkardWalk PTR [esi]).phoneLoc.Y,ax
      mWrite "   <-- phone dropped here!"
      call Crlf
    .ENDIF

    ; 방향 선택 (0=North, 1=South, 2=West, 3=East)
    mov  eax,4
    call RandomRange
    .IF eax == 0
      dec currY
    .ELSEIF eax == 1
      inc currY
    .ELSEIF eax == 2
      dec currX
    .ELSE
      inc currX
    .ENDIF

    add  edi,TYPE COORD                 ; 다음 COORD
    inc  ebx
    dec  ecx
    jnz  Again                          ; 루프 몸체가 길어 LOOP 대신 사용

    mov  (DrunkardWalk PTR [esi]).pathsUsed, WalkMax
    popad
    ret
TakeDrunkenWalk ENDP

;-------------------------------------------------------
DisplayPosition PROC USES eax, stepNum:DWORD, currX:WORD, currY:WORD
; "걸음번호: X,Y" 형식으로 출력
;-------------------------------------------------------
    mov   eax,stepNum
    call  WriteDec
    mWrite ": "
    movzx eax,currX
    call  WriteDec
    mWrite ","
    movzx eax,currY
    call  WriteDec
    call  Crlf
    ret
DisplayPosition ENDP

END main
