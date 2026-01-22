import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/room_entity.dart';

@RoutePage()
class FormRoomPage extends StatefulWidget {
  final RoomEntity? room;

  const FormRoomPage({super.key, this.room});

  @override
  State<FormRoomPage> createState() => _FormRoomPageState();
}

class _FormRoomPageState extends State<FormRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
      ),
      body: Center(child: Text('Form Room Page')),
    );
  }
}
