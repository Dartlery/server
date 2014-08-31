part of client;

class Upload extends Observable {
  final File _file;
  
  @observable String fileName;
  @observable int progress = 0;
  
  String filePath;
  
  Upload(this._file) {
    this.fileName = _file.name;
    this.filePath = this._file.toString();
  }
 
  List<int> _fileData = null;
  
  Future startUpload() {
    Completer comp = new Completer();
    new Future.sync(() {
      if(_fileData==null) {
        return this._getFileData().then((data) {
          this._fileData = data;
        });
      }
    }).then((_) {
      List<Map> output = new List<Map>();
      Map<String,dynamic> file = new Map<String,dynamic>();
      
      String b64 = crypto.CryptoUtils.bytesToBase64(_fileData);
      String ct  = null;
      if(_fileData.length>= mime.defaultMagicNumbersMaxLength) {
        ct = mime.lookupMimeType(file.toString(), 
            headerBytes: _fileData.sublist(0,mime.defaultMagicNumbersMaxLength));
      } else {
        ct = mime.lookupMimeType(file.toString());
      }
      if(ct==null) {
        ct = "text/plain";
      }
      
      file["tags"] = ["tagme"];
      file["data"] = b64;
      file["content_type"] = ct;
      
      output.add(file);

      HttpRequest request = new HttpRequest();

      request.onProgress.listen((ProgressEvent e) {
        Debug.addLine(e.loaded.toString());
      });
      
      request.onReadyStateChange.listen((e) {
        if(request.readyState == HttpRequest.DONE) {
          this.progress = 100;
          comp.complete(this);
          Debug.addLine(request.response.toString());
        }
      });
      
      request.open("POST", SERVER_ADDRESS + "files/", async:false);
      request.setRequestHeader("Content-Type",'application/json');
      request.send(JSON.encode(output));
    });
    return comp.future;
  }
  
  Future<List<int>> _getFileData() {
    Completer comp = new Completer();
    FileReader reader = new FileReader();
    reader.onLoad.listen((e) {
      Uint8List data = reader.result;
      comp.complete(data.toList());
    });
    reader.readAsArrayBuffer(_file);
    
    return comp.future;
  }
  
}
