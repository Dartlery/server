import 'dart:html';
import 'page_message.dart';

class PageAction {
  static const PageAction search = const PageAction("search", "search");
  static const PageAction refresh = const PageAction("refresh", "refresh");
  static const PageAction add = const PageAction("add", "add");
  static const PageAction edit = const PageAction("edit", "edit");
  static const PageAction delete = const PageAction("delete", "delete",
      message: const PageMessage("Delete", "Are you sure you want to delete?",
          buttons: PageMessageButtons.yesNo), shortcut: KeyCode.DELETE);
  static const PageAction compare = const PageAction("compare", "compare");
  static const PageAction tag = const PageAction("tag", "label");
  static const PageAction restore = const PageAction("restore", "restore");
  static const PageAction openInNew =
      const PageAction("openInNew", "open_in_new");

  final String icon;
  final String name;
  final PageMessage message;
  final int shortcut;
  final bool shortcutCtrl, shortcutAlt, shortcutShit;
  const PageAction(this.name, this.icon,
      {this.message, this.shortcut, this.shortcutCtrl= false, this.shortcutAlt= false, this.shortcutShit=false});

  @override
  String toString() => "Page Action: $name";
}