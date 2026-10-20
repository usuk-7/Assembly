; Chapter 6 - Programming Exercise 1. Filling an Array
;
; Create a procedure that fills an array of doublewords with N random
; integers, making sure the values fall within the range j...k, inclusive.
; When calling the procedure, pass a pointer to the array that will hold
; the data, pass N, and pass the values of j and k. Preserve all register
; values between calls to the procedure. Write a test program that calls
; the procedure twice, using different values for j and k. Verify your
; results using a debugger.

INCLUDE Irvine32.inc

.data
arrayA  SDWORD 10 DUP(?)
arrayB  SDWORD 12 DUP(?)
msgA    BYTE "Array A (10 values, range 20..40):",0dh,0ah,0
msgB    BYTE "Array B (12 values, range -50..50):",0dh,0ah,0

.code
main PROC
    call Randomize                  ; seed the random number generator once

    ; ---- first call: j = 20, k = 40 ----
    mov  esi,OFFSET arrayA          ; ESI = pointer to array
    mov  ecx,LENGTHOF arrayA        ; ECX = N
    mov  ebx,20                     ; EBX = j (minimum)
    mov  edx,40                     ; EDX = k (maximum)
    call FillArray

    mov  edx,OFFSET msgA
    call WriteString
    mov  esi,OFFSET arrayA
    mov  ecx,LENGTHOF arrayA
    call ShowArray

    ; ---- second call: j = -50, k = 50 (negative values included) ----
    mov  esi,OFFSET arrayB
    mov  ecx,LENGTHOF arrayB
    mov  ebx,-50
    mov  edx,50
    call FillArray

    mov  edx,OFFSET msgB
    call WriteString
    mov  esi,OFFSET arrayB
    mov  ecx,LENGTHOF arrayB
    call ShowArray

    exit
main ENDP

;-----------------------------------------------------------
FillArray PROC
; Fills a doubleword array with N random integers in range j..k.
; Receives: ESI = offset of the array
;           ECX = N (number of elements)
;           EBX = j (minimum value, signed)
;           EDX = k (maximum value, signed)
; Returns:  nothing (all registers are preserved)
;-----------------------------------------------------------
    pushad                          ; save all registers
    jecxz Done                      ; N = 0: nothing to do

    mov  eax,edx
    sub  eax,ebx
    inc  eax                        ; EAX = k - j + 1 = size of the range
    mov  edx,eax                    ; keep range size in EDX

L1:
    mov  eax,edx                    ; EAX = range size
    call RandomRange                ; EAX = random value 0 .. range-1
    add  eax,ebx                    ; shift into j .. k
    mov  [esi],eax                  ; store in array
    add  esi,TYPE SDWORD            ; next element
    loop L1

Done:
    popad                           ; restore all registers
    ret
FillArray ENDP

;-----------------------------------------------------------
ShowArray PROC
; Displays a signed doubleword array on one line.
; Receives: ESI = offset of the array, ECX = number of elements
;-----------------------------------------------------------
    pushad
    jecxz Done
L1:
    mov  eax,[esi]
    call WriteInt
    mov  al,' '
    call WriteChar
    add  esi,TYPE SDWORD
    loop L1
Done:
    call Crlf
    popad
    ret
ShowArray ENDP

END main
