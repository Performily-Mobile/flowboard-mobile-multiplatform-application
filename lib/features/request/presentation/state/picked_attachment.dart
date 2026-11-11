/// File chosen with the file picker, described before it is stored.
class PickedAttachment {
  /// Creates the description of the file.
  const PickedAttachment({required this.uri, required this.name, required this.contentType, required this.sizeInBytes});

  final String uri;
  final String name;
  final String contentType;
  final int sizeInBytes;
}
