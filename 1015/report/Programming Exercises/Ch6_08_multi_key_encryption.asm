; Chapter 6 - Programming Exercise 8. Message Encryption
;
; Revise the encryption program in Section 6.3.4 in the following manner:
; Create an encryption key consisting of multiple characters. Use this key
; to encrypt and decrypt the plaintext by XORing each character of the key
; against a corresponding byte in the message. Repeat the key as many times
; as necessary until all plain text bytes are translated. Suppose, for
; example, the key were equal to "ABXmv#7". This is how the key would align
; with the plain text bytes:
;   Plain text:  T h i s   i s   a   P l a i n t e x t   m e s s a g e (etc.)
;   Key:         A B X m v # 7 A B X m v # 7 A B X m v # 7 A B X m v # 7
;   (The key repeats until it equals the length of the plain text...)

INCLUDE Irvine32.inc

BUFMAX = 128                        ; maximum buffer size

.data
key         BYTE "ABXmv#7"          ; multi-character encryption key
KEYSIZE = ($ - key)                 ; number of key characters (7)

sPrompt     BYTE "Enter the plain text: ",0
sEncrypt    BYTE "Cipher text (hex bytes): ",0
sDecrypt    BYTE "Decrypted:               ",0
buffer      BYTE BUFMAX+1 DUP(0)
bufSize     DWORD ?

.code
main PROC
    call InputTheString             ; input the plain text
    call TranslateBuffer            ; encrypt the buffer
    call ShowCipherHex              ; cipher bytes may be 0 or unprintable -> show in hex
    call TranslateBuffer            ; decrypt the buffer (same operation)
    mov  edx,OFFSET sDecrypt
    call DisplayMessage
    exit
main ENDP

;-----------------------------------------------------------
InputTheString PROC
; Prompts the user for a plaintext string. Saves the string and its length.
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET sPrompt
    call WriteString
    mov  ecx,BUFMAX                 ; maximum character count
    mov  edx,OFFSET buffer          ; point to the buffer
    call ReadString                 ; EAX = number of characters read
    mov  bufSize,eax                ; save the length
    call Crlf
    popad
    ret
InputTheString ENDP

;-----------------------------------------------------------
DisplayMessage PROC
; Displays a message (EDX) followed by the buffer as text.
;-----------------------------------------------------------
    pushad
    call WriteString
    mov  edx,OFFSET buffer
    call WriteString
    call Crlf
    call Crlf
    popad
    ret
DisplayMessage ENDP

;-----------------------------------------------------------
ShowCipherHex PROC
; Displays every byte of the buffer as two hex digits.
;-----------------------------------------------------------
    pushad
    mov  edx,OFFSET sEncrypt
    call WriteString
    mov  ecx,bufSize
    jecxz Done
    mov  esi,0
L1:
    movzx eax,buffer[esi]           ; one cipher byte
    mov  ebx,1                      ; size = 1 byte
    call WriteHexB                  ; display as hex
    mov  al,' '
    call WriteChar
    inc  esi
    loop L1
Done:
    call Crlf
    call Crlf
    popad
    ret
ShowCipherHex ENDP

;-----------------------------------------------------------
TranslateBuffer PROC
; Encrypts/decrypts the buffer by XORing each byte with the next key
; character; the key restarts from its first character after the last one.
; Receives: nothing   Returns: nothing
;-----------------------------------------------------------
    pushad
    mov  ecx,bufSize                ; loop counter = message length
    jecxz Done                      ; empty message
    mov  esi,0                      ; ESI = index into buffer
    mov  edi,0                      ; EDI = index into key
L1:
    mov  al,key[edi]                ; current key character
    xor  buffer[esi],al             ; translate one byte
    inc  esi                        ; next message byte
    inc  edi                        ; next key character
    cmp  edi,KEYSIZE                ; reached the end of the key?
    jb   L2
    mov  edi,0                      ; yes: wrap around to the start of the key
L2:
    loop L1
Done:
    popad
    ret
TranslateBuffer ENDP

END main
