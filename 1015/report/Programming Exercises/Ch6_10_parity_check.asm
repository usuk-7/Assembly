; Chapter 6 - Programming Exercise 10. Parity Checking
;
; Data transmission systems and file subsystems often use a form of error
; detection that relies on calculating the parity (even or odd) of blocks of
; data. Your task is to create a procedure that returns True in the EAX
; register if the bytes in an array contain even parity, or False if the
; parity is odd. In other words, if you count all the bits in the entire
; array, their count will be even or odd. Preserve all other register values
; between calls to the procedure. Write a test program that calls your
; procedure twice, each time passing it a pointer to an array and the length
; of the array. The procedure's return value in EAX should be 1 (True) or
; 0 (False). For test data, create two arrays containing at least 10 bytes,
; one having even parity, and another having odd parity.
;
; Tip: INC/ADD/etc. also change the Parity flag, so the flag is examined
; only once, right after the last XOR/OR, instead of during the loop.

INCLUDE Irvine32.inc

.data
; Number of 1 bits: 1+2+3+4+5+6+7+8+0+2 = 38 (even)
evenArray   BYTE 01h,03h,07h,0Fh,1Fh,3Fh,7Fh,0FFh,00h,81h
; Number of 1 bits: 1+2+3+4+5+6+7+8+0+1 = 37 (odd)
oddArray    BYTE 01h,03h,07h,0Fh,1Fh,3Fh,7Fh,0FFh,00h,80h

msgEven     BYTE "evenArray -> EAX = ",0
msgOdd      BYTE "oddArray  -> EAX = ",0
msgTrue     BYTE "  (True: even parity)",0dh,0ah,0
msgFalse    BYTE "  (False: odd parity)",0dh,0ah,0

.code
main PROC
    ; ---- test 1: even parity ----
    mov  esi,OFFSET evenArray
    mov  ecx,LENGTHOF evenArray
    call ParityCheck
    mov  edx,OFFSET msgEven
    call WriteString
    call WriteDec                   ; 1 expected
    cmp  eax,1
    jne  Test1False
    mov  edx,OFFSET msgTrue
    jmp  Show1
Test1False:
    mov  edx,OFFSET msgFalse
Show1:
    call WriteString

    ; ---- test 2: odd parity ----
    mov  esi,OFFSET oddArray
    mov  ecx,LENGTHOF oddArray
    call ParityCheck
    mov  edx,OFFSET msgOdd
    call WriteString
    call WriteDec                   ; 0 expected
    cmp  eax,1
    jne  Test2False
    mov  edx,OFFSET msgTrue
    jmp  Show2
Test2False:
    mov  edx,OFFSET msgFalse
Show2:
    call WriteString

    exit
main ENDP

;-----------------------------------------------------------
ParityCheck PROC
; Determines whether the whole array has an even number of 1 bits.
; Receives: ESI = offset of a byte array, ECX = length of the array
; Returns:  EAX = 1 (True) if the total number of 1 bits is even,
;           EAX = 0 (False) if it is odd.
; All other registers are preserved.
; Idea: XOR of all bytes has the same parity as the whole array.
;-----------------------------------------------------------
    push esi
    push ecx
    push edx

    mov  dl,0                       ; DL = running XOR of all bytes
    jecxz Check                     ; empty array: DL = 0 -> even parity

L1:
    xor  dl,[esi]                   ; fold the next byte into DL
    inc  esi                        ; (INC changes PF, so PF is read only after the loop)
    loop L1                         ; LOOP does not change any flag

Check:
    or   dl,dl                      ; set PF from the final XOR value
    jp   IsEven                     ; PF = 1: even number of 1 bits
    mov  eax,0                      ; odd parity -> False
    jmp  Done
IsEven:
    mov  eax,1                      ; even parity -> True

Done:
    pop  edx
    pop  ecx
    pop  esi
    ret
ParityCheck ENDP

END main
