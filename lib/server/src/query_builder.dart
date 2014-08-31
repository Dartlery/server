part of server;

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
  
  static const String _NO_ARG_STRING = "This string indicates that an argument has not been passed";
  
  final List _fields = new List();
  final List _joins = new List();
  //final List _joinArgs = new List();
  final List _criteria = new List();
  final List _criteriaArgs = new List();
  final List _groupBy = new List();
  final List _orderBy = new List();
  
  
  final String action;
  final dynamic table;
  final String table_alias;
  
  int offset = 0, limit = 0;
  
  QueryBuilder(this.action, this.table, [this.table_alias = ""]) {
    
  }
  
  void addField(String field, [String alias = null]) {
    if(alias==null) {
      this._fields.add(field);
    } else {
      this._fields.add("${field} AS ${alias}");
    }
  }
  
  void addJoin(String join_type, dynamic source, List join_criteria, [String alias = ""]) {
    StringBuffer join = new StringBuffer();
    join.write(" ${join_type}");
    join.write(" JOIN ");
    if(source is String) {
      join.write(source);
    } else {
      join.write("(${source.toString()}) ");
    }
    if(alias!="") {
      join.write(" AS ${alias} ");
    }
    join.write(" ON ");
    join.writeAll(join_criteria," AND ");
    this._joins.add(join.toString());
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

  
  void addCriteria(String criteria, [dynamic arg = _NO_ARG_STRING]) {
    this._criteria.add(criteria);
    if(arg!=_NO_ARG_STRING) {
      this._criteriaArgs.add(arg);
    }
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
  
  List getArgs() {
    List output = new List();
    if(this.table is QueryBuilder) {
     output.addAll(this.table.getArgs()); 
    }
    output.addAll(this._criteriaArgs);
    return output;
  }
  
  @override
  String toString() {
    StringBuffer sql = new StringBuffer();
    
    sql.write(this.action);
    sql.write(" ");

    switch(this.action) {
      case "SELECT":
        
        
        sql.writeAll(this._fields,",");
        
        
        sql.write(" FROM ");
        if(this.table is String) {
          sql.write(this.table);
        } else {
          sql.write("(");
          sql.write(this.table.toString());
          sql.write(")");
        }
        if(this.table_alias!="") {
          sql.write(" AS ");
          sql.write(this.table_alias);
        }
        
        if(this._joins.length>0) {
          sql.writeAll(this._joins," ");
        }
        
        if(this._criteria.length>0) {
          sql.write(" WHERE ");
          sql.writeAll(this._criteria, " AND ");
        }
        if(this._groupBy.length>0) {
          sql.write(" GROUP BY ");
          sql.writeAll(this._groupBy,",");          
        }
        
        if(this._orderBy.length>0) {
          sql.write(" ORDER BY ");
          sql.writeAll(this._orderBy,",");          
        }
        
        if(!_disable_limit&&this.limit>0) {
          sql.write(" LIMIT ${this.offset}, ${this.limit}");
        }
        
        break;
      default:
        throw new Exception("${this.action} is not yet supported by QueryBuilder");
    }
    

    _log.info("Generating query: ${sql.toString()}");
    return sql.toString();
  }
  
}