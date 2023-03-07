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

                ;~~~Drawing frame~~~
                call Frame
                call Regs

@@End:          POPALL
                db 0eah
                old_int_08      dd 0
                endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Draws frame depending on it left top coordinates and parameters.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    BL = x1, BH = x2, DL = y1, DH = y2, SI = Address of style string, AH = Color
; Exit:     None
; Expects:  ES = 0b800h, DF = 0
; Destroys: AX, CX, SI
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Frame       proc
            PUSHALL

            ;~~~Setting up frame parameters~~~
            mov ax, cs
            mov ds, ax

            mov bx, video
            mov es, bx

            mov bl, x1
            mov dl, y1

            mov bh, x2
            mov dh, y2

            mov si, offset style
            mov ah, color

            xor cx, cx

            ;~~~Calculating display shift of frame~~~
            push ax
            CALCULATESHIFT
            mov di, ax          ; SHIFT: DI = 2 * (x1 + 80 * y1)
            pop ax

            ;~~~Left top corner~~~
            lodsb
            stosw

            ;~~~Horizontal top line~~~
            CALCULATEWIDTH
            mov al, [si]
            rep stosw
            inc si

            ;~~~Right top corner~~~
            lodsb
            stosw

            ;~~~Columns~~~
            CALCULATEHEIGHT

            push dx     ; NO REGISTERS???

            mov dx, 79d ; Putting 80 - 1 = 79 to DX.
            add dl, bl  ; DL = 79 + x1
            sub dl, bh  ; DL = 79 + x1 - x2
            shl dx, 1d  ; DL = (79 + (x1 - x2)) * 2

            @@Next:     lodsb
                        add di, dx          ; DI = DI + DX
                        stosw

                        push cx             ; Top 10 anime betrays
                        CALCULATEWIDTH 
                        mov al, [si]        ; Setting up fill symbol
                        rep stosw
                        inc si
                        pop cx              ; idk what to say. Hello average asm enjoyers???
 
                        lodsb
                        stosw
                        
                        sub si, 3d

                        loop @@Next

            add si, 3d  ; Putting to si address of left bottom corner.

            add di, dx
            pop dx

            ;~~~Left bottom corner~~~
            lodsb
            stosw

            ;~~~Horizontal bottom line~~~
            CALCULATEWIDTH
            mov al, [si]
            rep stosw
            inc si

            ;~~~Right bottom corner~~~
            lodsb
            stosw

            POPALL

            ret
            endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Prints registers values
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Entry:    AX, BX, CX, DX
; Exit:     None
; Expects:  None
; Destroys: None
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Regs        proc
            PUSHALL

            push dx cx bx ax

            ;~~~Setting up parameters~~~
            mov ax, cs
            mov ds, ax

            mov bx, video
            mov es, bx

            mov bl, x3
            mov dl, y3

            ;~~~Calculating shift~~~
            push ax
            CALCULATESHIFT
            mov di, ax          ; SHIFT: DI = 2 * (x1 + 80 * y1)
            pop ax

            mov si, offset names

            mov cx, reg_number

@@Next:     pop bx
            push cx

            call PrintStr
            call Itoa16
            NEWLINE

            pop cx
            loop @@Next
        
            POPALL

            ret
            endp
