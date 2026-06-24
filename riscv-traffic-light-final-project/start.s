.section .text.start
.global _start

_start:
    la sp, stack_top
    call main

loop:
    j loop

.section .bss
.space 1024
stack_top: