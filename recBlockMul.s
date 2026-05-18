//what to work on:
//recursive case, only base case works

recBlockMul:
        //  Input:
        //  X0: address of matrix A
        //  X1: address of matrix B
        //  X2: address of matrix C
        //  X3: current n
        //  X4: base
        //  X5: stride
        //
        //  Output:
        //  X0: sum of traces of all diagonal base-case blocks

        //YOUR CODE STARTS HERE

        // Save LR and saved registers because this function is recursive
        // and calls splitOffset, baseMultiplyAdd, and itself.
        SUBI    SP, SP, #80
        STUR    LR,  [SP, #0]
        STUR    X19, [SP, #8]
        STUR    X20, [SP, #16]
        STUR    X21, [SP, #24]
        STUR    X22, [SP, #32]
        STUR    X23, [SP, #40]
        STUR    X24, [SP, #48]
        STUR    X25, [SP, #56]
        STUR    X26, [SP, #64]
        STUR    X27, [SP, #72]

        // Save input arguments into preserved registers.
        ADD     X19, X0, XZR      // X19 = A
        ADD     X20, X1, XZR      // X20 = B
        ADD     X21, X2, XZR      // X21 = C
        ADD     X22, X3, XZR      // X22 = n
        ADD     X23, X4, XZR      // X23 = base
        ADD     X24, X5, XZR      // X24 = stride

        // Base case: if n <= base, call baseMultiplyAdd(A, B, C, n, stride)
        CMP     X22, X23
        B.LE    rbm_base_case

        // Recursive case will go here later.
        // For now, temporarily return 0 if testing structure only.
        ADD     X0, XZR, XZR
        B       rbm_done

rbm_base_case:
        ADD     X0, X19, XZR      // X0 = A
        ADD     X1, X20, XZR      // X1 = B
        ADD     X2, X21, XZR      // X2 = C
        ADD     X3, X22, XZR      // X3 = n
        ADD     X4, X24, XZR      // X4 = stride

        BL      baseMultiplyAdd   // returns trace in X0

        B       rbm_done

rbm_done:
        LDUR    LR,  [SP, #0]
        LDUR    X19, [SP, #8]
        LDUR    X20, [SP, #16]
        LDUR    X21, [SP, #24]
        LDUR    X22, [SP, #32]
        LDUR    X23, [SP, #40]
        LDUR    X24, [SP, #48]
        LDUR    X25, [SP, #56]
        LDUR    X26, [SP, #64]
        LDUR    X27, [SP, #72]
        ADDI    SP, SP, #80

        BR      LR

        //YOUR CODE ENDS HERE
