class PageAction {
  static const PageAction search = const PageAction("search", "search");
  static const PageAction refresh = const PageAction("refresh", "refresh");
  static const PageAction add = const PageAction("add", "add");
  static const PageAction edit = const PageAction("edit", "edit");
  static const PageAction delete = const PageAction("delete", "delete");
  static const PageAction compare = const PageAction("compare", "compare");
  static const PageAction tag = const PageAction("tag", "label");
  static const PageAction openInNew =
      const PageAction("openInNew", "open_in_new");

  final String icon;
  final String name;
  const PageAction(this.name, this.icon);
}
