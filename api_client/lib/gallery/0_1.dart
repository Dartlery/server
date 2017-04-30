// This is a generated file (see the discoveryapis_generator project).

library api_client.gallery.D0_1;

import 'dart:core' as core;
import 'dart:collection' as collection;
import 'dart:async' as async;
import 'dart:convert' as convert;

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError;

const core.String USER_AGENT = 'dart-api-client gallery/0.1';

/** Item REST API */
class GalleryApi {

  final commons.ApiRequester _requester;

  ItemsResourceApi get items => new ItemsResourceApi(_requester);
  SetupResourceApi get setup => new SetupResourceApi(_requester);
  TagCategoriesResourceApi get tagCategories => new TagCategoriesResourceApi(_requester);
  TagsResourceApi get tags => new TagsResourceApi(_requester);
  UsersResourceApi get users => new UsersResourceApi(_requester);

  GalleryApi(http.Client client, {core.String rootUrl: "http://localhost:3278/", core.String servicePath: "api/gallery/0.1/"}) :
      _requester = new commons.ApiRequester(client, rootUrl, servicePath, USER_AGENT);
}


class ItemsResourceApi {
  final commons.ApiRequester _requester;

  ItemsResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [IdResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<IdResponse> createItem(CreateItemRequest request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'items/';

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new IdResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future delete(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _downloadOptions = null;

    _url = 'items/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => null);
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [Item].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Item> getById(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'items/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new Item.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * Completes with a [PaginatedResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedResponse> getVisibleIds({core.int page, core.int perPage}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (page != null) {
      _queryParams["page"] = ["${page}"];
    }
    if (perPage != null) {
      _queryParams["perPage"] = ["${perPage}"];
    }

    _url = 'items/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedResponse.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [PaginatedResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedResponse> searchVisible(ItemSearchRequest request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'search/';

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedResponse.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [IdResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<IdResponse> updateItem(UpdateItemRequest request, core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'items/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new IdResponse.fromJson(data));
  }

}


class SetupResourceApi {
  final commons.ApiRequester _requester;

  SetupResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [SetupResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<SetupResponse> apply(SetupRequest request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'setup/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new SetupResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * Completes with a [SetupResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<SetupResponse> get() {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;


    _url = 'setup/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new SetupResponse.fromJson(data));
  }

}


class TagCategoriesResourceApi {
  final commons.ApiRequester _requester;

  TagCategoriesResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [IdResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<IdResponse> create(TagCategory request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'tag_categories/';

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new IdResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future delete(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _downloadOptions = null;

    _url = 'tag_categories/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => null);
  }

  /**
   * Request parameters:
   *
   * Completes with a [ListOfString].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<ListOfString> getAllIds() {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;


    _url = 'tag_categories/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new ListOfString.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [TagCategory].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<TagCategory> getById(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'tag_categories/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new TagCategory.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [IdResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<IdResponse> update(TagCategory request, core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'tag_categories/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new IdResponse.fromJson(data));
  }

}


class TagsResourceApi {
  final commons.ApiRequester _requester;

  TagsResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * Request parameters:
   *
   * [query] - Path parameter: 'query'.
   *
   * Completes with a [ListOfTag].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<ListOfTag> search(core.String query) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (query == null) {
      throw new core.ArgumentError("Parameter query is required.");
    }

    _url = 'tags/search/' + commons.Escaper.ecapeVariable('$query');

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new ListOfTag.fromJson(data));
  }

}


class UsersResourceApi {
  final commons.ApiRequester _requester;

  UsersResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [uuid] - Path parameter: 'uuid'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future changePassword(PasswordChangeRequest request, core.String uuid) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (uuid == null) {
      throw new core.ArgumentError("Parameter uuid is required.");
    }

    _downloadOptions = null;

    _url = 'users/' + commons.Escaper.ecapeVariable('$uuid') + '/password/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => null);
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [IdResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<IdResponse> create(User request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'users/';

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new IdResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [uuid] - Path parameter: 'uuid'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future delete(core.String uuid) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (uuid == null) {
      throw new core.ArgumentError("Parameter uuid is required.");
    }

    _downloadOptions = null;

    _url = 'users/' + commons.Escaper.ecapeVariable('$uuid') + '/';

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => null);
  }

  /**
   * Request parameters:
   *
   * [uuid] - Path parameter: 'uuid'.
   *
   * Completes with a [User].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<User> getById(core.String uuid) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (uuid == null) {
      throw new core.ArgumentError("Parameter uuid is required.");
    }

    _url = 'users/' + commons.Escaper.ecapeVariable('$uuid') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new User.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * Completes with a [User].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<User> getMe() {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;


    _url = 'current_user/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new User.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [uuid] - Path parameter: 'uuid'.
   *
   * Completes with a [IdResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<IdResponse> update(User request, core.String uuid) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (uuid == null) {
      throw new core.ArgumentError("Parameter uuid is required.");
    }

    _url = 'users/' + commons.Escaper.ecapeVariable('$uuid') + '/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new IdResponse.fromJson(data));
  }

}



class CreateItemRequest {
  MediaMessage file;
  Item item;

  CreateItemRequest();

  CreateItemRequest.fromJson(core.Map _json) {
    if (_json.containsKey("file")) {
      file = new MediaMessage.fromJson(_json["file"]);
    }
    if (_json.containsKey("item")) {
      item = new Item.fromJson(_json["item"]);
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (file != null) {
      _json["file"] = (file).toJson();
    }
    if (item != null) {
      _json["item"] = (item).toJson();
    }
    return _json;
  }
}

class IdResponse {
  core.String id;
  core.String location;

  IdResponse();

  IdResponse.fromJson(core.Map _json) {
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
    if (_json.containsKey("location")) {
      location = _json["location"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (id != null) {
      _json["id"] = id;
    }
    if (location != null) {
      _json["location"] = location;
    }
    return _json;
  }
}

class Item {
  core.List<core.int> fileData;
  core.String id;
  core.Map<core.String, core.String> metadata;
  core.List<Tag> tags;

  Item();

  Item.fromJson(core.Map _json) {
    if (_json.containsKey("fileData")) {
      fileData = _json["fileData"];
    }
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
    if (_json.containsKey("metadata")) {
      metadata = _json["metadata"];
    }
    if (_json.containsKey("tags")) {
      tags = _json["tags"].map((value) => new Tag.fromJson(value)).toList();
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (fileData != null) {
      _json["fileData"] = fileData;
    }
    if (id != null) {
      _json["id"] = id;
    }
    if (metadata != null) {
      _json["metadata"] = metadata;
    }
    if (tags != null) {
      _json["tags"] = tags.map((value) => (value).toJson()).toList();
    }
    return _json;
  }
}

class ItemSearchRequest {
  core.int page;
  core.int perPage;
  core.List<Tag> tags;

  ItemSearchRequest();

  ItemSearchRequest.fromJson(core.Map _json) {
    if (_json.containsKey("page")) {
      page = _json["page"];
    }
    if (_json.containsKey("perPage")) {
      perPage = _json["perPage"];
    }
    if (_json.containsKey("tags")) {
      tags = _json["tags"].map((value) => new Tag.fromJson(value)).toList();
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (page != null) {
      _json["page"] = page;
    }
    if (perPage != null) {
      _json["perPage"] = perPage;
    }
    if (tags != null) {
      _json["tags"] = tags.map((value) => (value).toJson()).toList();
    }
    return _json;
  }
}

class ListOfString
    extends collection.ListBase<core.String> {
  final core.List<core.String> _inner;

  ListOfString() : _inner = [];

  ListOfString.fromJson(core.List json)
      : _inner = json.map((value) => value).toList();

  core.List toJson() {
    return _inner.map((value) => value).toList();
  }

  core.String operator [](core.int key) => _inner[key];

  void operator []=(core.int key, core.String value) {
    _inner[key] = value;
  }

  core.int get length => _inner.length;

  void set length(core.int newLength) {
    _inner.length = newLength;
  }
}

class ListOfTag
    extends collection.ListBase<Tag> {
  final core.List<Tag> _inner;

  ListOfTag() : _inner = [];

  ListOfTag.fromJson(core.List json)
      : _inner = json.map((value) => new Tag.fromJson(value)).toList();

  core.List toJson() {
    return _inner.map((value) => (value).toJson()).toList();
  }

  Tag operator [](core.int key) => _inner[key];

  void operator []=(core.int key, Tag value) {
    _inner[key] = value;
  }

  core.int get length => _inner.length;

  void set length(core.int newLength) {
    _inner.length = newLength;
  }
}

class MediaMessage {
  core.List<core.int> bytes;
  core.String cacheControl;
  core.String contentEncoding;
  core.String contentLanguage;
  core.String contentType;
  core.String md5Hash;
  core.Map<core.String, core.String> metadata;
  core.DateTime updated;

  MediaMessage();

  MediaMessage.fromJson(core.Map _json) {
    if (_json.containsKey("bytes")) {
      bytes = _json["bytes"];
    }
    if (_json.containsKey("cacheControl")) {
      cacheControl = _json["cacheControl"];
    }
    if (_json.containsKey("contentEncoding")) {
      contentEncoding = _json["contentEncoding"];
    }
    if (_json.containsKey("contentLanguage")) {
      contentLanguage = _json["contentLanguage"];
    }
    if (_json.containsKey("contentType")) {
      contentType = _json["contentType"];
    }
    if (_json.containsKey("md5Hash")) {
      md5Hash = _json["md5Hash"];
    }
    if (_json.containsKey("metadata")) {
      metadata = _json["metadata"];
    }
    if (_json.containsKey("updated")) {
      updated = core.DateTime.parse(_json["updated"]);
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (bytes != null) {
      _json["bytes"] = bytes;
    }
    if (cacheControl != null) {
      _json["cacheControl"] = cacheControl;
    }
    if (contentEncoding != null) {
      _json["contentEncoding"] = contentEncoding;
    }
    if (contentLanguage != null) {
      _json["contentLanguage"] = contentLanguage;
    }
    if (contentType != null) {
      _json["contentType"] = contentType;
    }
    if (md5Hash != null) {
      _json["md5Hash"] = md5Hash;
    }
    if (metadata != null) {
      _json["metadata"] = metadata;
    }
    if (updated != null) {
      _json["updated"] = (updated).toIso8601String();
    }
    return _json;
  }
}

class PaginatedResponse {
  core.List<core.String> items;
  core.int page;
  core.int pageCount;
  core.int startIndex;
  core.int totalCount;
  core.int totalPages;

  PaginatedResponse();

  PaginatedResponse.fromJson(core.Map _json) {
    if (_json.containsKey("items")) {
      items = _json["items"];
    }
    if (_json.containsKey("page")) {
      page = _json["page"];
    }
    if (_json.containsKey("pageCount")) {
      pageCount = _json["pageCount"];
    }
    if (_json.containsKey("startIndex")) {
      startIndex = _json["startIndex"];
    }
    if (_json.containsKey("totalCount")) {
      totalCount = _json["totalCount"];
    }
    if (_json.containsKey("totalPages")) {
      totalPages = _json["totalPages"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (items != null) {
      _json["items"] = items;
    }
    if (page != null) {
      _json["page"] = page;
    }
    if (pageCount != null) {
      _json["pageCount"] = pageCount;
    }
    if (startIndex != null) {
      _json["startIndex"] = startIndex;
    }
    if (totalCount != null) {
      _json["totalCount"] = totalCount;
    }
    if (totalPages != null) {
      _json["totalPages"] = totalPages;
    }
    return _json;
  }
}

class PasswordChangeRequest {
  core.String currentPassword;
  core.String newPassword;

  PasswordChangeRequest();

  PasswordChangeRequest.fromJson(core.Map _json) {
    if (_json.containsKey("currentPassword")) {
      currentPassword = _json["currentPassword"];
    }
    if (_json.containsKey("newPassword")) {
      newPassword = _json["newPassword"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (currentPassword != null) {
      _json["currentPassword"] = currentPassword;
    }
    if (newPassword != null) {
      _json["newPassword"] = newPassword;
    }
    return _json;
  }
}

class SetupRequest {
  core.String adminPassword;
  core.String adminUser;

  SetupRequest();

  SetupRequest.fromJson(core.Map _json) {
    if (_json.containsKey("adminPassword")) {
      adminPassword = _json["adminPassword"];
    }
    if (_json.containsKey("adminUser")) {
      adminUser = _json["adminUser"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (adminPassword != null) {
      _json["adminPassword"] = adminPassword;
    }
    if (adminUser != null) {
      _json["adminUser"] = adminUser;
    }
    return _json;
  }
}

class SetupResponse {
  core.bool adminUser;

  SetupResponse();

  SetupResponse.fromJson(core.Map _json) {
    if (_json.containsKey("adminUser")) {
      adminUser = _json["adminUser"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (adminUser != null) {
      _json["adminUser"] = adminUser;
    }
    return _json;
  }
}

class Tag {
  core.String category;
  core.String id;

  Tag();

  Tag.fromJson(core.Map _json) {
    if (_json.containsKey("category")) {
      category = _json["category"];
    }
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (category != null) {
      _json["category"] = category;
    }
    if (id != null) {
      _json["id"] = id;
    }
    return _json;
  }
}

class TagCategory {
  core.String color;
  core.String id;

  TagCategory();

  TagCategory.fromJson(core.Map _json) {
    if (_json.containsKey("color")) {
      color = _json["color"];
    }
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (color != null) {
      _json["color"] = color;
    }
    if (id != null) {
      _json["id"] = id;
    }
    return _json;
  }
}

class UpdateItemRequest {
  core.List<MediaMessage> files;
  Item item;

  UpdateItemRequest();

  UpdateItemRequest.fromJson(core.Map _json) {
    if (_json.containsKey("files")) {
      files = _json["files"].map((value) => new MediaMessage.fromJson(value)).toList();
    }
    if (_json.containsKey("item")) {
      item = new Item.fromJson(_json["item"]);
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (files != null) {
      _json["files"] = files.map((value) => (value).toJson()).toList();
    }
    if (item != null) {
      _json["item"] = (item).toJson();
    }
    return _json;
  }
}

class User {
  core.String id;
  core.String name;
  core.String password;
  core.String type;

  User();

  User.fromJson(core.Map _json) {
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
    if (_json.containsKey("name")) {
      name = _json["name"];
    }
    if (_json.containsKey("password")) {
      password = _json["password"];
    }
    if (_json.containsKey("type")) {
      type = _json["type"];
    }
  }

  core.Map toJson() {
    var _json = new core.Map();
    if (id != null) {
      _json["id"] = id;
    }
    if (name != null) {
      _json["name"] = name;
    }
    if (password != null) {
      _json["password"] = password;
    }
    if (type != null) {
      _json["type"] = type;
    }
    return _json;
  }
}
