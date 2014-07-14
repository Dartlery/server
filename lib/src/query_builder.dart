part of dartlery;

class QueryBuilder {
  static final Logger _log = new Logger('QueryBuilder');

  static const String _GET_COUNT_WRAPPER_START = "SELECT COUNT(*) FROM (";
  static const String _GET_COUNT_WRAPPER_END = ") qwzbk";

  static const String ASCENDING = "ASC";
  static const String DESCENDING = "DESC";
  
  static const String AND = "AND";
  //static const String OR = "OR";
  
  static const String SELECT = "SELECT";
  static const String INSERT = "INSERT";
  static const String UPDATE = "UPDATE";
  static const String DELETE = "DELETE";
  
  final List _fields = new List();
  final List _joins = new List();
  final List _criteria = new List();
  final List _groupBy = new List();
  final List _orderBy = new List();
  
  
  final String action;
  final String table;
  final String table_alias;
  
  int offset = 0, limit = 0;
  
  QueryBuilder(this.action, this.table, [this.table_alias = ""]) {
    
  }
  
  
  void addField(String field) {
    this._fields.add(field);
  }
  
  void addJoin(String table, [String alias = ""]) {
    this._joins.add([table,alias]);
  }
  
  void addGroupBy(String field) {
    this._groupBy.add(field);
  }

  void addOrder(String field, [bool ascending = true]) {
    String direction = ASCENDING;
    if(!ascending) {
      direction = DESCENDING;
    }
    this._orderBy.add("${field} ${direction}");
  }

  void addCriteria(String criteria, [dynamic arg = null]) {
    this._criteria.add([criteria,arg]);
  }
  
  void setLimit(int offset, int limit) {
    this.offset = offset;
    this.limit = limit;
  }
  
  bool _disable_limit = false;
  
  String getCountQuery() {
    _disable_limit = true;
    String tmp = this.toString();
    _disable_limit = false;
    return _GET_COUNT_WRAPPER_START + tmp + _GET_COUNT_WRAPPER_END;
  }
  
  @override
  String toString() {
    StringBuffer sql = new StringBuffer();
    
    sql.write(this.action);
    sql.write(" ");

    switch(this.action) {
      case "SELECT":
        sql.write(this._fields.join(","));
        sql.write(" FROM ");
        sql.write(this.table);
        if(this.table_alias!="") {
          sql.write(" AS ");
          sql.write(this.table_alias);
        }
        // TODO: Add criteria support!
        
        if(this._groupBy.length>0) {
          sql.write(" GROUP BY ");
          sql.write(this._groupBy.join(","));          
        }
        
        if(this._orderBy.length>0) {
          sql.write(" ORDER BY ");
          sql.write(this._orderBy.join(","));          
        }
        
        if(!_disable_limit) {
          sql.write("LIMIT ${this.offset}, ${this.limit}");
        }
        
        break;
      default:
        throw new Exception("${this.action} is not yet supported by QueryBuilder");
    }
    

    return sql.toString();
  }
  
}