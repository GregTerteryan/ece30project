// What to work on:
// j loop
// k loop
// finding out which registers to save at the start and restore at the end

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

	// save all used registers that aren't input or output
	// used registers are X: 5, 6, 7, 8, 9, 10, 11, 12, 13 (WIP)

	// important: assume that n <= base (in this project, usually 2).
	// this is because recBlockMul only calls this function when n <= base.
	// so, just do normal matrix multiplication, and assume that A, B, and C
	// are all pointing to their respective quadrants/subquadrants in memory.

	ADD X10, XZR, XZR // i = 0
	ADD X13, XZR, XZR // t = 0, t will be in this temp value before X0
	SUBI SP, SP, #8
	STUR LR, [SP, #0] // store LR in stack
	BL iLoop // start the top loop with i
	BR LR

iLoop: // Done (maybe)
	SUBI SP, SP, #8
	STUR LR, [SP, #0] // store LR before another BL
	ADD X11, XZR, XZR // j = 0
	UMUL X6, X10, X4 // i * stride
	BL jLoop // start j loop
	LDUR LR, [SP, #0] // load old LR (goes to bMA)
	ADDI SP, SP, #8

	ADD X5, X2, XZR // C is the input matrix
	ADD X6, X10, XZR // row = i
	ADD X7, X10, XZR // col = i
	ADD X8, X4, XZR // stride
	SUBI SP, SP, #8
	STUR LR, [SP, #0] // store LR before another BL
	BL getAddr // after this, X5 points to C[i][i], or the current diagonal
	LDUR LR, [SP, #0] // restore LR (goes to bMA)
	ADDI SP, SP, #8
	LDUR X6, [X5, #0] // X6 = C[i][i]
	ADD X13, X13, X6 // t += C[i][i]
	
	ADDI X10, X10, #1 // i++
	CMP X10, X3
	B.LT iLoop // loop while i < n
	BR LR // go back to bMA otherwise

jLoop: // WIP
	SUBI SP, SP, #8
	STUR LR, [SP, #0] // store LR before another BL
	ADD X15, XZR, XZR // sum = 0
	ADD X12, XZR, XZR // k = 0
	BL kLoop // start k loop

	ADD X7, X6, X11 // i * stride + j
	ADD X14, X14, X15
	STUR X14 [X2, X7] // C[i * stride + j] += sum

	ADDI X11, X11, #1 // j++
	CMP X11, X3
	B.LT jLoop // loop while j<n

	LDUR LR, [SP, #0] // load old LR (goes to iLoop)
	ADDI SP, SP, #8
	BR LR // go to iLoop

kLoop: // WIP
	
	ADDI X12, X12, #1
	CMP X12, X3
	B.LT kLoop
	BR LR
	
        //YOUR CODE ENDS HERE
