CODEP: equ 0 
SPP: equ 4
STKSZ: equ 16*1024

section .rodata
    extern Scheduler_Function
    extern Target_Function
    extern Printer_Function
    extern Drone_Function

    Format_int: db "%d", 0, 0
    Format_float: db "%f", 0, 0
    MAX_INTEGER: dd 65535

section .bss
    global NumberOfDrones
    global SchedulerCycle
    global StepsToPrint
    global Distance
    global Seed
    global Target_X
    global Target_Y
    global Drones_dynamic_array
    global CO_Drones_array

    NumberOfDrones: resb 4
    SchedulerCycle: resb 4
    StepsToPrint: resb 4
    Distance: resb 4
    Seed: resb 4 

    Drones_dynamic_array: resb 4

    Target_X: resb 4
    Target_Y: resb 4

    CO_Drones_array: resb 4

    SchedulerStk: resb STKSZ
    TargetStk: resb STKSZ
    PrinterStk: resb STKSZ

    SPT: resb 4
    SPMAIN: resb 4
    CURR: resb 4

section .data
    global CO_PRINTER
    global CO_SCHEDULER
    global CO_TARGET
    global Current_Drone
    global div_value
    global sub_value
    global return_from_random_algorithm
    global val_0
    global val_100
    global val_180
    global val_360
    Current_Drone: dd 0
    CO0: dd Scheduler_Function
         dd SchedulerStk + STKSZ
    CO1:    dd Target_Function
                  dd TargetStk + STKSZ
    CO2:   dd Printer_Function
                  dd PrinterStk + STKSZ
    
    CO_SCHEDULER: dd CO0
    CO_TARGET: dd CO1
    CO_PRINTER: dd CO2
    return_from_random_algorithm: dd 0
    div_value: dd 100
    sub_value: dd 0
  
    val_0: dd 0
    val_100: dd 100
    val_180: dd 180
    val_360: dd 360

section .text
    align 16
    global main
    global end_scheduler
    global Random_algorthim
    global resume
    extern malloc 
    extern free
    extern sscanf
    extern create_new_target
%macro allocateArrays 0
        allocateMem [NumberOfDrones], 24, Drones_dynamic_array
        allocateMem [NumberOfDrones], 12, CO_Drones_array
%endmacro

%macro allocateCODrones 0
    mov ebx, [CO_Drones_array]
    mov ecx, 0
    %%allocateLoop:
        mov dword [ebx], Drone_Function
        lea edx, [ebx + 8]
        allocateMem 1, STKSZ, edx
        mov edx, [ebx + 8]
        add edx, STKSZ
        mov [ebx + SPP], edx
        call co_init
        add ebx, 12
        inc ecx
        cmp ecx, [NumberOfDrones]
        jne %%allocateLoop
%endmacro

%macro allocateMem 3
    pushad
    push dword %3
    push dword %2
    push dword %1
    pop eax
    pop ebx
    mul ebx

    push eax
    call malloc
    add esp, 4
    pop ebx
    mov [ebx], eax
    popad
%endmacro

%macro initial_co 0
    mov ebx, [CO_SCHEDULER]
    call co_init
    mov ebx, [CO_PRINTER]
    call co_init
    call create_new_target
    mov ebx, [CO_TARGET]
    call co_init
%endmacro

%macro Free 1
    pushad
    push %1
    call free
    add esp, 4
    popad
%endmacro
%macro FreeALL 0
    mov ebx, [CO_Drones_array]
    mov ecx, 0
    %%freeDrones:
        mov edx, [ebx + 8]
        Free edx
        add ebx, 12
        inc ecx
        cmp ecx, [NumberOfDrones]
        jne %%freeDrones
        Free dword [Drones_dynamic_array]
        Free dword [CO_Drones_array]
%endmacro

%macro initDrones 0
        mov ebx, [Drones_dynamic_array]
        mov ecx, 0

        %%Loop:
            mov dword [ebx +20], 1
            mov dword [ebx + 16], 0
            get_random_value 100, [ebx + 0]
            get_random_value 100, [ebx + 4]
            get_random_value 100, [ebx + 8]
            get_random_value 360, [ebx + 12]
            add ebx, 24
            inc ecx
            cmp ecx, [NumberOfDrones]
            jne %%Loop

%endmacro

%macro get_random_value 2
    push eax
    mov dword [div_value], %1
    mov dword [sub_value], 0
    call Random_algorthim
    mov eax, [return_from_random_algorithm]
    mov %2, eax
    pop eax
%endmacro


%macro parseCmdLine 0
    mov ebp, esp
    mov ecx, [esp+4] ; ecx = argc
    cmp ecx,6
    jne finishProgram
    mov ebx, [esp+8] ; ebx = argv

    add ebx, 4
    mov edx, [ebx]
    push NumberOfDrones
    push Format_int
    push edx
    call sscanf
    add esp, 12

    add ebx, 4
    mov edx, [ebx]
    push SchedulerCycle
    push Format_int
    push edx
    call sscanf
    add esp, 12

    add ebx, 4
    mov edx, [ebx]
    push StepsToPrint
    push Format_int
    push edx
    call sscanf
    add esp, 12

    add ebx, 4
    mov edx, [ebx]
    push Distance
    push Format_float
    push edx
    call sscanf
    add esp, 12

    add ebx, 4
    mov edx, [ebx]
    push Seed
    push Format_int
    push edx
    call sscanf
    add esp, 12
%endmacro

%macro st_scheduler 0
    start_scheduler:
        mov dword [Current_Drone], 0
        pushad
        mov [SPMAIN], esp
        mov ebx, [CO_SCHEDULER]
        jmp do_resume
        
    end_scheduler:
        mov esp, [SPMAIN]
        popad
%endmacro


main:
    parseCmdLine 
    initial_co
    allocateArrays
    allocateCODrones
    initDrones
    st_scheduler
    FreeALL

    finishProgram:
        mov esp, ebp
        mov eax, 0 ; Program exit code
        ret
co_init:
    pushad
    mov eax, [ebx + CODEP] ;get initial EIP value – pointer to COi function
    mov [SPT], esp ; save ESP value
    mov esp, [ebx + SPP]; get initial ESP value – pointer to COi stack
    mov	ebp,esp
    push eax ; push initial “return” address
    pushfd ; push flags
    pushad ; push all other registers
    mov [ebx+SPP], esp ; save new SPi value (after all the pushes)
    mov esp, [SPT] ; restore ESP value
    popad
    ret

resume: ; save state of current co-routine
    pushfd
    pushad
    mov edx, [CURR]
    mov [edx+SPP], esp ; save current ESP
    do_resume: ; load ESP for resumed co-routine
        mov esp, [ebx+SPP]
        mov [CURR], ebx
        popad ; restore resumed co-routine state
        popfd
        ret ; "return" to resumed co-routine go to the function and run ; the cor start work
        
Random_algorthim:
    pushad
    mov esi,0
    mov ebx,0
    mov eax,0
    mov ecx,0
    do:
        mov bx,[Seed]
        mov eax,0
        mov ax,bx ;;ax=Seed
        shr ax,0 ;; bit 16
        mov cx,bx
        shr cx,2 ;; bit 14
        xor ax,cx ;;  bit 16 xor bit 14 
        mov ecx,0 
        mov cx,bx 
        shr cx,3  ;; bit 13
        xor ax,cx ;; (bit 16 xor bit 14) xor bit 13 
        mov ecx,0
        mov cx,bx 
        shr cx,5 ;; bit 11
        xor ax, cx ;;((bit 16 xor bit 14) xor bit 13) xor bit 11
        mov cx,bx
        shr cx,1  ;;(Seed >> 1)
        shl ax,15 ;;(bit << 15)
        or cx,ax  ;;(Seed >> 1) | (bit << 15);
        mov [Seed],cx 
        inc esi
        cmp esi,16 ;; do 16 
        jnz do
        ;; Seed contain the number
        finit
        fild dword [Seed]
        ffree
        popad
    Save:
        finit
        fild dword [Seed] 
        fild dword [MAX_INTEGER]
        fdivp
        fild dword [div_value]
        fmulp
        fild dword [sub_value]
        fsubp
        fstp dword [return_from_random_algorithm]
        ffree
    ret