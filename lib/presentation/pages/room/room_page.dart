import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/color_schemes.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/room/room_bloc.dart';
import 'package:frontend/presentation/bloc/room/room_event.dart';
import 'package:frontend/presentation/bloc/room/room_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc(serviceLocator.get())..add(GetRoomsEvent()),
      child: const RoomView(),
    );
  }
}

class RoomView extends StatefulWidget {
  const RoomView({super.key});

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatCard(
                        title: 'Total Rooms',
                        count: state.rooms.length.toString(),
                        color: Colors.green.shade100,
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Available Rooms',
                        count: state.availableRooms.length.toString(),
                        color: colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Occupied Rooms',
                        count: state.occupiedRooms.length.toString(),
                        color: colorScheme.errorContainer,
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Maintenance Rooms',
                        count: state.maintenanceRooms.length.toString(),
                        color: colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                            ),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(text: 'All'),
                              Tab(text: 'Available'),
                              Tab(text: 'Occupied'),
                              Tab(text: 'Maintenance'),
                            ],
                            controller: _controller,
                          ),
                        ),
                      ),

                      if (context.can(PermissionKeys.manageRooms)) ...[
                        SizedBox(width: 20),
                        BasicButton(
                          onPressed: () {},
                          label: 'Tambah Kamar',
                          leadIcon: Icon(Icons.add),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        BasicCard(child: Text('All Rooms List Here')),
                        BasicCard(child: Text('Available Rooms List Here')),
                        BasicCard(child: Text('Occupied Rooms List Here')),
                        BasicCard(child: Text('Maintenance Rooms List Here')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
