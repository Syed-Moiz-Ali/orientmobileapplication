import 'package:flutter/material.dart';
import 'package:shared_core/src/widgets/error_view.dart';
import 'package:shared_core/src/widgets/loading_indicator.dart';

sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncState<T> {
  final T data;
  const AsyncData(this.data);
}

class AsyncError<T> extends AsyncState<T> {
  final String message;
  final Object? exception;
  final VoidCallback? onRetry;

  const AsyncError(this.message, {this.exception, this.onRetry});
}

extension AsyncStateX<T> on AsyncState<T> {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(String message, VoidCallback? onRetry) error,
  }) {
    return switch (this) {
      AsyncInitial() => initial(),
      AsyncLoading() => loading(),
      AsyncData(data: final d) => data(d),
      AsyncError(message: final m, onRetry: final r) => error(m, r),
    };
  }
}

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncState<T> state;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget? initialWidget;
  final String? loadingMessage;

  const AsyncValueWidget({
    super.key,
    required this.state,
    required this.builder,
    this.loadingWidget,
    this.initialWidget,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: () => initialWidget ?? const SizedBox.shrink(),
      loading: () => loadingWidget ?? LoadingIndicator(message: loadingMessage),
      data: (data) => builder(data),
      error: (message, onRetry) => _defaultError(message, onRetry),
    );
  }

  Widget _defaultError(String message, VoidCallback? onRetry) {
    return ErrorView(message: message, onRetry: onRetry);
  }
}
