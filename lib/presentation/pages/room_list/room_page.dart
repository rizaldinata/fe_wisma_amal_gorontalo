import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_event.dart';
import 'package:frontend/presentation/bloc/room_list/room_state.dart';
import 'package:frontend/presentation/pages/room_list/widget/room_card.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/card/summary_stat_card.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_spacing.dart';

@RoutePage()
class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc(
        createRoomUseCase: serviceLocator.get(),
        deleteRoomUseCase: serviceLocator.get(),
        getRoomsUseCase: serviceLocator.get(),
        updateRoomUseCase: serviceLocator.get(),
      )..add(GetRoomsEvent()),
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
    final isDark = AppTheme.isDark(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final roles = authState.userInfo?.roles ?? [];
        final isAdmin = roles.contains('admin') || roles.contains('super-admin');
        
        return BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: isAdmin ? 'Kelola Kamar' : 'Daftar Kamar Tersedia',
                    breadcrumb: 'Kamar & Reservasi / Kelola Kamar',
                    action: isAdmin ? ElevatedButton.icon(
                      onPressed: () async {
                        await context.router.navigate(const AddRoomRoute());
                        if (mounted) {
                          context.read<RoomBloc>().add(GetRoomsEvent());
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Kamar'),
                    ) : null,
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAdmin) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Total Kamar',
                                    value: state.rooms.length.toString(),
                                    icon: Icons.bed_outlined,
                                    iconColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                                    iconBg: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Tersedia',
                                    value: state.availableRooms.length.toString(),
                                    icon: Icons.check_circle_outline,
                                    iconColor: isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood,
                                    iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Terisi',
                                    value: state.occupiedRooms.length.toString(),
                                    icon: Icons.person_outline,
                                    iconColor: isDark ? AppColorsDark.conditionPoor : AppColorsLight.conditionPoor,
                                    iconBg: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Perbaikan',
                                    value: state.maintenanceRooms.length.toString(),
                                    icon: Icons.build_circle_outlined,
                                    iconColor: isDark ? AppColorsDark.conditionFair : AppColorsLight.conditionFair,
                                    iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                          ],

                          /// TAB
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                            ),
                            child: TabBar(
                              controller: _controller,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: const [
                                Tab(text: 'Semua'),
                                Tab(text: 'Tersedia'),
                                Tab(text: 'Terisi'),
                                Tab(text: 'Perbaikan'),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          /// GRID
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
                              return _buildRoomGrid(currentRooms, state, isDark);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoomGrid(List<RoomEntity> rooms, RoomState state, bool isDark) {
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
          style: TextStyle(color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
        ),
      );
    }

    if (rooms.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bed_outlined, size: 64, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Tidak ada kamar',
                style: TextStyle(fontSize: 16, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (constraints.maxWidth ~/ 300).clamp(1, 10),
            crossAxisSpacing: AppSpacing.xl,
            mainAxisSpacing: AppSpacing.xl,
            childAspectRatio: 0.6,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return RoomCard(
              onTap: () async {
                await context.router.navigate(RoomDetailRoute(roomId: room.id));
                if (context.mounted) {
                  context.read<RoomBloc>().add(GetRoomsEvent());
                }
              },
              onDelete: () async {
                final confirmed = await AppDialog.show(
                  context,
                  title: 'Delete Room',
                  message: 'Are you sure you want to delete this room?',
                  confirmLabel: 'Delete',
                  type: AppDialogType.danger,
                );

                if (confirmed == true) {
                  context.read<RoomBloc>().add(DeleteRoomEvent(room.id));
                }
              },
              title: room.title,
              imageUrl: room.imageUrl.firstOrNull?.thumbnail,
              availability: room.status,
              description: room.description,
              roomNumber: room.number,
              price: '${room.priceFormatted} / bulan',
            );
          },
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
