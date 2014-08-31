part of client;


class GalleryFile {
  int id;
  
  String source;
  String thumbnailSource;
  String mimeType;
  
  List<String> tags;
  
  DivElement _page_ele = new DivElement();
  
  GalleryFile(Map image_data) {
    
    this.id = image_data["id"];
    
    this.source = image_data["source"];
    this.thumbnailSource = image_data["thumbnail_source"];;
    
    
    if(image_data["tags"]==null) {
      this.tags = new List<String>();
    } else {
      this.tags = image_data["tags"];
    }
  }
  
  String getTagString() {
    StringBuffer output = new StringBuffer();
    
    for(String tag in this.tags) {
      output.write(tag);
      output.write(" ");
    }
    
    return output.toString().trimRight();
  }
  
  void imageClicked(MouseEvent event) {
     //gallery.Hide();
     //this._generatePage();
  }
  
  
  void _generatePage() {
    this._page_ele = new DivElement();
    this._page_ele.className = "file_page";
    this._page_ele.id = "file_page_" + this.id.toString();
    
    DivElement back_ele = new DivElement();
    this._page_ele.append(back_ele);
    back_ele.innerHtml = "Back";
    back_ele.className = "back";
    back_ele.onClick.listen(backClicked);
    
    ImageElement img_ele = new ImageElement();
    img_ele.src = this.source;
    this._page_ele.append(img_ele);
    
    // Set up the info display
    DivElement info_ele = new DivElement();
    info_ele.className = "info";
    this._page_ele.append(info_ele);
        
    DivElement tag_ele = new DivElement();
    tag_ele.innerHtml = this.getTagString();
    tag_ele.className = "tags";
    info_ele.append(tag_ele);
    
    InputElement edit_btn = new InputElement();
    edit_btn.type = "button";
    edit_btn.value = "Edit";
    edit_btn.onClick.listen(_editButtonClick);
    info_ele.append(edit_btn);

    // Set up the edit controls
    DivElement edit_ele = new DivElement();
    this._page_ele.append(edit_ele);
    edit_ele.className = "edit";
    edit_ele.style.display = "none";
    
    InputElement tag_input_ele = new InputElement();
    tag_input_ele.type = "text";
    tag_input_ele.value = this.getTagString();
    tag_input_ele.className = "tags";
    edit_ele.append(tag_input_ele);
    
    InputElement image_edit_save = new InputElement();
    image_edit_save.type = "button";
    image_edit_save.value = "Save";
    edit_ele.append(image_edit_save);
    image_edit_save.onClick.listen(_saveButtonClick);
    
    document.body.append(this._page_ele);
    
  }
  
  void _editButtonClick(MouseEvent event) {
    this._page_ele.querySelector(".info").style.display = "none";
    this._page_ele.querySelector(".edit").style.display = "block";
  }
  
  void _saveButtonClick(MouseEvent event) {
    this._page_ele.querySelector(".info").style.display = "block";
    this._page_ele.querySelector(".edit").style.display = "none";
  }
  
  void _closePage() {
    this._page_ele.remove();
    this._page_ele = null;
  }
  
  void backClicked(MouseEvent event) {
    //this._closePage();
    //gallery.Show();
  }
  
}