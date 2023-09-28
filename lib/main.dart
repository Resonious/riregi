import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _AppState();
}

// export fn rr_start(dir_path_ptr: [*:0]const u8, dir_path_len: u32) ?*anyopaque {
typedef RRStartNative = Pointer<Void> Function(Pointer<Utf8>, Uint32);
typedef RRStart = Pointer<Void> Function(Pointer<Utf8>, int);
// export fn rr_cleanup(app_state_ptr: *anyopaque) void {
typedef RRCleanupNative = Void Function(Pointer<Void>);
typedef RRCleanup = void Function(Pointer<Void>);

// export fn rr_get_error() [*c]const u8 {
typedef RRGetErrorNative = Pointer<Utf8> Function();
typedef RRGetError = RRGetErrorNative;

// export fn rr_menu_len(app_state_ptr: *anyopaque) u32 {
typedef RRMenuLenNative = Uint32 Function(Pointer<Void>);
typedef RRMenuLen = int Function(Pointer<Void>);

// export fn rr_menu_add(
//     app_state_ptr: *anyopaque,
//     price: i64,
//     name: [*c]const u8,
//     name_len: u32,
//     image_path: [*c]const u8,
//     image_path_len: u32,
// ) c_int {
typedef RRMenuAddNative = Int Function(
  Pointer<Void>,
  Int64,
  Pointer<Utf8>,
  Uint32,
  Pointer<Utf8>,
  Uint32,
);
typedef RRMenuAdd = int Function(
  Pointer<Void>,
  int,
  Pointer<Utf8>,
  int,
  Pointer<Utf8>,
  int,
);

// export fn rr_menu_item_name(app_state_ptr: *anyopaque, index: u32) [*c]const u8 {
typedef RRMenuItemNameNative = Pointer<Utf8> Function(Pointer<Void>, Uint32);
typedef RRMenuItemName = Pointer<Utf8> Function(Pointer<Void>, int);

// export fn rr_menu_item_image_path(app_state_ptr: *anyopaque, index: u32) [*c]const u8 {
typedef RRMenuItemImagePathNative = Pointer<Utf8> Function(
  Pointer<Void>,
  Uint32,
);
typedef RRMenuItemImagePath = Pointer<Utf8> Function(
  Pointer<Void>,
  int,
);

// export fn rr_menu_item_price(app_state_ptr: *anyopaque, index: u32) i64 {
typedef RRMenuItemPriceNative = Int64 Function(Pointer<Void>, Uint32);
typedef RRMenuItemPrice = Int64 Function(Pointer<Void>, int);

class ActiveAppState {
  final DynamicLibrary lib;
  final String dataPath;
  late final RRStart rrStart;
  late final RRCleanup rrCleanup;
  late final RRMenuAdd rrMenuAdd;
  late final RRMenuLen rrMenuLen;
  late final RRMenuItemName rrMenuItemName;

  late final Pointer<Void> ctx;

  ActiveAppState({required this.lib, required this.dataPath}) {
    rrStart = lib.lookupFunction<RRStartNative, RRStart>("rr_start");
    rrCleanup = lib.lookupFunction<RRCleanupNative, RRCleanup>("rr_cleanup");
    rrMenuAdd = lib.lookupFunction<RRMenuAddNative, RRMenuAdd>("rr_menu_add");
    rrMenuLen = lib.lookupFunction<RRMenuLenNative, RRMenuLen>("rr_menu_len");
    rrMenuItemName = lib.lookupFunction<RRMenuItemNameNative, RRMenuItemName>(
      "rr_menu_item_name",
    );

    final path = dataPath.toNativeUtf8();
    ctx = rrStart(path, path.length);
    if (ctx.address == 0) {
      log('we have a problem');
    }
  }
}

class _AppState extends State<MyApp> {
  ActiveAppState? app;

  @override
  Widget build(BuildContext context) {
    const title = 'リレジ';

    if (app == null) {
      const platform = MethodChannel('com.riregi/lib');

      Future.wait([
        platform.invokeMethod<String>("getDataLibPath"),
        platform.invokeMethod<String>("getDataPath"),
      ]).then((value) {
        setState(() {
          var libPath = value[0]!;
          var dataPath = value[1]!;

          log('YES!! $value');
          app = ActiveAppState(
            lib: DynamicLibrary.open(libPath),
            dataPath: dataPath,
          );
        });
      });
    }

    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: app == null
          ? const Text('wouhn')
          : MyHomePage(title: title, app: app!),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.app});

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
  State<MyHomePage> createState() => _MyHomePageState();
}

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

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      final name = nameController.text.toNativeUtf8();

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
    final itemCount = widget.app.rrMenuLen(widget.app.ctx);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
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
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Name of new menu item',
              ),
              controller: nameController,
            ),
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
