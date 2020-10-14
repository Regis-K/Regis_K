; Вариант 16
; Задача:
; Сформировать массив B из элементов А
; значения которых больше среднего арифметического

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize       db 'Enter size of vector A: ', 0
        strIncorrectSize db 'Incorrect size.', 10, 0
        strVecElemI      db '[%d]? ', 0
        strScanInt       db '%d', 0
        strVecElemOut    db 'B[%d] = %d', 10, 0
        strVecB          db 'Vector B is: ', 0
        strVecMeanOut    db 'Mean = [%d]', 0
        strVecBNull      db 'Vector B is empty', 0

        vec_size     dd 0
        vec_size_B   dd 0
        sum          dd 0
        vec_mean     dd 0
        i            dd ?
        index        dd -1
        value        dd 1
        tmp          dd ?
        tmpB         dd ?
        tmpStack     dd ?
        vec          rd 100
        vecB         rd 100

;--------------------------------------------------------------------------

section '.code' code readable executable
start:
; Вводим массива А
        call VectorInput
;Находим среднее арифметическое всех элементов вектора А
        call VectorMean
; Формируем массив B из массива A
        call CreateVectorB
; Выводим массив B
        call VectorOutB
finish:
        call [getch]
        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------

VectorInput:

        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; Иначе:
        push strIncorrectSize
        call [printf]
        add esp, 4
        jmp finish


getVector:
        xor ecx, ecx
        mov ebx, vec

getVecLoop: ; Цикл считывания элементов массива
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector

        ; Считывание элемента массива
        mov [i], ecx

        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4 ;
        jmp getVecLoop ;
endInputVector:
        ret

;--------------------------------------------------------------------------

VectorMean:
        xor ecx, ecx
        mov ebx, vec
sumVecLoop:
        cmp ecx, [vec_size]
        je endSumVector
        mov eax, [sum]
        add eax, [ebx]
        mov [sum], eax
        inc ecx
        add ebx, 4
        jmp sumVecLoop
endSumVector:
        mov eax, [sum]
        mov ebx, [vec_size]
        xor edx, edx
        div ebx
        mov [vec_mean], eax

        ret

;--------------------------------------------------------------------------

CreateVectorB:
        mov [tmpStack], esp
        xor ecx, ecx
        mov eax, vec
        mov ebx, vecB

CreateVecLoop:
        mov [tmp], eax
        mov [tmpB], ebx
        cmp ecx, [vec_size]
        je endCreate
        mov [i], ecx

        mov eax, [tmp]
        mov edx, [eax]
        cmp [vec_mean], edx
        jl FillVectorB

        mov eax, [tmp]
        mov ebx, [tmpB]

        mov ecx, [i]
        inc ecx
        add eax, 4

        jmp CreateVecLoop

FillVectorB: ; Если текущий элемент > среднего значения добавляем его в массив В
        mov eax, [tmp]
        mov ebx, [tmpB]
        mov [ebx], edx


        mov ecx, [i]
        inc ecx
        add eax, 4
        add ebx, 4

        mov edx, [vec_size_B]
        inc edx
        mov [vec_size_B], edx

        jmp CreateVecLoop

endCreate:
        mov esp, [tmpStack]
        ret

;-------------------------------------------------------------------

VectorOutB:
        cmp [vec_size_B], 0
        je VectorNull
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, vecB
        jmp putVecLoopB

VectorNull:

        push strVecBNull
        call [printf]
        jmp endOutputVectorB

putVecLoopB:
        mov [tmp], ebx
        cmp ecx, [vec_size_B]
        je endOutputVectorB
        mov [i], ecx

        ; Вывод элемента массива
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoopB
endOutputVectorB:
        mov esp, [tmpStack]
        ret

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'


; Программа прошла следующие наборы тестов:
;1)vec_size = 10:  vector = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}: output = {6, 7, 8, 9, 10}
;2)vec_size = 0: output = incorrect size
;3)vec_size = 5: vector = {1, 1, 1, 1, 1}: output = Vector B is empty
;4)vec_size = 5: vector = {2, 2, 2, 2, 1}: output = {2, 2, 2, 2}