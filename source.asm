section "Header", ROM0[$100]
    jr EntryPoint

    ds $150 - @, 0  ; Make room for the header

EntryPoint:
    ld de, $0000    ; this is where you change the initial x (upper byte) and y (lower byte)

; this abomination would be much cleaner if the debug print didn't require \r\n
FillLoop:
    ld a, "7"
    ld h, a
    ld bc, (8 * $100) + (StringTable - $FF00)
.outer:
    ld l, 8
.inner:
    ldh [c], a
    inc c
    dec l
    jr nz, .inner
.outerEnd:
    ld a, "\r"
    ldh [c], a
    inc c
    ld a, "\n"
    ldh [c], a
    inc c
    ld a, h
    dec b
    jr nz, .outer
.end:
    dec c
    xor a, a
    ldh [c], a

Search:
    ld h, "0" - 1
    call Recursion

; this is the debug print activation routine for no$gmb and BGB. this does not work on hardware.
BGBDebugPrint:
    ld d, d
    jr .end
    dw $6464        ; magic
    dw $0001        ; load from address space
    dw StringTable  ; address to load from
    dw 0            ; bank 0 (irrelevant to HRAM)
.end:

HangMachine:
    db $76          ; this places a halt instruction without a nop after it as opposed to "halt", saving one byte.
                    ; this halt hangs permanently because by default all interrupts are disabled but interrupting is enabled.
                    ; if this halt isn't here, the program will repeat for a long time because of a return address stack underflow

Recursion:
    inc h
.depthCheck:
    ld a, "7"
    cp a, h
    jr z, .abort
.positionBoundCheck:
    ld a, 8
    cp a, d
    jr c, .abort
    cp a, e
    jr c, .abort
    ld a, StringTable - $FF00
    ld c, a
    ld l, 10        ; row length
.yLoop:
    add a, e
    dec l
    jr nz, .yLoop
.suboptimalCheck
    add a, d
    ld c, a
    ldh a, [c]
    cp a, h
    jr c, .abort
    ld a, h
    ldh [c], a

.theActualSearch:
    push de
    inc d
    inc e
    inc e
    call Recursion
    inc d
    dec e
    call Recursion
    dec e
    dec e
    call Recursion
    dec d
    dec e
    call Recursion
    dec d
    dec d
    call Recursion
    dec d
    inc e
    call Recursion
    inc e
    inc e
    call Recursion
    inc d
    inc e
    call Recursion
    pop de

.abort:
    dec h
    ret

section "Memory", HRAM
StringTable:
    ds 80           ; (8 + 2) * 8 (eight spaces per line, two control characters (\r\n) per line, eight lines. null terminator replaces last control character)
                    ; with the default stack pointer and our table in HRAM, we get 23 words of stack space. nice.
