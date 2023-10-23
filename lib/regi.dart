import 'package:flutter/material.dart';

import 'package:ffi/ffi.dart';

import 'data.dart';
import 'menu.dart';

enum PaymentMethod {
  cash,
  dbarai,
  merpay,
  aupay,
}

String paymentMethodJA(PaymentMethod pm) {
  return switch (pm) {
    PaymentMethod.cash => "現金",
    PaymentMethod.dbarai => "ｄ払い",
    PaymentMethod.merpay => "メルペイ",
    PaymentMethod.aupay => "auPAY",
  };
}

List<Map<int, int>> _makeChange(int total, int paid) {
  if (total > paid) {
    throw ArgumentError(
        "Paid amount should be greater than or equal to total price.");
  }

  int change = paid - total;
  List<int> denominations = [10000, 5000, 1000, 500, 100, 50, 10, 5, 1];
  List<Map<int, int>> result = [];

  for (int denom in denominations) {
    // integer division to get count of current denomination
    int count = change ~/ denom;
    if (count > 0) {
      result.add({denom: count});
      change -= denom * count;
    }
  }

  return result;
}

class _OrderFinishModal extends StatefulWidget {
  const _OrderFinishModal(this.app, {required this.onSubmit});

  final ActiveAppState app;
  final void Function() onSubmit;

  @override
  State<_OrderFinishModal> createState() => _OrderFinishModalState();
}

class _OrderFinishModalState extends State<_OrderFinishModal> {
  List<Map<int, int>> change = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const labelWidth = 100.0;
    final a = widget.app;
    final total = a.rrCurrentOrderTotal(a.ctx);

    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 30,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text('お会計'),
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    '合計',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    currency.format(a.rrCurrentOrderTotal(a.ctx)),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text('お預り金',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        child: Text(
                          currency.currencySymbol,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                          onChanged: (value) {
                            final paid = int.tryParse(value) ?? 0;
                            if (paid < total) {
                              setState(() {
                                change = [];
                              });
                              return;
                            }

                            setState(() {
                              change = _makeChange(total, paid);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.grey),
                      ),
                      child: Column(
                        children: [
                          const Text('お釣り'),
                          Expanded(
                            child: SizedBox(
                              width: 100,
                              child: ListView(
                                children: change
                                    .map(
                                      (e) => Row(
                                        children: [
                                          Text(e.keys.first.toString()),
                                          const Text('円: ×'),
                                          Text(e.values.first.toString()),
                                        ],
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 165,
                      child: ListView(
                        children: PaymentMethod.values
                            .map((e) => RadioListTile<PaymentMethod>(
                                  title: Text(paymentMethodJA(e)),
                                  value: e,
                                  groupValue: PaymentMethod.values[
                                      a.rrCurrentOrderPaymentMethod(a.ctx)],
                                  onChanged: (value) {
                                    setState(() {
                                      a.rrCurrentOrderSetPaymentMethod(
                                          a.ctx, e.index);
                                    });
                                  },
                                ))
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ElevatedButton(
              onPressed: () {
                a.rrCompleteOrder(a.ctx);
                Navigator.pop(context);
                widget.onSubmit();
              },
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  '完了',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegiPage extends StatefulWidget {
  const RegiPage({super.key, required this.app});

  final ActiveAppState app;

  static Widget buildFloatingActionButton(
    BuildContext context,
    ActiveAppState app,
    void Function() onUpdate,
  ) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: _OrderFinishModal(app, onSubmit: onUpdate),
          ),
        );
      },
      tooltip: 'お会計を開始する',
      child: const Icon(Icons.payments),
    );
  }

  @override
  State<RegiPage> createState() => _RegiPageState();
}

class _RegiPageState extends State<RegiPage> {
  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final screen = MediaQuery.of(context).size;

    final menuItemsCount = a.rrMenuLen(a.ctx);
    final orderItemsCount = a.rrCurrentOrderLen(a.ctx);

    return Flex(
      direction: screen.width > screen.height ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
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
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    screen.width > screen.height ? 5 : 4,
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
                              (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  currency.format(a.rrOrderItemPrice(a.ctx, i)),
                                  textAlign: TextAlign.center,
                                ),
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
                          child: Center(
                              child: Text(
                            currency.format(a.rrCurrentOrderTotal(a.ctx)),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.right,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Container(
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
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    screen.width > screen.height ? 6 : 4,
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
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
