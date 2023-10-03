import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:ffi/ffi.dart';

import 'data.dart';

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

      if (!isNew && await selectedImage!.exists()) {
        final a = widget.app;
        final newPath = picked.path.toNativeUtf8();
        a.rrMenuItemSetImagePath(
            a.ctx, widget.editIndex!, newPath, newPath.length);
        widget.onSubmit();
      }
    }
  }

  _submitNew() {
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

  Widget _menuItemNameText(BuildContext context) {
    return Text(
      _menuItemName!,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
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
                          _menuItemNameText(context),
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Image(
                        onPressed: _pickImage,
                        image: FileImage(selectedImage!),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedImage = null;
                          });

                          if (!isNew) {
                            final a = widget.app;
                            final newPath = 'none'.toNativeUtf8();
                            a.rrMenuItemSetImagePath(a.ctx, widget.editIndex!,
                                newPath, newPath.length);
                            widget.onSubmit();
                          }
                        },
                        child: const Text('画像を削除'),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 20, 20),
            child: TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              onChanged: isNew
                  ? null
                  : (value) {
                      final a = widget.app;
                      final newName = value.toNativeUtf8();
                      a.rrMenuItemSetName(
                          a.ctx, widget.editIndex!, newName, newName.length);
                      widget.onSubmit();
                    },
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
                    onChanged: isNew
                        ? null
                        : (value) {
                            final a = widget.app;
                            final newPrice = int.tryParse(value);
                            if (newPrice == null) return;
                            a.rrMenuItemSetPrice(
                                a.ctx, widget.editIndex!, newPrice);
                            widget.onSubmit();
                          },
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24 * 2),
                  ElevatedButton(
                    onPressed: () {
                      if (isNew) _submitNew();
                      Navigator.pop(context);
                      if (isNew) widget.onSubmit();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        isNew ? '追加' : '閉じる',
                      ),
                    ),
                  ),
                  isNew
                      ? const SizedBox(width: 24 * 2)
                      : IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.delete, semanticLabel: '削除'),
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('商品の削除'),
                                content: Wrap(
                                  direction: Axis.horizontal,
                                  children: [
                                    _menuItemNameText(context),
                                    const Text('を削除してもよろしいですか？'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final a = widget.app;
                                      a.rrMenuRemove(a.ctx, widget.editIndex!);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      widget.onSubmit();
                                    },
                                    child: const Text('削除'),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.image,
    this.onPressed,
    this.size = 150,
    this.text,
  });

  final double size;
  final ImageProvider image;
  final void Function()? onPressed;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Material(
        child: Ink.image(
          fit: BoxFit.fitWidth,
          width: size,
          height: size,
          image: image,
          child: InkWell(
            onTap: onPressed,
            child: text == null
                ? null
                : Center(
                    child: Stack(
                      children: [
                        Text(
                          text!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 0.5
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          text!,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatefulWidget {
  const MenuItem({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.onPressed,
  });

  final String name;
  final int price;
  final String imagePath;

  final void Function()? onPressed;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(
        () {
          setState(
            () {},
          );
        },
      );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final price = widget.price;

    return Tooltip(
      message: '$name ¥$price',
      child: Container(
        transform: Transform.scale(scale: animation.value).transform,
        child: _content(context, name, price.toString(), widget.imagePath),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    String name,
    String price,
    String imagePath,
  ) {
    if (imagePath.isNotEmpty && imagePath != 'none') {
      return _Image(
        size: 80,
        image: FileImage(File(imagePath)),
        onPressed: widget.onPressed,
        text: '¥$price',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: InkWell(
          onTap: widget.onPressed,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.currency_yen,
                      size: 10,
                    ),
                    Text(price),
                  ],
                )
              ],
            ),
          ),
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

// TODO: this could be stateless, but we'd have to make it so
// that each menu item is stateful and can rerender itself when
// edited.. as of right now, we're doing pretty much a full rerender
// every time an edit happens.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.app});

  final ActiveAppState app;

  static Widget buildFloatingActionButton(
    BuildContext context,
    ActiveAppState app,
    void Function() onUpdate,
  ) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () {
        editMenuItemInModal(context, app, onSubmit: onUpdate);
      },
      tooltip: '商品の新規作成',
      child: const Icon(Icons.add),
    );
  }

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    final a = widget.app;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: a.rrMenuLen(a.ctx),
      itemBuilder: (BuildContext context, int index) {
        return MenuItem(
          name: a.rrMenuItemName(a.ctx, index).toDartString(),
          price: a.rrMenuItemPrice(a.ctx, index),
          imagePath: a.rrMenuItemImagePath(a.ctx, index).toDartString(),
          onPressed: () {
            editMenuItemInModal(
              context,
              a,
              editIndex: index,
              onSubmit: () => setState(() {}),
            );
          },
        );
      },
    );
  }
}
