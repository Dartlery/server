import 'dart:async';
import 'dart:html';
import 'package:dartlery/routes.dart';
import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:angular2/router.dart';
import '../src/a_api_error_thing.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/api/api.dart';
import 'package:mime/mime.dart';

@Component(
    selector: 'item-upload',
    styleUrls: const ['../shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives
    ],
    template: '''<modal [visible]="visible">
      <material-dialog class="basic-dialog">
          <h3 header>Upload</h3>
            <form (ngSubmit)="onSubmit()" #loginForm="ngForm">
            <p>
              <material-input [(ngModel)]="tags" ngControl="tags"
                    floatingLabel required  label="Tags"></material-input><br/>
              <input type="file" (change)="fileChanged(\$event)" />
              <error-output [error]="apiError"></error-output>
              <input type="submit" style="position: absolute; left: -9999px; width: 1px; height: 1px;"/>
          </p>
            </form>
          <div footer style="text-align: right">
            <material-yes-no-buttons yesHighlighted
            yesText="Upload" (yes)="onSubmit()"
            noText="Cancel" (no)="visible = false"
            [pending]="processing" [yesDisabled]="!loginForm.valid">
            </material-yes-no-buttons>

          </div>
      </material-dialog>
    </modal>''')
class ItemUploadComponent extends AApiErrorThing {
  static final Logger _log = new Logger("ItemUploadComponent");

  String tags;

  MediaMessage msg;

  bool loading = false;

  Future<Null> fileChanged(Event e) async {
    try {
      FileUploadInputElement input = e.target;

      if (input.files.length == 0) return;
      final File file = input.files[0];

      loading = true;
      processing = true;

      final FileReader reader = new FileReader();
      reader.readAsArrayBuffer(file);
      await for (dynamic fileEvent in reader.onLoad) {
        try {
          _log.fine(fileEvent);
          msg = new MediaMessage();
          msg.bytes = reader.result;
        } finally {
          loading = false;
          processing = false;
        }
      }
    } catch(e,st) {
      window.alert(e.toString());

    }
  }

  bool _visible = false;


  String fileUpload;

  @Output()
  EventEmitter<bool> visibleChange = new EventEmitter<bool>();

  final ApiService _api;

  ItemUploadComponent(this._api, Router router, AuthenticationService auth): super(router, auth);


  @override
  Logger get loggerImpl => _log;

  bool get visible => _visible;

  @Input()
  set visible(bool value) {
    reset();
    if (value) {
      processing = false;
    }
    _visible = value;
    visibleChange.emit(_visible);
  }

  Future<Null> onSubmit() async {
    if(msg==null)
      return;
    await performApiCall(() async {
      final CreateItemRequest request  = new CreateItemRequest();
      request.item = new Item();
      request.item.tags = <Tag>[];
      for(String tag in tags.split(" ")) {
        if(StringTools.isNullOrWhitespace(tag))
          continue;

        final Tag newTag = new Tag();
        newTag.id = tag;
        request.item.tags.add(newTag);
      }
      request.file = msg;

      await _api.items.createItem(request);

      visible = false;
    });
  }

  void reset() {
    msg = null;

    errorMessage = "";
  }

}