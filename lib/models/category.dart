import 'package:flutter_app/models/article.dart';

/// Model for an Article category
///
/// It has the necessary information for all controllers and views (api keys, images, description)
/// and a List of all Articles for the Category.
class Category {
    final String name;
    final String description;
    final String apiName;
    final String imgUrl;
    List<Article> _articles = new List<Article>();

    /// Create a new category
    Category(this.name, this.apiName, this.description, this.imgUrl, this._articles);

    /// Create a new empty category
    Category.createEmpty(this.name, this.apiName, this.description, this.imgUrl) {
      this._articles = new List<Article>();
    }

    /// Add an Article to the category
    ///
    /// The article will be inserted at the beginning of the List, so that
    /// newest Articles are always at the top
    addArticle(Article a) {
        _articles.insert(0, a);
    }

    /// Get all articles
    ///
    /// return: Reference to the List with all articles
    List<Article> getArticles() {
        return _articles;
    }

    void addArticles(List<Article> articles) {
        _articles.addAll(articles);
    }
}