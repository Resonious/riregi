import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:ffi/ffi.dart';

import 'data.dart';
import 'menu.dart';

class RegiPage extends StatefulWidget {
  const RegiPage({super.key, required this.app});

  final ActiveAppState app;

  @override
  State<RegiPage> createState() => _RegiPageState();
}

class _RegiPageState extends State<RegiPage> {
  @override
  Widget build(BuildContext context) {
    final a = widget.app;

    final menuItemsCount = a.rrMenuLen(a.ctx);
    final orderItemsCount = a.rrCurrentOrderLen(a.ctx);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: orderItemsCount == 0
                          ? const Center(
                              child: Text(
                                '空',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: orderItemsCount,
                              itemBuilder: (BuildContext context, int index) {
                                return MenuItem(
                                  name: a
                                      .rrOrderItemName(a.ctx, index)
                                      .toDartString(),
                                  price: a.rrOrderItemPrice(a.ctx, index),
                                  imagePath: a
                                      .rrOrderItemImagePath(a.ctx, index)
                                      .toDartString(),
                                  onPressed: () {
                                    setState(() {
                                      a.rrRemoveOrderItem(a.ctx, index);
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: List<Widget>.generate(
                              orderItemsCount,
                              (i) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.currency_yen,
                                    size: 10,
                                  ),
                                  Text(a.rrOrderItemPrice(a.ctx, i).toString()),
                                ],
                              ),
                              growable: false,
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1.0, color: Colors.grey),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.currency_yen,
                                size: 10,
                              ),
                              Text(a.rrCurrentOrderTotal(a.ctx).toString(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 30, child: Text('メニュー')),
                  Expanded(
                      child: menuItemsCount == 0
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'メニューが空っぽです。',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '商品を追加してください。',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: menuItemsCount,
                              itemBuilder: (BuildContext context, int index) {
                                return MenuItem(
                                  name: a
                                      .rrMenuItemName(a.ctx, index)
                                      .toDartString(),
                                  price: a.rrMenuItemPrice(a.ctx, index),
                                  imagePath: a
                                      .rrMenuItemImagePath(a.ctx, index)
                                      .toDartString(),
                                  onPressed: () {
                                    setState(() {
                                      a.rrAddItemToOrder(a.ctx, index);
                                    });
                                  },
                                );
                              },
                            )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
