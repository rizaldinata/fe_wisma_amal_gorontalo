import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/room/room_bloc.dart';
import 'package:frontend/presentation/bloc/room/room_event.dart';
import 'package:frontend/presentation/bloc/room/room_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RoomBloc>()..add(GetRoomsEvent()),
      child: const RoomView(),
    );
  }
}

class RoomView extends StatelessWidget {
  const RoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Kamar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RoomBloc>().add(GetRoomsEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.router.push(FormRoomRoute());
          if (result == true && context.mounted) {
            context.read<RoomBloc>().add(GetRoomsEvent());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<RoomBloc, RoomState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppSnackbar.showError(state.errorMessage!);
          }
          if (state.successMessage != null) {
            AppSnackbar.showSuccess(state.successMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == RoomStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.rooms.isEmpty) {
            return const Center(child: Text("Belum ada data kamar"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RoomBloc>().add(GetRoomsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                return _buildRoomCard(context, room);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomEntity room) {
    Color statusColor;
    switch (room.status) {
      case 'available':
        statusColor = Colors.green;
        break;
      case 'occupied':
        statusColor = Colors.red;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.meeting_room, color: statusColor),
        ),
        title: Text(
          "Kamar ${room.number}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${room.type} - Rp ${room.price}"),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                room.status.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await context.router.push(
                FormRoomRoute(room: room),
              );
              if (result == true && context.mounted) {
                context.read<RoomBloc>().add(GetRoomsEvent());
              }
            } else if (value == 'delete') {
              _showDeleteDialog(context, room);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text("Edit")),
            const PopupMenuItem(
              value: 'delete',
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RoomEntity room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Kamar"),
        content: Text("Yakin ingin menghapus kamar ${room.number}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RoomBloc>().add(DeleteRoomEvent(room.id));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
