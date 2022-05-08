pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/gates.circom";
include "../../node_modules/circomlib-matrix/circuits/matMul.circom";
include "../../node_modules/circomlib-matrix/circuits/matSub.circom";

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    component mul = matMul(n, n, 1);
    component sub = matSub(n, 1);

    // A*x = mul.out
    for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
            mul.a[i][j] <== A[i][j];
        }
        mul.b[i][0] <== x[i];
    }

    // mul.out - b = sub.out
    for (var i = 0; i < n; i++) {
        sub.a[i][0] <== mul.out[i][0];
        sub.b[i][0] <== b[i];
    }

    // sub.out === 0
    component zero[n];
    for (var i = 0; i < n; i++) {
        zero[i] = IsZero();
        zero[i].in <== sub.out[i][0];
        zero[i].out === 1;
    }

    // ∏(zero.out) === 1
    component mand = MultiAND(n);
    for (var i = 0; i < n; i++) {
        mand.in[i] <== zero[i].out;
    }
    
    // return 1 if Ax-b=0
    out <== mand.out;
}

component main {public [A, b]} = SystemOfEquations(3);