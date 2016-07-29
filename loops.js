const myArray = [ 1, 2, 3, 4, 5 ];

function sumSquares(myArray) {
	var squares = [];
	for(var x = 0; x < myArray.length; x++) {
		squares.push(myArray[x] * myArray[x]);
	}

	var sum = 0;
	for(var y = 0 ; y < squares.length; y++) {
		sum += squares[y];
	}
	return sum;
}

function sumSquaresMapReduce(myArray) {
	return myArray
		.map(function (x) { return x * x; })
		.reduce(function (a,b) { return a + b; }, 0);
}



function iteratorFromArray(arr) {
	const helper = function (x) {
		return {
			value: (x < arr.length) ? arr[x] : null,
			next: ((x + 1) < arr.length) ? function() { return helper(x + 1); } : null
		};
	};
	return function () { return helper(0); };
}

function mapHelper(f) {
	return function (a,b) {
		a.push(f(b));
		return a;
	};
}

function map(f, list) {
	return list.reduce(mapHelper(f), []);
}

function iterativeReduce(f, initial, iterator) {
	var sum = initial;
	var cur = iterator();
	do { // Seriously, we can use loops to implement primitives behind the scenes!
		sum = f(sum, cur.value);
	} while ((cur.next != null) && (cur = cur.next())); // if we're being evil, might as well go all the way.
	return sum;
}

function iterativeMap(f, iterator) {
	const helper = function(iter) {
		const element = iter();
		return {
				value: f(element.value),
				next: (element.next == null) ? null : iterativeMap(f, element.next)
		};
	};
	return function () { return helper(iterator); }
}

function iterativeSumSquaresMapReduce(iterator) {
	return iterativeReduce(function (a, b) { return a + b; }, 0,
		iterativeMap(function (x) { return x * x; }, iterator));
}


function iterativeMapReduce(step1, step2, seed, iterator) {
	return iterativeReduce(step2, seed,
		iterativeMap(step1, iterator));
}

function mapListHelper(functionList) {
	return function (x) {
		return functionList.map(function (f) { return f(x); });
	};
}

function reduceListHelper(functionList) {
	return function (accumulator, values) {
		return functionList.map(function (f, i) {
			return f(accumulator[i], values[i]);
		});
	};
}

iterativeMap(mapListHelper([ function (x) { return 1; }, function (x) { return x * x; }, function (x) { return x; } ]), iteratorFromArray(myArray))().next();
