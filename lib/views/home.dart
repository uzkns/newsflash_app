import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/article_download_controller.dart';
import 'package:flutter_app/controllers/article_persistence_controller.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/views/widgets/category_tile.dart';
import 'package:flutter_app/views/widgets/news_block.dart';

/// The home view.
///
/// A white top bar with the App name in it.
/// All fetched Articles will be displayed here as a scrollable list of Cards.
/// Above it are the two categories (saved/dismissed)
/// Below it are controls to go to saved/dismissed Articles.
/// A floating button allows for connection to the ESense earables.
class Home extends StatefulWidget {
    @override
    _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
    //holds all articles
    List<Article> articles = new List<Article>();
    ArticlePersistenceController apc = ArticlePersistenceController();
    int _navigationBarIndex = 1;
    final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
    Category dismissed = new Category.createEmpty("Dismissed", "Articles that are no longer relevant", "https://images.unsplash.com/photo-1600932717369-d507b606a25d?ixid=MXwxMjA3fDB8MHxzZWFyY2h8N3x8cmVkfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60");
    Category saved = new Category.createEmpty("Saved", "Articles that are saved for later reading", "https://images.unsplash.com/photo-1497211419994-14ae40a3c7a3?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");

    //indicates that the fetching of articles is done
    bool _loading = true;
    //Indicates weather the app is subscribed to esense sensor events
    bool _sensing = false;
    //indicted wether the esense is connected
    bool _connected = false;

    final String eSenseName = "eSense-0332"; //TODO change
    StreamSubscription subscription;
    int _threshold = 5; //TODO tweak



    @override
    void initState() {
      _fetchArticles();
      super.initState();
      _loading = true;
    }

    /// Fetches all Articles, loads saved Articles from disk and compares them.
    ///
    ///
    /// This is done as the first step in initalization.
    ///
    /// The Articles are downloaded with the ArticleDownloadController and
    /// compared to the saved Articles from the ArticlePersistenceController.
    /// The saved Articles are added to the "saved"-category and removed from
    /// the "main" Article list.
    ///
    /// This has to be async'd because network and file operations are async.
    /// The app can display the Articles when _loading becomes false.
    _fetchArticles() async {
        ArticleDownloadController adc = ArticleDownloadController();
        await adc.fetch();
        articles = adc.articles;

        List<Article> aList = await apc.loadArticleListFromDisk();
        for (Article a in aList) {
          saved.addArticle(a);
        }

        ArticlePersistenceController.removeDuplicates(articles, saved.getArticles());

        setState(() {
          _loading = false;
        });
    }


    /// Removes the top Card, dismissing the Article
    ///
    /// This is called when the first Card in the article-list is dismissed not
    /// by hand, but via the earable.
    /// When removing "by hand" (using touch controls), the Dismissible widget
    /// provides everything we need. But this widget does only work with
    /// swipe-controls. For dismissing the Card with the Earable, the list has
    /// to be transformed manually.
    ///
    /// This method removes the Article from the Article-list, adds it to
    /// the dismissed-category and removes the Card from the view.
    dismissFirstArticle() {
        AnimatedListState _list = listKey.currentState;
        dismissed.addArticle(articles.removeAt(0));
        _list.removeItem(0, (_, animation) => buildDismissible(context, 0, animation, TextDirection.ltr));
    }

    /// Removes the top Card, saving the Article
    ///
    /// This is called when the first Card in the article-list is dismissed not
    /// by hand, but via the earable.
    /// When removing "by hand" (using touch controls), the Dismissible widget
    /// provides everything we need. But this widget does only work with
    /// swipe-controls. For dismissing the Card with the Earable, the list has
    /// to be transformed manually.
    ///
    /// This method removes the Article from the Article-list, adds it to
    /// the dismissed-category, saves it to the disk and removes the Card
    /// from the view.
    ///
    /// It needs to be async for disk operations.
    saveFirstArticle() async {
        AnimatedListState _list = listKey.currentState;
        Article a = articles.removeAt(0);
        _list.removeItem(0, (_, animation) => buildDismissible(context, 0, animation, TextDirection.rtl));
        saved.addArticle(a);
        await apc.saveArticleToDisk(a);
    }


    @override
    Widget build(BuildContext context) {
      //TODO register motion controls here so that we have access to the context

      return Scaffold(
          appBar: AppBar(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text("News"), Text("Flash", style: TextStyle(color: Colors.red),)]
              ),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SafeArea(
              child: _loading ? Center(
                  child: Container(
                      child: CircularProgressIndicator(),
                  ),
              ) : SingleChildScrollView(
                  child: Container(
                      child: Column(
                          children: <Widget>[

                            // --- Top Buttons
                              Align(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Container(
                                      height: 70,
                                      child: ListView.builder(
                                          itemCount: 2,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                              List<Category> _categories = new List<Category>();
                                              _categories.add(dismissed);
                                              _categories.add(saved);
                                              return CategoryTile(_categories[index]);
                                          }
                                      )
                                  )
                              ),

                              // --- Articles
                              Container(
                                  padding: EdgeInsets.only(top: 12),
                                  child: AnimatedList(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      key: listKey,
                                      initialItemCount: articles.length,
                                      itemBuilder: (context, index, animation) {
                                          return buildDismissible(context, index, animation, null);
                                      }
                                  )
                              )
                        ],
                      )
                  ),
              ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
                if (_connected == false) {
                    _connectToESense();
                } else {
                    _disconnectFromESense();
                }
            },
            child: Icon(Icons.bluetooth),
            backgroundColor: Colors.green,
          ),
          bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.remove_circle),
                  label: 'Dismiss',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.save),
                  label: 'Save',
              ),
              ],
              currentIndex: _navigationBarIndex,
              selectedItemColor: Colors.amber[800],
              onTap: (int index) {

                  //TODO replace with buttons to go to dismissed/saved articles
                  if (articles.isEmpty) {
                    return;
                  }

                  if (index == 0) {
                      dismissFirstArticle();
                  } else if (index == 2) {
                      saveFirstArticle();
                  } else if (index == 1) {
                      saved.clear();
                      apc.clear();
                  }
              }
      ),
      );
    }


    /// Makes Card dismissible, so that it can be "swiped away" to either
    /// direction by hand.
    SlideTransition buildDismissible(context, index, animation, direction) {
      final article = articles[index];
      return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset(0, 0),
          ).animate(animation),
          textDirection: direction,
          child: Dismissible(

              key: Key(article.url),
              child: NewsBlock.fromArticle(article),

              onDismissed: (direction) {
                switch(direction) {
                  case DismissDirection.endToStart: //to the left / dismissed
                    setState(() {
                      dismissed.addArticle(articles[index]);
                      articles.removeAt(index);
                    });
                    break;
                  case DismissDirection.startToEnd: //to the right / saved
                    setState(() {
                      Article a = articles[index];
                      saved.addArticle(a);
                      apc.saveArticleToDisk(a); //TODO debug, it is async
                      articles.removeAt(index);
                    });
                    break;
                  default:
                    break;
                }
              },

              background: saveBackground(),
              secondaryBackground: dismissBackground()

      ));
    }


    Future<void> _connectToESense() async {
      ESenseManager.connectionEvents.listen((event) {
        if (event.type == ConnectionType.connected) _startSensing();
      });


      _connected = await ESenseManager.connect(eSenseName);
      _startSensing();
    }

    void _startSensing() async {
      // subscribe to sensor event from the eSense device
      subscription = ESenseManager.sensorEvents.listen((event) {
          if (event.runtimeType == AccelerometerOffsetRead) {
              int offset = (event as AccelerometerOffsetRead).offsetY;

              if (offset >= _threshold) {
                  dismissFirstArticle();
              } else if (offset <= -(_threshold)) {
                  saveFirstArticle();
              }
          };
      });
      setState(() {
        _sensing = true;
      });
    }

    void _disconnectFromESense() {
      subscription.cancel();
      setState(() {
        _sensing = false;
      });
      ESenseManager.disconnect();
      super.dispose();
    }
}


