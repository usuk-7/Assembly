; Ch3 Programming Exercise 2: Symbolic Integer Constants
; Write a program that defines symbolic constants for all seven days of the
; week. Create an array variable that uses the symbols as initializers.

INCLUDE Irvine32.inc

; 요일을 나타내는 기호 정수 상수 정의 (일=0 ~ 토=6)
SUNDAY    = 0
MONDAY    = 1
TUESDAY   = 2
WEDNESDAY = 3
THURSDAY  = 4
FRIDAY    = 5
SATURDAY  = 6

.data
; 위에서 정의한 기호 상수들을 초기값으로 사용하는 배열
weekDays BYTE SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY

.code
main PROC
    ; weekDays 배열의 각 값을 출력해서 상수가 제대로 들어갔는지 확인
    mov esi, OFFSET weekDays
    mov ecx, LENGTHOF weekDays
L1:
    movzx eax, BYTE PTR [esi]   ; 배열 원소를 부호 확장 없이 EAX로 로드
    call WriteDec                 ; 정수 값 출력
    call Crlf
    inc esi
    loop L1

    invoke ExitProcess, 0
main ENDP
END main
