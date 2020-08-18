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

## Notes

The brainfuck operations `,` (input to cell) and `.` (output from cell) are
not supported, as HBCHT doesn't allow for input/output while running the
program.

For implementation reasons, the brainfuck program operates on every other cell.
That means, the program `+>+>+`, which one would expect to write 1 to cells 0, 1
and 2, actually writes to cells 0, 2 and 4:

```
$ echo '+>+>+' | ./bf2hbcht | hbcht -
0: 1
2: 1
4: 1
```

## How it works

The principle behind how it works is as follows:

First the car is captured - no matter which direction it's going - and sent on
the same path towards the right.

For each brainfuck operator, a component has been made, where the car enters
from the left, and exits from the right.

These components are threaded together, to form the final program.

See the `notes/` directory for notes on the different components used.

