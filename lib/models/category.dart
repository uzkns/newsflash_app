import 'package:flutter_app/models/article.dart';

/// Model for an Article category
///
/// Thus far, there are only two categories of Articles:
///     - Saved articles
///     - dismissed Articles
class Category {
    final String name;
    final String description;
    final String imgUrl;
    List<Article> _articles = new List<Article>();

    /// Create a new category
    Category(this.name, this.description, this.imgUrl, this._articles);

    /// Create a new empty category
    Category.createEmpty(this.name, this.description, this.imgUrl) {
      this._articles = new List<Article>();
    }

    /// Add an Article to the category
    ///
    /// The article will be inserted at the beginning of the List, so that
    /// newest Articles are always at the top
    addArticle(Article a) {
        //TODO move save-to-disk logic to here if possible
        _articles.insert(0, a);
    }

    /// Get all articles
    ///
    /// return: Reference to the List with all articles
    List<Article> getArticles() {
        return _articles;
    }

    /// Empties the List with all articles
    ///
    /// Probably a debug method TODO maybe remove?
    clear() {
        _articles = new List<Article>();
    }
}