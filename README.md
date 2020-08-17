# bf2hbcht

[Brainfuck](https://esolangs.org/wiki/Brainfuck) to [Half-Broken Car in Heavy
Traffic](https://esolangs.org/wiki/Half-Broken_Car_in_Heavy_Traffic)
transpiler.

The compiler for HBCHT can be found at https://github.com/nqpz/hbcht .

As a sidenote, the fact that this is possible should prove, that the HBCHT is
Turing complete.

## Usage

Requires GHC to compile. An easy way to obtain GHC is through
[stack](https://haskellstack.org).

To compile, simply run:

```
# If you are using stack:
stack ghc bf2hbcht.hs

# If you are using GHC directly:
ghc bf2hbcht.hs
```

The program expects the input on standard in, and outputs the result on standard
out.

Example of usage:

```
$ cat examples/mult_3_5.bf
; multiplies 3 and 5
+++>+++++<[->[->+>+<<]>>[-<<+>>]<<<]>[-]>[-<<+>>]

$ cat examples/mult_3_5.bf | ./bf2hbcht > /tmp/mult_3_5.hb
$ hbcht /tmp/mult_3_5.hb
0: 15
```

## How it works

The principle behind how it works is as follows:

First the car is capture, no matter which direction it's going, and sent on the
same path to the right.

For each brainfuck operator, a component has been made, where the car enters
from the left, and exits from the right.

These components are threaded together, to form the final program.

See the `notes/` directory for notes on the different components used.

