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
        SUBI    SP, SP, #184
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

        B       rbm_recursive_case

rbm_recursive_case:
        // Compute half = n / 2.
        LSR     X25, X22, #1      // X25 = half
        STUR    X25, [SP, #80]    // Save half on stack

        // Initialize trace accumulator t = 0.
        ADD     X26, XZR, XZR     // X26 = trace accumulator

        // A11 = splitOffset(A, n, 0, stride)
        ADD     X0, X19, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #0
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #88]

        // A12 = splitOffset(A, n, 1, stride)
        ADD     X0, X19, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #1
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #96]

        // A21 = splitOffset(A, n, 2, stride)
        ADD     X0, X19, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #2
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #104]

        // A22 = splitOffset(A, n, 3, stride)
        ADD     X0, X19, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #3
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #112]

        // B11 = splitOffset(B, n, 0, stride)
        ADD     X0, X20, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #0
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #120]

        // B12 = splitOffset(B, n, 1, stride)
        ADD     X0, X20, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #1
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #128]

        // B21 = splitOffset(B, n, 2, stride)
        ADD     X0, X20, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #2
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #136]

        // B22 = splitOffset(B, n, 3, stride)
        ADD     X0, X20, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #3
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #144]

        // C11 = splitOffset(C, n, 0, stride)
        ADD     X0, X21, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #0
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #152]

        // C12 = splitOffset(C, n, 1, stride)
        ADD     X0, X21, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #1
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #160]

        // C21 = splitOffset(C, n, 2, stride)
        ADD     X0, X21, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #2
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #168]

        // C22 = splitOffset(C, n, 3, stride)
        ADD     X0, X21, XZR
        ADD     X1, X22, XZR
        ADDI    X2, XZR, #3
        ADD     X3, X24, XZR
        BL      splitOffset
        STUR    X8, [SP, #176]


        // C11 = A11*B11 + A12*B21
        // Only the second call's trace is added because after the
        // second call, C11 contains the full accumulated block.

        // recBlockMul(A11, B11, C11, half, base, stride)
        LDUR    X0, [SP, #88]     // X0 = A11
        LDUR    X1, [SP, #120]    // X1 = B11
        LDUR    X2, [SP, #152]    // X2 = C11
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul       // Ignore trace from first partial C11 call

        // t += recBlockMul(A12, B21, C11, half, base, stride)
        LDUR    X0, [SP, #96]     // X0 = A12
        LDUR    X1, [SP, #136]    // X1 = B21
        LDUR    X2, [SP, #152]    // X2 = C11
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul
        ADD     X26, X26, X0      // trace += returned trace for full C11



        // C12 = A11*B12 + A12*B22
        // Off-diagonal block, so trace return is ignored.

        // recBlockMul(A11, B12, C12, half, base, stride)
        LDUR    X0, [SP, #88]     // X0 = A11
        LDUR    X1, [SP, #128]    // X1 = B12
        LDUR    X2, [SP, #160]    // X2 = C12
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul

        // recBlockMul(A12, B22, C12, half, base, stride)
        LDUR    X0, [SP, #96]     // X0 = A12
        LDUR    X1, [SP, #144]    // X1 = B22
        LDUR    X2, [SP, #160]    // X2 = C12
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul



        // C21 = A21*B11 + A22*B21
        // Off-diagonal block, so trace return is ignored.

        // recBlockMul(A21, B11, C21, half, base, stride)
        LDUR    X0, [SP, #104]    // X0 = A21
        LDUR    X1, [SP, #120]    // X1 = B11
        LDUR    X2, [SP, #168]    // X2 = C21
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul

        // recBlockMul(A22, B21, C21, half, base, stride)
        LDUR    X0, [SP, #112]    // X0 = A22
        LDUR    X1, [SP, #136]    // X1 = B21
        LDUR    X2, [SP, #168]    // X2 = C21
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul



        // C22 = A21*B12 + A22*B22
        // Only the second call's trace is added because after the
        // second call, C22 contains the full accumulated block.


        // recBlockMul(A21, B12, C22, half, base, stride)
        LDUR    X0, [SP, #104]    // X0 = A21
        LDUR    X1, [SP, #128]    // X1 = B12
        LDUR    X2, [SP, #176]    // X2 = C22
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul       // Ignore trace from first partial C22 call

        // t += recBlockMul(A22, B22, C22, half, base, stride)
        LDUR    X0, [SP, #112]    // X0 = A22
        LDUR    X1, [SP, #144]    // X1 = B22
        LDUR    X2, [SP, #176]    // X2 = C22
        LDUR    X3, [SP, #80]     // X3 = half
        ADD     X4, X23, XZR      // X4 = base
        ADD     X5, X24, XZR      // X5 = stride
        BL      recBlockMul
        ADD     X26, X26, X0      // trace += returned trace for full C22

        // Return accumulated trace.
        ADD     X0, X26, XZR
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
        ADDI    SP, SP, #184

        BR      LR

        //YOUR CODE ENDS HERE
