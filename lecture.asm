.model tiny
.286

locals @@

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.data

;~~~Video Output~~~
video = 0b800h  ; Address of video segment start.
shift = 880     ; Display shift.
color = 4eh     ; Output color.

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code

org 100h

Start:      cli                             ; Pooping declined.
            xor bx, bx
            mov es, bx

            mov bx, 4*9                     ; Signing in interruption table.
            mov ax, es:[bx]  

            mov OLD09OFS, ax                ; Moving current offset and segment shift to varibles.
            mov ax, es:[bx+2] 
            mov OLD09SEG, ax

            mov es:[bx], offset New09       ; Function itself to Interruption Table.
            mov ax, cs                      ; Second part of address.
            mov es:[bx+2], ax
            sti                             ; Pooping accepted.

Next:       in al, 60h                      ; Keyboard symbol input.
            cmp al, 1                       ; Comparing with Escape code.
            jne Next

            mov ax, 3100h                   ; Calling 31 Interrupt.

            mov dx, offset EOP
            shr dx, 4
            inc dx
            
            int 21h

New09       proc 
            push ax bx es                   ; Pushing regs before destroying it.

            mov bx, 0b800h                  ; Moving address of video segment start to ES.
            mov es, bx

            mov ah, color                   ; Setting up output color.
            mov bx, shift                   ; Moving display shift to BX.
            
            in al, 60h                      ; Keyboard symbol input.
            mov es:[bx], ax                 ; Moving symbol to video memory.

            in al, 61h                      ; Blinking with elder bit.
            or al, 80h                      
            out 61h, al
            and al, not 80h
            out 61h, al

            mov al, 20h                     ; Interruption ended.
            out 20h, al

            pop es bx ax                    ; Popping out previous register values.

            db 0eah                         ; Jump to Old Segment:Old Offset code.

            Old09Ofs dw 0
            Old09Seg dw 0

            endp

EOP:
end         Start
