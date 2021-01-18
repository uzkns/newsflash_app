import 'package:flutter_app/controllers/article_download_controller.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/models/category.dart';

// TODO as Singleton

/// This class controls the article categories. It is reposnsibe for filling the
/// categories with articles and removing duplicate articles.
///
/// From these categories, the top horizontal-scrolling list is built.
///
/// Note: It does NOT hold the saved/dismissed articles! These are in home.dart
class ArticleCategorizationController {

    //The language of the articles that are to be fetched.
    //TODO make changable by settings
    final String _language = "de";

    // All categories
    Category _business;
    Category _entertainment;
    Category _general;
    Category _health;
    Category _science;
    Category _sports;
    Category _technology;

    // All categories as a List
    List<Category> _categories;

    /// Creates all categories. They are empty after creation.
    ArticleCategorizationController() {
        _business = new Category.createEmpty("Business", "business", "Business and finance news", "https://images.unsplash.com/photo-1491336477066-31156b5e4f35?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");
        _entertainment = new Category.createEmpty("Entertainment", "entertainment", "Entertainment news and stars", "https://images.unsplash.com/photo-1496337589254-7e19d01cec44?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");
        _general = new Category.createEmpty("General", "general", "General news", "https://images.unsplash.com/photo-1572949645841-094f3a9c4c94?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80");
        _health = new Category.createEmpty("Health", "health", "Health and Fitness news", "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");
        _science = new Category.createEmpty("Science", "science", "Science news and findings", "https://images.unsplash.com/photo-1564325724739-bae0bd08762c?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");
        _sports = new Category.createEmpty("Sports", "sports", "Sports news", "https://images.unsplash.com/photo-1560272564-c83b66b1ad12?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=687&q=80");
        _technology = new Category.createEmpty("Technology", "technology", "Technology and Internet culture news", "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");

        _categories = new List<Category>();
        _categories.add(_general);
        _categories.add(_business);
        _categories.add(_entertainment);
        _categories.add(_health);
        _categories.add(_science);
        _categories.add(_sports);
        _categories.add(_technology);
    }

    // Getter for all categories
    Category get business => _business;
    Category get general => _general;
    Category get entertainment => _entertainment;
    Category get health => _health;
    Category get science => _science;
    Category get sports => _sports;
    Category get technology => _technology;

    /// Returns a List with all categories.
    List<Category> getAllCategories() {
      return _categories;
    }

    /// Fetches articles for a given category.
    /// This uses
    ///     ArticleDownloadController->fetch()
    /// with the categories api-name to get the top headlines for the category
    /// and language.
    Future<void> fetchArticles(Category c) async {
        ArticleDownloadController adc = ArticleDownloadController.getTopHeadlines(c.apiName, _language, "");
        await adc.fetch();
        c.addArticles(adc.articles);
    }

    /// Fetches articles for all categories
    /// Unfortuately, the fetching cannot happen in parallel because
    /// the view (home.dart) will not wait for it to be finished and display
    /// an empty card list. So, we have to "await" every category to finish.
    ///
    /// The categories are filled after this completes.
    Future<void> fetchForAll() async {
        //TODO see if general can be handled extra
        for (Category c in _categories) {
            await this.fetchArticles(c);
        }
        return;
    }



    /// removes duplicates from a List of Articles
    ///
    /// the first parameter should be a reference to the list
    /// from which the items should be removed.
    ///
    /// Takes the elements from duplicates and
    /// compares them one-by-one to the elements in list.
    /// If a duplicate is found, it will be removed from list
    ///
    /// return: void
    static void removeDuplicates(List<Article> list, List<Article> duplicates) {
        for (Article a in duplicates) {
          list.remove(a);
        }
    }
}
