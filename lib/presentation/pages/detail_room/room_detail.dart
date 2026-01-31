import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/detail_room/detail_room_bloc.dart';
import 'package:frontend/presentation/pages/room_form/form_room.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/image/image_carousel.dart';

@RoutePage()
class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key, @PathParam('id') required this.roomId});
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DetailRoomBloc(repository: serviceLocator.get())
            ..add(LoadDetailRoomEvent(roomId)),
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
        if (state.status == FormzSubmissionStatus.inProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == FormzSubmissionStatus.failure) {
          return Scaffold(
            appBar: CustomAppbar(
              icon: const Icon(Icons.arrow_back),
              title: 'Room Detail',
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
            title: 'Room Detail',
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
                    SizedBox(height: 24),

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
                                  PermissionKeys.manageRooms,
                                )) ...[
                                  SizedBox(
                                    width: 200,
                                    child: BasicButton(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      type: ButtonType.secondary,
                                      trailIcon: Icon(Icons.edit),
                                      onPressed: () async {
                                        await context.router.push(
                                          FormRoomRoute(
                                            formMode: FormMode.edit,
                                            roomId: state.room?.id,
                                          ),
                                        );

                                        context.read<DetailRoomBloc>().add(
                                          LoadDetailRoomEvent(state.room!.id),
                                        );
                                      },
                                      label: 'Edit Kamar',
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
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
                                    SizedBox(width: 10),
                                    if (state.room?.number != null &&
                                        state.room!.number.isNotEmpty) ...[
                                      Text(
                                        'No. ${state.room?.number}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      SizedBox(width: 10),
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
                                SizedBox(height: 30),
                                Divider(),
                                SizedBox(height: 30),
                                Text(
                                  'Fasilitas',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: 300,
                                  child: Wrap(
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
                                ),
                                SizedBox(height: 30),
                                Divider(),
                                SizedBox(height: 30),
                                Text(
                                  'Deskripsi',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  state.room?.description ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            flex: 30,
                            child: BasicCard(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.room?.priceFormatted}/ bulan',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 20),
                                  BasicButton(
                                    onPressed: () {},
                                    label: 'Pesan Sekarang',
                                  ),
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
