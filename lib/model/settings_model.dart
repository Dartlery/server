part of model;

class SettingsModel {
  static int thumbnailMaxDimension = 200;
  
  static const String FILES_DIR = 'files'; 
  static const String THUMBS_DIR = 'thumbs';
  static const String STATIC_DIR = 'static';

  static const String API_URL = "http://127.0.0.1:8888/";
  
  static final List<String> allowedMimeTypes = new List<String>();
  
  static bool _staticInitialized = false; 
  
  SettingsModel() {
    if(!_staticInitialized) {
      allowedMimeTypes.add("image/jpeg");
      allowedMimeTypes.add("image/gif");
      allowedMimeTypes.add("image/png");
      _staticInitialized = true;
    }
  }
  
  
}