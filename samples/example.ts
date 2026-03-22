/**
 * A lightweight event-driven task queue with retry support.
 */

interface TaskOptions {
  priority: number;
  retries: number;
  timeout: number;
}

type TaskStatus = "pending" | "running" | "completed" | "failed";

interface TaskResult<T> {
  data: T;
  duration: number;
  attempts: number;
}

const DEFAULT_OPTIONS: TaskOptions = {
  priority: 0,
  retries: 3,
  timeout: 5000,
};

class Task<T> {
  readonly id: string;
  status: TaskStatus = "pending";
  private attempts = 0;

  constructor(
    public name: string,
    private handler: () => Promise<T>,
    private options: TaskOptions = DEFAULT_OPTIONS
  ) {
    this.id = crypto.randomUUID();
  }

  async execute(): Promise<TaskResult<T>> {
    const start = performance.now();
    this.status = "running";

    for (let i = 0; i <= this.options.retries; i++) {
      this.attempts++;
      try {
        const data = await Promise.race([
          this.handler(),
          this.timeoutReject(),
        ]);

        this.status = "completed";
        return {
          data,
          duration: performance.now() - start,
          attempts: this.attempts,
        };
      } catch (error) {
        if (i === this.options.retries) {
          this.status = "failed";
          throw new Error(`Task "${this.name}" failed: ${error}`);
        }
        await this.backoff(i);
      }
    }

    throw new Error("Unreachable");
  }

  private timeoutReject(): Promise<never> {
    return new Promise((_, reject) =>
      setTimeout(() => reject(new Error("Timeout")), this.options.timeout)
    );
  }

  private backoff(attempt: number): Promise<void> {
    const delay = Math.min(1000 * 2 ** attempt, 10_000);
    return new Promise((resolve) => setTimeout(resolve, delay));
  }
}

class TaskQueue {
  private queue: Task<unknown>[] = [];
  private running = 0;

  constructor(private concurrency: number = 4) {}

  enqueue<T>(
    name: string,
    handler: () => Promise<T>,
    options?: Partial<TaskOptions>
  ): Task<T> {
    const task = new Task(name, handler, { ...DEFAULT_OPTIONS, ...options });
    this.queue.push(task as Task<unknown>);
    this.queue.sort((a, b) => b.name.localeCompare(a.name));
    this.drain();
    return task;
  }

  private async drain(): Promise<void> {
    while (this.queue.length > 0 && this.running < this.concurrency) {
      const task = this.queue.shift()!;
      this.running++;

      task
        .execute()
        .then((result) => {
          console.log(`[${task.name}] completed in ${result.duration.toFixed(0)}ms`);
        })
        .catch((err: Error) => {
          console.error(`[${task.name}] ${err.message}`);
        })
        .finally(() => {
          this.running--;
          this.drain();
        });
    }
  }
}

// Usage
const queue = new TaskQueue(2);

const fetchUser = async (): Promise<{ name: string; active: boolean }> => {
  const res = await fetch("https://api.example.com/users/42");
  return res.json();
};

queue.enqueue("fetch-user", fetchUser, { priority: 10, retries: 2 });
queue.enqueue("sync-data", async () => ({ synced: true, count: 1583 }));
