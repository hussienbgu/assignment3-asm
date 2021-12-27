section .text
    global Drone_Function
    extern CO_SCHEDULER
    extern CO_TARGET
    extern Target_X
    extern Target_Y
    extern return_from_random_algorithm
    extern resume
    extern Distance
    extern Drones_dynamic_array
    extern Current_Drone
    extern div_value
    extern sub_value
    extern Random_algorthim
    extern val_0
    extern val_100
    extern val_180
    extern val_360

    
%macro speedModify 0
    mov dword [div_value], 20
    mov dword [sub_value], 10
    call Random_algorthim 
    finit
    fld dword [return_from_random_algorithm]
    fadd dword [edx + 8]
    fild dword [val_100]
    fcomip
    ja %%checkSpeedBelow0
    fild dword [val_100]
    jmp %%endM
    
    %%checkSpeedBelow0:
    fild dword [val_0]
    fcomip
    jb %%endM 
    fild dword [val_0]
    %%endM:
    fstp dword [edx + 8]
    ffree
%endmacro


%macro alphaModify 0
    mov dword [div_value], 120
    mov dword [sub_value], 60
    call Random_algorthim 
    finit
    fld dword [return_from_random_algorithm]
    fadd dword [edx + 12]
    fild dword [val_360]
    fcomip
    ja %%checkAlphaNegative 
    fisub dword [val_360]
    jmp %%saveDroneHeading
    
    %%checkAlphaNegative:
    fild dword [val_0]
    fcomip
    jb %%saveDroneHeading 
    fiadd dword [val_360]
    
    %%saveDroneHeading:
    fstp dword [edx + 12]
    ffree
%endmacro


%macro move_D 0
    finit
    fld dword [edx + 12]
    fldpi
    fmulp
    fild dword [val_180]
    fdivp
    fsincos
    fld dword [edx + 8]
    fmulp
    fld dword [edx + 0]
    faddp
    fild dword [val_100]

    fcomi
    ja %%checkNeg 
    fsubp st1, st0 
    jmp %%heree

    %%checkNeg:
    fisub dword [val_100] 
    fcomip
    jb %%heree 
    fiadd dword [val_100]

    %%heree:
    fstp dword [edx + 0]

    fld dword [edx + 8]
    fmulp
    fld dword [edx + 4]
    faddp
    fild dword [val_100]


    fcomi
    ja %%checkNeg1 
    fsubp st1, st0 
    jmp %%here

    %%checkNeg1:
    fisub dword [val_100] 
    fcomip
    jb %%here 
    fiadd dword [val_100] 

    %%here:
    fstp dword [edx + 4]
    ffree
%endmacro

%macro loopdrone 0
    %%Loop:
        mov eax, 0
        finit
        fld dword [edx + 0]
        fsub dword [Target_X] ; st0 = droneX - targatX
        fmul st0, st0

        fld dword [edx + 4]
        fsub dword [Target_Y] ; st0 = droneY - targatY
        fmul st0, st0

        faddp
        fsqrt
        fld dword [Distance]
        fcomi
        jb %%endMayDestroy ; jump if d < current distance from target
        mov eax, 1

        %%endMayDestroy:
        ffree
    
    cmp eax, 0
    je %%droneStep

    inc dword [edx + 16]
    mov ebx, [CO_TARGET]
    call resume

    %%droneStep:
    move_D
    alphaModify
    speedModify
    mov ebx, [CO_SCHEDULER]
    call resume
    jmp %%Loop
%endmacro

%macro get_Current_drone 0
    push ebx
    mov eax, [Current_Drone]
    mov ebx, 24
    mul ebx
    add eax, [Drones_dynamic_array] 
    pop ebx
    mov edx, eax
%endmacro

Drone_Function:
    get_Current_drone
    move_D
    alphaModify
    speedModify
    loopdrone