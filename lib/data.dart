import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef RRGetErrorNative = Pointer<Utf8> Function();
typedef RRGetError = Pointer<Utf8> Function();
typedef RRStartNative = Pointer<Void> Function(Pointer<Utf8>, Uint32);
typedef RRStart = Pointer<Void> Function(Pointer<Utf8>, int);
typedef RRCleanupNative = Void Function(Pointer<Void>);
typedef RRCleanup = void Function(Pointer<Void>);
typedef RRMenuLenNative = Uint32 Function(Pointer<Void>);
typedef RRMenuLen = int Function(Pointer<Void>);
typedef RRMenuAddNative = Int Function(
    Pointer<Void>, Int64, Pointer<Utf8>, Uint32, Pointer<Utf8>, Uint32);
typedef RRMenuAdd = int Function(
    Pointer<Void>, int, Pointer<Utf8>, int, Pointer<Utf8>, int);
typedef RRMenuUpdateNative = Int Function(
    Pointer<Void>, Uint32, Int64, Pointer<Utf8>, Uint32, Pointer<Utf8>, Uint32);
typedef RRMenuUpdate = int Function(
    Pointer<Void>, int, int, Pointer<Utf8>, int, Pointer<Utf8>, int);
typedef RRMenuRemoveNative = Int Function(Pointer<Void>, Uint32);
typedef RRMenuRemove = int Function(Pointer<Void>, int);
typedef RRMenuItemNameNative = Pointer<Utf8> Function(Pointer<Void>, Uint32);
typedef RRMenuItemName = Pointer<Utf8> Function(Pointer<Void>, int);
typedef RRMenuItemImagePathNative = Pointer<Utf8> Function(
    Pointer<Void>, Uint32);
typedef RRMenuItemImagePath = Pointer<Utf8> Function(Pointer<Void>, int);
typedef RRMenuItemPriceNative = Int64 Function(Pointer<Void>, Uint32);
typedef RRMenuItemPrice = int Function(Pointer<Void>, int);
typedef RRMenuItemSetNameNative = Int Function(
    Pointer<Void>, Uint32, Pointer<Utf8>, Uint32);
typedef RRMenuItemSetName = int Function(
    Pointer<Void>, int, Pointer<Utf8>, int);
typedef RRMenuItemSetImagePathNative = Int Function(
    Pointer<Void>, Uint32, Pointer<Utf8>, Uint32);
typedef RRMenuItemSetImagePath = int Function(
    Pointer<Void>, int, Pointer<Utf8>, int);
typedef RRMenuItemSetPriceNative = Int Function(Pointer<Void>, Uint32, Int64);
typedef RRMenuItemSetPrice = int Function(Pointer<Void>, int, int);
typedef RROrdersLenNative = Uint64 Function(Pointer<Void>);
typedef RROrdersLen = int Function(Pointer<Void>);
typedef RRCurrentOrderLenNative = Uint32 Function(Pointer<Void>);
typedef RRCurrentOrderLen = int Function(Pointer<Void>);
typedef RRCurrentOrderTotalNative = Int64 Function(Pointer<Void>);
typedef RRCurrentOrderTotal = int Function(Pointer<Void>);
typedef RRCurrentOrderPaymentMethodNative = Uint16 Function(Pointer<Void>);
typedef RRCurrentOrderPaymentMethod = int Function(Pointer<Void>);
typedef RRCurrentOrderSetPaymentMethodNative = Void Function(
    Pointer<Void>, Uint16);
typedef RRCurrentOrderSetPaymentMethod = void Function(Pointer<Void>, int);
typedef RROrderLenNative = Uint32 Function(Pointer<Void>, Uint64);
typedef RROrderLen = int Function(Pointer<Void>, int);
typedef RROrderTotalNative = Int64 Function(Pointer<Void>, Uint64);
typedef RROrderTotal = int Function(Pointer<Void>, int);
typedef RROrderPaymentMethodNative = Uint16 Function(Pointer<Void>, Uint64);
typedef RROrderPaymentMethod = int Function(Pointer<Void>, int);
typedef RROrderTimestampNative = Int64 Function(Pointer<Void>, Uint64);
typedef RROrderTimestamp = int Function(Pointer<Void>, int);
typedef RRAddItemToOrderNative = Int Function(Pointer<Void>, Uint32);
typedef RRAddItemToOrder = int Function(Pointer<Void>, int);
typedef RRRemoveOrderItemNative = Int Function(Pointer<Void>, Uint32);
typedef RRRemoveOrderItem = int Function(Pointer<Void>, int);
typedef RROrderItemNameNative = Pointer<Utf8> Function(Pointer<Void>, Uint32);
typedef RROrderItemName = Pointer<Utf8> Function(Pointer<Void>, int);
typedef RROrderItemImagePathNative = Pointer<Utf8> Function(
    Pointer<Void>, Uint32);
typedef RROrderItemImagePath = Pointer<Utf8> Function(Pointer<Void>, int);
typedef RROrderItemPriceNative = Int64 Function(Pointer<Void>, Uint32);
typedef RROrderItemPrice = int Function(Pointer<Void>, int);
typedef RRViewOrderNative = Int Function(Pointer<Void>, Uint64);
typedef RRViewOrder = int Function(Pointer<Void>, int);
typedef RRViewItemNameNative = Pointer<Utf8> Function(Pointer<Void>, Uint32);
typedef RRViewItemName = Pointer<Utf8> Function(Pointer<Void>, int);
typedef RRViewItemImagePathNative = Pointer<Utf8> Function(
    Pointer<Void>, Uint32);
typedef RRViewItemImagePath = Pointer<Utf8> Function(Pointer<Void>, int);
typedef RRViewItemPriceNative = Int64 Function(Pointer<Void>, Uint32);
typedef RRViewItemPrice = int Function(Pointer<Void>, int);
typedef RRCompleteOrderNative = Int Function(Pointer<Void>);
typedef RRCompleteOrder = int Function(Pointer<Void>);

class ActiveAppState {
  final DynamicLibrary lib;
  final String dataPath;

  late final RRGetError rrGetError;
  late final RRStart rrStart;
  late final RRCleanup rrCleanup;
  late final RRMenuLen rrMenuLen;
  late final RRMenuAdd rrMenuAdd;
  late final RRMenuUpdate rrMenuUpdate;
  late final RRMenuRemove rrMenuRemove;
  late final RRMenuItemName rrMenuItemName;
  late final RRMenuItemImagePath rrMenuItemImagePath;
  late final RRMenuItemPrice rrMenuItemPrice;
  late final RRMenuItemSetName rrMenuItemSetName;
  late final RRMenuItemSetImagePath rrMenuItemSetImagePath;
  late final RRMenuItemSetPrice rrMenuItemSetPrice;
  late final RROrdersLen rrOrdersLen;
  late final RRCurrentOrderLen rrCurrentOrderLen;
  late final RRCurrentOrderTotal rrCurrentOrderTotal;
  late final RRCurrentOrderPaymentMethod rrCurrentOrderPaymentMethod;
  late final RRCurrentOrderSetPaymentMethod rrCurrentOrderSetPaymentMethod;
  late final RROrderLen rrOrderLen;
  late final RROrderTotal rrOrderTotal;
  late final RROrderPaymentMethod rrOrderPaymentMethod;
  late final RROrderTimestamp rrOrderTimestamp;
  late final RRAddItemToOrder rrAddItemToOrder;
  late final RRRemoveOrderItem rrRemoveOrderItem;
  late final RROrderItemName rrOrderItemName;
  late final RROrderItemImagePath rrOrderItemImagePath;
  late final RROrderItemPrice rrOrderItemPrice;
  late final RRViewOrder rrViewOrder;
  late final RRViewItemName rrViewItemName;
  late final RRViewItemImagePath rrViewItemImagePath;
  late final RRViewItemPrice rrViewItemPrice;
  late final RRCompleteOrder rrCompleteOrder;

  late final Pointer<Void> ctx;

  ActiveAppState({required this.lib, required this.dataPath}) {
    rrGetError =
        lib.lookupFunction<RRGetErrorNative, RRGetError>("rr_get_error");
    rrStart = lib.lookupFunction<RRStartNative, RRStart>("rr_start");
    rrCleanup = lib.lookupFunction<RRCleanupNative, RRCleanup>("rr_cleanup");
    rrMenuLen = lib.lookupFunction<RRMenuLenNative, RRMenuLen>("rr_menu_len");
    rrMenuAdd = lib.lookupFunction<RRMenuAddNative, RRMenuAdd>("rr_menu_add");
    rrMenuUpdate =
        lib.lookupFunction<RRMenuUpdateNative, RRMenuUpdate>("rr_menu_update");
    rrMenuRemove =
        lib.lookupFunction<RRMenuRemoveNative, RRMenuRemove>("rr_menu_remove");
    rrMenuItemName = lib.lookupFunction<RRMenuItemNameNative, RRMenuItemName>(
        "rr_menu_item_name");
    rrMenuItemImagePath =
        lib.lookupFunction<RRMenuItemImagePathNative, RRMenuItemImagePath>(
            "rr_menu_item_image_path");
    rrMenuItemPrice =
        lib.lookupFunction<RRMenuItemPriceNative, RRMenuItemPrice>(
            "rr_menu_item_price");
    rrMenuItemSetName =
        lib.lookupFunction<RRMenuItemSetNameNative, RRMenuItemSetName>(
            "rr_menu_item_set_name");
    rrMenuItemSetImagePath = lib.lookupFunction<RRMenuItemSetImagePathNative,
        RRMenuItemSetImagePath>("rr_menu_item_set_image_path");
    rrMenuItemSetPrice =
        lib.lookupFunction<RRMenuItemSetPriceNative, RRMenuItemSetPrice>(
            "rr_menu_item_set_price");
    rrOrdersLen =
        lib.lookupFunction<RROrdersLenNative, RROrdersLen>("rr_orders_len");
    rrCurrentOrderLen =
        lib.lookupFunction<RRCurrentOrderLenNative, RRCurrentOrderLen>(
            "rr_current_order_len");
    rrCurrentOrderTotal =
        lib.lookupFunction<RRCurrentOrderTotalNative, RRCurrentOrderTotal>(
            "rr_current_order_total");
    rrCurrentOrderPaymentMethod = lib.lookupFunction<
        RRCurrentOrderPaymentMethodNative,
        RRCurrentOrderPaymentMethod>("rr_current_order_payment_method");
    rrCurrentOrderSetPaymentMethod = lib.lookupFunction<
        RRCurrentOrderSetPaymentMethodNative,
        RRCurrentOrderSetPaymentMethod>("rr_current_order_set_payment_method");
    rrOrderLen =
        lib.lookupFunction<RROrderLenNative, RROrderLen>("rr_order_len");
    rrOrderTotal =
        lib.lookupFunction<RROrderTotalNative, RROrderTotal>("rr_order_total");
    rrOrderPaymentMethod =
        lib.lookupFunction<RROrderPaymentMethodNative, RROrderPaymentMethod>(
            "rr_order_payment_method");
    rrOrderTimestamp =
        lib.lookupFunction<RROrderTimestampNative, RROrderTimestamp>(
            "rr_order_timestamp");
    rrAddItemToOrder =
        lib.lookupFunction<RRAddItemToOrderNative, RRAddItemToOrder>(
            "rr_add_item_to_order");
    rrRemoveOrderItem =
        lib.lookupFunction<RRRemoveOrderItemNative, RRRemoveOrderItem>(
            "rr_remove_order_item");
    rrOrderItemName =
        lib.lookupFunction<RROrderItemNameNative, RROrderItemName>(
            "rr_order_item_name");
    rrOrderItemImagePath =
        lib.lookupFunction<RROrderItemImagePathNative, RROrderItemImagePath>(
            "rr_order_item_image_path");
    rrOrderItemPrice =
        lib.lookupFunction<RROrderItemPriceNative, RROrderItemPrice>(
            "rr_order_item_price");
    rrViewOrder =
        lib.lookupFunction<RRViewOrderNative, RRViewOrder>("rr_view_order");
    rrViewItemName = lib.lookupFunction<RRViewItemNameNative, RRViewItemName>(
        "rr_view_item_name");
    rrViewItemImagePath =
        lib.lookupFunction<RRViewItemImagePathNative, RRViewItemImagePath>(
            "rr_view_item_image_path");
    rrViewItemPrice =
        lib.lookupFunction<RRViewItemPriceNative, RRViewItemPrice>(
            "rr_view_item_price");
    rrCompleteOrder =
        lib.lookupFunction<RRCompleteOrderNative, RRCompleteOrder>(
            "rr_complete_order");

    final path = dataPath.toNativeUtf8();
    ctx = rrStart(path, path.length);
    if (ctx.address == 0) {
      log('we have a problem');
    }
  }
}
