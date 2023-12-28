class Book {
  String ?id;
  String? title;
  String? author;
  double? price;
  String? subject;
  String? imageUrl;

  Book(this.id,this.title, this.author, this.price, this.subject, this.imageUrl);

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'title': title,
      'author': author,
      'price': price,
      'subject': subject,
      'imageUrl': imageUrl,
    };
  }

  factory Book.fromJson(String key,Map<dynamic, dynamic> json) {
    return Book(
      key,
      json['title'] as String?,
      json['author'] as String?,
      json['price'] as double?,
      json['subject'] as String?,
      json['imageUrl'] as String?,
    );
  }
}
