;~~~WARNING: These functions work only with 0-terminated strings :WARNING~~~

; Good_string_example:  db "aboba", 0
; Bad_string_example:   db "I don't read warnings xD"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Counts length of string
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    SI = Address of string
; Exit:     CX = Length of string
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Strlen      proc
            xor cx, cx
            push ax si

@@Next:     inc cx
            lodsb
            cmp al, 0
            jne @@Next

            dec cx    
            pop si ax

            ret
            endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Finds index of symbol in string
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    SI = Address of string, 
;           BL = Symbol
; Exit:     CX = -1 / Index of symbol in string
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Strchr          proc
                push ax si
                xor cx, cx

@@Next:         inc cx
                lodsb

                cmp al, 0
                je @@Terminate

                cmp al, bl
                je @@End

                jmp @@Next

@@Terminate:    xor cx, cx

@@End:          dec cx
                pop si ax

                ret
                endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Copies the first n symbols of string
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    SI = Address of string
;           DI = Address of string with copied symbols
;           CX = Number of symbols to copy (n)
; Exit:     None
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Strncpy     proc
            push bx cx di si

@@Next:     movsb
            mov bl, ds:[di]

            cmp bl, 0
            je @@End

            loop @@Next

@@End:      xor bl, bl
            mov ds:[di], bl

            pop si di cx bx

            ret
            endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Compares the first n symbols of strings
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    SI = Address of first string
;           DI = Address of second string
;           CX = Number of symbols to compare (n)
; Exit:     AX = 0 String1[:n] == String2[:n]
;           AX > 0 String1[:n] >  String2[:n]
;           AX < 0 String1[:n] <  String2[:n]
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Strncmp     proc
            push bx cx di si

@@Next:     lodsb

            mov bl, [di]
            inc di

            dec cx
            sub al, bl

            cmp al, 0
            jne @@End

            loop @@Next 

@@End:      pop si di cx bx

            ret
            endp
