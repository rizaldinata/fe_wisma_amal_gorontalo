import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_event.dart';
import 'package:frontend/presentation/bloc/room_list/room_state.dart';
import 'package:frontend/presentation/pages/room_list/widget/room_card.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                            tabs: const [
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
                        const SizedBox(width: 20),
                        BasicButton(
                          onPressed: () {
                            context.router.navigate(AddRoomRoute());
                          },
                          label: 'Tambah Kamar',
                          leadIcon: const Icon(Icons.add),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final List<RoomEntity> currentRooms;
                      switch (_controller.index) {
                        case 0:
                          currentRooms = state.rooms;
                          break;
                        case 1:
                          currentRooms = state.availableRooms;
                          break;
                        case 2:
                          currentRooms = state.occupiedRooms;
                          break;
                        case 3:
                          currentRooms = state.maintenanceRooms;
                          break;
                        default:
                          currentRooms = state.rooms;
                      }

                      return _buildRoomGrid(currentRooms, state);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomGrid(List<RoomEntity> rooms, RoomState state) {
    print('Building room grid with ${rooms.length} rooms');
    if (state.status == FormzSubmissionStatus.inProgress) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == FormzSubmissionStatus.failure) {
      return Center(
        child: Text(
          'Gagal memuat kamar: ${state.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (rooms.isEmpty) {
      return BasicCard(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bed_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tidak ada kamar',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return BasicCard(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 300,
              crossAxisSpacing: 30,
              mainAxisSpacing: 16,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return RoomCard(
                onTap: () {
                  context.router.navigate(RoomDetailRoute(roomId: room.id));
                },
                title: room.title,
                imageUrl: room.imageUrl.first.thumbnail,
                availability: room.status,
                description: room.description,
                price: '${room.priceFormatted} / bulan',
              );
            },
            itemCount: rooms.length,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
