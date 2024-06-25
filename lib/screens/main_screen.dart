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
            context.read<MainCubit>().updateState(spinState);
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 60.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
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
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                                          context.read<MainCubit>().addState(const SpinState()),
                                        );
                                  },
                                  child: const Chip(
                                    label: Text("+ New Tab"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return const Expanded(
                        child: SpinScreen(),
                      );
                    },
                    childCount: 1, // Adjust this if you have multiple children
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
