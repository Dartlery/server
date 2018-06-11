import 'dart:html';

class PageMessage {
  final String title;
  final String message;
  final String secondaryOption;
  final PageMessageButtons buttons;

  const PageMessage(this.title, this.message,
      {this.secondaryOption = null, this.buttons = PageMessageButtons.ok});
}

class PageMessageButtons {
  static const PageMessageButtons ok =
      const PageMessageButtons(const <PageMessageButton>[PageMessageButton.ok]);
  static const PageMessageButtons okCancel =
      const PageMessageButtons(const <PageMessageButton>[
    PageMessageButton.ok,
    PageMessageButton.cancel
  ]);
  static const PageMessageButtons yesNo = const PageMessageButtons(
      const <PageMessageButton>[PageMessageButton.yes, PageMessageButton.no]);

  final List<PageMessageButton> buttons;
  const PageMessageButtons(this.buttons);
}

class PageMessageButton<T> {
  static const PageMessageButton<bool> ok =
      const PageMessageButton<bool>("OK", true, shortcut: KeyCode.ENTER);
  static const PageMessageButton<bool> cancel =
      const PageMessageButton<bool>("Cancel", false, shortcut: KeyCode.ESC);
  static const PageMessageButton<bool> yes =
      const PageMessageButton<bool>("Yes", true, shortcut: KeyCode.ENTER);
  static const PageMessageButton<bool> no =
      const PageMessageButton<bool>("No", false, shortcut: KeyCode.ESC);

  final T value;
  final String text;
  final int shortcut;

  const PageMessageButton(this.text, this.value, {this.shortcut});
}
