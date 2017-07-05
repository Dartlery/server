// This is a generated file (see the discoveryapis_generator project).

library api_client.gallery.v0_1;

import 'dart:core' as core;
import 'dart:collection' as collection;
import 'dart:async' as async;
import 'dart:convert' as convert;

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError;

const core.String USER_AGENT = 'dart-api-client gallery/v0.1';

/** Item REST API */
class GalleryApi {

  final commons.ApiRequester _requester;

  ExtensionDataResourceApi get extensionData => new ExtensionDataResourceApi(_requester);
  ImportResourceApi get import => new ImportResourceApi(_requester);
  ItemsResourceApi get items => new ItemsResourceApi(_requester);
  SetupResourceApi get setup => new SetupResourceApi(_requester);
  TagCategoriesResourceApi get tagCategories => new TagCategoriesResourceApi(_requester);
  TagsResourceApi get tags => new TagsResourceApi(_requester);
  UsersResourceApi get users => new UsersResourceApi(_requester);

  GalleryApi(http.Client client, {core.String rootUrl: "http://localhost:3278/", core.String servicePath: "api/gallery/v0.1/"}) :
      _requester = new commons.ApiRequester(client, rootUrl, servicePath, USER_AGENT);
}


class ExtensionDataResourceApi {
  final commons.ApiRequester _requester;

  ExtensionDataResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * Request parameters:
   *
   * [extensionId] - Path parameter: 'extensionId'.
   *
   * [key] - Path parameter: 'key'.
   *
   * [primaryId] - Path parameter: 'primaryId'.
   *
   * [secondaryId] - Path parameter: 'secondaryId'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future delete(core.String extensionId, core.String key, core.String primaryId, core.String secondaryId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (extensionId == null) {
      throw new core.ArgumentError("Parameter extensionId is required.");
    }
    if (key == null) {
      throw new core.ArgumentError("Parameter key is required.");
    }
    if (primaryId == null) {
      throw new core.ArgumentError("Parameter primaryId is required.");
    }
    if (secondaryId == null) {
      throw new core.ArgumentError("Parameter secondaryId is required.");
    }

    _downloadOptions = null;

    _url = 'extension_data/' + commons.Escaper.ecapeVariable('$extensionId') + '/' + commons.Escaper.ecapeVariable('$key') + '/' + commons.Escaper.ecapeVariable('$primaryId') + '/' + commons.Escaper.ecapeVariable('$secondaryId') + '/';

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
   * [extensionId] - Path parameter: 'extensionId'.
   *
   * [key] - Path parameter: 'key'.
   *
   * [orderByValues] - Query parameter: 'orderByValues'.
   *
   * [orderDescending] - Query parameter: 'orderDescending'.
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * Completes with a [PaginatedExtensionDataResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedExtensionDataResponse> get(core.String extensionId, core.String key, {core.bool orderByValues, core.bool orderDescending, core.int page, core.int perPage}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (extensionId == null) {
      throw new core.ArgumentError("Parameter extensionId is required.");
    }
    if (key == null) {
      throw new core.ArgumentError("Parameter key is required.");
    }
    if (orderByValues != null) {
      _queryParams["orderByValues"] = ["${orderByValues}"];
    }
    if (orderDescending != null) {
      _queryParams["orderDescending"] = ["${orderDescending}"];
    }
    if (page != null) {
      _queryParams["page"] = ["${page}"];
    }
    if (perPage != null) {
      _queryParams["perPage"] = ["${perPage}"];
    }

    _url = 'extension_data/' + commons.Escaper.ecapeVariable('$extensionId') + '/' + commons.Escaper.ecapeVariable('$key') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedExtensionDataResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [extensionId] - Path parameter: 'extensionId'.
   *
   * [key] - Path parameter: 'key'.
   *
   * [primaryId] - Path parameter: 'primaryId'.
   *
   * [secondaryId] - Path parameter: 'secondaryId'.
   *
   * Completes with a [PaginatedExtensionDataResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedExtensionDataResponse> getByPrimaryAndSecondaryId(core.String extensionId, core.String key, core.String primaryId, core.String secondaryId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (extensionId == null) {
      throw new core.ArgumentError("Parameter extensionId is required.");
    }
    if (key == null) {
      throw new core.ArgumentError("Parameter key is required.");
    }
    if (primaryId == null) {
      throw new core.ArgumentError("Parameter primaryId is required.");
    }
    if (secondaryId == null) {
      throw new core.ArgumentError("Parameter secondaryId is required.");
    }

    _url = 'extension_data/' + commons.Escaper.ecapeVariable('$extensionId') + '/' + commons.Escaper.ecapeVariable('$key') + '/' + commons.Escaper.ecapeVariable('$primaryId') + '/' + commons.Escaper.ecapeVariable('$secondaryId') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedExtensionDataResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [extensionId] - Path parameter: 'extensionId'.
   *
   * [key] - Path parameter: 'key'.
   *
   * [primaryId] - Path parameter: 'primaryId'.
   *
   * [bidirectional] - Query parameter: 'bidirectional'.
   *
   * [orderByValues] - Query parameter: 'orderByValues'.
   *
   * [orderDescending] - Query parameter: 'orderDescending'.
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * Completes with a [PaginatedExtensionDataResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedExtensionDataResponse> getByPrimaryId(core.String extensionId, core.String key, core.String primaryId, {core.bool bidirectional, core.bool orderByValues, core.bool orderDescending, core.int page, core.int perPage}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (extensionId == null) {
      throw new core.ArgumentError("Parameter extensionId is required.");
    }
    if (key == null) {
      throw new core.ArgumentError("Parameter key is required.");
    }
    if (primaryId == null) {
      throw new core.ArgumentError("Parameter primaryId is required.");
    }
    if (bidirectional != null) {
      _queryParams["bidirectional"] = ["${bidirectional}"];
    }
    if (orderByValues != null) {
      _queryParams["orderByValues"] = ["${orderByValues}"];
    }
    if (orderDescending != null) {
      _queryParams["orderDescending"] = ["${orderDescending}"];
    }
    if (page != null) {
      _queryParams["page"] = ["${page}"];
    }
    if (perPage != null) {
      _queryParams["perPage"] = ["${perPage}"];
    }

    _url = 'extension_data/' + commons.Escaper.ecapeVariable('$extensionId') + '/' + commons.Escaper.ecapeVariable('$key') + '/' + commons.Escaper.ecapeVariable('$primaryId') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedExtensionDataResponse.fromJson(data));
  }

}


class ImportResourceApi {
  final commons.ApiRequester _requester;

  ImportResourceApi(commons.ApiRequester client) : 
      _requester = client;

  /**
   * Request parameters:
   *
   * [everything] - Query parameter: 'everything'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future clearResults({core.bool everything}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (everything != null) {
      _queryParams["everything"] = ["${everything}"];
    }

    _downloadOptions = null;

    _url = 'import/results/';

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
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * Completes with a [PaginatedImportResultsResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedImportResultsResponse> getResults({core.int page, core.int perPage}) {
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

    _url = 'import/results/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedImportResultsResponse.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [StringResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<StringResponse> importFromPath(ImportPathRequest request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'import/results/';

    var _response = _requester.request(_url,
                                       "POST",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new StringResponse.fromJson(data));
  }

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
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [ListOfTag].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<ListOfTag> getTagsByItemId(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'items/' + commons.Escaper.ecapeVariable('$id') + '/tags/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new ListOfTag.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * [cutoffDate] - Query parameter: 'cutoffDate'.
   *
   * [inTrash] - Query parameter: 'inTrash'.
   *
   * Completes with a [PaginatedItemResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedItemResponse> getVisibleIds({core.int page, core.int perPage, core.String cutoffDate, core.bool inTrash}) {
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
    if (cutoffDate != null) {
      _queryParams["cutoffDate"] = [cutoffDate];
    }
    if (inTrash != null) {
      _queryParams["inTrash"] = ["${inTrash}"];
    }

    _url = 'items/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedItemResponse.fromJson(data));
  }

  /**
   * Merges the data from [sourceItemId] into the item specified by [id], and
   * then deletes the item associated with [sourceItemId]
   *
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * [targetItemId] - Path parameter: 'targetItemId'.
   *
   * Completes with a [Item].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<Item> mergeItems(IdRequest request, core.String targetItemId) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }
    if (targetItemId == null) {
      throw new core.ArgumentError("Parameter targetItemId is required.");
    }

    _url = 'items/' + commons.Escaper.ecapeVariable('$targetItemId') + '/merge/';

    var _response = _requester.request(_url,
                                       "PUT",
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
   * [tags] - Path parameter: 'tags'.
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * [cutoffDate] - Query parameter: 'cutoffDate'.
   *
   * [inTrash] - Query parameter: 'inTrash'.
   *
   * Completes with a [PaginatedItemResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedItemResponse> searchVisible(core.String tags, {core.int page, core.int perPage, core.String cutoffDate, core.bool inTrash}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (tags == null) {
      throw new core.ArgumentError("Parameter tags is required.");
    }
    if (page != null) {
      _queryParams["page"] = ["${page}"];
    }
    if (perPage != null) {
      _queryParams["perPage"] = ["${perPage}"];
    }
    if (cutoffDate != null) {
      _queryParams["cutoffDate"] = [cutoffDate];
    }
    if (inTrash != null) {
      _queryParams["inTrash"] = ["${inTrash}"];
    }

    _url = 'search/items/' + commons.Escaper.ecapeVariable('$tags') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedItemResponse.fromJson(data));
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
  async.Future<IdResponse> update(Item request, core.String id) {
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

  /**
   * [request] - The metadata request object.
   *
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
  async.Future updateTagsForItemId(ListOfTag request, core.String id) {
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

    _downloadOptions = null;

    _url = 'items/' + commons.Escaper.ecapeVariable('$id') + '/tags/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => null);
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
   * [id] - Path parameter: 'id'.
   *
   * [category] - Path parameter: 'category'.
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future clearRedirect(core.String id, core.String category) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }
    if (category == null) {
      throw new core.ArgumentError("Parameter category is required.");
    }

    _downloadOptions = null;

    _url = 'tag_redirects/' + commons.Escaper.ecapeVariable('$id') + '/' + commons.Escaper.ecapeVariable('$category') + '/';

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
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future clearRedirectWithoutCategory(core.String id) {
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

    _url = 'tag_redirects/' + commons.Escaper.ecapeVariable('$id') + '/';

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
   * [category] - Path parameter: 'category'.
   *
   * Completes with a [CountResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<CountResponse> delete(core.String id, core.String category) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }
    if (category == null) {
      throw new core.ArgumentError("Parameter category is required.");
    }

    _url = 'tag/' + commons.Escaper.ecapeVariable('$id') + '/' + commons.Escaper.ecapeVariable('$category') + '/';

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new CountResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [CountResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<CountResponse> deleteWithoutCategory(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'tag/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "DELETE",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new CountResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * [countAsc] - Query parameter: 'countAsc'.
   *
   * Completes with a [PaginatedTagResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedTagResponse> getAllTagInfo({core.int page, core.int perPage, core.bool countAsc}) {
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
    if (countAsc != null) {
      _queryParams["countAsc"] = ["${countAsc}"];
    }

    _url = 'tags/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedTagResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * Completes with a [ListOfTagInfo].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<ListOfTagInfo> getRedirects() {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;


    _url = 'tag_redirects/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new ListOfTagInfo.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * [category] - Path parameter: 'category'.
   *
   * Completes with a [TagInfo].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<TagInfo> getTagInfo(core.String id, core.String category) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }
    if (category == null) {
      throw new core.ArgumentError("Parameter category is required.");
    }

    _url = 'tags/' + commons.Escaper.ecapeVariable('$id') + '/' + commons.Escaper.ecapeVariable('$category') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new TagInfo.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * [id] - Path parameter: 'id'.
   *
   * Completes with a [TagInfo].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<TagInfo> getTagInfoWithoutCategory(core.String id) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (id == null) {
      throw new core.ArgumentError("Parameter id is required.");
    }

    _url = 'tags/' + commons.Escaper.ecapeVariable('$id') + '/';

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new TagInfo.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [CountResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<CountResponse> replace(ReplaceTagsRequest request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _url = 'tags/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new CountResponse.fromJson(data));
  }

  /**
   * Request parameters:
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future resetTagInfo() {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;


    _downloadOptions = null;

    _url = 'tag_info/';

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
   * [query] - Path parameter: 'query'.
   *
   * [page] - Query parameter: 'page'.
   *
   * [perPage] - Query parameter: 'perPage'.
   *
   * [countAsc] - Query parameter: 'countAsc'.
   *
   * Completes with a [PaginatedTagResponse].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<PaginatedTagResponse> search(core.String query, {core.int page, core.int perPage, core.bool countAsc}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (query == null) {
      throw new core.ArgumentError("Parameter query is required.");
    }
    if (page != null) {
      _queryParams["page"] = ["${page}"];
    }
    if (perPage != null) {
      _queryParams["perPage"] = ["${perPage}"];
    }
    if (countAsc != null) {
      _queryParams["countAsc"] = ["${countAsc}"];
    }

    _url = 'search/tags/' + commons.Escaper.ecapeVariable('$query');

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => new PaginatedTagResponse.fromJson(data));
  }

  /**
   * [request] - The metadata request object.
   *
   * Request parameters:
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future setRedirect(TagInfo request) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.JSON.encode((request).toJson());
    }

    _downloadOptions = null;

    _url = 'tag_redirects/';

    var _response = _requester.request(_url,
                                       "PUT",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => null);
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



class CountResponse {
  core.int count;

  CountResponse();

  CountResponse.fromJson(core.Map _json) {
    if (_json.containsKey("count")) {
      count = _json["count"];
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (count != null) {
      _json["count"] = count;
    }
    return _json;
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (file != null) {
      _json["file"] = (file).toJson();
    }
    if (item != null) {
      _json["item"] = (item).toJson();
    }
    return _json;
  }
}

class ExtensionData {
  core.String primaryId;
  core.String secondaryId;
  core.String value;

  ExtensionData();

  ExtensionData.fromJson(core.Map _json) {
    if (_json.containsKey("primaryId")) {
      primaryId = _json["primaryId"];
    }
    if (_json.containsKey("secondaryId")) {
      secondaryId = _json["secondaryId"];
    }
    if (_json.containsKey("value")) {
      value = _json["value"];
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (primaryId != null) {
      _json["primaryId"] = primaryId;
    }
    if (secondaryId != null) {
      _json["secondaryId"] = secondaryId;
    }
    if (value != null) {
      _json["value"] = value;
    }
    return _json;
  }
}

class IdRequest {
  core.String id;

  IdRequest();

  IdRequest.fromJson(core.Map _json) {
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (id != null) {
      _json["id"] = id;
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (id != null) {
      _json["id"] = id;
    }
    if (location != null) {
      _json["location"] = location;
    }
    return _json;
  }
}

class ImportPathRequest {
  core.bool interpretShimmieNames;
  core.bool mergeExisting;
  core.String path;
  core.bool stopOnError;

  ImportPathRequest();

  ImportPathRequest.fromJson(core.Map _json) {
    if (_json.containsKey("interpretShimmieNames")) {
      interpretShimmieNames = _json["interpretShimmieNames"];
    }
    if (_json.containsKey("mergeExisting")) {
      mergeExisting = _json["mergeExisting"];
    }
    if (_json.containsKey("path")) {
      path = _json["path"];
    }
    if (_json.containsKey("stopOnError")) {
      stopOnError = _json["stopOnError"];
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (interpretShimmieNames != null) {
      _json["interpretShimmieNames"] = interpretShimmieNames;
    }
    if (mergeExisting != null) {
      _json["mergeExisting"] = mergeExisting;
    }
    if (path != null) {
      _json["path"] = path;
    }
    if (stopOnError != null) {
      _json["stopOnError"] = stopOnError;
    }
    return _json;
  }
}

class ImportResult {
  core.DateTime batchTimestamp;
  core.String error;
  core.String fileName;
  core.String id;
  core.String result;
  core.String source;
  core.bool thumbnailCreated;
  core.DateTime timestamp;

  ImportResult();

  ImportResult.fromJson(core.Map _json) {
    if (_json.containsKey("batchTimestamp")) {
      batchTimestamp = core.DateTime.parse(_json["batchTimestamp"]);
    }
    if (_json.containsKey("error")) {
      error = _json["error"];
    }
    if (_json.containsKey("fileName")) {
      fileName = _json["fileName"];
    }
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
    if (_json.containsKey("result")) {
      result = _json["result"];
    }
    if (_json.containsKey("source")) {
      source = _json["source"];
    }
    if (_json.containsKey("thumbnailCreated")) {
      thumbnailCreated = _json["thumbnailCreated"];
    }
    if (_json.containsKey("timestamp")) {
      timestamp = core.DateTime.parse(_json["timestamp"]);
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (batchTimestamp != null) {
      _json["batchTimestamp"] = (batchTimestamp).toIso8601String();
    }
    if (error != null) {
      _json["error"] = error;
    }
    if (fileName != null) {
      _json["fileName"] = fileName;
    }
    if (id != null) {
      _json["id"] = id;
    }
    if (result != null) {
      _json["result"] = result;
    }
    if (source != null) {
      _json["source"] = source;
    }
    if (thumbnailCreated != null) {
      _json["thumbnailCreated"] = thumbnailCreated;
    }
    if (timestamp != null) {
      _json["timestamp"] = (timestamp).toIso8601String();
    }
    return _json;
  }
}

class Item {
  core.bool audio;
  core.String downloadName;
  core.int duration;
  core.List<core.String> errors;
  core.String extension;
  core.List<core.int> fileData;
  core.String fileName;
  core.bool fullFileAvailable;
  core.int height;
  core.String id;
  core.int length;
  core.Map<core.String, core.String> metadata;
  core.String mime;
  core.String source;
  core.List<Tag> tags;
  core.DateTime uploaded;
  core.String uploader;
  core.bool video;
  core.int width;

  Item();

  Item.fromJson(core.Map _json) {
    if (_json.containsKey("audio")) {
      audio = _json["audio"];
    }
    if (_json.containsKey("downloadName")) {
      downloadName = _json["downloadName"];
    }
    if (_json.containsKey("duration")) {
      duration = _json["duration"];
    }
    if (_json.containsKey("errors")) {
      errors = _json["errors"];
    }
    if (_json.containsKey("extension")) {
      extension = _json["extension"];
    }
    if (_json.containsKey("fileData")) {
      fileData = _json["fileData"];
    }
    if (_json.containsKey("fileName")) {
      fileName = _json["fileName"];
    }
    if (_json.containsKey("fullFileAvailable")) {
      fullFileAvailable = _json["fullFileAvailable"];
    }
    if (_json.containsKey("height")) {
      height = _json["height"];
    }
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
    if (_json.containsKey("length")) {
      length = _json["length"];
    }
    if (_json.containsKey("metadata")) {
      metadata = _json["metadata"];
    }
    if (_json.containsKey("mime")) {
      mime = _json["mime"];
    }
    if (_json.containsKey("source")) {
      source = _json["source"];
    }
    if (_json.containsKey("tags")) {
      tags = _json["tags"].map((value) => new Tag.fromJson(value)).toList();
    }
    if (_json.containsKey("uploaded")) {
      uploaded = core.DateTime.parse(_json["uploaded"]);
    }
    if (_json.containsKey("uploader")) {
      uploader = _json["uploader"];
    }
    if (_json.containsKey("video")) {
      video = _json["video"];
    }
    if (_json.containsKey("width")) {
      width = _json["width"];
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (audio != null) {
      _json["audio"] = audio;
    }
    if (downloadName != null) {
      _json["downloadName"] = downloadName;
    }
    if (duration != null) {
      _json["duration"] = duration;
    }
    if (errors != null) {
      _json["errors"] = errors;
    }
    if (extension != null) {
      _json["extension"] = extension;
    }
    if (fileData != null) {
      _json["fileData"] = fileData;
    }
    if (fileName != null) {
      _json["fileName"] = fileName;
    }
    if (fullFileAvailable != null) {
      _json["fullFileAvailable"] = fullFileAvailable;
    }
    if (height != null) {
      _json["height"] = height;
    }
    if (id != null) {
      _json["id"] = id;
    }
    if (length != null) {
      _json["length"] = length;
    }
    if (metadata != null) {
      _json["metadata"] = metadata;
    }
    if (mime != null) {
      _json["mime"] = mime;
    }
    if (source != null) {
      _json["source"] = source;
    }
    if (tags != null) {
      _json["tags"] = tags.map((value) => (value).toJson()).toList();
    }
    if (uploaded != null) {
      _json["uploaded"] = (uploaded).toIso8601String();
    }
    if (uploader != null) {
      _json["uploader"] = uploader;
    }
    if (video != null) {
      _json["video"] = video;
    }
    if (width != null) {
      _json["width"] = width;
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

  core.List<core.String> toJson() {
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

  core.List<core.Map<core.String, core.Object>> toJson() {
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

class ListOfTagInfo
    extends collection.ListBase<TagInfo> {
  final core.List<TagInfo> _inner;

  ListOfTagInfo() : _inner = [];

  ListOfTagInfo.fromJson(core.List json)
      : _inner = json.map((value) => new TagInfo.fromJson(value)).toList();

  core.List<core.Map<core.String, core.Object>> toJson() {
    return _inner.map((value) => (value).toJson()).toList();
  }

  TagInfo operator [](core.int key) => _inner[key];

  void operator []=(core.int key, TagInfo value) {
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
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

class PaginatedExtensionDataResponse {
  core.List<ExtensionData> items;
  core.int page;
  core.int pageCount;
  core.int startIndex;
  core.int totalCount;
  core.int totalPages;

  PaginatedExtensionDataResponse();

  PaginatedExtensionDataResponse.fromJson(core.Map _json) {
    if (_json.containsKey("items")) {
      items = _json["items"].map((value) => new ExtensionData.fromJson(value)).toList();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (items != null) {
      _json["items"] = items.map((value) => (value).toJson()).toList();
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

class PaginatedImportResultsResponse {
  core.List<ImportResult> items;
  core.int page;
  core.int pageCount;
  core.int startIndex;
  core.int totalCount;
  core.int totalPages;

  PaginatedImportResultsResponse();

  PaginatedImportResultsResponse.fromJson(core.Map _json) {
    if (_json.containsKey("items")) {
      items = _json["items"].map((value) => new ImportResult.fromJson(value)).toList();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (items != null) {
      _json["items"] = items.map((value) => (value).toJson()).toList();
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

class PaginatedItemResponse {
  core.List<core.String> items;
  core.int page;
  core.int pageCount;
  core.List<Tag> queryTags;
  core.int startIndex;
  core.int totalCount;
  core.int totalPages;

  PaginatedItemResponse();

  PaginatedItemResponse.fromJson(core.Map _json) {
    if (_json.containsKey("items")) {
      items = _json["items"];
    }
    if (_json.containsKey("page")) {
      page = _json["page"];
    }
    if (_json.containsKey("pageCount")) {
      pageCount = _json["pageCount"];
    }
    if (_json.containsKey("queryTags")) {
      queryTags = _json["queryTags"].map((value) => new Tag.fromJson(value)).toList();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (items != null) {
      _json["items"] = items;
    }
    if (page != null) {
      _json["page"] = page;
    }
    if (pageCount != null) {
      _json["pageCount"] = pageCount;
    }
    if (queryTags != null) {
      _json["queryTags"] = queryTags.map((value) => (value).toJson()).toList();
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

class PaginatedTagResponse {
  core.List<TagInfo> items;
  core.int page;
  core.int pageCount;
  core.int startIndex;
  core.int totalCount;
  core.int totalPages;

  PaginatedTagResponse();

  PaginatedTagResponse.fromJson(core.Map _json) {
    if (_json.containsKey("items")) {
      items = _json["items"].map((value) => new TagInfo.fromJson(value)).toList();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (items != null) {
      _json["items"] = items.map((value) => (value).toJson()).toList();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (currentPassword != null) {
      _json["currentPassword"] = currentPassword;
    }
    if (newPassword != null) {
      _json["newPassword"] = newPassword;
    }
    return _json;
  }
}

class ReplaceTagsRequest {
  core.List<Tag> newTags;
  core.List<Tag> originalTags;

  ReplaceTagsRequest();

  ReplaceTagsRequest.fromJson(core.Map _json) {
    if (_json.containsKey("newTags")) {
      newTags = _json["newTags"].map((value) => new Tag.fromJson(value)).toList();
    }
    if (_json.containsKey("originalTags")) {
      originalTags = _json["originalTags"].map((value) => new Tag.fromJson(value)).toList();
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (newTags != null) {
      _json["newTags"] = newTags.map((value) => (value).toJson()).toList();
    }
    if (originalTags != null) {
      _json["originalTags"] = originalTags.map((value) => (value).toJson()).toList();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (adminUser != null) {
      _json["adminUser"] = adminUser;
    }
    return _json;
  }
}

class StringResponse {
  core.String data;

  StringResponse();

  StringResponse.fromJson(core.Map _json) {
    if (_json.containsKey("data")) {
      data = _json["data"];
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (data != null) {
      _json["data"] = data;
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (color != null) {
      _json["color"] = color;
    }
    if (id != null) {
      _json["id"] = id;
    }
    return _json;
  }
}

class TagInfo {
  core.String category;
  core.int count;
  core.String id;
  Tag redirect;

  TagInfo();

  TagInfo.fromJson(core.Map _json) {
    if (_json.containsKey("category")) {
      category = _json["category"];
    }
    if (_json.containsKey("count")) {
      count = _json["count"];
    }
    if (_json.containsKey("id")) {
      id = _json["id"];
    }
    if (_json.containsKey("redirect")) {
      redirect = new Tag.fromJson(_json["redirect"]);
    }
  }

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
    if (category != null) {
      _json["category"] = category;
    }
    if (count != null) {
      _json["count"] = count;
    }
    if (id != null) {
      _json["id"] = id;
    }
    if (redirect != null) {
      _json["redirect"] = (redirect).toJson();
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

  core.Map<core.String, core.Object> toJson() {
    final core.Map<core.String, core.Object> _json = new core.Map<core.String, core.Object>();
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
