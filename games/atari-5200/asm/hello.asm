; Atari 5200 "Hello World" sample code
; Written by Daniel Boris (dboris@comcast.net)
;
; Assemble with DASM
;

        processor 6502

DMACTL  equ     $D400           ;DMA Control
sDMACTL equ     $07             ;DMA Control Shadow
DLISTL  equ     $D402           ;Display list lo
DLISTH  equ     $D403           ;Display list hi
sDLISTL equ     $05             ;Display list lo shadow
sDLISTH equ     $06             ;Display list hi shadow
CHBASE  equ     $D409           ;Character set base
CHACTL  equ     $D401           ;Character control
NMIEN   equ     $D40E           ;NMI Enable
COLOR1  equ     $0D             ;Color 1 shadow
COLOR2  equ     $0E             ;Color 2 shadow

        org     $4000           ;Start of cartridge area
        sei                     ;Disable interrupts
        cld                     ;Clear decimal mode
Start
        ldx     #$00
        lda     #$00
crloop1    
        sta     $00,x           ;Clear zero page
        sta     $D400,x         ;Clear ANTIC
        sta     $C000,x         ;Clear GTIA
        sta     $E800,x         ;Clear POKEY
        dex
        bne     crloop1
        ldy     #$00            ;Clear Ram
        lda     #$02            ;Start at $0200
        sta     $81             
        lda     #$00
        sta     $80
crloop2
        lda     #$00            
crloop3
        sta     ($80),y         ;Store data
        iny                     ;Next byte
        bne     crloop3         ;Branch if not done page
        inc     $81             ;Next page
        lda     $81
        cmp     #$40            ;Check if end of RAM
        bne     crloop2         ;Branch if not

        ldx     #$21
dlloop                          ;Create Display List
        lda     dlist,x         ;Get byte
        sta     $1000,x         ;Copy to RAM
        dex                     ;next byte
        bpl     dlloop
        
        lda     #$03            ;point IRQ vector
        sta     $200            ;to BIOS routine
        lda     #$FC
        sta     $201
        lda     #$B8            ;point VBI vector
        sta     $202            ;to BIOS routine
        lda     #$FC
        sta     $203
        lda     #$B2            ;point Deferred VBI
        sta     $204            ;to BIOS routine
        lda     #$FC
        sta     $205
        lda     #$03
        sta     CHACTL          ;Set Character Control
        lda     #$84            ;Set color PF2
        sta     COLOR2             
        lda     #$0F            ;Set color PF1
        sta     COLOR1
        lda     #$00            ;Set Display list pointer
        sta     sDLISTL
        sta     DLISTL
        lda     #$10
        sta     sDLISTH
        sta     DLISTH
        lda     #$f8            ;Set Charcter Set Base
        sta     CHBASE
        lda     #$22            ;Enable DMA
        sta     sDMACTL
        lda     #$40            ;Enable NMI
        sta     NMIEN

print
        ldy     #$00           
        cld
prloop
        lda     text1,y         ;Get character
        sec
        sbc     #$20            ;Convert to ATASCII
        sta     $1800,y         ;Store in video memory
        iny                     ;Next character
        cpy     #11             
        bne     prloop
wait
        jmp     wait

        ;Display list data
        org     $b000
dlist   .byte     $70,$70,$70,$42,$00,$18,$02,$02,$02,$02,$02,$02,$02
        .byte     $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
        .byte      $02,$02,$02,$41,$00,$10

        ;Text data
         org     $b100
text1   .byte      "ASM - HELLO, ATARI 5200"

        org     $bffd
        .byte   $FF         ;Don't display Atari logo
        .byte   $00,$40     ;Start code at $4000
