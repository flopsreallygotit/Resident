;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Exits to DOS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    None
; Exit:     None
; Expects:  None
; Destroys: AX
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EXIT            macro
                nop
                mov ax, 4c00h
                int 21h
                nop
                endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shifts cursor to new line after register print
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    DI = Current display shift
; Exit:     DI = New display shift
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NEWLINE         macro
                nop
                sub di, 9d * 2
                add di, 80d * 2
                nop
                endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Allows program stay resident
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    None
; Exit:     DX = End of program address
; Expects:  EOP (Label that points to the end of program)
; Destroys: AX
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STAYRESIDENT    macro
                nop
                mov ax, 3100h
                mov dx, offset EOP
                shr dx, 4
                inc dx
                int 21h
                nop
                endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Pushes AX, BX, CX, DX, SP, BP, SI, DI, ES, DS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    None
; Exit:     None
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PUSHALL     macro
            pusha
            push es ds
            endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Pops out AX, BX, CX, DX, SP, BP, SI, DI, ES, DS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    None
; Exit:     None
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

POPALL      macro
            pop ds es
            popa
            endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Calculates display shift.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    BL = x, DL = y
; Exit:     AX
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CALCULATESHIFT      macro
                    nop
                    mov ah, 80d     ; AH = 80
                    mov al, dl      ; AL = y
                    mul ah          ; AL = y * 80
                    add al, bl      ; AL = y * 80 + x
                    shl ax, 1d      ; AX = 2 * (x + 80 * y) 
                    nop
                    endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Calculates width of frame depending on corner coordinates.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    BL = x1, BH = x2
; Exit:     CL = Width of frame.
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CALCULATEWIDTH      macro
                    nop
                    mov cl, bh  ; CL = x2
                    sub cl, bl  ; CL = x2 - x1
                    sub cl, 1d  ; CL = x2 - x1 - 1
                    nop
                    endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Calculates height of frame depending on corner coordinates.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    DL = y1, DH = y2
; Exit:     CL = Height of frame.
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CALCULATEHEIGHT     macro
                    nop
                    mov cl, dh  ; CL = y2
                    sub cl, dl  ; CL = y2 - x1
                    sub cl, 1d  ; CL = y2 - y1 - 1
                    nop
                    endm
