/// The Model for an article
/// The fields are final and set by the download controller.
/// They correspond to the JSON values that newsapi.org provides.
class Article {

  final String sourceId;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;
  final String content;

  Article(this.sourceId, this.author, this.title, this.description, this.url,
      this.urlToImage, this.publishedAt, this.content);

  /// Used for serialization
  ///
  /// Creates a JSON String with all information of the Article to be saved
  /// to the disk by the persistence controller.
  Map toJson() => {
    "sourceId" : sourceId,
    "author" : author,
    "title" : title,
    "description" : description,
    "url" : url,
    "urlToImage" : urlToImage,
    "publishedAt" : publishedAt.toIso8601String(),
    "content" : content,
  };

  /// Used for deserialization
  ///
  /// Creates an Article from a JSON encoded String which has been
  /// created by Article#toJson() or read by the persistence controller.
  factory Article.fromJson(Map<String, dynamic> json) {
    print("here");
    return Article(
        json["sourceId"],
        json["author"],
        json["title"],
        json["description"],
        json["url"],
        json["urlToImage"],
        DateTime.parse(json["publishedAt"]),
        json["content"]);
  }

  /// Implementation of equality between Articles
  ///
  /// For simplicity it can be assumed that two Articles are the same when they
  /// represent the same URL. This makes sense since (assuming the URL contents
  /// do not change) two identical URLs always point to the same Article at
  /// all times. So if I visited the URL already, I have seen the Article.
  ///
  /// return: true (if the same), false (if not the same)
  @override
  bool operator ==(Object other) {
    if (other is Article) {
      if (other.url == this.url) {
        return true;
      }
    }

    return false;
  }

}


