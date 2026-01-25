import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/image/image_carousel.dart';
import 'package:frontend/presentation/widget/core/image/image_container.dart';
import 'package:frontend/presentation/widget/core/textform/textfield.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class AddRoomPage extends StatelessWidget {
  AddRoomPage({super.key});

  final TextEditingController fasilitasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        icon: const Icon(Icons.arrow_back),
        title: 'Room Detail',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: BasicCard(
            title: 'Add Room',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Room Images'),
                SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: Row(
                    children: [
                      Expanded(
                        child: ImageCarousel(
                          onDelete: (index) {},
                          showDeleteButton: true,
                          equalHeight: true,
                          height: 300,
                          images: List.generate(
                            5,
                            (index) => CarouselImage.network(
                              'http://127.0.0.1:8000/storage-access/rooms/thumbs/dummy-room-203-1.jpg',
                            ),
                          ),
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
                                onPressed: () {},
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
                        ),
                        SizedBox(height: 30),
                        CustomTextForm(
                          title: 'Price',
                          hintText: 'Enter room price',
                          keyboardType: TextInputType.number,
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
                          children: List.generate(
                            5,
                            (index) => CustomChip(
                              color: Theme.of(context).colorScheme.primary,
                              label: 'Facility ${index + 1}',
                            ),
                          ),
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
                                  ).colorScheme.surfaceContainerHigh,
                                ),
                              ),
                              SizedBox(width: 10),
                              CustomIconButton(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(150),
                                icon: Icon(Icons.add_rounded),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        CustomTextForm(
                          title: 'Description',
                          hintText: 'Enter room description',
                          maxLines: 10,
                        ),
                        SizedBox(height: 30),
                        BasicButton(onPressed: () {}, label: 'Add Room'),

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
  }
}
