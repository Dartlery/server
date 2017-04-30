import 'dart:async';
import 'dart:html';

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';

import '../src/a_api_error_thing.dart';

@Component(
    selector: 'tag-entry',
    styles: const [''],
    styleUrls: const ['../shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[materialDirectives],
    template: '''
    <div style="width: 100%;white-space: nowrap;">
    <material-chips style="float: left;">
      <material-chip *ngFor="let t of selectedTags" (remove)="deselectTag(t)">{{t}}</material-chip>
    </material-chips>
    <material-input label="Tag(s)" [(ngModel)]="tagQuery" popupSource #tagListSource="popupSource" (keyup)="searchKeyup(\$event)">
    </material-input>
    </div>
    <material-popup [source]="tagListSource" [(visible)]="tagListVisible" [offsetY]="26">
      <material-list>
        <material-list-item (trigger)="selectTag(t)"  *ngFor="let t of availableTags">
          {{t}}
        </material-list-item>
      </material-list>
    </material-popup>
    ''')
class TagEntryComponent extends AApiErrorThing {
  static final Logger _log = new Logger("TagEntryComponent");

  @Input()
  DetailedApiRequestError error;

  List<TagWrapper> selectedTags = <TagWrapper>[];

  List<TagWrapper> availableTags = <TagWrapper>[];

  String tagQuery = "";

  bool tagListVisible = true;

  ApiService _api;

  @Output()
  EventEmitter<TagEntryChangedEvent> changed = new EventEmitter<TagEntryChangedEvent>();

  TagEntryComponent(this._api, Router router, AuthenticationService auth)
      : super(router, auth);

  @override
  Logger get loggerImpl => _log;

  void deselectTag(TagWrapper t) {
    if (this.selectedTags.contains(t)) {
      this.selectedTags.remove(t);
      changed.emit(new TagEntryChangedEvent(new List<TagWrapper>.from(selectedTags)));
    }
  }

  Future<Null> fetchAvailableTags() async {
    await performApiCall(() async {
      availableTags.clear();
      if(StringTools.isNullOrWhitespace(tagQuery))
        return;
      final List<Tag> tags = await _api.tags.search(tagQuery);
      for (Tag t in tags) {
        availableTags.add(new TagWrapper(t));
      }
      tagListVisible = tags.isNotEmpty;
    });
  }

  void searchKeyup(KeyboardEvent e) {
    if (e.keyCode == KeyCode.ENTER) {}
    fetchAvailableTags();
  }

  void selectTag(TagWrapper t) {
    if (!this.selectedTags.contains(t)) {
      this.selectedTags.add(t);
      changed.emit(new TagEntryChangedEvent(new List<TagWrapper>.from(selectedTags)));
    }
    tagQuery = "";
  }
}

class TagEntryChangedEvent {
  final List<TagWrapper> tags;
  TagEntryChangedEvent(this.tags);
}