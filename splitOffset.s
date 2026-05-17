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
