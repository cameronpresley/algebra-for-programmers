-module(threads).
-export([counter/1, drain/2, startOneDrain/0, startTwoDrains/0]).

counter(X, Lock_PID) ->
	receive
		{ counter_set, NewX, Lock_PID } ->
			io:format("counter ~w: ~w~n", [ self(), NewX ]),
			counter(NewX, Lock_PID);
		{ counter_inc, Lock_PID } ->
			io:format("counter ~w: ~w~n", [ self(), X + 1 ]),
			Lock_PID ! { counter_inc, X + 1, self() },
			counter(X + 1, Lock_PID);
		{ counter_dec, Lock_PID } ->
			io:format("counter ~w: ~w~n", [ self(), X - 1 ]),
			Lock_PID ! { counter_dec, X - 1, self() },
			counter(X - 1, Lock_PID);
		{ counter_unlock, Lock_PID } ->
			io:format("counter ~w UNLOCKED ~w~n", [ self(), Lock_PID ]),
			counter(X);
		_ ->
			counter(X, Lock_PID)
	end.

counter(X) ->
	receive
		{ counter_lock, Lock_PID } ->
			io:format("counter ~w locking for ~w: ~w~n", [ self(), Lock_PID, X ]),
			Lock_PID ! { ok, X, self() },
			counter(X, Lock_PID);
		_ ->
			counter(X)
	end.


drain(done) ->
	io:format("Drain finished. ~w~n.", [ self() ]).

drain_sink_ok(Source, Sink) ->
	receive
		{ counter_inc, _, Sink } ->
			Sink ! { counter_unlock, self() },
			Source ! { counter_unlock, self() },
			drain(Source, Sink);
		_ ->
			drain_sink_ok(Source, Sink)
	end.

drain_wait_for_sink(Source, Sink, X) ->
	receive
		{ ok, Y, Sink } ->
			Source ! { counter_dec, self() },
			Sink ! { counter_inc, self() },
			io:format("Draining ~w: ~w to ~w~n", [self(), X, Y]),
			drain_sink_ok(Source, Sink);
		_ ->
			drain_wait_for_sink(Source, Sink, X)
	end.

drain(Source, Sink) ->
	Source ! { counter_lock, self() },
	receive
		{ ok, 0, Source } ->
			Source ! { counter_unlock, self() },
			drain(done);
		{ ok, X, Source } ->
			Sink ! { counter_lock, self() },
			drain_wait_for_sink(Source, Sink, X);
		_ ->
			drain(Source, Sink)
	end.

startOneDrain() ->
	A = spawn(threads, counter, [5]),
	B = spawn(threads, counter, [10]),
	spawn(threads, drain, [ A, B ]).

startTwoDrains() ->
	A = spawn(threads, counter, [5]),
	B = spawn(threads, counter, [10]),
	spawn(threads, drain, [ A, B ]),
	spawn(threads, drain, [ B, A ]).
