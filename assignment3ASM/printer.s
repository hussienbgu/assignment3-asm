section .rodata
    floatFormat: db "%.2f",0
    floatFormatComma: db "%.2f,",0
    floatFormatLine: db "%.2f",10,0
    FormatIntLine: db " score: %d",10,0
    FormatIntComma: db " ID: %d,",0

section .text
    global Printer_Function
    extern CO_SCHEDULER
    extern NumberOfDrones
    extern Drones_dynamic_array
    extern Target_X
    extern Target_Y
    extern resume
    extern printf

%macro printFloat 1
    pushad
    finit
    fld dword %1
    sub esp, 8
    fstp qword [esp]
    ffree
    push dword floatFormatComma
    call printf
    add esp, 12
    popad
%endmacro

%macro printFloatWithLine 1
    pushad
    finit
    fld dword %1
    sub esp, 8
    fstp qword [esp]
    ffree
    push dword floatFormatLine
    call printf
    add esp, 12
    popad
%endmacro

%macro printIntLine 1
    pushad
    push dword %1
    push dword FormatIntLine
    call printf
    add esp, 8
    popad
%endmacro

%macro printIntComma 1
    pushad
    push dword %1
    push dword FormatIntComma
    call printf
    add esp, 8
    popad
%endmacro

Printer_Function:
    printFloat [Target_X]
    printFloatWithLine [Target_Y]    
    mov ebx, [Drones_dynamic_array]
    mov ecx, 0

    Loop:
        mov eax, dword [ebx + 20] ;;isActive
        cmp eax, 0
        je last
        inc ecx
        printIntComma ecx

        dec ecx
        printFloat [ebx+0]
        printFloat [ebx+4]
        printFloat [ebx+12]
        printFloat [ebx+8]
        printIntLine [ebx+16]
    last:
        add ebx, 24
        inc ecx
        cmp ecx, [NumberOfDrones]
        jne Loop
    
    mov ebx, [CO_SCHEDULER]
    call resume
    jmp Printer_Function