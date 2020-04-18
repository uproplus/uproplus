class ApiResponse {
  dynamic message;
  String code;
  ApiResponse({this.message, this.code});

  ApiResponse.fromMappedJson(Map<String, dynamic> json)
      : message = json['message'],
        code = json['code'];

}
