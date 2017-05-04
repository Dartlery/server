import 'dart:async';
import 'dart:html';
import 'package:angular2/router.dart';
import 'package:angular2/angular2.dart';
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
    directives: const <dynamic>[materialDirectives, ROUTER_DIRECTIVES],
    template: '''
    <div style="width: 100%;white-space: nowrap;">
    <material-chips style="float: left;">
      <material-chip *ngFor="let t of selectedTags" (remove)="deselectTag(t)"><a [routerLink]="['ItemsSearch', {'query':t.toQueryString()}]" >{{t}}</a></material-chip>
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

  String generateQueryString(Tag t) => TagWrapper.createQueryString(t);

  TagList selectedTags = new TagList();

  TagList availableTags = new TagList();

  String tagQuery = "";

  bool tagListVisible = true;

  ApiService _api;

  @Input()
  set selected(List<Tag> tags) {
    this.selectedTags.clear();
    this.selectedTags.addTags(tags);
  }

  List<Tag> get selected => selectedTags.toListOfTags();

  @Output()
  EventEmitter<List<Tag>> selectedChanged = new EventEmitter<List<Tag>>();

  TagEntryComponent(this._api, Router router, AuthenticationService auth)
      : super(router, auth);

  @override
  Logger get loggerImpl => _log;

  void deselectTag(TagWrapper t) {
    if (this.selectedTags.contains(t)) {
      this.selectedTags.remove(t);
      _sendUpdatedTagEvent();
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
    switch(e.keyCode) {
      case KeyCode.ENTER:
        final Tag tag = new Tag();
        tag.id = tagQuery;
        selectedTags.add(new TagWrapper(tag));
        tagQuery = "";
        _sendUpdatedTagEvent();
        break;
        // TODO: Add up-down arrow handlers to allow for selecting suggested tags via keyboard.
      default:
        fetchAvailableTags();
        break;
    }
  }

  void selectTag(TagWrapper t) {
    if (!this.selectedTags.contains(t)) {
      this.selectedTags.add(t);
      _sendUpdatedTagEvent();
    }
    tagQuery = "";
  }
  void _sendUpdatedTagEvent() => selectedChanged.emit(selectedTags.toListOfTags());

}