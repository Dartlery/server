part of model;

class SettingsModel {
  static int thumbnailMaxDimension = 200;
  
  static const String FILES_DIR = 'files'; 
  static const String THUMBS_DIR = 'thumbs';
  static const String STATIC_DIR = 'static';

  final List<String> allowedMimeTypes = new List<String>();
  
  SettingsModel() {
    allowedMimeTypes.add("image/jpeg");
    allowedMimeTypes.add("image/gif");
    allowedMimeTypes.add("image/png");
  }
  
  
}