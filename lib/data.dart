import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

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
typedef RRMenuUpdateNative = Int Function(
  Pointer<Void>,
  Uint32,
  Int64,
  Pointer<Utf8>,
  Uint32,
  Pointer<Utf8>,
  Uint32,
);
typedef RRMenuUpdate = int Function(
  Pointer<Void>,
  int,
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
typedef RRMenuItemPrice = int Function(Pointer<Void>, int);

typedef RRMenuItemSetNameNative = Bool Function(
    Pointer<Void>, Uint32, Pointer<Utf8>, Uint32);
typedef RRMenuItemSetName = bool Function(
    Pointer<Void>, int, Pointer<Utf8>, int);

typedef RRMenuItemSetImagePathNative = Bool Function(
    Pointer<Void>, Uint32, Pointer<Utf8>, Uint32);
typedef RRMenuItemSetImagePath = bool Function(
    Pointer<Void>, int, Pointer<Utf8>, int);

typedef RRMenuItemSetPriceNative = Bool Function(Pointer<Void>, Uint32, Int64);
typedef RRMenuItemSetPrice = bool Function(Pointer<Void>, int, int);

class ActiveAppState {
  final DynamicLibrary lib;
  final String dataPath;
  late final RRStart rrStart;
  late final RRCleanup rrCleanup;
  late final RRMenuAdd rrMenuAdd;
  late final RRMenuUpdate rrMenuUpdate;
  late final RRMenuLen rrMenuLen;
  late final RRMenuItemName rrMenuItemName;
  late final RRMenuItemImagePath rrMenuItemImagePath;
  late final RRMenuItemPrice rrMenuItemPrice;
  late final RRMenuItemSetName rrMenuItemSetName;
  late final RRMenuItemSetImagePath rrMenuItemSetImagePath;
  late final RRMenuItemSetPrice rrMenuItemSetPrice;

  late final Pointer<Void> ctx;

  ActiveAppState({required this.lib, required this.dataPath}) {
    rrStart = lib.lookupFunction<RRStartNative, RRStart>("rr_start");
    rrCleanup = lib.lookupFunction<RRCleanupNative, RRCleanup>("rr_cleanup");
    rrMenuAdd = lib.lookupFunction<RRMenuAddNative, RRMenuAdd>("rr_menu_add");
    rrMenuUpdate =
        lib.lookupFunction<RRMenuUpdateNative, RRMenuUpdate>("rr_menu_update");
    rrMenuLen = lib.lookupFunction<RRMenuLenNative, RRMenuLen>("rr_menu_len");
    rrMenuItemName = lib.lookupFunction<RRMenuItemNameNative, RRMenuItemName>(
      "rr_menu_item_name",
    );
    rrMenuItemImagePath =
        lib.lookupFunction<RRMenuItemImagePathNative, RRMenuItemImagePath>(
      "rr_menu_item_image_path",
    );
    rrMenuItemPrice =
        lib.lookupFunction<RRMenuItemPriceNative, RRMenuItemPrice>(
      "rr_menu_item_price",
    );
    rrMenuItemSetName =
        lib.lookupFunction<RRMenuItemSetNameNative, RRMenuItemSetName>(
      "rr_menu_item_set_name",
    );
    rrMenuItemSetImagePath = lib
        .lookupFunction<RRMenuItemSetImagePathNative, RRMenuItemSetImagePath>(
      "rr_menu_item_set_image_path",
    );
    rrMenuItemSetPrice =
        lib.lookupFunction<RRMenuItemSetPriceNative, RRMenuItemSetPrice>(
      "rr_menu_item_set_price",
    );

    final path = dataPath.toNativeUtf8();
    ctx = rrStart(path, path.length);
    if (ctx.address == 0) {
      log('we have a problem');
    }
  }
}
