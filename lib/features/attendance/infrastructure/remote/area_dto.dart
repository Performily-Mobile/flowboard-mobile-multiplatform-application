class AreaDto {
  const AreaDto(this.data);

  final Map<String, dynamic> data;

  factory AreaDto.fromJson(Map<String, dynamic> json) => AreaDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get id => data['id'];
  dynamic get name => data['name'];
}