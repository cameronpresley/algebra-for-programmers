import Control.Concurrent
import Control.Concurrent.STM
import Control.Monad

moveOne from to source sink =
    (case ((==) 0 from) of
        True -> (return ())
        False ->
            ((>>=)
                (writeTVar source (from - 1))
                (\_ -> (writeTVar sink (to + 1)))))

drainOne source sink =
    ((>>=)
        (readTVar source)
        (\from -> ((>>=)
            (readTVar sink)
            (\to -> (moveOne from to source sink)))))

drain name source sink lock =
    ((>>=)
        (atomically (readTVar source))
        (\from ->
            ((>>=)
                (atomically (readTVar sink))
                (\to ->
                    ((>>=)
                        (withMVar lock (\_ -> putStrLn (((++) "draining " ((++) name ((++) " " ((++) (show from) ((++) ", " (show to)))))))))
                        (\_ -> (case ((>) from 0) of
                            True ->
                                ((>>=)
                                    (atomically (drainOne source sink))
                                    (\_ -> ((>>=)
                                        (milliSleep 1)
                                        (\_ -> (drain name source sink lock)))))
                            False -> (return ()))))))))


oneDrain lock ctr1 ctr2 = forkIO (drain "a" ctr1 ctr2 lock)

twoDrains lock ctr1 ctr2 =
    ((>>=)
        (forkIO (drain "a" ctr1 ctr2 lock))
        (\_ -> (forkIO (drain "b" ctr2 ctr1 lock))))

main =
    ((>>=)
        (newMVar ())
        (\lock ->
            ((>>=)
                (atomically (newTVar 5))
                (\ctr1 ->
                    ((>>=)
                        (atomically (newTVar 10)) 
                        (\ctr2 ->
                            ((>>=)
                                (oneDrain lock ctr1 ctr2)
                                --(twoDrains lock ctr1 ctr2)
                                (\_ -> (milliSleep 60)))))))))

milliSleep time = threadDelay ((*) 1000 time)
