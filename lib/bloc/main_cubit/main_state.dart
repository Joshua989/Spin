// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:spin/bloc/spin_cubit/spin_state.dart';

part 'main_state.g.dart';

@JsonSerializable(explicitToJson: true)
class MainState {
  final List<SpinState> states;
  final int currentIndex;
  final bool isLoading;

  SpinState get currentState => states[currentIndex];

  MainState({
    this.states = const [],
    this.currentIndex = 0,
    this.isLoading = true,
  });

  MainState copyWith({
    List<SpinState>? states,
    int? currentIndex,
    bool? isLoading,
  }) {
    return MainState(
      states: states ?? this.states,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory MainState.fromJson(Map<String, dynamic> json) =>
      _$MainStateFromJson(json);

  Map<String, dynamic> toJson() => _$MainStateToJson(this);
}
