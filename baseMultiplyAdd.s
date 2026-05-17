// What to work on:
// haven't checked yet

baseMultiplyAdd:
        //  Input:
        //  X0: The address of (pointer to) the first value of matrix A.
        //  X1: The address of (pointer to) the first value of matrix B.
        //  X2: The address of (pointer to) the first value of matrix C.
        //  X3: n
        //  X4: The stride of the matrices
        //
        //  Output:
        //  X0: The trace of the resulting n*n block of C.
        //  The block C should be updated in memory.

        //YOUR CODE STARTS HERE

        // Save LR and saved registers because this function calls getAddr
        // and uses X19-X26 to hold important loop values.
        SUBI    SP, SP, #72
        STUR    LR,  [SP, #0]
        STUR    X19, [SP, #8]
        STUR    X20, [SP, #16]
        STUR    X21, [SP, #24]
        STUR    X22, [SP, #32]
        STUR    X23, [SP, #40]
        STUR    X24, [SP, #48]
        STUR    X25, [SP, #56]
        STUR    X26, [SP, #64]

        // Copy function inputs into saved registers so getAddr calls
        // do not accidentally destroy our main values.
        ADD     X19, X0, XZR      // X19 = base address of A
        ADD     X20, X1, XZR      // X20 = base address of B
        ADD     X21, X2, XZR      // X21 = base address of C
        ADD     X22, X3, XZR      // X22 = block size n
        ADD     X23, X4, XZR      // X23 = stride

        // Initialize trace and outer loop counter.
        ADD     X26, XZR, XZR     // trace = 0
        ADD     X24, XZR, XZR     // i = 0

i_loop:
        CMP     X24, X22          // Check if i >= n
        B.GE    bma_done          // If yes, all rows are finished

        ADD     X25, XZR, XZR     // j = 0 at the start of each row

j_loop:
        CMP     X25, X22          // Check if j >= n
        B.GE    after_j           // If row is done, move to trace update

        ADD     X13, XZR, XZR     // sum = 0 for C[i][j]
        ADD     X14, XZR, XZR     // k = 0 for dot product

        // Next step will be k loop

        ADDI    X25, X25, #1      // j++
        B       j_loop            // Repeat for next column

after_j:
        // Get the address of C[i][i], the diagonal element for this row.
        ADD     X5, X21, XZR      // X5 = base address of C
        ADD     X6, X24, XZR      // X6 = row i
        ADD     X7, X24, XZR      // X7 = column i
        ADD     X8, X23, XZR      // X8 = stride
        BL      getAddr           // X5 = address of C[i][i]

        // Add C[i][i] to the running trace.
        LDUR    X9, [X5, #0]      // X9 = C[i][i]
        ADD     X26, X26, X9      // trace += C[i][i]

        // Move to the next row.
        ADDI    X24, X24, #1      // i++
        B       i_loop            // Repeat for next row

k_loop:
        CMP     X14, X22          // Check if k >= n
        B.GE    after_k           // If yes, dot product is done

        ADD     X5, X19, XZR      // X5 = base address of A
        ADD     X6, X24, XZR      // X6 = row i
        ADD     X7, X14, XZR      // X7 = column k
        ADD     X8, X23, XZR      // X8 = stride
        BL      getAddr           // X5 = address of A[i][k]
        LDUR    X10, [X5, #0]     // X10 = A[i][k]

        ADD     X5, X20, XZR      // X5 = base address of B
        ADD     X6, X14, XZR      // X6 = row k
        ADD     X7, X25, XZR      // X7 = column j
        ADD     X8, X23, XZR      // X8 = stride
        BL      getAddr           // X5 = address of B[k][j]
        LDUR    X11, [X5, #0]     // X11 = B[k][j]

        MUL     X12, X10, X11     // product = A[i][k] * B[k][j]
        ADD     X13, X13, X12     // sum += product

        ADDI    X14, X14, #1      // k++
        B       k_loop            // Repeat for next k

after_k:
        // Get the address of C[i][j] so we can accumulate the dot product.
        ADD     X5, X21, XZR      // X5 = base address of C
        ADD     X6, X24, XZR      // X6 = row i
        ADD     X7, X25, XZR      // X7 = column j
        ADD     X8, X23, XZR      // X8 = stride
        BL      getAddr           // X5 = address of C[i][j]

        // Load the old C[i][j], add the computed sum, and store it back.
        LDUR    X15, [X5, #0]     // X15 = old C[i][j]
        ADD     X16, X15, X13     // X16 = old C[i][j] + sum
        STUR    X16, [X5, #0]     // C[i][j] += sum

        // Move to the next column j.
        ADDI    X25, X25, #1      // j++
        B       j_loop            // Continue across the row

bma_done:
        // Return the final trace value in X0.
        ADD     X0, X26, XZR      // X0 = trace

        // Restore LR and all saved registers used by this function.
        LDUR    LR,  [SP, #0]
        LDUR    X19, [SP, #8]
        LDUR    X20, [SP, #16]
        LDUR    X21, [SP, #24]
        LDUR    X22, [SP, #32]
        LDUR    X23, [SP, #40]
        LDUR    X24, [SP, #48]
        LDUR    X25, [SP, #56]
        LDUR    X26, [SP, #64]
        ADDI    SP, SP, #72

        BR      LR
        
        //YOUR CODE ENDS HERE
