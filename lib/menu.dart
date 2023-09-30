import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

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

class _NewMenuItemModal extends StatefulWidget {
  const _NewMenuItemModal(ActiveAppState a,
      {required this.onSubmit, this.editIndex})
      : app = a;

  final void Function() onSubmit;
  final ActiveAppState app;
  final int? editIndex;

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

    if (isNew) {
      a.rrMenuAdd(
        a.ctx,
        price,
        name,
        name.length,
        imagePath,
        imagePath.length,
      );
    } else {
      a.rrMenuUpdate(
        a.ctx,
        widget.editIndex!,
        price,
        name,
        name.length,
        imagePath,
        imagePath.length,
      );
    }
  }

  bool get isNew => widget.editIndex == null;
  late String? _menuItemName;

  @override
  void initState() {
    super.initState();
    if (isNew) return;
    final a = widget.app;
    final i = widget.editIndex!;

    _menuItemName = a.rrMenuItemName(a.ctx, i).toDartString();

    nameController.text = _menuItemName!;
    priceController.text = a.rrMenuItemPrice(a.ctx, i).toString();

    selectedImage = File(a.rrMenuItemImagePath(a.ctx, i).toDartString());
    selectedImage!.exists().then(
      (exists) {
        if (!exists) {
          setState(() {
            selectedImage = null;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: isNew
                    ? const Text('新しい商品')
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _menuItemName!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('を編集'),
                        ],
                      ),
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
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    isNew ? '追加' : '保存',
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
  const _Image({required this.image, this.onPressed, this.size = 150});

  final double size;
  final ImageProvider image;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Material(
        child: Ink.image(
          fit: BoxFit.fill,
          width: size,
          height: size,
          image: image,
          child: InkWell(
            onTap: onPressed,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(ActiveAppState app, this.index, {this.onPressed}) : a = app;

  final ActiveAppState a;
  final int index;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final imagePath = a.rrMenuItemImagePath(a.ctx, index).toDartString();

    if (imagePath.isNotEmpty && imagePath != 'none') {
      return _Image(
        size: 80,
        image: FileImage(File(imagePath)),
        onPressed: onPressed,
      );
    }

    return Material(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(a.rrMenuItemName(a.ctx, index).toDartString()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.currency_yen,
                  size: 10,
                ),
                Text(a.rrMenuItemPrice(a.ctx, index).toString()),
              ],
            )
          ],
        ),
      ),
    );
  }
}

void editMenuItemInModal(
  BuildContext context,
  ActiveAppState app, {
  required void Function() onSubmit,
  int? editIndex,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: _NewMenuItemModal(
        app,
        onSubmit: onSubmit,
        editIndex: editIndex,
      ),
    ),
  );
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    final a = widget.app;

    // This method is rerun every time setState is called, for instance as done
    // by the _addMenuItem method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: const Text('メニュー編集'),
      ),

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: a.rrMenuLen(a.ctx),
          itemBuilder: (BuildContext context, int index) {
            return _MenuItem(a, index, onPressed: () {
              editMenuItemInModal(
                context,
                a,
                editIndex: index,
                onSubmit: () => setState(() {}),
              );
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          editMenuItemInModal(context, a, onSubmit: () => setState(() {}));
        },
        tooltip: '商品の新規作成',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
