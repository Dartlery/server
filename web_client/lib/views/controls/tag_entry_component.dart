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
    directives: const <dynamic>[materialDirectives, ROUTER_DIRECTIVES],
    template: '''
    <div style="width: 100%;white-space: nowrap;">
    <material-chips style="float: left;">
      <material-chip *ngFor="let t of selectedTagsInternal" (remove)="deselectTag(t)"><a [routerLink]="['ItemsSearch', {'query':t.toQueryString()}]" >{{t}}</a></material-chip>
    </material-chips>
    <span *ngIf="inputVisible" >
    <material-input label="Tag(s)" [(ngModel)]="tagQuery" popupSource #tagListSource="popupSource" (keyup)="searchKeyup(\$event)">
    </material-input>
    <material-popup [source]="tagListSource" [(visible)]="tagListVisible" [offsetY]="26">
      <material-list>
        <material-list-item (trigger)="selectTag(t)"  *ngFor="let t of availableTags">
          {{t}}
        </material-list-item>
      </material-list>
    </material-popup>

    </span>
    </div>
    ''')
class TagEntryComponent extends AApiErrorThing implements OnDestroy {
  static final Logger _log = new Logger("TagEntryComponent");

  @Input()
  DetailedApiRequestError error;

  @Input()
  bool singleTag = false;

  @Input()
  bool existingTags = false;

  TagList selectedTagsInternal = new TagList();

  TagList availableTags = new TagList();

  String tagQuery = "";

  @Input()
  bool tagListVisible = true;

  ApiService _api;

  final StreamController<List<Tag>> _selectedTagsChangeController =
      new StreamController<List<Tag>>();

  final StreamController<Tag> _selectedTagChangeController =
      new StreamController<Tag>();

  TagEntryComponent(this._api, Router router, AuthenticationService auth)
      : super(router, auth);

  bool get inputVisible {
    if (singleTag && selectedTagsInternal.isNotEmpty) return false;
    return true;
  }

  @override
  Logger get loggerImpl => _log;

  List<Tag> get selected => selectedTagsInternal.toListOfTags();

  @Input()
  set selectedTag(Tag tag) {
    this.selectedTagsInternal.clear();
    if (tag != null) this.selectedTagsInternal.addTags([tag]);
  }

  @Output()
  Stream<Tag> get selectedTagChange => _selectedTagChangeController.stream;

  List<Tag> get selectedTags => selectedTagsInternal.toListOfTags();

  @Input()
  set selectedTags(List<Tag> tags) {
    if (singleTag) throw new Exception("Single tag mode, use selectedTag");
    this.selectedTagsInternal.clear();
    if(tags!=null)
      this.selectedTagsInternal.addTags(tags);
  }

  @Output()
  Stream<List<Tag>> get selectedTagsChange =>
      _selectedTagsChangeController.stream;

  void deselectTag(TagWrapper t) {
    if (this.selectedTagsInternal.contains(t)) {
      this.selectedTagsInternal.remove(t);
      _sendUpdatedTagEvent();
    }
  }

  Future<Null> fetchAvailableTags() async {
    await performApiCall(() async {
      availableTags.clear();
      if (StringTools.isNullOrWhitespace(tagQuery)) return;
      final List<TagInfo> tags = await _api.tags.search(tagQuery);
      for (TagInfo t in tags) {
        availableTags.add(new TagWrapper.fromTagInfo(t));
      }
      tagListVisible = tags.isNotEmpty;
    });
  }

  String generateQueryString(Tag t) => TagWrapper.createQueryString(t);

  @override
  void ngOnDestroy() {
    _selectedTagsChangeController.close();
    _selectedTagChangeController.close();
  }

  void searchKeyup(KeyboardEvent e) {
    switch (e.keyCode) {
      case KeyCode.ENTER:
        if (!existingTags&&StringTools.isNotNullOrWhitespace(tagQuery)) {
          final Tag tag = new Tag();
          if(tagQuery.contains(categoryDeliminator)) {
            tag.id = tagQuery.substring(tagQuery.indexOf(categoryDeliminator)+1).trim();
            if(StringTools.isNullOrWhitespace(tag.id))
              return;
            tag.category = tagQuery.substring(0, tagQuery.indexOf(categoryDeliminator)).trim();
            if(StringTools.isNullOrWhitespace(tag.category))
              return;
          } else {
            tag.id = tagQuery.trim();
          }
          selectTag(new TagWrapper.fromTag(tag));
          tagQuery = "";
          _sendUpdatedTagEvent();
        }
        break;
      // TODO: Add up-down arrow handlers to allow for selecting suggested tags via keyboard.
      default:
        fetchAvailableTags();
        break;
    }
  }

  void selectTag(TagWrapper t) {
    if (!this.selectedTagsInternal.contains(t)) {
      if (singleTag) selectedTagsInternal.clear();
      this.selectedTagsInternal.add(t);
      _sendUpdatedTagEvent();
    }
    tagQuery = "";
  }

  void _sendUpdatedTagEvent() {
    _selectedTagsChangeController
        .add(selectedTagsInternal?.toListOfTags() ?? []);
    if (singleTag) {
      if (selectedTagsInternal.isEmpty)
        _selectedTagChangeController.add(null);
      else
        _selectedTagChangeController.add(selectedTagsInternal.first.tag);
    }
  }
}
