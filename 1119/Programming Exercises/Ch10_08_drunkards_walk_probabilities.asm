; Ch10 Programming Exercise 8. Drunkard's Walk with Probabilities
;
; When testing the DrunkardWalk program, you may have noticed that the professor doesn't seem
; to wander very far from the starting point. This is no doubt caused by an equal probability of the
; professor moving in any direction. Modify the program so there is a 50% probability the professor
; will continue to walk in the same direction as he or she did when taking the previous step. There
; should be a 10% probability that he or she will reverse direction and a 20% probability that he or
; she will turn either right or left. Assign a default starting direction before the loop begins.
;
; 확률 해석: 직진 50%, 반대 10%, 오른쪽 20%, 왼쪽 20% (합 100%)

INCLUDE Irvine32.inc

WalkMax = 50
StartX  = 25
StartY  = 25

; 방향 번호를 시계 방향 순서로 정함 → +1 = 오른쪽, +2 = 반대, +3 = 왼쪽 (mod 4)
NORTH = 0
EAST  = 1
SOUTH = 2
WEST  = 3

DrunkardWalk STRUCT
    path      COORD WalkMax DUP(<0,0>)
    pathsUsed WORD 0
DrunkardWalk ENDS

DisplayPosition PROTO currX:WORD, currY:WORD

.data
aWalk DrunkardWalk <>

.code
main PROC
    call Randomize
    mov  esi,OFFSET aWalk
    call TakeDrunkenWalk
    exit
main ENDP

;-------------------------------------------------------
TakeDrunkenWalk PROC
    LOCAL currX:WORD, currY:WORD
;
; 이전 방향을 기준으로 확률에 따라 다음 방향을 정해 걷는다.
; Receives: ESI = DrunkardWalk 구조체 주소
; 레지스터: EBX = 현재 방향(0~3)
;-------------------------------------------------------
    pushad
    mov  edi,esi
    add  edi,OFFSET DrunkardWalk.path
    mov  ecx,WalkMax
    mov  currX,StartX
    mov  currY,StartY
    mov  ebx,NORTH                      ; 기본 시작 방향

Again:
    mov  ax,currX
    mov  (COORD PTR [edi]).X,ax
    mov  ax,currY
    mov  (COORD PTR [edi]).Y,ax
    INVOKE DisplayPosition, currX, currY

    ; 0~99 난수로 방향 변화 결정
    mov  eax,100
    call RandomRange
    .IF eax < 50                        ; 0~49  : 50% 직진 (변화 없음)
      nop
    .ELSEIF eax < 60                    ; 50~59 : 10% 반대 방향
      add ebx,2
    .ELSEIF eax < 80                    ; 60~79 : 20% 오른쪽
      add ebx,1
    .ELSE                               ; 80~99 : 20% 왼쪽
      add ebx,3
    .ENDIF
    and  ebx,3                          ; mod 4 (0~3 유지)

    ; 방향대로 한 칸 이동
    .IF ebx == NORTH
      dec currY
    .ELSEIF ebx == EAST
      inc currX
    .ELSEIF ebx == SOUTH
      inc currY
    .ELSE                               ; WEST
      dec currX
    .ENDIF

    add  edi,TYPE COORD
    dec  ecx
    jnz  Again

    mov  (DrunkardWalk PTR [esi]).pathsUsed, WalkMax
    popad
    ret
TakeDrunkenWalk ENDP

;-------------------------------------------------------
DisplayPosition PROC currX:WORD, currY:WORD
; 현재 X,Y 출력
;-------------------------------------------------------
.data
commaStr BYTE ",",0
.code
    pushad
    movzx eax,currX
    call  WriteDec
    mov   edx,OFFSET commaStr
    call  WriteString
    movzx eax,currY
    call  WriteDec
    call  Crlf
    popad
    ret
DisplayPosition ENDP

END main
