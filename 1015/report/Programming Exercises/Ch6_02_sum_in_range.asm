; Chapter 6 - Programming Exercise 2. Summing Array Elements in a Range
;
; Create a procedure that returns the sum of all array elements falling
; within the range j...k (inclusive). Write a test program that calls the
; procedure twice, passing a pointer to a signed doubleword array, the size
; of the array, and the values of j and k. Return the sum in the EAX
; register, and preserve all other register values between calls to the
; procedure.

INCLUDE Irvine32.inc

.data
array   SDWORD -20,-5,0,7,12,25,40,-13,8,100
msg1    BYTE "Sum of elements in 0..20   = ",0
msg2    BYTE "Sum of elements in -15..10 = ",0

.code
main PROC
    ; ---- first call: j = 0, k = 20  -> 0 + 7 + 12 + 8 = 27 ----
    mov  esi,OFFSET array
    mov  ecx,LENGTHOF array
    mov  ebx,0
    mov  edx,20
    call SumInRange
    mov  edx,OFFSET msg1
    call WriteString
    call WriteInt                   ; EAX = sum
    call Crlf

    ; ---- second call: j = -15, k = 10 -> -5 + 0 + 7 + -13 + 8 = -3 ----
    mov  esi,OFFSET array
    mov  ecx,LENGTHOF array
    mov  ebx,-15
    mov  edx,10
    call SumInRange
    mov  edx,OFFSET msg2
    call WriteString
    call WriteInt
    call Crlf

    exit
main ENDP

;-----------------------------------------------------------
SumInRange PROC
; Sums the elements of a signed doubleword array that lie in j..k.
; Receives: ESI = offset of the array
;           ECX = number of elements
;           EBX = j (minimum, signed)
;           EDX = k (maximum, signed)
; Returns:  EAX = sum (all other registers preserved)
;-----------------------------------------------------------
    push esi
    push ecx

    mov  eax,0                      ; sum = 0
    jecxz Done                      ; empty array

L1:
    cmp  SDWORD PTR [esi],ebx       ; element < j ?
    jl   Skip                       ; yes: not in range
    cmp  SDWORD PTR [esi],edx       ; element > k ?
    jg   Skip                       ; yes: not in range
    add  eax,[esi]                  ; in range: add to sum
Skip:
    add  esi,TYPE SDWORD            ; next element
    loop L1

Done:
    pop  ecx
    pop  esi
    ret
SumInRange ENDP

END main
