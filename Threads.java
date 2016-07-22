final class Counter {
	private int counter;
	public Counter(int initial) { this.counter = initial; }
	public int increment() { return this.counter++; }
	public int decrement() { return this.counter--; }
	public int get() { return this.counter; }
	public int set(int value) { return this.counter = value; }
}

final class Drain implements Runnable {
	private final Counter source;
	private final Counter sink;
	public Drain(Counter source, Counter sink) {
		this.source = source;
		this.sink = sink;
	}
	@Override public void run() {
		boolean flag = true;
		while(flag) {
			synchronized(source) {
				if(source.get() > 0) {
					synchronized(sink) {
						try {
							Thread.sleep(150);
						} catch (InterruptedException ie) { }
						source.decrement();
						sink.increment();
						System.out.println("Drain(" + this + "): " + source.get() + ", " + sink.get());
					}
				} else {
					flag = false;
				}
				try {
					Thread.sleep(40);
				} catch (InterruptedException ie) { }
			}
		}
	}
}

public final class Threads {
	public static void main(String[] args) throws Exception {
		final Counter a = new Counter(5);
		final Counter b = new Counter(10);
		final Drain d1 = new Drain(a, b);
		System.out.println("Counters: " + a.get() + ", " + b.get());
		final Thread t1 = new Thread(d1);
		t1.start();
		t1.join();
		System.out.println("Counters: " + a.get() + ", " + b.get());
		a.set(5);
		final Thread t2 = new Thread(new Drain(a, b));
		final Thread t3 = new Thread(new Drain(b, a));
		t2.start();
		t3.start();
		t2.join();
		t3.join();
		System.out.println("Counters: " + a.get() + ", " + b.get());
	}
}
