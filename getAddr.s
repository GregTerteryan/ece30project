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
	ADDI X10, XZR, #8 // longs are 8 bits
	MUL X9, X9, X10 // X9 amount of longs
	ADD X5, X5, X9 // skip to address
	
	// restore all used non-IO registers
	LDUR X9, [SP, #0]
	LDUR X10, [SP, #8]
	ADDI SP, SP, #16

	BR LR
        //YOUR CODE ENDS HERE
