class SqlQuery {
  String get query => _query;
  String _query;
  Map<String, dynamic> parameters;

  SqlQuery(this._query, {this.parameters});
}

class SelectSqlQuery {
  List<String> fields;
}