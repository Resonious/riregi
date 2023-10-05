import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'menu.dart';
import 'regi.dart';
import 'orders.dart';

void main() {
  runApp(const MyApp());
}

enum AppPage {
  register,
  menu,
  orders,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  ActiveAppState? app;
  String? dataPath;
  String? dataError;

  @override
  void initState() {
    super.initState();
    const platform = MethodChannel('com.riregi/lib');

    Future.wait([
      platform.invokeMethod<String>("getDataLibPath"),
      platform.invokeMethod<String>("getDataPath"),
    ]).then((value) {
      setState(() {
        var libPath = value[0]!;
        var dataPath = value[1]!;

        app = ActiveAppState(
          lib: DynamicLibrary.open(libPath),
          dataPath: dataPath,
        );
        this.dataPath = dataPath;

        final err = app!.rrGetError();
        if (err.address != 0) dataError = err.toDartString();
      });
    });
  }

  @override
  void dispose() {
    if (app != null) {
      app!.rrCleanup(app!.ctx);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const title = 'リレジ';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: app == null
          ? const Scaffold(body: Center(child: Text('読み込み中')))
          : dataError == null
              ? Scaffold(body: AppFrame(app: app!, dataPath: dataPath!))
              : Scaffold(body: Center(child: Text(dataError!))),
    );
  }
}

class AppFrame extends StatefulWidget {
  const AppFrame({super.key, required this.app, required this.dataPath});

  final ActiveAppState app;
  final String dataPath;

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  AppPage page = AppPage.register;

  @override
  void initState() {
    super.initState();
    final a = widget.app;

    if (a.rrMenuLen(a.ctx) == 0) {
      page = AppPage.menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: switch (page) {
          AppPage.register => const Text('レジ'),
          AppPage.menu => const Text('メニュー編集'),
          AppPage.orders => const Text('注文履歴'),
        },
      ),
      body: switch (page) {
        AppPage.register => RegiPage(app: widget.app),
        AppPage.menu => MenuPage(app: widget.app, dataPath: widget.dataPath),
        AppPage.orders => OrdersPage(app: widget.app),
      },
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            _NavButton(
              icon: Icons.receipt_long,
              text: 'レジ',
              selected: page == AppPage.register,
              onPressed: () => setState(() => page = AppPage.register),
            ),
            _NavButton(
              icon: Icons.edit_square,
              text: 'メニュー編集',
              selected: page == AppPage.menu,
              onPressed: () => setState(() => page = AppPage.menu),
            ),
            _NavButton(
              icon: Icons.list_alt,
              text: '履歴',
              selected: page == AppPage.orders,
              onPressed: () => setState(() => page = AppPage.orders),
            ),
          ],
        ),
      ),
      floatingActionButton: switch (page) {
        AppPage.register =>
          RegiPage.buildFloatingActionButton(context, widget.app, () {
            setState(() {});
          }),
        AppPage.menu =>
          MenuPage.buildFloatingActionButton(context, widget.app, () {
            setState(() {});
          }, dataPath: widget.dataPath),
        AppPage.orders => null,
      },
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.text,
    this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).colorScheme.primary : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: SizedBox(
        width: 80,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: selected ? 12 : 10,
                    color: color,
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
