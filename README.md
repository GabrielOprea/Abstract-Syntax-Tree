# Abstract-Syntax-Tree
A program that receives an expression as input and builds an Abstract Syntax Tree corresponding to this expression. The expression numerical values are converted to integers using a custom made atoi function.

For the atoi function I first called strlen, then used a loop from len to 0. If I encounter
a '-' character, I jump to a label where I perform multiplication by -1. Else, I convert
the numeric character to a digit, add it to the partial sum, then multiply the partial
sum by 10 for the next digit to be added. To add the digits in reverse order, first I
push them in the stack, then I pop in reverse order.

To build the AST, I used strtok to parse the input string. If the substring is a number,
then I created a leaf node, else I create an operator node, and call the function
recursively on the left and right subtrees. The recursive call will return pointers
to the subtrees, and I set these pointers as left son and right son.

The main function in the program is create_tree, that creates a new stack frame, and
calls the auxiliary function described earlier.
