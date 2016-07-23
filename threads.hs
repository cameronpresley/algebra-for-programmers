module Threads where
import Control.Concurrent.STM
import Control.Monad

type Counter = TVar [ Int ]

moveOne 0 to source sink = true
moveOne from to source sink = do
	writeTVar source (from - 1)
	writeTVar sink (to + 1)

drainOne source sink = do
	from <- readTVar source
	to <- readTVar sink
	moveOne from to source sink
