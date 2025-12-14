/// Result type for handling success/failure operations
/// Alternative to dartz Either with more idiomatic Dart API
/// Part of BLoC Pro VIP Architecture
library;

import '../failure/failure.dart';

/// Result type represents either Success or Fail
/// Use this instead of throwing exceptions for expected failures
sealed class Result<T> {
  const Result();

  /// Create a success result
  const factory Result.success(T data) = Success<T>;

  /// Create a failure result
  const factory Result.failure(Failure failure) = Fail<T>;

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Fail<T>;

  /// Pattern matching with named parameters
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Fail(failure: final f) => failure(f),
    };
  }

  /// Pattern matching with optional failure handler
  R? whenSuccess<R>(R Function(T data) success) {
    return switch (this) {
      Success(:final data) => success(data),
      Fail() => null,
    };
  }

  /// Pattern matching with optional success handler
  R? whenFailure<R>(R Function(Failure failure) failure) {
    return switch (this) {
      Success() => null,
      Fail(failure: final f) => failure(f),
    };
  }

  /// Map success value to another type
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success(:final data) => Result.success(mapper(data)),
      Fail(:final failure) => Result.failure(failure),
    };
  }

  /// FlatMap for chaining Result operations
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success(:final data) => mapper(data),
      Fail(:final failure) => Result.failure(failure),
    };
  }

  /// Get value or return default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(:final data) => data,
      Fail() => defaultValue,
    };
  }

  /// Get value or compute default lazily
  T getOrElseLazy(T Function() defaultValue) {
    return switch (this) {
      Success(:final data) => data,
      Fail() => defaultValue(),
    };
  }

  /// Get value or throw the failure
  T getOrThrow() {
    return switch (this) {
      Success(:final data) => data,
      Fail(:final failure) => throw failure,
    };
  }

  /// Get failure or null if success
  Failure? get failureOrNull {
    return switch (this) {
      Success() => null,
      Fail(:final failure) => failure,
    };
  }

  /// Get data or null if failure
  T? get dataOrNull {
    return switch (this) {
      Success(:final data) => data,
      Fail() => null,
    };
  }

  /// Transform failure
  Result<T> mapFailure(Failure Function(Failure failure) mapper) {
    return switch (this) {
      Success() => this,
      Fail(:final failure) => Result.failure(mapper(failure)),
    };
  }

  /// Recover from failure with another value
  Result<T> recover(T Function(Failure failure) recovery) {
    return switch (this) {
      Success() => this,
      Fail(:final failure) => Result.success(recovery(failure)),
    };
  }

  /// Recover from failure with another Result
  Result<T> recoverWith(Result<T> Function(Failure failure) recovery) {
    return switch (this) {
      Success() => this,
      Fail(:final failure) => recovery(failure),
    };
  }
}

/// Success case of Result
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failure case of Result
class Fail<T> extends Result<T> {
  final Failure failure;

  const Fail(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Fail<T> && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Fail($failure)';
}

/// Extension for converting Future to Result
extension FutureResultX<T> on Future<T> {
  /// Convert Future<T> to Future<Result<T>>
  /// Catches exceptions and wraps them in appropriate Failure
  Future<Result<T>> toResult({
    Failure Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (error, stackTrace) {
      if (onError != null) {
        return Result.failure(onError(error, stackTrace));
      }
      return Result.failure(UnknownFailure.fromException(error, stackTrace));
    }
  }
}

/// Extension for List of Results
extension ResultListX<T> on List<Result<T>> {
  /// Combine list of Results into Result of list
  /// Returns first failure if any, or success with all values
  Result<List<T>> sequence() {
    final List<T> values = [];
    for (final result in this) {
      switch (result) {
        case Success(:final data):
          values.add(data);
        case Fail(:final failure):
          return Result.failure(failure);
      }
    }
    return Result.success(values);
  }

  /// Get all successes, ignoring failures
  List<T> get successes {
    return whereType<Success<T>>().map((s) => s.data).toList();
  }

  /// Get all failures
  List<Failure> get failures {
    return whereType<Fail<T>>().map((f) => f.failure).toList();
  }
}

/// Utility functions for Result
class ResultUtils {
  ResultUtils._();

  /// Run async operation and wrap in Result
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Result.success(data);
    } catch (error, stackTrace) {
      return Result.failure(UnknownFailure.fromException(error, stackTrace));
    }
  }

  /// Run sync operation and wrap in Result
  static Result<T> guardSync<T>(T Function() action) {
    try {
      final data = action();
      return Result.success(data);
    } catch (error, stackTrace) {
      return Result.failure(UnknownFailure.fromException(error, stackTrace));
    }
  }

  /// Combine two Results
  static Result<(T1, T2)> combine2<T1, T2>(
    Result<T1> r1,
    Result<T2> r2,
  ) {
    return r1.flatMap((d1) => r2.map((d2) => (d1, d2)));
  }

  /// Combine three Results
  static Result<(T1, T2, T3)> combine3<T1, T2, T3>(
    Result<T1> r1,
    Result<T2> r2,
    Result<T3> r3,
  ) {
    return r1.flatMap((d1) => r2.flatMap((d2) => r3.map((d3) => (d1, d2, d3))));
  }
}
