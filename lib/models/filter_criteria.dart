class FilterCriteria {
  final int pageSize;
  final int pageNum;
  final List<String> style;
  final int availability;
  final int sortby;
  final List<String> collection;
  final int set;
  final List<String> category;
  final List<String> supplier;
  final String textFilter;
  final List<String> subCategory;

  FilterCriteria({
    required this.pageSize,
    required this.pageNum,
    required this.style,
    required this.availability,
    required this.sortby,
    required this.collection,
    required this.set,
    required this.category,
    required this.supplier,
    required this.textFilter,
    required this.subCategory,
  });

  FilterCriteria copyWith({
    int? pageSize,
    int? pageNum,
    List<String>? style,
    int? availability,
    int? sortby,
    List<String>? collection,
    int? set,
    List<String>? category,
    List<String>? supplier,
    String? textFilter,
    List<String>? subCategory
  }) {
    return FilterCriteria(
      pageSize: pageSize ?? this.pageSize,
      pageNum: pageNum ?? this.pageNum,
      style: style ?? this.style,
      availability: availability ?? this.availability,
      sortby: sortby ?? this.sortby,
      collection: collection ?? this.collection,
      set: set ?? this.set,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      textFilter: textFilter ?? this.textFilter,
      subCategory: subCategory ?? this.subCategory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageSize': pageSize,
      'pageNum': pageNum,
      'style': style,
      'availability': availability,
      'sortby': sortby,
      'collection': collection,
      'set': set,
      'category': category,
      'supplier': supplier,
      'textFilter': textFilter,
      'subCategory': subCategory,
    };
  }
}
