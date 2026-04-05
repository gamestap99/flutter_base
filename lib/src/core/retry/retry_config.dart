/// Retry configuration for network operations
/// Part of BLoC Pro VIP Architecture
library;

/// Configuration for retry behavior
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Initial delay before first retry
  final Duration initialDelay;

  /// Multiplier for exponential backoff
  final double multiplier;

  /// Maximum delay between retries
  final Duration maxDelay;

  /// Whether to use jitter (randomness) in delay
  final bool useJitter;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.multiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.useJitter = true,
  });

  /// No retry configuration
  static const none = RetryConfig(maxAttempts: 0);

  /// Aggressive retry for important operations
  static const aggressive = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 200),
    multiplier: 1.5,
  );

  /// Conservative retry for less critical operations
  static const conservative = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 1),
    multiplier: 2.0,
  );

  /// Calculate delay for a specific attempt
  Duration getDelayForAttempt(int attempt) {
    if (attempt <= 0) return Duration.zero;

    var delay = initialDelay;
    for (var i = 1; i < attempt; i++) {
      delay = Duration(
        milliseconds: (delay.inMilliseconds * multiplier).round(),
      );
      if (delay > maxDelay) {
        delay = maxDelay;
        break;
      }
    }

    if (useJitter) {
      // Add random jitter up to 25% of delay
      final jitter = (delay.inMilliseconds * 0.25 * _random()).round();
      delay = Duration(milliseconds: delay.inMilliseconds + jitter);
    }

    return delay;
  }

  /// Simple random for jitter
  static double _random() {
    return DateTime.now().microsecond / 1000000;
  }

  RetryConfig copyWith({
    int? maxAttempts,
    Duration? initialDelay,
    double? multiplier,
    Duration? maxDelay,
    bool? useJitter,
  }) {
    return RetryConfig(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      initialDelay: initialDelay ?? this.initialDelay,
      multiplier: multiplier ?? this.multiplier,
      maxDelay: maxDelay ?? this.maxDelay,
      useJitter: useJitter ?? this.useJitter,
    );
  }
}

/// Retry executor with exponential backoff
class RetryExecutor {
  final RetryConfig config;

  const RetryExecutor([this.config = const RetryConfig()]);

  /// Execute an async operation with retry logic
  /// [action] - the operation to execute
  /// [shouldRetry] - optional predicate to determine if should retry on error
  /// [onRetry] - optional callback called before each retry
  Future<T> execute<T>(
    Future<T> Function() action, {
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Duration delay, Object error)? onRetry,
  }) async {
    int attempt = 0;
    Object? lastError;
    StackTrace? lastStackTrace;

    while (attempt < config.maxAttempts) {
      try {
        return await action();
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        attempt++;

        // Check if we should retry
        if (attempt >= config.maxAttempts) break;
        if (shouldRetry != null && !shouldRetry(error)) break;

        // Calculate delay and wait
        final delay = config.getDelayForAttempt(attempt);
        onRetry?.call(attempt, delay, error);
        await Future.delayed(delay);
      }
    }

    // All retries exhausted, throw last error
    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }
}
