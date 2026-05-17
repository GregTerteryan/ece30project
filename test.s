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
        //  X0: The address of (pointer to) the first value of matrix A.
        //  X1: The address of (pointer to) the first value of matrix B.
        //  X2: The address of (pointer to) the first value of matrix C.
        //  X3: The current matrix size needed (n)
        //  X4: The base
        //  X5: The stride of the matrices
        
        ADD X8, X5, XZR
        ADDI X7, XZR, #1
        ADDI X6, XZR, #1
        ADD X5, X0, XZR
        BL     getAddr

        // Print trace
        // ADDI   X1, XZR, #10      // X1 = newline character
        // PUTCHAR X1
        // ADD    X1, X0, XZR       // X1 = trace value returned in X0
        // PUTINT X1
        // ADDI   X1, XZR, #10      // newline
        // PUTCHAR X1

        // Print result matrix C
        // LDA    X0, c               // base address of result matrix
        // LDA    X6, stride          // load stride's address
        // LDUR    X1, [X6, #0]       // set n = stride
        // LDUR    X2, [X6, #0]       // set stride
        
        // BL     PRINTMATRIX

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
