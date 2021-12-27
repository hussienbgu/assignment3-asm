
section .text

    global Target_Function
    global create_new_target
    extern Target_Y
    extern div_value
    extern sub_value
    extern Random_algorthim
    extern return_from_random_algorithm
    extern resume
    extern CO_Drones_array
    extern Current_Drone
    extern Target_X

Target_Function:

    push eax
    mov dword [div_value], 100
    mov dword [sub_value], 0
    call Random_algorthim
    mov eax, [return_from_random_algorithm]
    mov [Target_X], eax
    pop eax
    push eax
    mov dword [div_value], 100
    mov dword [sub_value], 0
    call Random_algorthim
    mov eax, [return_from_random_algorithm]
    mov [Target_Y], eax
    pop eax
    mov eax, [Current_Drone]
    mov ebx, 12
    mul ebx
    add eax, [CO_Drones_array]
    mov ebx, eax
    call resume
    jmp Target_Function

create_new_target:

    push eax
    mov dword [div_value], 100
    mov dword [sub_value], 0
    call Random_algorthim
    mov eax, [return_from_random_algorithm]
    mov [Target_X], eax
    pop eax
    push eax
    mov dword [div_value], 100
    mov dword [sub_value], 0
    call Random_algorthim
    mov eax, [return_from_random_algorithm]
    mov [Target_Y], eax
    pop eax
    ret