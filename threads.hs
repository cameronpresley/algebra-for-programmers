import Control.Concurrent
import Control.Concurrent.STM
import Control.Monad

moveOne 0 to source sink = return ()
moveOne from to source sink = do
    writeTVar source (from - 1)
    writeTVar sink (to + 1)

drainOne source sink = do
    from <- readTVar source
    to <- readTVar sink
    moveOne from to source sink

drain name source sink lock = do
    from <- atomically $ readTVar source
    to <- atomically $ readTVar sink
    withMVar lock $ \_ -> putStrLn $ "draining " ++ name ++ " " ++ (show from) ++ ", " ++ (show to)
    if from > 0
        then
            (atomically $ drainOne source sink) >> milliSleep 1 >> (drain name source sink lock)
        else return ()


oneDrain lock ctr1 ctr2 =
    forkIO $ drain "a" ctr1 ctr2 lock

twoDrains lock ctr1 ctr2 = do
    forkIO $ drain "a" ctr1 ctr2 lock
    forkIO $ drain "b" ctr2 ctr1 lock

main = do
    lock <- newMVar ()
    ctr1 <- atomically $ newTVar 5
    ctr2 <- atomically $ newTVar 10
    oneDrain lock ctr1 ctr2
    -- twoDrains lock ctr1 ctr2
    milliSleep 60

milliSleep = threadDelay . (*) 1000
