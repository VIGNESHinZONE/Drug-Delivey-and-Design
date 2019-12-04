// Copyright (c) Microsoft Corporation. All rights reserved.

namespace Quantum.Week2 {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;
    
    
    //////////////////////////////////////////////////////////////////
    // This is the set of programming assignments for week 2.
    //////////////////////////////////////////////////////////////////

    // The tasks cover the following topics:
    //  - teleportation
    //  - superdense coding
    //  - quantum oracles
    //  - Deutsch-Jozsa algorithm
    //
    // We recommend to solve the following katas before doing these assignments:
    //  - Teleportation
    //  - SuperdenseCoding
    //  - DeutschJozsaAlgorithm
    // from https://github.com/Microsoft/QuantumKatas

    //////////////////////////////////////////////////////////////////
    // Part I. Quantum oracles and Deutsch-Jozsa algorithm
    //////////////////////////////////////////////////////////////////

    // In this section the oracles are defined on computational basis states,
    // as described at https://docs.microsoft.com/en-us/quantum/concepts/oracles.
    
    // Task 1.1. (The oracles for Deutsch algorithm)
    // Inputs:
    //      1) a qubit in an arbitrary state |x⟩ (function input)
    //      2) a qubit in an arbitrary state |y⟩ (function output)
    //      3) an integer F which defines which function to implement:
    //         F = 0 : f(x) = 0
    //         F = 1 : f(x) = 1
    //         F = 2 : f(x) = x
    //         F = 3 : f(x) = 1 - x
    // Goal: transform state |x⟩|y⟩ into state |x⟩|y ⊕ f(x)⟩ (⊕ is addition modulo 2).
    operation Task11 (x : Qubit, y : Qubit, F : Int) : Unit {
        // ...
	if (F == 1) {

            X(y);

        } elif (F == 2) {

            CNOT(x,y);

        } elif (F == 3) {

            X(x);
            CNOT(x,y);
            X(x);

        }
    }


    // Task 1.2. (Deutsch Algorithm)
    // Input: a quantum operation - the oracle |x⟩|y⟩ -> |x⟩|y ⊕ f(x)⟩,
    //        where f(x) is one of the functions implemented in task 1.1.
    // Output: f(0) ⊕ f(1)
    //        i.e., for f(x) = 0 or f(x) = 1 the output will be 0,
    //        and for f(x) = x or f(x) = 1 - x the output will be 1.
    operation Task12 (oracle : ((Qubit, Qubit) => Unit)) : Int {
        // ...
	mutable output = 0;

        using ((x, y) = (Qubit(), Qubit())) {

            // Preparing the qubits
            H(x);

            X(y);
            H(y);

            // Applying oracle
            oracle(x,y);

            H(x);

            if (M(x) == One) {
                set output = 1;
            }

        }
        
        return output;
    }

    }


    // Task 1.3*. (Majority oracle on 5 qubits)
    // Inputs:
    //      1) 5 qubits in arbitrary state |x⟩ (input register)
    //      2) a qubit in arbitrary state |y⟩ (output qubit)
    // Goal: transform state |x⟩|y⟩ into state |x⟩|y ⊕ MAJ(x)⟩ (⊕ is addition modulo 2),
    //       where MAJ is majority function on 5-bit vectors, defined as follows:
    //       MAJ(x) = 1 if 3 or more bits of x are 1, and 0 otherwise.
    operation Task13 (x : Qubit[], y : Qubit) : Unit {
        // ...
	mutable ind =0;
        mutable count = 0;
        for (i in 1..5){
            mutable res = M(x[ind]);
            set ind = ind +1;
            if (res == One){
                set count = count + 1;
            }
        }
        if (count >= 3){
            X(y);
        }       
    }
	
	
	


    //////////////////////////////////////////////////////////////////
    // Part II. Teleportation and superdense coding
    //////////////////////////////////////////////////////////////////

    // Task 2.1. Superdense coding using |Ψ⁻⟩ = (|01⟩ - |10⟩) / sqrt(2)
    // 
    // This task considers a modification of the superdense coding protocol 
    // in which the pair of qubits shared by Alice and Bob are entangled in a state |Ψ⁻⟩ = (|01⟩ - |10⟩) / sqrt(2).
    // Alice's performs the standard message encoding operation, as implemented in SuperdenseCoding kata:
    // operation EncodeMessageInQubit_Reference (qAlice : Qubit, message : Bool[]) : Unit {
    //     if (message[0]) {
    //         Z(qAlice);
    //     }
    //     if (message[1]) {
    //         X(qAlice);
    //     }
    // }
    // After performing this operation she sends her qubit to Bob.
    //
    // Your task is to implement Bob's part of the protocol (the message decoding) to obtain the two bits of Alice's message.
    operation Task21 (qBob : Qubit, qAlice : Qubit) : Bool[] {
        // ...
	CNOT(qAlice,qBob);
	H(qAlice);
	if(M(qAlice) == One && M(qBob) == One){
	return(false,false);	
	}
	elif(M(qAlice) == Zero && M(qBob) == One){
	return(true,false);	
	}

	eliif(M(qAlice) == One && M(qBob) == Zero){
	return(false,true);	
	}
	elif(M(qAlice) == Zero && M(qBob) == Zero){
	return(true,true);	
	}


    }




    // Task 2.2*. S-gate teleportation
    // 
    // Alice and Bob share a qubit in the state S|Φ⁺⟩ = (|00⟩ + i|11⟩) / sqrt(2)
    // (here S denotes the S gate https://docs.microsoft.com/en-us/qsharp/api/prelude/microsoft.quantum.primitive.s).
    // Alice has a qubit in the state |ψ⟩ = α|0⟩ + β|1⟩.
    // She wants to send to Bob the state S|ψ⟩ = α|0⟩ + β i|1⟩ without Bob applying any S gates to his qubit.
    // Alice performs the standard message sending operation, as implemented in Teleportation kata:
    // operation SendMessage_Reference (qAlice : Qubit, qMessage : Qubit) : (Bool, Bool) {
    //     CNOT(qMessage, qAlice);
    //     H(qMessage);
    //     return (M(qMessage) == One, M(qAlice) == One);
    // }
    // She sends Bob the return of this operation.
    //
    // Your task is to implement Bob's part of the protocol (the fix-up), so that he ends up with a qubit in the state S|ψ⟩.
    // You can only use Pauli and H gates; you can not use S, T or arbitrary rotation gates.
    operation Task22 (qBob : Qubit, (b1 : Bool, b2 : Bool)) : Unit {
        // ...
	if (b2 == true) 
	{
      		Y(qBob);
    	}

    	if (b1 == true) 
	{
      		Z(qBob);
    	}
  
    }





    // Task 2.3*. T-gate teleportation
    // 
    // Alice and Bob share a qubit in the state T|Φ⁺⟩ = (|00⟩ + exp(iπ/4) |11⟩) / sqrt(2)
    // (here T denotes the T gate https://docs.microsoft.com/en-us/qsharp/api/prelude/microsoft.quantum.primitive.t).
    // Alice has a qubit in the state |ψ⟩ = α|0⟩ + β|1⟩.
    // She wants to send to Bob the state T|ψ⟩ = α|0⟩ + β exp(iπ/4) |1⟩ without Bob applying any T gates to his qubit.
    // 
    // Alice performs the same steps as in task 1.2.
    //
    // Your task is to implement Bob's part of the protocol (the fix-up), so that he ends up with a qubit in the state T|ψ⟩.
    // You can only use Pauli gates, H and S gates; you can not use T gate or arbitrary rotation gates.
    operation Task23 (qBob : Qubit, (b1 : Bool, b2 : Bool)) : Unit {
        // ...

	
	if (b2 == true) 
	{
      		Y(qBob);
      		Z(qBob);
      		S(qBob);
    	}

    	if (b1 == true) 
	{
      		Z(qBob);
    	}
  	
	}
