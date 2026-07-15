import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/detail_room/detail_room_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/widget/core/image/image_carousel.dart';

@RoutePage()
class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key, @PathParam('id') required this.roomId});
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailRoomBloc(
        getRoomByIdUseCase: serviceLocator.get(),
        updateRoomUseCase: serviceLocator.get(),
      )..add(LoadDetailRoomEvent(roomId)),
      child: const RoomDetailView(),
    );
  }
}

class RoomDetailView extends StatelessWidget {
  const RoomDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailRoomBloc, DetailRoomState>(
      listener: (context, state) {},
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final roles = authState.userInfo?.roles ?? [];
        final isLoggedIn = authState.isLoggedIn;

        final isAdmin =
            roles.contains('admin') || roles.contains('super-admin');

        if (state.status == FormzSubmissionStatus.inProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == FormzSubmissionStatus.failure) {
          return Scaffold(
            appBar: CustomAppbar(
              icon: const Icon(Icons.arrow_back),
              title: 'Detail Kamar',
            ),
            body: Center(
              child: Text(
                state.errorMessage ?? 'Terjadi kesalahan tak terduga',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppbar(
            icon: const Icon(Icons.arrow_back),
            title: 'Detail Kamar',
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: BasicCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 400,
                      child: DynamicCarousel(
                        height: 400,
                        items:
                            state.room?.imageUrl
                                .map(
                                  (url) => CarouselImage.network(
                                    url.url,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (context.can(
                                  PermissionKeys.updateRooms,
                                )) ...[
                                  SizedBox(
                                    width: 200,
                                    child: BasicButton(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      type: ButtonType.secondary,
                                      trailIcon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        await context.router.push(
                                          EditRoomRoute(roomId: state.room!.id),
                                        );

                                        context.read<DetailRoomBloc>().add(
                                          LoadDetailRoomEvent(state.room!.id),
                                        );
                                      },
                                      label: 'Edit Kamar',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                /// TITLE
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.room?.title ?? '',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (state.room?.number != null &&
                                        state.room!.number.isNotEmpty) ...[
                                      Text(
                                        'No. ${state.room?.number}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    CustomChip(
                                      label:
                                          state.room?.status.displayName ?? '',
                                      color:
                                          state.room?.status.getColor ??
                                          Colors.grey,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),
                                const Divider(),
                                const SizedBox(height: 30),

                                /// FASILITAS
                                Text(
                                  'Fasilitas',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 20),

                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children:
                                      state.room?.facilities
                                          .map(
                                            (facility) => CustomChip(
                                              label: facility,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          )
                                          .toList() ??
                                      [],
                                ),

                                const SizedBox(height: 30),
                                const Divider(),
                                const SizedBox(height: 30),

                                Text(
                                  'Deskripsi',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  state.room?.description ?? '',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 30),

                          Expanded(
                            flex: 30,
                            child: BasicCard(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// PRICE
                                  Text(
                                    '${state.room?.priceFormatted} / bulan',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),

                                  if (state.room?.priceDaily != null &&
                                      state.room!.priceDaily > 0) ...[
                                    const SizedBox(height: 8),
                                    // Text(
                                    //   '${state.room?.priceDailyFormatted} / hari',
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .titleMedium
                                    //       ?.copyWith(
                                    //         color: Colors.blue.shade700,
                                    //       ),
                                    // ),
                                  ],
                                  if (!isAdmin &&
                                      state.room?.status ==
                                          RoomStatusEnum.available) ...[
                                    const SizedBox(height: 20),
                                    if (isLoggedIn)
                                      BasicButton(
                                        onPressed: () {
                                          context.router.push(
                                            ReservationDetailFormRoute(
                                              room: state.room!,
                                            ),
                                          );
                                        },
                                        label: 'Pesan Sekarang',
                                      )
                                    else
                                      BasicButton(
                                        onPressed: () {
                                          context.router.push(
                                            LoginRoute(pendingRoom: state.room),
                                          );
                                        },
                                        label: 'Login untuk Memesan',
                                      ),
                                  ],
                                ],
                              ),
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
        );
      },
    );
  }
}
