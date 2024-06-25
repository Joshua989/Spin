import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin/bloc/main_cubit/main_state.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';
import 'package:spin/constants/shared_preferences_keys.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState()) {
    _initStates();
  }

  Future<void> _initStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesString = prefs.getString(SharedPreferencesKeys.states);
    if (statesString != null) {
      final states = MainState.fromJson(jsonDecode(statesString));
      emit(states.copyWith(isLoading: false));
    } else {
      emit(state.copyWith(states: [const SpinState()], isLoading: false));
    }
  }

  SpinState addState(SpinState newState) {
    final states = state.states;
    emit(
      state.copyWith(
        states: [...states, newState],
        currentIndex: states.length,
      ),
    );
    save();
    return newState;
  }

  /// Returns true if the current state was removed
  bool removeState(int index) {
    final states = state.states;
    if (states.length > 1) {
      states.removeAt(index);
      emit(state.copyWith(states: states));
      save();
      if (index == state.currentIndex) {
        return true;
      }
    }

    return false;
  }

  void clearStates() {
    emit(state.copyWith(states: []));
  }

  SpinState setIndex(int index) {
    emit(state.copyWith(currentIndex: index));
    return state.states[index];
  }

  void loadState(MainState mainState) {
    emit(mainState);
  }

  void updateState(SpinState newState) {
    final states = state.states;
    states[state.currentIndex] = newState;
    emit(state.copyWith(states: states));
    save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreferencesKeys.states, jsonEncode(state.toJson()));
  }
}
