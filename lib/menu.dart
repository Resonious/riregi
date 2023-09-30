import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

import 'package:ffi/ffi.dart';

import 'data.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title, required this.app});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final ActiveAppState app;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

// BIG TODO
// actually this whole file. make this a real page where you can view and edit
// the whole menu.
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(2.0),
      child: Center(
        child: Row(
          children: [
            Text('-1'),
            Text('Tacos x1'),
            Text('+1'),
          ],
        ),
      ),
    );
  }
}

class _NewMenuItemModal extends StatefulWidget {
  const _NewMenuItemModal({required this.app, required this.onSubmit});

  final void Function() onSubmit;
  final ActiveAppState app;

  @override
  State<_NewMenuItemModal> createState() => _NewMenuItemModalState();
}

class _NewMenuItemModalState extends State<_NewMenuItemModal> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) {
      log("picked nothing");
    } else {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  _submit() {
    final a = widget.app;
    final name = nameController.text.toNativeUtf8();
    final price = int.tryParse(priceController.text) ?? 0;
    final imagePath = (selectedImage?.path ?? 'none').toNativeUtf8();

    a.rrMenuAdd(
      a.ctx,
      price,
      name,
      name.length,
      imagePath,
      imagePath.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 30,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text('新しい商品'),
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: selectedImage == null
                ? ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('画像'),
                  )
                : _Image(
                    onPressed: _pickImage,
                    image: FileImage(selectedImage!),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 20, 20),
            child: TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '商品名',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  child: Icon(
                    Icons.currency_yen,
                    size: 20.0,
                    semanticLabel: 'JPY',
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: false,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '値段',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _submit();
                  Navigator.pop(context);
                  widget.onSubmit();
                },
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    '追加',
                    textScaleFactor: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.image, this.onPressed});

  final ImageProvider image;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Material(
        child: Ink.image(
          fit: BoxFit.fill,
          width: 150,
          height: 150,
          image: image,
          child: InkWell(
            onTap: onPressed,
          ),
        ),
      ),
    );
  }
}

class _MenuPageState extends State<MenuPage> {
  void _addMenuItem() {
    setState(() {
      // final name = nameController.text.toNativeUtf8();
      final name = "crap".toNativeUtf8();

      widget.app.rrMenuAdd(
        widget.app.ctx,
        999,
        name,
        name.length,
        name,
        name.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final itemCount = a.rrMenuLen(a.ctx);

    // This method is rerun every time setState is called, for instance as done
    // by the _addMenuItem method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have this many MENU ITEMS, man!!',
            ),
            Text(
              '$itemCount',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const MenuItemCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: _NewMenuItemModal(
                app: a,
                onSubmit: () => setState(() {}),
              ),
            ),
          );
        },
        tooltip: 'Add new menu item',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
