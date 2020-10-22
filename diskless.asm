include    bios.inc

#define SERP    bn2
#define SERN    b2
#define SERSEQ     req
#define SERREQ     seq

rclisp:    equ     09000h            ; address for rclisp
rcforth:   equ     0a000h            ; address for rcforth
edtasm:    equ     0b000h            ; address for edtasm
rcbasic:   equ     0c000h            ; address for rcbasic
visual02:  equ     0e000h            ; address of Visual/02

base:      equ     07f00h            ; XMODEM data segment
baud:      equ     base+0
init:      equ     base+1
block:     equ     base+2            ; current block
count:     equ     base+3            ; byte send/receive count
xdone:     equ     base+4
h1:        equ     base+5
h2:        equ     base+6
h3:        equ     base+7
txrx:      equ     base+8            ; buffer for tx/rx
temp1:     equ     base+150
temp2:     equ     base+152
buffer:    equ     base+154          ; address for input buffer
ack:       equ     06h
nak:       equ     15h
soh:       equ     01h
etx:       equ     03h
eot:       equ     04h
can:       equ     18h
csub:      equ     1ah

           org     8000h
           lbr     cold              ; jump to cold start
           lbr     warm              ; jump to warm start
openw:     lbr     xopenw            ; open XMODEM channel for writing
openr:     lbr     xopenr            ; open XMODEM channel for reading
read:      lbr     xread             ; read from XMODEM channel
write:     lbr     xwrite            ; write to XMODEM channel
closew:    lbr     xclosew           ; close XMODEM channel for writing
closer:    lbr     xcloser           ; close XMODEM channel for reading

; *******************************************************
; ***** Cold start, P=0, need initcall and autobaud *****
; *******************************************************
cold:      mov     r2,01ffh          ; set stack in low memory
           mov     r6,cold2          ; need to startup address after initcall
           lbr     f_initcall        ; setup SCALL and SRET
cold2:     sep     scall             ; now call the autobaud
           dw      f_setbd
; *******************************************************
; ***** Warm start, p=3, initcall and autobaud done *****
; *******************************************************
warm:      mov     r2,01ffh          ; set stack to low memory
           sex     r2
main:      ldi     0ch               ; form feed
           sep     scall             ; clear the screen
           dw      f_type
           mov     rd,02004h         ; set screen position
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display banner
           dw      f_inmsg
           db      'Pico/Elf V2',0
           mov     rd,02006h         ; set position
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '1. Rc/Basic L2',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '2. Rc/Forth',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '3. Rc/Lisp',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '4. EDTASM',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '5. Visual/02',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '6. Minimon',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '7. Dump Memory',0
           inc     rd                ; next row
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; display menu item
           dw      f_inmsg
           db      '8. Load Memory',0
           inc     rd                ; next row
           inc     rd                ; next row
           ghi     rd                ; get x
           adi     3                 ; add 3
           phi     rd                ; put it back
           sep     scall             ; set cursor position
           dw      gotoxy
           sep     scall             ; show prompt
           dw      f_inmsg
           db      'Option ? ',0
           mov     rf,buffer         ; use lowest memory for input buffer
           sep     scall             ; get input from user
           dw      f_input
           mov     rf,buffer         ; use lowest memory for input buffer
           ldn     rf                ; get input character
           smi     '1'               ; check for Rc/Basic
           lbz     option1           ; jump if so
           ldn     rf                ; get input character
           smi     '2'               ; check for Rc/Forth
           lbz     option2           ; jump if so
           ldn     rf                ; get input character
           smi     '3'               ; check for Rc/Lisp
           lbz     option3           ; jump if so
           ldn     rf                ; get input character
           smi     '4'               ; check for EDTASM
           lbz     option4           ; jump if so
           ldn     rf                ; get input character
           smi     '5'               ; check for Visual/02
           lbz     option5           ; jump if so
           ldn     rf                ; get input character
           smi     '6'               ; check for Minimon
           lbz     option6           ; jump if so
           ldn     rf                ; get input character
           smi     '7'               ; check for Memory Dump
           lbz     dump              ; jump if so


loop:      lbr     main

option1:   mov     r0,rcbasic+3      ; setup for call to Rc/Basic
           sep     r0                ; jump to Rc/Basic

option2:   mov     r0,rcforth        ; setup for call to Rc/Forth
           sep     r0                ; jump to Rc/Forth

option3:   mov     r0,rclisp         ; setup for call to Rc/Lisp
           sep     r0                ; jump to Rc/Lisp

option4:   mov     r0,edtasm         ; setup for call to EDTASM
           sep     r0                ; jump to EDTASM

option5:   mov     r0,visual02       ; setup for call to Visual/02
           sep     r0                ; jump to Visual/02
           
option6:   ldi     0ch               ; clear the screen
           sep     scall
           dw      f_type
           lbr     0f913h            ; jump to BIOS minimon

dump:      ldi     0ch               ; clear the screen
           sep     scall
           dw      f_type
           sep     scall             ; display program message
           dw      f_inmsg
           db      'Memory Dump',10,13,10,13,'Start address (hex): ',0
           mov     rf,buffer         ; point to input buffer
           sep     scall             ; get input from user
           dw      f_input
           mov     rf,buffer         ; convert hex
           sep     scall
           dw      f_hexin
           mov     rf,temp1          ; point to temporary storage
           ghi     rd                ; get high byte of address
           str     rf                ; and store it
           inc     rf
           glo     rd                ; get low byte of address
           str     rf                ; and store it
           sep     scall             ; prompt for ending address
           dw      f_inmsg
           db      10,13,'Ending address (hex): ',0
           mov     rf,buffer         ; point to input buffer
           sep     scall             ; get input from user
           dw      f_input
           mov     rf,buffer         ; convert hex
           sep     scall
           dw      f_hexin
           mov     rf,temp1+1        ; point to lsb of start address
           sex     rf                ; point X to start address
           glo     rd                ; subtract start address from end address
           sm
           plo     rc                ; and put into count
           dec     rf                ; point to high byte
           ghi     rd                ; subtract high byte of address
           smb
           phi     rc                ; rc now has total byte count
           sex     r2                ; point x back to stack
           mov     rf,temp2          ; point to temp 2
           ghi     rc                ; and store count
           str     rf
           inc     rf
           glo     rc
           str     rf
           sep     scall             ; show start message
           dw      f_inmsg
           db      10,13,10,13,'Starting XMODEM dump. . .',0
           sep     scall             ; open XMODEM channel
           dw      xopenw
           mov     rf,temp1          ; point to start address
           mov     rc,4              ; wrill write start address and size
           sep     scall             ; write them to the XMODEM channel
           dw      xwrite
           mov     rd,temp1          ; now need to retrieve values for block write
           lda     rd                ; start with starting address
           phi     rf
           lda     rd
           plo     rf                ; rf now has starting memory address
           lda     rd                ; now get byte count
           phi     rc
           lda     rd
           plo     rc
           sep     scall             ; now write memory to XMODEM channel
           dw      xwrite
           sep     scall             ; close xmodem channel
           dw      xclosew
           lbr     main



; *********************************************************
; ***** Takes value in D and makes 2 char ascii in RF *****
; *********************************************************
itoa:      plo     rf                ; save value
           ldi     0                 ; clear high byte
           phi     rf
           glo     rf                ; recover low
itoalp:    smi     10                ; see if greater than 10
           lbnf    itoadn            ; jump if not
           plo     rf                ; store new value
           ghi     rf                ; get high character
           adi     1                 ; add 1
           phi     rf                ; and put it back
           glo     rf                ; retrieve low character
           lbr     itoalp            ; and keep processing
itoadn:    glo     rf                ; get low character
           adi     030h              ; convert to ascii
           plo     rf                ; put it back
           ghi     rf                ; get high character
           adi     030h              ; convert to ascii
           phi     rf                ; put it back
           sep     sret              ; return to caller

; *********************************************
; ***** Send vt100 sequence to set cursor *****
; ***** RD.0 = y                          *****
; ***** RD.1 = x                          *****
; *********************************************
gotoxy:    ldi     27                ; escape character
           sep     scall             ; write it
           dw      f_type
           ldi     '['               ; square bracket
           sep     scall             ; write it
           dw      f_type
           glo     rd                ; get x
           sep     scall             ; convert to ascii
           dw      itoa
           ghi     rf                ; high character
           sep     scall             ; write it
           dw      f_type
           glo     rf                ; low character
           sep     scall             ; write it
           dw      f_type
           ldi     ';'               ; need separator
           sep     scall             ; write it
           dw      f_type
           ghi     rd                ; get y
           sep     scall             ; convert to ascii
           dw      itoa
           ghi     rf                ; high character
           sep     scall             ; write it
           dw      f_type
           glo     rf                ; low character
           sep     scall             ; write it
           dw      f_type
           ldi     'H'               ; need terminator for position
           sep     scall             ; write it
           dw      f_type
           sep     sret              ; return to caller

; *******************************************
; ***** Open XMODEM channel for writing *****
; *******************************************
xopenw:    push    rf                ; save consumed register
           mov     rf,block          ; current block number
           ldi     1                 ; starts at 1
           str     rf                ; store into block number
           inc     rf                ; point to byte count
           ldi     0                 ; set count to zero
           str     rf                ; store to byte count
           mov     rf,baud           ; place to store baud constant
           ghi     re                ; need to turn off echo
           str     rf                ; save it
           ani     0feh
           phi     re                ; put it back
xopenw1:   sep     scall             ; read a byte from the serial port
           dw      f_read
           smi     nak               ; need a nak character
           lbnz    xopenw1           ; wait until a nak is received
           pop     rf                ; recover rf
           sep     sret              ; and return to caller

; ***********************************
; ***** Write to XMODEM channel *****
; ***** RF - pointer to data    *****
; ***** RC - Count of data      *****
; ***********************************
xwrite:    push    r8                ; save consumed registers
           push    ra
           mov     ra,count          ; need address of count
           ldn     ra                ; get count
           str     r2                ; store for add
           plo     r8                ; put into count as well
           ldi     txrx.0            ; low byte of buffer
           add                       ; add current byte count
           plo     ra                ; put into ra
           ldi     txrx.1            ; high byte of buffer
           adci    0                 ; propagate carry
           phi     ra                ; ra now has address
xwrite1:   lda     rf                ; retrieve next byte to write
           str     ra                ; store into buffer
           inc     ra
           inc     r8                ; increment buffer count
           glo     r8                ; get buffer count
           ani     080h              ; check for 128 bytes in buffer
           lbz     xwrite2           ; jump if not
           sep     scall             ; send current block
           dw      xsend
           ldi     0                 ; zero buffer count
           plo     r8
           mov     ra,txrx           ; reset buffer position
xwrite2:   dec     rc                ; decrement count
           glo     rc                ; see if done
           lbnz    xwrite1           ; loop back if not
           ghi     rc                ; need to check high byte
           lbnz    xwrite1           ; loop back if not
           mov     ra,count          ; need to write new count
           glo     r8                ; get the count
           str     ra                ; and save it
           pop     ra                ; pop consumed registers
           pop     r8
           sep     sret              ; and return to caller


; *******************************
; ***** Send complete block *****
; *******************************
xsend:     push    rf                 ; save consumed registers
           push    rc
xsendnak:  ldi     soh                ; need to send soh character
           phi     rc                 ; initial value for checksum
           sep     scall              ; send it
           dw      f_type
           mov     rf,block           ; need current block number
           ldn     rf                 ; get block number
           str     r2                 ; save it
           ghi     rc                 ; get checksum
           add                        ; add in new byte
           phi     rc                 ; put it back
           ldn     r2                 ; recover block number
           sep     scall              ; and send it
           dw      f_tty
           ldn     rf                 ; get block number back
           sdi     255                ; subtract from 255
           str     r2                 ; save it
           ghi     rc                 ; get current checksum
           add                        ; add in inverted block number
           phi     rc                 ; put it back
           ldn     r2                 ; recover inverted block number
           sep     scall              ; send it
           dw      f_tty
           ldi     128                ; 128 bytes to write
           plo     rc                 ; place into counter
           mov     rf,txrx            ; point rf to data block
xsend1:    lda     rf                 ; retrieve next byte
           str     r2                 ; save it
           ghi     rc                 ; get checksum
           add                        ; add in new byte
           phi     rc                 ; save checksum
           ldn     r2                 ; recover byte
           sep     scall              ; and send it
           dw      f_tty
           dec     rc                 ; decrement byte count
           glo     rc                 ; get count
           lbnz    xsend1             ; jump if more bytes to send
           ghi     rc                 ; get checksum byte
           sep     scall              ; and send it
           dw      f_type
xsend2:    sep     scall              ; read byte from serial port
           dw      f_read
           str     r2                 ; save it
           smi     nak                ; was it a nak
           lbz     xsendnak           ; resend block if nak
           mov     rf,block           ; point to block number
           ldn     rf                 ; get block number
           adi     1                  ; increment block number
           str     rf                 ; and put it back
           inc     rf                 ; point to buffer count
           ldi     0                  ; set buffer count
           str     rf
           pop     rc                 ; recover registers
           pop     rf
           sep     sret               ; and return

; **************************************
; ***** Close XMODEM write channel *****
; **************************************
xclosew:   push    rf                 ; save consumed registers
           push    rc
           mov     rf,count           ; get count of characters unsent
           ldn     rf                 ; retrieve count
           lbz     xclosewd           ; jump if no untransmitted characters
           plo     rc                 ; put into count
           str     r2                 ; save for add
           ldi     txrx.0             ; low byte of buffer
           add                        ; add characters in buffer
           plo     rf                 ; put into rf
           ldi     txrx.1             ; high byte of transmit buffer
           adci    0                  ; propagate carry
           phi     rf                 ; rf now has position to write at
xclosew1:  ldi     csub               ; character to put into buffer
           str     rf                 ; store into transmit buffer
           inc     rf                 ; point to next position
           inc     rc                 ; increment byte count
           glo     rc                 ; get count
           ani     080h               ; need 128 bytes
           lbz     xclosew1           ; loop if not enough
           sep     scall              ; send final block
           dw      xsend
xclosewd:  ldi     eot                ; need to send eot
           sep     scall              ; send it
           dw      f_type
           mov     rf,baud            ; need to restore baud constant
           ldn     rf                 ; get it
           phi     re                 ; put it back
           pop     rc                 ; recover consumed registers
           pop     rf
           sep     sret               ; and return

; *******************************************
; ***** Open XMODEM channel for reading *****
; *******************************************
xopenr:    push    rf                 ; save consumed registers
           mov     rf,baud            ; point to baud constant
           ghi     re                 ; get baud constant
           str     rf                 ; save it
           ani     0feh               ; turn off echo
           phi     re                 ; put it back
           inc     rf                 ; point to init block
           ldi     nak                ; need to send initial nak
           str     rf                 ; store it
           inc     rf                 ; point to block number
           ldi     1                  ; expect 1
           str     rf                 ; store it
           inc     rf                 ; point to count
           ldi     128                ; mark as no bytes in buffer
           str     rf                 ; store it
           inc     rf                 ; point to done
           ldi     0                  ; mark as not done
           str     rf
            
  ldi 0
  plo rf
  phi rf
  ldi 010h
  plo re
xopenr1:   dec     rf
           glo     rf
           lbnz    xopenr1
           ghi     rf
           lbnz    xopenr1
           dec     re
           glo     re
           lbnz    xopenr1
           pop     rf                 ; recover consumed register
           sep     sret               ; and return

; ************************************
; ***** Read from XMODEM channel *****
; ***** RF - pointer to data     *****
; ***** RC - Count of data       *****
; ************************************
xread:     push    ra                 ; save consumed registers
           push    r9
           mov     ra,count           ; need current read count
           ldn     ra                 ; get read count
           plo     r9                 ; store it here
           str     r2                 ; store for add
           ldi     txrx.0             ; low byte of buffer address
           add                        ; add count
           plo     ra                 ; store into ra
           ldi     txrx.01            ; high byte of buffer address
           adci    0                  ; propagate carry
           phi     ra                 ; ra now has address
xreadlp:   glo     r9                 ; get count
           ani     080h               ; need to see if bytes to read
           lbz     xread1             ; jump if so
           sep     scall              ; receive another block
           dw      xrecv
           mov     ra,txrx            ; back to beginning of buffer
           ldi     0                  ; zero count
           plo     r9
xread1:    lda     ra                 ; read byte from receive buffer
           str     rf                 ; store into output
           inc     rf
           inc     r9                 ; increment buffer count
           dec     rc                 ; decrement read count
           glo     rc                 ; get low of count
           lbnz    xreadlp            ; loop back if more to read
           ghi     rc                 ; need to check high byte
           lbnz    xreadlp            ; loop back if more
           mov     ra,count           ; need to store buffer count
           glo     r9                 ; get it
           str     ra                 ; and store it
           pop     r9                 ; recover used registers
           pop     ra
           sep     sret               ; and return to caller

; ********************************
; ***** Receive XMODEM block *****
; ********************************
xrecv:     push    rf                 ; save consumed registers
           push    rc
xrecvnak:
xrecvlp:   sep     scall              ; receive a byte
           dw      readblk
           lbdf    xrecveot           ; jump if EOT received
           mov     rf,h2              ; point to received block number
           ldn     rf                 ; get it
           str     r2                 ; store for comparison
           mov     rf,block           ; get expected block number
           ldn     rf                 ; retrieve it
           sm                         ; check against received block number
           lbnz    xrecvnak1          ; jump if bad black number
           mov     rf,h1              ; point to header byte
           ldi     0                  ; checksum starts at zero
           phi     rc
           ldi     131                ; 131 bytes need to be added to checksum
           plo     rc
xrecv1:    lda     rf                 ; next byte from buffer
           str     r2                 ; store for add
           ghi     rc                 ; get checksum
           add                        ; add in byte
           phi     rc                 ; put checksum back
           dec     rc                 ; decrement byte count
           glo     rc                 ; see if done
           lbnz    xrecv1             ; jump if more to add up
           ldn     rf                 ; get received checksum
           str     r2                 ; store for comparison
           ghi     rc                 ; get computed checksum
           sm                         ; and compare
           lbnz    xrecvnak1          ; jump if bad

           mov     rf,init            ; point to init number
           ldi     ack                ; need to send an ack
           str     rf
           inc     rf                 ; point to block number
           ldn     rf                 ; get block number
           adi     1                  ; increment block number
           str     rf                 ; put it back
           inc     rf                 ; point to count
           ldi     0                  ; no bytes read from this block
           str     rf
xrecvret:  pop     rc                 ; recover consumed registers
           pop     rf
           sep     sret               ; return to caller

xrecvnak1: mov     rf,init            ; point to init byte
           ldi     nak                ; need a nak
           str     rf                 ; store it
           lbr     xrecvnak           ; need to have packet resent

xrecveot:  mov     rf,xdone           ; need to mark EOT received
           ldi     1
           str     rf
           lbr     xrecvret           ; jump to return

; *************************************
; ***** Close XMODEM read channel *****
; *************************************
xcloser:   ldi     018h               ; send CAN to remote end
           sep     scall
           dw      f_type
           mov     rf,baud            ; need to restore baud constant
           ldn     rf                 ; get it
           phi     re                 ; put it back
           sep     sret               ; return to caller

           org     8500h
readblk:   push    rc                 ; save consumed registers
           push    ra
           push    rd
           push    r9
           ldi     132                ; 132 bytes to receive
           plo     ra
           ldi     1                  ; first character flag
           phi     ra

           mov     rf,init            ; get byte to send
           ldn     rf                 ; retrieve it
           phi     r9                 ; Place for transmit
           mov     rf,h1              ; point to input buffer
           mov     rd,delay           ; address of bit delay routine

type:      ldi     9                   ; 9 bits to send
           plo     r9
           ldi     0
           shr
sendlp:    bdf     sendnb              ; jump if no bit
           SERSEQ                      ; set output
           br      sendct
sendnb:    SERREQ                      ; reset output
           br      sendct
sendct:    sep     rd                  ; perform bit delay
           sex r2
           sex r2
           ghi     r9
           shrc
           phi     r9
           dec     r9
           glo     r9
           bnz     sendlp
           SERREQ                      ; set stop bits

readblk1:  ldi     8                  ; 8 bits to receive
           plo     rc
           ghi     re                  ; first delay is half bit size
           phi     rc
           shr
           shr
           phi     re
           SERP    $                   ; wait for transmission
           sep     rd                  ; wait half the pulse width
           ghi     rc                  ; recover baud constant
           phi     re
           sep     rd                  ; move past start bit
           br      recvlp
recvlp0:   br      recvlp1             ; equalize between 0 and 1
recvlp:    ghi     rc
           shr                         ; shift right
           SERN    recvlp0             ; jump if zero bi
           ori     128                 ; set bit
recvlp1:   phi     rc
           sep     rd                  ; perform bit delay
           dec     rc                  ; decrement bit count
           nop
           nop
           glo     rc                  ; check for zero
           bnz     recvlp              ; loop if not
recvdone:  ghi     rc                  ; get character
           str     rf                  ; store into buffer
           inc     rf                  ; increment buffer
           ghi     ra                  ; get first character flag
           shr                         ; shift into df
           phi     ra                  ; and put it back
           bnf     recvgo              ; jump if not first character
           ghi     rc                  ; get character
           smi     04h                 ; check for EOT
           bnz     recvgo              ; jump if not EOT
           ldi     1                   ; indicate EOT received
           br      recvret
recvgo:    dec     ra                  ; decrement receive count
           glo     ra                  ; see if done
           lbnz    readblk1            ; jump if more bytes to read
           ldi     0                   ; clear df flag for full block read
recvret:   shr
           pop     r9
           pop     rd                  ; recover consumed registers
           pop     ra
           pop     rc
           sep     sret                ; and return to caller

           sep     r3
delay:     ghi     re                  ; get baud constant
           shr                         ; remove echo flag
           plo     re                  ; put into counter
           sex     r2                  ; waste a cycle
delay1:    dec     re                  ; decrement counter
           glo     re                  ; get count
           bz      delay-1             ; return if zero
           br      delay1              ; otherwise keep going

