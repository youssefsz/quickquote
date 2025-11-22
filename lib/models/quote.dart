class Quote {
  final String text;
  final String author;

  // Generate a unique ID based on text and author for identification
  String get id => '${text.hashCode}_${author.hashCode}';

  Quote({required this.text, required this.author});

  Map<String, dynamic> toJson() {
    return {'text': text, 'author': author};
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(text: json['text'] ?? '', author: json['author'] ?? 'Unknown');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}
