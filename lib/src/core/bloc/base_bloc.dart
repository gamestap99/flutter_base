import 'package:flutter_bloc/flutter_bloc.dart';

class BaseBlocBuilder<B extends StateStreamable<S>, S> extends BlocBuilder<B, S> {
  const BaseBlocBuilder({
    super.key,
    required super.builder,
    super.bloc,
    super.buildWhen,
  });
}
