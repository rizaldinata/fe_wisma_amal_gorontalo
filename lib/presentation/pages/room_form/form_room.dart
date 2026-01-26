import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/utils/image_utils.dart';
import 'package:frontend/data/repository/room_repository.dart';
import 'package:frontend/presentation/bloc/detail_room/detail_room_bloc.dart';
import 'package:frontend/presentation/bloc/form_room/form_room_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/image/image_carousel.dart';
import 'package:frontend/presentation/widget/core/textform/textfield.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

enum FormMode { add, edit }

@RoutePage()
class FormRoomPage extends StatelessWidget {
  const FormRoomPage({super.key, required this.formMode, this.roomId});
  final FormMode formMode;
  final int? roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FormRoomBloc(repository: serviceLocator.get<RoomRepository>())
            ..add(LoadFormRoomEvent(roomId: roomId)),
      child: FormRoomView(formMode: formMode, roomId: roomId),
    );
  }
}

class FormRoomView extends StatefulWidget {
  const FormRoomView({super.key, required this.formMode, this.roomId});
  final FormMode formMode;
  final int? roomId;

  @override
  State<FormRoomView> createState() => _FormRoomViewState();
}

class _FormRoomViewState extends State<FormRoomView> {
  final TextEditingController fasilitasController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  void setInitData(FormRoomState state) {
    titleController.text = state.room.title;
    descriptionController.text = state.room.description;
    priceController.text = state.room.price.toString();
  }

  @override
  void dispose() {
    fasilitasController.dispose();
    descriptionController.dispose();
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormRoomBloc, FormRoomState>(
      builder: (context, state) {
        if (widget.formMode == FormMode.edit && state.loadStatus.isSuccess) {
          setInitData(state);
        }

        return Scaffold(
          appBar: CustomAppbar(
            icon: const Icon(Icons.arrow_back),
            title: 'Back',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: BasicCard(
                title: widget.formMode == FormMode.add
                    ? 'Add Room'
                    : 'Edit Room',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Images'),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.imageFiles.isNotEmpty)
                            Expanded(
                              child: DynamicCarousel(
                                onDelete: (index) {
                                  var imageToDelete = state.imageFiles[index];
                                  if (imageToDelete.id != null) {
                                    context.read<FormRoomBloc>().add(
                                      RemoveRoomImageEvent(
                                        index: imageToDelete.id!,
                                      ),
                                    );
                                  }
                                },
                                height: 300,
                                items: state.imageFiles
                                    .map(
                                      (e) => e.url != null
                                          ? CarouselImage.network(e.url!)
                                          : CarouselImage.memory(
                                              e.file!.bytes!,
                                            ),
                                    )
                                    .toList(),
                              ),
                            ),
                          SizedBox(width: 20),

                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh.withAlpha(100),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: CustomIconButton(
                                    icon: Icon(Icons.add_rounded),
                                    onPressed: () async {
                                      context.read<FormRoomBloc>().add(
                                        PickRoomImagesEvent(),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text('Add Image'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextForm(
                              title: 'Title',
                              hintText: 'Enter room title',
                              controller: titleController,
                            ),
                            SizedBox(height: 30),
                            CustomTextForm(
                              title: 'Price',
                              hintText: 'Enter room price',
                              keyboardType: TextInputType.number,
                              controller: priceController,
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Facilities',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: state.room.facilities
                                  .map(
                                    (e) => CustomChip(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      label: e,
                                    ),
                                  )
                                  .toList(),
                            ),
                            SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 300),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: fasilitasController,
                                      fillColor: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerLow,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  CustomIconButton(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(150),
                                    icon: Icon(Icons.add_rounded),
                                    onPressed: () {
                                      context.read<FormRoomBloc>().add(
                                        EditFormRoomEvent(
                                          roomData: state.room.copyWith(
                                            facilities: [
                                              ...state.room.facilities,
                                              fasilitasController.text,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            CustomTextForm(
                              title: 'Description',
                              hintText: 'Enter room description',
                              maxLines: 10,
                              controller: descriptionController,
                            ),
                            SizedBox(height: 30),
                            BasicButton(
                              onPressed: () {
                                print('Submit form room');
                                print('Update room');
                                context.read<FormRoomBloc>().add(
                                  SubmitFormRoomEvent(
                                    roomData: state.room.copyWith(
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      price:
                                          double.tryParse(
                                            priceController.text,
                                          ) ??
                                          0,
                                    ),
                                  ),
                                );
                                context.router.pop(true);
                              },
                              label: widget.formMode == FormMode.add
                                  ? 'Add Room'
                                  : 'Update Room',
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
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
