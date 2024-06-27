import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spin/bloc/main_cubit/main_cubit.dart';
import 'package:spin/bloc/main_cubit/main_state.dart';
import 'package:spin/bloc/spin_cubit/spin_cubit.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';
import 'package:spin/screens/spin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //await Future.delayed(Duration(milliseconds: 500));
      context.read<SpinCubit>().loadState(
            context.read<MainCubit>().state.currentState,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container();
        }

        return BlocListener<SpinCubit, SpinState>(
          listener: (context, spinState) {
            /// Ensure the state is updated when the SpinCubit emits a new state
            context.read<MainCubit>().updateState(spinState);
          },
          child: Scaffold(
            body: Column(
              children: [
                const Expanded(
                  child: SpinScreen(),
                ),
                SizedBox(
                  height: 48.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...state.states.mapIndexed<Widget>(
                        (i, v) {
                          return GestureDetector(
                            onTap: () {
                              context.read<SpinCubit>().loadState(
                                    context.read<MainCubit>().setIndex(i),
                                  );
                            },
                            onLongPress: () {
                              if (context.read<MainCubit>().removeState(i)) {
                                context.read<SpinCubit>().loadState(
                                      context.read<MainCubit>().setIndex(0),
                                    );
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Chip(
                                label: Text(
                                  "Tab ${i + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                backgroundColor: state.currentIndex == i
                                    ? Colors.red
                                    : Colors.grey[300],
                              ),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<SpinCubit>().loadState(
                                context
                                    .read<MainCubit>()
                                    .addState(const SpinState()),
                              );
                        },
                        child: const Chip(
                          label: Text("+ New Tab"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
