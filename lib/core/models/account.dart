class Account {
  String name;
  Account({this.name});

  Account.initial()
      : name = '';

  Account.fromMap(Map<String, dynamic> map) {
    name = map['name'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
