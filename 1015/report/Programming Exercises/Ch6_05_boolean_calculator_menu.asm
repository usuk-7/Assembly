; Chapter 6 - Programming Exercise 5. Boolean Calculator (1)
;
; Create a program that functions as a simple boolean calculator for 32-bit
; integers. It should display a menu that asks the user to make a selection
; from the following list:
;     1. x AND y
;     2. x OR y
;     3. NOT x
;     4. x XOR y
;     5. Exit program
; When the user makes a choice, call a procedure that displays the name of
; the operation about to be performed. You must implement this procedure
; using the Table-Driven Selection technique, shown in Section 6.5.4.
; (You will implement the operations in Exercise 6.)

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

; Table of lookup values (menu keys) and procedure offsets.
CaseTable   BYTE '1'
            DWORD Show_AND
EntrySize = ($ - CaseTable)             ; size of one table entry (5 bytes)
            BYTE '2'
            DWORD Show_OR
            BYTE '3'
            DWORD Show_NOT
            BYTE '4'
            DWORD Show_XOR
            BYTE '5'
            DWORD Show_Exit
NumberOfEntries = ($ - CaseTable) / EntrySize

choice      BYTE ?

.code
main PROC
MenuLoop:
    mov  edx,OFFSET menuText
    call WriteString
    call ReadChar                   ; AL = key pressed
    call WriteChar                  ; echo it
    call Crlf
    mov  choice,al                  ; remember the choice
    call SelectOperation            ; table-driven: show the operation name
    cmp  choice,'5'
    jne  MenuLoop                   ; repeat until the user chooses Exit
    exit
main ENDP

;-----------------------------------------------------------
SelectOperation PROC
; Searches CaseTable for the key in AL and calls the matching procedure.
; Receives: AL = menu key character
; Returns:  nothing (registers preserved)
;-----------------------------------------------------------
    pushad
    mov  ebx,OFFSET CaseTable       ; EBX points to the table
    mov  ecx,NumberOfEntries        ; loop counter
L1:
    cmp  al,[ebx]                   ; match found?
    jne  L2                         ; no: continue
    call NEAR PTR [ebx + 1]         ; yes: call the procedure whose address follows the key
    jmp  Done
L2:
    add  ebx,EntrySize              ; point to the next entry
    loop L1
    mov  edx,OFFSET msgInvalid      ; no entry matched
    call WriteString
Done:
    popad
    ret
SelectOperation ENDP

;-----------------------------------------------------------
; Each procedure displays the name of its operation.
;-----------------------------------------------------------
Show_AND PROC
    mov  edx,OFFSET nameAND
    call WriteString
    ret
Show_AND ENDP

Show_OR PROC
    mov  edx,OFFSET nameOR
    call WriteString
    ret
Show_OR ENDP

Show_NOT PROC
    mov  edx,OFFSET nameNOT
    call WriteString
    ret
Show_NOT ENDP

Show_XOR PROC
    mov  edx,OFFSET nameXOR
    call WriteString
    ret
Show_XOR ENDP

Show_Exit PROC
    mov  edx,OFFSET nameExit
    call WriteString
    ret
Show_Exit ENDP

END main
