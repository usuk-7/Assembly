; Chapter 6 - Programming Exercise 9. Validating a PIN
;
; Banks use a Personal Identification Number (PIN) to uniquely identify each
; customer. Let us assume that our bank has a specified range of acceptable
; values for each digit in its customers' 5-digit PINs. The table below
; contains the acceptable ranges, where digits are numbered from left to
; right in the PIN.
;       Digit Number    Range
;            1          5 to 9
;            2          2 to 5
;            3          4 to 8
;            4          1 to 4
;            5          3 to 6
; Your task is to create a procedure named Validate_PIN that receives a
; pointer to an array of byte containing a 5-digit PIN. Declare two arrays
; to hold the minimum and maximum range values, and use these arrays to
; validate each digit of the PIN that was passed to the procedure. If any
; digit is found to be outside its valid range, immediately return the
; digit's position (between 1 and 5) in the EAX register. If the entire PIN
; is valid, return 0 in EAX. Preserve all other register values between
; calls to the procedure. Write a test program that calls Validate_PIN at
; least four times, using both valid and invalid byte arrays.

INCLUDE Irvine32.inc

PIN_LEN = 5

.data
minDigits   BYTE 5,2,4,1,3          ; minimum allowed value of digits 1..5
maxDigits   BYTE 9,5,8,4,6          ; maximum allowed value of digits 1..5

; Test PINs (each digit stored as a number 0..9)
pin1        BYTE 5,2,4,1,3          ; 52413 : valid
pin2        BYTE 4,3,5,3,4          ; 43534 : digit 1 out of range
pin3        BYTE 5,9,5,3,4          ; 59534 : digit 2 out of range
pin4        BYTE 5,2,4,0,3          ; 52403 : digit 4 out of range
pin5        BYTE 5,2,4,1,7          ; 52417 : digit 5 out of range
pin6        BYTE 6,4,5,3,5          ; 64535 : valid by the table above

msgPin      BYTE "PIN #",0
msgValid    BYTE ": Valid",0dh,0ah,0
msgInvalid  BYTE ": Invalid, digit position out of range = ",0

.code
main PROC
    mov  esi,OFFSET pin1
    mov  ebx,1
    call TestPin
    mov  esi,OFFSET pin2
    mov  ebx,2
    call TestPin
    mov  esi,OFFSET pin3
    mov  ebx,3
    call TestPin
    mov  esi,OFFSET pin4
    mov  ebx,4
    call TestPin
    mov  esi,OFFSET pin5
    mov  ebx,5
    call TestPin
    mov  esi,OFFSET pin6
    mov  ebx,6
    call TestPin
    exit
main ENDP

;-----------------------------------------------------------
TestPin PROC
; Calls Validate_PIN and prints the outcome.
; Receives: ESI = offset of the PIN, EBX = test number
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET msgPin
    call WriteString
    mov  eax,ebx
    call WriteDec                   ; test number
    call Validate_PIN               ; EAX = 0 (valid) or failing position
    cmp  eax,0
    jne  Bad
    mov  edx,OFFSET msgValid
    call WriteString
    jmp  Done
Bad:
    mov  edx,OFFSET msgInvalid
    call WriteString
    call WriteDec                   ; position of the bad digit
    call Crlf
Done:
    popad
    ret
TestPin ENDP

;-----------------------------------------------------------
Validate_PIN PROC
; Checks each digit of a 5-digit PIN against minDigits/maxDigits.
; Receives: ESI = offset of the PIN (5 bytes, each 0..9)
; Returns:  EAX = 0 if every digit is in range,
;           otherwise EAX = position (1..5) of the first bad digit.
; All other registers are preserved.
;-----------------------------------------------------------
    push ebx
    push ecx

    mov  ebx,0                      ; EBX = digit index (0..4)
    mov  ecx,PIN_LEN                ; loop counter
L1:
    mov  al,[esi+ebx]               ; current digit
    cmp  al,minDigits[ebx]
    jb   BadDigit                   ; below the minimum
    cmp  al,maxDigits[ebx]
    ja   BadDigit                   ; above the maximum
    inc  ebx                        ; next digit
    loop L1

    mov  eax,0                      ; all digits valid
    jmp  Done

BadDigit:
    mov  eax,ebx
    inc  eax                        ; convert index (0-based) to position (1-based)

Done:
    pop  ecx
    pop  ebx
    ret
Validate_PIN ENDP

END main
