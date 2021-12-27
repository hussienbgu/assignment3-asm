section .text
    global Scheduler_Function
    extern CO_PRINTER
    extern end_scheduler
    extern NumberOfDrones
    extern StepsToPrint
    extern SchedulerCycle
    extern CO_Drones_array
    extern Drones_dynamic_array
    extern Current_Drone
    extern resume

section .data
    min: dd 0
    toDestroy: dd 0
    liveDrones: dd 0


Scheduler_Function:
    mov eax, [NumberOfDrones]
    mov dword [liveDrones], eax
    mov ecx, 0
    loopScheduler:

        push ecx
        mov edx, 0
        mov dword eax, ecx
        mov dword ecx, [NumberOfDrones]
        div ecx
        pop ecx
        mov dword [Current_Drone], edx

        push ecx
        mov edx, 0
        mov dword eax, edx
        mov dword ecx, 24
        mul ecx
        pop ecx
        mov ebx, [Drones_dynamic_array]
        mov edx, [ebx + eax + 20]
        cmp edx, 0
        je printBoard

        push ecx
        mov edx, 0
        mov dword eax, [Current_Drone]
        mov dword ecx, 12
        mul ecx
        pop ecx
        mov ebx, [CO_Drones_array]
        add ebx, eax
        call resume
        printBoard:
        push ecx
        mov edx, 0
        mov dword eax, ecx
        mov dword ecx, [StepsToPrint]
        div ecx
        pop ecx        
        cmp edx, 0 
        jne endPrint
        mov ebx, [CO_PRINTER]
        call resume

        endPrint:
        push ecx
        mov edx, 0
        mov dword eax, ecx
        mov dword ecx, [NumberOfDrones]
        div ecx
        pop ecx
        mov ebx, edx 
        push ecx
        mov edx, 0
        mov dword eax, ecx
        mov dword ecx, [SchedulerCycle]
        div ecx
        pop ecx
        cmp edx, 0
        jnz loopSchedulerStep
        cmp ebx, 0
        jnz loopSchedulerStep

        pushad
        mov dword ecx, 0
        mov dword [min], 0xFFFFFFFF
        mov dword [toDestroy], 0
        mov ebx, [Drones_dynamic_array]
        
        loopRRound:
            cmp ecx, [NumberOfDrones]
            je endR
            cmp dword [ebx + 20], 0
            je _step
            mov eax, [min]
            cmp dword [ebx + 16], eax
            jbe _min
            jmp _step
            _min:
                mov eax, [ebx + 16]
                mov dword [min], eax
                mov dword [toDestroy], ecx
            _step:
                add ebx, 24
                inc ecx
                jmp loopRRound
        endR:
            dec dword [liveDrones]
            mov eax, [toDestroy]
            mov ebx, 24
            mul ebx
            mov ebx, [Drones_dynamic_array]
            mov dword [ebx + eax + 20], 0
            popad
            

        loopSchedulerStep:
        inc ecx
        cmp dword [liveDrones], 1
        je endScheduler
        jmp loopScheduler

    endScheduler:
        mov ebx, [CO_PRINTER]
        call resume
        jmp end_scheduler