;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Places interrupt in Interruption Table
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    BX = Address of interrupt to replace
;           DI = Address of buffer for saving old interrupt
;           SI = Address of new interrupt
; Exit:     None
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PlaceInterrupt      proc
                    PUSHALL

                    xor ax, ax
                    mov es, ax

                    ;~~~Old Interrupt Saving~~~
                    mov ax, word ptr es:[bx]
                    mov [di], ax

                    mov ax, word ptr es:[bx + 2]
                    mov [di + 2], ax

                    ;~~~Placing new interrupt~~~    ;~~~~~~~~~~~~~~~\
                    cli                             ;               |
                                                    ;               |
                    mov ax, si                      ;               |
                    mov word ptr es:[bx], ax        ;              \|/
                                                    ;       Interrupt calls are forbidden.        
                    mov ax, cs                      ;              /|\
                    mov word ptr es:[bx + 2], ax    ;               |
                                                    ;               |
                    sti                             ;~~~~~~~~~~~~~~~/

                    POPALL
                    ret
                    endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Switches frame print flag.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    None
; Exit:     None
; Expects:  Custom 9 interruption
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

New_int_09      proc
                PUSHALL

                ;~~~Checking keyboard input~~~
                in al, 60h
                cmp al, button
                jne @@End

                ;~~~Switching up frame~~~
                not cs:flag
                cmp cs:flag, 00h
                je @@Write
                
                mov ax, video
                mov ds, ax
                xor si, si

                mov ax, buffer
                mov es, ax
                xor di, di

                mov cx, buf_size
                call WriteBuffer
                jmp @@End

@@Write:        mov ax, video
                mov es, ax
                xor di, di

                mov ax, buffer
                mov ds, ax
                xor si, si

                mov cx, buf_size
                call WriteBuffer

@@End:          mov ah, al          ; Blinking with elder bit.
                or al, 80h
                out 61h, al
                mov al, ah
                out 61h, al
                
                mov al, 20h         ; Ending interruption.
                out 20h, al
                    
                POPALL

                db 0eah             ; Jump on old interruption.
                old_int_09      dd 0
                endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Prints buffer.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    CX = Size of buffer
;           DI = Address of start of buffer for copy.
;           SI = Address of start of buffer.
; Exit:     None
; Expects:  None
; Destroys: AX
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WriteBuffer     proc
@@Next:         lodsw
                stosw
                loop @@Next

                ret
                endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Prints frame with regs if flag is true
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    None
; Exit:     None
; Expects:  Custom 8 interruption
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

New_int_08      proc
                PUSHALL
                cmp cs:flag, 0
                je @@End

                ; call Regs

                ;~~~Drawing frame~~~
                ; PUSHALL

                ; mov ax, cs
                ; mov ds, ax

                ; mov bl, x1
                ; mov bh, x2

                ; mov dl, y1
                ; mov dh, y2

                ; mov ah, color

                ; mov si, offset style

                ; call Frame

                ; POPALL

                mov bx, video
                mov es, bx

                mov al, 48d
                mov ah, 4eh

                mov di, shift

                stosw

@@End:          POPALL
                db 0eah
                old_int_08      dd 0
                endp

; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Draws frame depending on it left top coordinates and parameters.
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Entry:    BL = x1, BH = x2, DL = y1, DH = y2, SI = Address of style string, Stack: Fill, Color
; ; Exit:     None
; ; Expects:  ES = 0b800h, DF = 0
; ; Destroys: AX, CX, SI
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Frame       proc
;             ;~~~Calculating display shift of frame~~~
;             push ax
;             call CalculateShift
;             mov di, ax          ; SHIFT: DI = 2 * (x1 + 80 * y1)
;             pop ax

;             ;~~~Left top corner~~~
;             mov al, [si]    ; TODO lodsb
;             stosw
;             inc si

;             ;~~~Horizontal top line~~~
;             call CalculateWidth
;             mov al, [si]
;             rep stosw
;             inc si

;             ;~~~Right top corner~~~
;             mov al, [si]
;             stosw
;             inc si

;             ;~~~Columns~~~
;             call CalculateHeight

;             push dx     ; NO REGISTERS???

;             mov dx, 79d ; Putting 80 - 1 = 79 to DX.
;             add dl, bl  ; DL = 79 + x1
;             sub dl, bh  ; DL = 79 + x1 - x2
;             shl dx, 1d  ; DL = (79 + (x1 - x2)) * 2

;             @@Next:     mov al, [si]
;                         add di, dx          ; DI = DI + DX
;                         stosw
;                         inc si

;                         push cx             ; Top 10 anime betrays

;                         call CalculateWidth 
;                         mov al, [si]        ; Setting up fill symbol
;                         rep stosw
;                         inc si

;                         pop cx              ; idk what to say. Hello average asm enjoyers???
;                         mov al, [si]
;                         stosw
                        
;                         dec si              ; Returning to left column symbol.
;                         dec si

;                         loop @@Next

;             add si, 3d  ; Putting to si address of left bottom corner.

;             add di, dx
;             pop dx

;             ;~~~Left bottom corner~~~
;             mov al, [si]
;             stosw
;             inc si

;             ;~~~Horizontal bottom line~~~
;             call CalculateWidth
;             mov al, [si]
;             rep stosw
;             inc si

;             ;~~~Right bottom corner~~~
;             mov al, [si]
;             stosw

;             ret
;             endp

; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Calculates display shift.
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Entry:    BL = x, DL = y
; ; Exit:     AX
; ; Expects:  None
; ; Destroys: None
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; CalculateShift      proc
;                     mov ah, 80d     ; AH = 80
;                     mov al, dl      ; AL = y

;                     mul ah          ; AL = y * 80

;                     add al, bl      ; AL = y * 80 + x
;                     shl ax, 1d      ; AX = 2 * (x + 80 * y) 

;                     ret
;                     endp

; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Calculates width of frame depending on corner coordinates.
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Entry:    BL = x1, BH = x2
; ; Exit:     CL = Width of frame.
; ; Expects:  None
; ; Destroys: None
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; CalculateWidth      proc
;                     mov cl, bh  ; CL = x2
;                     sub cl, bl  ; CL = x2 - x1
;                     sub cl, 1d  ; CL = x2 - x1 - 1
;                     ret
;                     endp

; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Calculates height of frame depending on corner coordinates.
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ; Entry:    DL = y1, DH = y2
; ; Exit:     CL = Height of frame.
; ; Expects:  None
; ; Destroys: None
; ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; CalculateHeight     proc
;                     mov cl, dh  ; CL = y2
;                     sub cl, dl  ; CL = y2 - x1
;                     sub cl, 1d  ; CL = y2 - y1 - 1
;                     ret
;                     endp

