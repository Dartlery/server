import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/routes/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:angular_forms/angular_forms.dart';
import '../src/a_api_error_thing.dart';
import 'common_controls.dart';

@Component(
    selector: 'item-upload',
    styleUrls: const ['../shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      coreDirectives,
      formDirectives,
      materialDirectives,
      commonControls
    ],
    template: '''<modal [visible]="visible">
      <material-dialog class="basic-dialog">
          <h3 header>Upload</h3>
              <tag-entry style="width: 100%" (selectedChanged)="setTags(\$event)"></tag-entry>
            <form (ngSubmit)="onSubmit()" #loginForm="ngForm">
            <p>
              <input type="file" (change)="fileChanged(\$event)" />
              <error-output [error]="apiError"></error-output>
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

  List<Tag> tags = <Tag>[];

  String fileName;
  MediaMessage msg;

  bool loading = false;

  bool _visible = false;

  String fileUpload;

  void setTags(List<Tag> event) {
    this.tags = event;
  }

  final StreamController<bool> _visibleChangeController = new StreamController<bool>();
  @Output()
  Stream<bool> get visibleChange => _visibleChangeController.stream;


  final ApiService _api;

  ItemUploadComponent(this._api, Router router, AuthenticationService auth)
      : super(router, auth);

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
    _visibleChangeController.add(_visible);
  }

  Future<Null> fileChanged(Event e) async {
    try {
      final FileUploadInputElement input = e.target;

      if (input.files.length == 0) return;
      final File file = input.files[0];

      fileName = file.name;

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
    } catch (e, st) {
      window.alert(e.toString());
    }
  }

  Future<Null> onSubmit() async {
    if (msg == null) return;
    await performApiCall(() async {
      final CreateItemRequest request = new CreateItemRequest();
      request.item = new Item();
      request.item.tags = tags;
      request.item.fileName = fileName;
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
