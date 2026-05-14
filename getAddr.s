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
	// includes: X9
	SUBI SP, SP, #8
	STUR X9, [SP, #0]

	// elements skipped = row*stride + col
	UMUL X9, X6, X8 // row*stride
	ADD X9, X9, X7 // row*stride + col
	ADD X5, X5, X9 // skip X9 amount of elements
	
	// restore all used non-IO registers
	LDUR X9, [SP, #0]
	ADDI SP, SP, #8

	BR LR
        //YOUR CODE ENDS HERE
