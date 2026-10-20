; Chapter 6 - Programming Exercise 6. Boolean Calculator (2)
;
; Continue the solution program from Exercise 5 by implementing the
; following procedures:
;  - AND_op: Prompt the user for two hexadecimal integers. AND them together
;    and display the result in hexadecimal.
;  - OR_op:  Prompt the user for two hexadecimal integers. OR them together
;    and display the result in hexadecimal.
;  - NOT_op: Prompt the user for a hexadecimal integer. NOT the integer and
;    display the result in hexadecimal.
;  - XOR_op: Prompt the user for two hexadecimal integers. Exclusive-OR them
;    together and display the result in hexadecimal.
;
; The menu is still table-driven (Exercise 5): the table now holds the
; offsets of the real operation procedures. Each procedure first displays the
; name of the operation, then does the work.

INCLUDE Irvine32.inc

.data
menuText    BYTE 0dh,0ah
            BYTE "1. x AND y",0dh,0ah
            BYTE "2. x OR y",0dh,0ah
            BYTE "3. NOT x",0dh,0ah
            BYTE "4. x XOR y",0dh,0ah
            BYTE "5. Exit program",0dh,0ah
            BYTE "Choose (1-5): ",0

nameAND     BYTE "Operation: x AND y",0dh,0ah,0
nameOR      BYTE "Operation: x OR y",0dh,0ah,0
nameNOT     BYTE "Operation: NOT x",0dh,0ah,0
nameXOR     BYTE "Operation: x XOR y",0dh,0ah,0
nameExit    BYTE "Exiting program...",0dh,0ah,0
msgInvalid  BYTE "Invalid choice. Please enter 1 to 5.",0dh,0ah,0

promptX     BYTE "Enter hexadecimal integer x: ",0
promptY     BYTE "Enter hexadecimal integer y: ",0
msgResult   BYTE "Result (hex): ",0

; Table of menu keys and procedure offsets.
CaseTable   BYTE '1'
            DWORD AND_op
EntrySize = ($ - CaseTable)
            BYTE '2'
            DWORD OR_op
            BYTE '3'
            DWORD NOT_op
            BYTE '4'
            DWORD XOR_op
            BYTE '5'
            DWORD Exit_op
NumberOfEntries = ($ - CaseTable) / EntrySize

choice      BYTE ?

.code
main PROC
MenuLoop:
    mov  edx,OFFSET menuText
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf
    mov  choice,al
    call SelectOperation            ; table-driven dispatch
    cmp  choice,'5'
    jne  MenuLoop
    exit
main ENDP

;-----------------------------------------------------------
SelectOperation PROC
; Receives: AL = menu key. Calls the procedure found in CaseTable.
;-----------------------------------------------------------
    pushad
    mov  ebx,OFFSET CaseTable
    mov  ecx,NumberOfEntries
L1:
    cmp  al,[ebx]
    jne  L2
    call NEAR PTR [ebx + 1]
    jmp  Done
L2:
    add  ebx,EntrySize
    loop L1
    mov  edx,OFFSET msgInvalid
    call WriteString
Done:
    popad
    ret
SelectOperation ENDP

;-----------------------------------------------------------
AND_op PROC
; Reads two hex integers, ANDs them, displays the result in hex.
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET nameAND
    call WriteString
    mov  edx,OFFSET promptX
    call WriteString
    call ReadHex                    ; EAX = x
    mov  ebx,eax                    ; keep x in EBX
    mov  edx,OFFSET promptY
    call WriteString
    call ReadHex                    ; EAX = y
    and  eax,ebx                    ; EAX = y AND x
    mov  edx,OFFSET msgResult
    call WriteString
    call WriteHex
    call Crlf
    popad
    ret
AND_op ENDP

;-----------------------------------------------------------
OR_op PROC
; Reads two hex integers, ORs them, displays the result in hex.
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET nameOR
    call WriteString
    mov  edx,OFFSET promptX
    call WriteString
    call ReadHex
    mov  ebx,eax
    mov  edx,OFFSET promptY
    call WriteString
    call ReadHex
    or   eax,ebx                    ; EAX = y OR x
    mov  edx,OFFSET msgResult
    call WriteString
    call WriteHex
    call Crlf
    popad
    ret
OR_op ENDP

;-----------------------------------------------------------
NOT_op PROC
; Reads one hex integer, inverts all its bits, displays the result in hex.
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET nameNOT
    call WriteString
    mov  edx,OFFSET promptX
    call WriteString
    call ReadHex                    ; EAX = x
    not  eax                        ; EAX = NOT x
    mov  edx,OFFSET msgResult
    call WriteString
    call WriteHex
    call Crlf
    popad
    ret
NOT_op ENDP

;-----------------------------------------------------------
XOR_op PROC
; Reads two hex integers, XORs them, displays the result in hex.
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET nameXOR
    call WriteString
    mov  edx,OFFSET promptX
    call WriteString
    call ReadHex
    mov  ebx,eax
    mov  edx,OFFSET promptY
    call WriteString
    call ReadHex
    xor  eax,ebx                    ; EAX = y XOR x
    mov  edx,OFFSET msgResult
    call WriteString
    call WriteHex
    call Crlf
    popad
    ret
XOR_op ENDP

;-----------------------------------------------------------
Exit_op PROC
; Menu item 5: just announce the exit (main loop ends afterwards).
;-----------------------------------------------------------
    mov  edx,OFFSET nameExit
    call WriteString
    ret
Exit_op ENDP

END main
