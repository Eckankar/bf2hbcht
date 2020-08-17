import Debug.Trace (trace)

-- Block <contents> <in-height> <out-height>
data Block = Block [String] Int Int

instance Show Block where
    show b = "\n" ++ unlines ls ++ "\n"
        where
            arrowBlock = Block [" ---> "] 0 0
            Block ls _ _ = concatBlocks [arrowBlock, b, arrowBlock]

emptyBlock :: Block
emptyBlock = Block [""] 0 0

pad (ls@(l1:_)) top bottom =
    replicate top padding ++ ls ++ replicate bottom padding
        where padding = map (const ' ') l1

combineBlocks :: Block -> Block -> Block
combineBlocks bLeft@(Block l1 s1 e1) bRight@(Block l2 s2 e2) =
    Block merged (s1 + (pos $ -dTop)) (e2 + pos dTop)
        where dTop = e1 - s2
              dBot = (length l1 - e1) - (length l2 - s2)
              paddedL1 = pad l1 (pos $ -dTop) (pos $ -dBot)
              paddedL2 = pad l2 (pos dTop) (pos dBot)
              merged = zipWith (++) paddedL1 paddedL2
              pos = max 0

blockDimensions :: Block -> (Int, Int)
blockDimensions (Block ls@(l1:_) _ _) = (length l1, length ls)

concatBlocks :: [Block] -> Block
concatBlocks = foldl combineBlocks emptyBlock

bfToBlocks :: [Char] -> [Block]
bfToBlocks ('>' : is) =
    Block [">>"] 0 0 : bfToBlocks is
bfToBlocks ('<' : is) =
    Block ["    v ",
           ">v<<< ",
           "    ^<",
           " >    ",
           " ^    "] 2 3 : bfToBlocks is
bfToBlocks ('+' : is) =
    Block ["     v ",
           "  >v<< ",
           "v>   ^<",
           ">^<>   ",
           "^  ^   "] 2 3 : bfToBlocks is
bfToBlocks ('-' : is) =
    Block ["v   v ",
           "v>v<< ",
           ">   ^<",
           "^ >   ",
           "  ^   "] 0 3 : bfToBlocks is
bfToBlocks ('[' : is) =
    [entryBlock, condBlock, contentsBlock, returnBlock, exitBlock] ++
        bfToBlocks rest
        where (contents, rest) = untilMatchingBracket 0 [] is
              contentsBlock = concatBlocks $ bfToBlocks contents
              (contW, contH) = blockDimensions contentsBlock
              Block _ contS contE = contentsBlock

              topPad = max 0 $ contS - 2
              botPad = max 0 $ contH - contS - 2

              entryTop =    ["              ",
                             ">v            "]
              entryPadding = replicate topPad "              "
              entryMerge =  ["            v ",
                             "         >v<< ",
                             "         v>   ", -- exit
                             "      >v <^   ",
                             " >     >    ^<",
                             " ^            ",
                 {- entry -} "        v     ",
                             "       ^>^<   ",
                             "        ^     "]

              entryLines = entryTop ++ entryPadding ++ entryMerge
              entryBlock = Block entryLines
                                 (length entryLines - 3)
                                 (length entryLines - 7)

              condBody = [" ",
                          "/",
                          " ",
                          " ",
                          " "]
              condPadding = replicate botPad " "
              condBottom = ["v",
                            "v",
                            ">",
                            "^"]

              condLines = condBody ++ condPadding ++ condBottom
              condBlock = Block condLines 1 1

              returnTop = [" v ",
                           "<< "]
              returnPadding = replicate (topPad + contE-contS) "   "
              returnBody = ["   ",
                            "   ",
                            "v  ",
                            ">^<",
                            "^  "]

              returnLines = returnTop ++ returnPadding ++ returnBody
              returnBlock = Block returnLines
                                  (length returnLines - 3)
                                  (length returnLines - 3) -- to line up

              exitBody =   ["     v ",
                            "  >v<< ",
                            ">    ^<",
                            "   >   ",
                            "   ^   "]
              exitPadding = replicate (botPad - (contE-contS)) "       "
              exitBottom = ["       ",
                            "       ",
                            "^<     ",
                            "       "]

              exitLines = exitBody ++ exitPadding ++ exitBottom
              exitBlock = Block exitLines 1 3

              untilMatchingBracket 0 acc (']' : rs) = (reverse acc, rs)
              untilMatchingBracket n acc (']' : rs) =
                  untilMatchingBracket (n-1) (']':acc) rs
              untilMatchingBracket n acc ('[' : rs) =
                  untilMatchingBracket (n+1) ('[':acc) rs
              untilMatchingBracket n acc (r : rs) =
                  untilMatchingBracket n (r:acc) rs
              untilMatchingBracket _ _ [] = error "Unbalanced brackets in input"
bfToBlocks (_ : is) = bfToBlocks is
bfToBlocks [] = []


startingBlock = Block ["                              v ",
                       "                          >v<<< ",
                       "             v            v>    ",
                       "          >v<<         >v <^    ",
                       "          v>            >     ^<",
                       "       >v <^         >   v      ",
                       "   >    >    ^<         ^>^<    ",
                       ">v<o>    v               ^      ",
                       " v v    ^>^<                    ",
                       "   v     ^                      ",
                       "                                ",
                       "             v                  ",
                       "          >v<<                  ",
                       "          v>         ^<         ",
                       "       >v <^                    ",
                       " >      >    ^<                 ",
                       " ^ >     v                      ",
                       "   ^    ^>^<                    ",
                       "         ^                      "] 0 2
endingBlock = Block ["#"] 0 0

main :: IO ()
main = do input <- getContents
          let blocks = bfToBlocks input
          let Block output _ _ =
                concatBlocks $ startingBlock : blocks ++ [endingBlock]
          putStrLn $ unlines output
