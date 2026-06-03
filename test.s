// ========================================================================================
//     TEAM  INFO
// Group member 1 name: Amir Pascua
// Group member 1 PID: A17440527
// Group member 2 name: Greg Terteryan
// Group member 2 PID: A18990702
// ========================================================================================

// ========================================================================================
// This is the data loading and runInference code. DO NOT MODIFY. 
// You can edit or run your own test cases by modifying the .txt data files
// ========================================================================================
// Load the initialized input matrices
LDA     X0, a
LDA     X1, b
LDA     X2, c
LDA     X3, stride
LDA     X4, base

LDUR    X5, [X3, #0] // load stride
ADD     X3, X5, XZR  // Set n = stride
LDUR    X4, [X4, #0] // load base 

runInference:
        // Input:
        //  X0: The address of (pointer to) the first value of matirx A.
        //  X1: The address of (pointer to) the first value of matirx B.
        //  X2: The address of (pointer to) the first value of matirx C.
        //  X3: The current matrix size needed (n)
        //  X4: The base
        //  X5: The stride of the matrices

        BL     recBlockMul

        // Print trace
        ADDI   X1, XZR, #10      // X1 = newline character
        PUTCHAR X1
        ADD    X1, X0, XZR       // X1 = trace value returned in X0
        PUTINT X1
        ADDI   X1, XZR, #10      // newline
        PUTCHAR X1

        // Print result matrix C
        LDA    X0, c               // base address of result matrix
        LDA    X6, stride          // load stride's address
        LDUR    X1, [X6, #0]       // set n = stride
        LDUR    X2, [X6, #0]       // set stride
        
        BL     PRINTMATRIX

        STOP

// ========================================================================================





////////////////////////////////
//                            //
//       getAddr              //
//                            //
////////////////////////////////
getAddr:
        //  Input:
        //  X5: The address of (pointer to) the first value of the matirx.
        //  X6: The row of the element(0 indexed).
        //  X7: The column of the element(0 indexed).
        //  X8: The stride of the matrix(how many elements to skip to get to the next row).

        //   Output:
        //   X5: The address of (pointer to) the desired element of the matrix.

        //YOUR CODE STARTS HERE

        // save all used non-IO registers
        // includes: X9, X10
        SUBI SP, SP, #16
        STUR X9, [SP, #0]
        STUR X10, [SP, #8]

        // elements skipped = row*stride + col
        MUL X9, X6, X8 // row*stride
        ADD X9, X9, X7 // row*stride + col
        ADDI X10, XZR, #8 // longs are 8 bytes
        MUL X9, X9, X10 // X9 amount of longs
        ADD X5, X5, X9 // skip to address
        
        // restore all used non-IO registers
        LDUR X9, [SP, #0]
        LDUR X10, [SP, #8]
        ADDI SP, SP, #16

        BR LR
        //YOUR CODE ENDS HERE





////////////////////////////////
//                            //
//       baseMultiplyAdd      //
//                            //
////////////////////////////////
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
        CMP     X25, X22
        B.GE    after_j

        ADD     X13, XZR, XZR     // sum = 0 for C[i][j]
        ADD     X14, XZR, XZR     // k = 0 for dot product

        B       k_loop            // Start computing sum

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





////////////////////////////////
//                            //
//       splitOffset          //
//                            //
////////////////////////////////
splitOffset:
        //  Input:
        //  X0: The address of (pointer to) the first value of the matirx.
        //  X1: n
        //  X2: 0-3 corresponding to the four quadrant of the matrix.
        //  X3: stride

        //   Output:
        //   X8: The address of (pointer to) the desired submatrix.


        //YOUR CODE STARTS HERE

        // Compute half = n / 2.
        LSR     X9, X1, #1        // X9 = half

        // Start with quadrant 0 check.
        CMP     X2, XZR           // Check if quadrant == 0
        B.EQ    split_q0

        ADDI    X10, XZR, #1      // X10 = 1
        CMP     X2, X10           // Check if quadrant == 1
        B.EQ    split_q1

        ADDI    X10, XZR, #2      // X10 = 2
        CMP     X2, X10           // Check if quadrant == 2
        B.EQ    split_q2

        // If not 0, 1, or 2, treat as quadrant 3.
        B       split_q3

split_q0:
        ADD     X8, X0, XZR       // top-left starts at base
        BR      LR

split_q1:
        LSL     X11, X9, #3       // byte offset = half * 8
        ADD     X8, X0, X11       // return base + half
        BR      LR

split_q2:
        MUL     X10, X9, X3       // element offset = half * stride
        LSL     X11, X10, #3      // byte offset = element offset * 8
        ADD     X8, X0, X11       // return base + half * stride
        BR      LR

split_q3:
        MUL     X10, X9, X3       // element offset = half * stride
        ADD     X10, X10, X9      // element offset += half
        LSL     X11, X10, #3      // byte offset = element offset * 8
        ADD     X8, X0, X11       // return base + half * stride + half
        BR      LR

        //YOUR CODE ENDS HERE





////////////////////////////////
//                            //
//       recBlockMul          //
//                            //
////////////////////////////////
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






// ========================================================================================
// Functions after this are for printing results. DO NOT MODIFY
// ========================================================================================
PRINTMATRIX:
        // Input:
        // X0: base address of matrix
        // X1: n (matrix dimension)
        // X2: stride

        SUBI   SP, SP, #40
        STUR   FP, [SP, #0]
        ADDI   FP, SP, #8
        STUR   LR, [SP, #8]

        // Save parameters
        STUR   X0, [SP, #16]     // save base
        STUR   X1, [SP, #24]     // save n
        STUR   X2, [SP, #32]     // save stride

        ADDI   X5, XZR, #32      // X5 = space character
        ADDI   X6, XZR, #10      // X6 = newline character
        ADDI   X3, XZR, #0       // i = 0 (row counter)

ROW_LOOP:
        LDUR   X1, [SP, #24]     // load n
        CMP    X3, X1            // if i >= n, done
        B.GE   PRINT_DONE

        ADDI   X4, XZR, #0       // j = 0 (col counter)

COL_LOOP:
        LDUR   X1, [SP, #24]     // load n
        CMP    X4, X1            // if j >= n, end row
        B.GE   END_ROW

        // Calculate address: base + (i * stride + j) * 8
        LDUR   X7, [SP, #16]     // load base
        MUL    X19, X3, X2       // i * stride
        ADD    X19, X19, X4      // i * stride + j
        LSL    X19, X19, #3      // * 8 for byte offset
        ADD    X7, X7, X19       // final address

        // Load and print value
        LDUR   X1, [X7, #0]      // load matrix[i][j]
        PUTINT X1

        // Print space
        PUTCHAR X5

        // j++
        ADDI   X4, X4, #1
        B      COL_LOOP

END_ROW:
        // Print newline
        PUTCHAR X6

        // i++
        ADDI   X3, X3, #1
        B      ROW_LOOP

PRINT_DONE:
        LDUR   LR, [SP, #8]
        LDUR   FP, [SP, #0]
        ADDI   SP, SP, #40
        BR     LR
