; Chapter 6 - Programming Exercise 7. Probabilities and Colors
;
; Write a program that randomly chooses among three different colors for
; displaying text on the screen. Use a loop to display 20 lines of text,
; each with a randomly chosen color. The probabilities for each color are
; to be as follows: white = 30%, blue = 10%, green = 60%.
; Suggestion: Generate a random integer between 0 and 9. If the resulting
; integer falls in the range 0 to 2 (inclusive), choose white. If the
; integer equals 3, choose blue. If the integer falls in the range 4 to 9
; (inclusive), choose green. Test your program by running it ten times,
; each time observing whether the distribution of line colors appears to
; match the required probabilities.

INCLUDE Irvine32.inc

.data
msgLine     BYTE "Line ",0
msgText     BYTE ": This line has a randomly chosen color.",0dh,0ah,0
msgWhite    BYTE "White lines: ",0
msgBlue     BYTE "Blue lines:  ",0
msgGreen    BYTE "Green lines: ",0
whiteCount  DWORD 0
blueCount   DWORD 0
greenCount  DWORD 0

.code
main PROC
    call Randomize
    mov  esi,1                      ; ESI = line number (1..20)

L1:
    mov  eax,10
    call RandomRange                ; EAX = 0..9
    cmp  eax,2
    jbe  UseWhite                   ; 0..2  -> white (30%)
    cmp  eax,3
    je   UseBlue                    ; 3     -> blue  (10%)

    ; 4..9 -> green (60%)
    inc  greenCount
    mov  eax,green + (black * 16)
    jmp  ApplyColor

UseWhite:
    inc  whiteCount
    mov  eax,white + (black * 16)
    jmp  ApplyColor

UseBlue:
    inc  blueCount
    mov  eax,blue + (black * 16)

ApplyColor:
    call SetTextColor               ; EAX = foreground + background*16

    mov  edx,OFFSET msgLine
    call WriteString
    mov  eax,esi
    call WriteDec                   ; line number
    mov  edx,OFFSET msgText
    call WriteString

    inc  esi
    cmp  esi,20
    jbe  L1                         ; repeat for lines 1..20

    ; restore the default color and show the counts for checking the odds
    mov  eax,white + (black * 16)
    call SetTextColor
    call Crlf

    mov  edx,OFFSET msgWhite
    call WriteString
    mov  eax,whiteCount
    call WriteDec
    call Crlf

    mov  edx,OFFSET msgBlue
    call WriteString
    mov  eax,blueCount
    call WriteDec
    call Crlf

    mov  edx,OFFSET msgGreen
    call WriteString
    mov  eax,greenCount
    call WriteDec
    call Crlf

    exit
main ENDP

END main
