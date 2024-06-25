import 'package:bloc/bloc.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';

class SpinCubit extends Cubit<SpinState> {
  SpinCubit() : super(const SpinState());

  void switchState(SpinState state) {
    emit(state);
  }

  void addSpin(String spin) {
    final spins = state.spins;
    emit(
      state.copyWith(
        spins: [...spins, spin],
        betResults: [...state.betResults, 0],
        betResults2: [...state.betResults2, 0],
        totalModifiers: [...state.totalModifiers, 0],
      ),
    );
  }

  void removeSpin() {
    final spins = state.spins;
    if (spins.isNotEmpty) {
      emit(
        state.copyWith(
          spins: spins.sublist(0, spins.length - 1),
          betResults: state.betResults.sublist(0, state.betResults.length - 1),
          betResults2:
              state.betResults2.sublist(0, state.betResults2.length - 1),
          totalModifiers:
              state.totalModifiers.sublist(0, state.totalModifiers.length - 1),
        ),
      );
    }
  }

  void clearSpins() {
    emit(state.copyWith(spins: [], betResults: [], totalModifiers: [], betResults2: []));
  }

  void toggleIsAbove() {
    emit(state.copyWith(isAbove: !state.isAbove));
  }

  void setSpinsToLookBack(int spinsToLookBack) {
    emit(state.copyWith(spinsToLookBack: spinsToLookBack));
  }

  void setStartHighlightAt(double startHighlightAt) {
    emit(state.copyWith(startHighlightAt: startHighlightAt));
  }

  void loadState(SpinState spinState) {
    emit(spinState);
  }

  void setBet(int index, double value) {
    final betResults = state.betResults;
    betResults[index] = value;
    emit(state.copyWith(betResults: betResults));
  }

  void setBet2(int index, double value) {
    final betResults2 = state.betResults2;
    betResults2[index] = value;
    emit(state.copyWith(betResults2: betResults2));
  }

  void setTotalModifier(int index, double value) {
    final totalModifiers = state.totalModifiers;
    totalModifiers[index] = value;
    emit(state.copyWith(totalModifiers: totalModifiers));
  }

  void undo() {
    final spins = state.spins;
    if (spins.isNotEmpty) {
      final betResults = state.betResults;
      emit(
        state.copyWith(
          spins: spins.sublist(0, spins.length - 1),
          betResults: betResults.sublist(0, betResults.length - 1),
          betResults2:
              state.betResults2.sublist(0, state.betResults2.length - 1),
        ),
      );
    }
  }

  void setSpinType(SpinType spinType) {
    emit(state.copyWith(spinType: spinType));
  }
}
