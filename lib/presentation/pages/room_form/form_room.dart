import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/utils/formatter/digit_formatter.dart';
import 'package:frontend/core/utils/image_utils.dart';
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
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

enum FormMode { add, edit }

// wrapper add room
@RoutePage(name: 'AddRoomRoute')
class AddRoomPage extends StatelessWidget {
  const AddRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormRoomBloc(
        createRoomUseCase: serviceLocator.get(),
        getRoomByIdUseCase: serviceLocator.get(),
        updateRoomUseCase: serviceLocator.get(),
        deleteRoomImageUseCase: serviceLocator.get(),
        uploadRoomImageUseCase: serviceLocator.get(),
      )..add(const LoadFormRoomEvent()),
      child: const FormRoomView(formMode: FormMode.add),
    );
  }
}

// wrapper edit room
@RoutePage(name: 'EditRoomRoute')
class EditRoomPage extends StatelessWidget {
  const EditRoomPage({super.key, @PathParam('id') required this.roomId});
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormRoomBloc(
        createRoomUseCase: serviceLocator.get(),
        getRoomByIdUseCase: serviceLocator.get(),
        updateRoomUseCase: serviceLocator.get(),
        deleteRoomImageUseCase: serviceLocator.get(),
        uploadRoomImageUseCase: serviceLocator.get(),
      )..add(LoadFormRoomEvent(roomId: roomId)),
      child: FormRoomView(formMode: FormMode.edit, roomId: roomId),
    );
  }
}

class FormRoomPage extends StatelessWidget {
  const FormRoomPage({super.key, this.roomId, required this.formMode});
  final FormMode formMode;
  final int? roomId;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
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

  final TextEditingController roomNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _facilitiesError;

  void setInitData(FormRoomState state) {
    titleController.text = state.room.title;
    descriptionController.text = state.room.description;
    priceController.text = ThousandsFormatter.format(state.room.price.toInt());
    roomNumberController.text = state.room.number;
  }

  @override
  void dispose() {
    fasilitasController.dispose();
    descriptionController.dispose();
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  List<Widget> buildChipList(List<String> facilities) {
    var widgets = <Widget>[];
    for (var i = 0; i < facilities.length; i++) {
      widgets.add(
        CustomChip(
          label: facilities[i],
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            context.read<FormRoomBloc>().add(RemoveFacilityEvent(index: i));
          },
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormRoomBloc, FormRoomState>(
      listener: (context, state) {
        if (state.facilities.isNotEmpty && _facilitiesError != null) {
          setState(() {
            _facilitiesError = null;
          });
        }

        if (state.submitStatus.isSuccess) {
          AppSnackbar.showSuccess(
            widget.formMode == FormMode.add
                ? 'Room added successfully'
                : 'Room updated successfully',
          );
          context.router.pop(true);
        } else if (state.submitStatus.isFailure) {
          AppSnackbar.showError(state.errorMessage ?? 'Failed to submit form');
        }
      },
      builder: (context, state) {
        if (widget.formMode == FormMode.edit &&
            state.loadStatus.isSuccess &&
            titleController.text.isEmpty &&
            descriptionController.text.isEmpty &&
            priceController.text.isEmpty) {
          setInitData(state);
        }

        if (state.loadStatus.isInProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: CustomAppbar(
            icon: const Icon(Icons.arrow_back),
            title: 'Kembali',
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
                                      RemoveRoomImageEvent(file: imageToDelete),
                                    );
                                  }
                                },
                                height: 300,
                                items: state.imageFiles.map((e) {
                                  if (e.url != null) {
                                    return CarouselImage.network(e.url!);
                                  } else if (e.file != null &&
                                      e.file!.bytes != null) {
                                    return CarouselImage.memory(e.file!.bytes!);
                                  } else {
                                    // Fallback if somehow both are null
                                    return const CarouselImage.asset(
                                      'assets/images/placeholder.png',
                                    );
                                  }
                                }).toList(),
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
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextForm(
                                    title: 'Title',
                                    hintText: 'Enter room title',
                                    controller: titleController,
                                    isRequired: true,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Title is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  CustomTextForm(
                                    title: 'Room number',
                                    hintText: 'Enter room number',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    maxLines: 1,
                                    controller: roomNumberController,
                                    isRequired: true,
                                  ),
                                  SizedBox(height: 30),
                                  CustomTextForm(
                                    title: 'Price',
                                    hintText: 'Enter room price',
                                    keyboardType: TextInputType.number,
                                    controller: priceController,
                                    isRequired: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      ThousandsFormatter(),
                                    ],
                                    validator: (v) {
                                      // final price = ThousandsFormatter.parse(
                                      //   priceController.text.trim(),
                                      // );
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Price is required';
                                      }
                                      final p = ThousandsFormatter.parse(
                                        v.trim(),
                                      );
                                      if (p == null || p <= 0) {
                                        return 'Price must be greater than 0';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    'Facilities',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: buildChipList(state.facilities),
                                  ),
                                  if (_facilitiesError != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _facilitiesError!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.red.shade300,
                                          ),
                                    ),
                                  ],
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 300),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Focus(
                                            onFocusChange: (hasFocus) {
                                              if (!hasFocus) {
                                                if (state.facilities.isEmpty) {
                                                  setState(() {
                                                    _facilitiesError =
                                                        'Please add at least one facility';
                                                  });
                                                } else if (_facilitiesError !=
                                                    null) {
                                                  setState(() {
                                                    _facilitiesError = null;
                                                  });
                                                }
                                              }
                                            },
                                            child: CustomTextField(
                                              controller: fasilitasController,
                                              fillColor: Theme.of(
                                                context,
                                              ).colorScheme.surfaceContainerLow,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        CustomIconButton(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary.withAlpha(150),
                                          icon: Icon(Icons.add_rounded),
                                          onPressed: () {
                                            if (fasilitasController.text
                                                .trim()
                                                .isEmpty) {
                                              setState(() {
                                                _facilitiesError =
                                                    'Please enter a facility';
                                              });
                                              AppSnackbar.showError(
                                                'Please enter a facility',
                                              );
                                              return;
                                            }

                                            context.read<FormRoomBloc>().add(
                                              AddFacilityEvent(
                                                facility: fasilitasController
                                                    .text
                                                    .trim(),
                                              ),
                                            );
                                            fasilitasController.clear();
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
                                    isRequired: true,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Description is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  BasicButton(
                                    onPressed: () {
                                      final valid =
                                          _formKey.currentState?.validate() ??
                                          false;
                                      if (!valid) {
                                        AppSnackbar.showError(
                                          'Please correct the form errors',
                                        );
                                        return;
                                      }

                                      if (state.facilities.isEmpty) {
                                        setState(() {
                                          _facilitiesError =
                                              'Please add at least one facility';
                                        });
                                        AppSnackbar.showError(
                                          'Please add at least one facility',
                                        );
                                        return;
                                      }

                                      // final price =
                                      //     double.tryParse(
                                      //       priceController.text.trim(),
                                      //     ) ??
                                      //     0;
                                      final price = ThousandsFormatter.parse(
                                        priceController.text.trim(),
                                      );

                                      context.read<FormRoomBloc>().add(
                                        SubmitFormRoomEvent(
                                          formMode: widget.formMode,
                                          roomData: state.room.copyWith(
                                            title: titleController.text.trim(),
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            price: price.toDouble(),
                                            facilities: state.facilities,
                                            number: roomNumberController.text
                                                .trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    label: widget.formMode == FormMode.add
                                        ? 'Add Room'
                                        : 'Update Room',
                                  ),
                                ],
                              ),
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
