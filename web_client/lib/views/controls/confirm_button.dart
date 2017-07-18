import 'package:dartlery_shared/tools.dart';
import 'dart:async';
import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/services/services.dart';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/api/api.dart';

@Component(
    selector: 'confirm-button',
    styles: const [''],
    styleUrls: const ['../shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[materialDirectives],
    template: '''<div>
    <material-button *ngIf="!showConfirmation" icon (trigger)="showConfirmation=true"><glyph icon="{{icon}}"></glyph></material-button> 
    <material-button *ngIf="showConfirmation" icon (trigger)="showConfirmation=false"><glyph icon="cancel"></glyph></material-button>
    <br *ngIf="orientation=='vertical'"/> 
    <material-button *ngIf="showConfirmation" icon (trigger)="triggerInternal()"><glyph icon="{{icon}}"></glyph></material-button> 
    </div>''')
class ConfirmButtonComponent implements OnDestroy {
  @Input()
  String icon;

  bool showConfirmation = false;

  @Input()
  String orientation = "vertical";

  final StreamController<Null> _triggerStreamController =
      new StreamController<Null>.broadcast();

  @Output()
  Stream<Null> get trigger => _triggerStreamController.stream;

  void triggerInternal() {
    _triggerStreamController.add(null);
    showConfirmation = false;
  }

  @override
  void ngOnDestroy() {
    _triggerStreamController.close();
  }
}
