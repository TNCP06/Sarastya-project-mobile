
class Part {
  final int id;
  final int partNumber;
  final int channelMsgId;
  final String fileName;
  final int fileSize;
  final String uploadedAt;
  final bool hasThumb;
  final String? streamUrl;

  Part({
    required this.id,
    required this.partNumber,
    required this.channelMsgId,
    required this.fileName,
    required this.fileSize,
    required this.uploadedAt,
    required this.hasThumb,
    this.streamUrl,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] ?? json['partId'], // handle stream-info Part payload vs detail Part payload
      partNumber: json['partNumber'],
      channelMsgId: json['channelMsgId'],
      fileName: json['fileName'],
      fileSize: json['fileSize'] ?? 0,
      uploadedAt: json['uploadedAt'] ?? '',
      hasThumb: json['hasThumb'] ?? false,
      streamUrl: json['streamUrl'],
    );
  }
}
