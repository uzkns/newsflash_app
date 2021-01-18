import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/article_categorization_controller.dart';
import 'package:flutter_app/controllers/article_persistence_controller.dart';
import 'package:flutter_app/models/article.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/views/saved_article_view.dart';
import 'package:flutter_app/views/settings_view.dart';
import 'package:flutter_app/views/widgets/category_tile.dart';
import 'package:flutter_app/views/widgets/dialog.dart';
import 'package:flutter_app/views/widgets/news_block.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// The home view.
///
/// A white top bar with the App name in it.
/// All fetched Articles will be displayed here as a scrollable list of Cards.
/// Above it are all the categories in a horizontal list
/// Below it are controls to go to saved/dismissed Articles.
/// A floating button allows for connection to the ESense earables.
class Home extends StatefulWidget {
    @override
    _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

    //holds all "general" articles
    ArticlePersistenceController apc = ArticlePersistenceController();
    ArticleCategorizationController acc = ArticleCategorizationController();
    final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();


    // saved and dismissed articles are saved as extra categories
    Category dismissed = new Category.createEmpty("Dismissed", "", "Articles that are no longer relevant", "https://images.unsplash.com/photo-1600932717369-d507b606a25d?ixid=MXwxMjA3fDB8MHxzZWFyY2h8N3x8cmVkfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60");
    Category saved = new Category.createEmpty("Saved", "", "Articles that are saved for later reading", "https://images.unsplash.com/photo-1497211419994-14ae40a3c7a3?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80");

    //indicates that the fetching of articles is done
    bool _loading = true;
    // is bluetooth on?
    bool _btOn = false;
    //indicted weather the esense is connected
    bool _connected = false;


    final String eSenseName = "eSense-0332"; //TODO change to the name of the device
    int _threshold = 2250; //TODO tweak
    FlutterBlue flutterBlue;
    BluetoothCharacteristic motionSenor;
    BluetoothCharacteristic startStop;
    BluetoothDevice device;
    var dataList = new List<int>();


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
        await acc.fetchForAll();

        List<Article> aList = await apc.loadArticleListFromDisk();
        for (Article a in aList) {
          saved.addArticle(a);
        }

        ArticleCategorizationController.removeDuplicates(acc.general.getArticles(), saved.getArticles());

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
        dismissed.addArticle(acc.general.getArticles().removeAt(0));
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
        Article a = acc.general.getArticles().removeAt(0);
        _list.removeItem(0, (_, animation) => buildDismissible(context, 0, animation, TextDirection.rtl));
        saved.addArticle(a);
        await apc.saveArticleToDisk(a);
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text("News"), Text("Flash", style: TextStyle(color: Colors.red),)]
              ),
            centerTitle: true,
            elevation: 0.0,
              actions: <Widget>[
                  IconButton(icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsView(this.apc)
                          )
                      );
                    },
                  ),
                ]
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

                            // --- Category Buttons
                              Align(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Container(
                                      height: 70,
                                      child: ListView.builder(
                                          itemCount: acc.getAllCategories().length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {

                                              return CategoryTile(acc.getAllCategories()[index], this.apc, this.saved);
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
                                      initialItemCount: acc.general.getArticles().length,
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
            backgroundColor: _connected ? Colors.green : Colors.red,
          ),
          bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.save),
                  label: 'Saved',
              ),
              ],
              currentIndex: 0,
              selectedItemColor: Colors.red[800],
              onTap: (int index) {

                  if (acc.general.getArticles().isEmpty) {
                    return;
                  }

                  switch (index) {
                    case 0: //Left -- nothing / stay on Home screen
                      break;
                    case 1: //Right -- saved articles
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SavedArticleView(this.saved)
                          )
                      );
                      break;
                  }
              }
      ),
      );
    }


    /// Makes Card dismissible, so that it can be "swiped away" to either
    /// direction by hand.
    SlideTransition buildDismissible(context, index, animation, direction) {
      final article = acc.general.getArticles()[index];
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
                      dismissed.addArticle(acc.general.getArticles()[index]);
                      acc.general.getArticles().removeAt(index);
                    });
                    break;
                  case DismissDirection.startToEnd: //to the right / saved
                    setState(() {
                      Article a = acc.general.getArticles()[index];
                      saved.addArticle(a);
                      apc.saveArticleToDisk(a);
                      acc.general.getArticles().removeAt(index);
                    });
                    break;
                  default:
                    break;
                }
              },

              background: saveBackground(),
              secondaryBackground: dismissBackground()
          )
      );
    }


    /// Connects to an ESense earable using bluetooth (FlutterBlue).
    /// The name of the ESense to use is stored in a variable in home.dart
    /// If the connection is successful, _connected will be true and the
    /// floating button for the connection will turn green.
    /// If it fails, a dialog will be shown.
    ///
    /// If it is already connected, the ESense will be disconnected using
    /// _disconnectFromESense() method.
    Future<void> _connectToESense() {
        flutterBlue = FlutterBlue.instance;
        setState((){
            if(_btOn) {
                _disconnectFromESense();
            } else {
                _btOn = true;
                flutterBlue.isOn.then((isOn) {
                    if(isOn) {
                        flutterBlue.scan(timeout: Duration(seconds: 4)).listen((_onScanResult)).onDone(() {
                            if(device == null) {
                                ESenseDialog.showBluetoothDialog(context, "Connection failed", "No ESense device found. Make sure the device is turned on");
                            }

                            _connected = true;
                        });
                    } else {
                      ESenseDialog.showBluetoothDialog(context, "Connection failed", "Bluetooth is turned off. Please turn it on and try again.");
                    }
                });

            }
        });
    }


    /// Disconnects from the ESense earable.
    /// All event subscriptions/alters will be stopped, the scanning for devices
    /// will be stopped and the earable will be successfully disconnected.
    ///
    /// No error message will be shown if disconnecting fails.
    Future<void> _disconnectFromESense() async {
        if(device == null) {
            setState(() {
                _btOn = false;
                _connected = false;
            });
            return;
        }

        flutterBlue.stopScan();
        await startStop.write([0x53, 0x16, 0x02, 0x00, 0x14]);
        motionSenor.setNotifyValue(false);

        device.disconnect().whenComplete((){
            setState((){
                _btOn = false;
                _connected = false;
            });
            startStop = null;
            motionSenor = null;
        });
    }


    /// The scan result of the bluetooth connection function is evaluated here.
    ///
    /// If the device is an ESense device and all charateristics are received
    /// successfully, scanning for further devices will be stopped and the
    /// event listener for the motion sensor is started.
    void _onScanResult(ScanResult scanResult) {
        BluetoothDevice device = scanResult.device;
        if(device.name.contains("eSense")) {
            this.device = device;
            flutterBlue.stopScan();

            this.device.connect().whenComplete(() async {
                await _initCharacteristics(this.device).then((value) {
                    if(!value) {
                        flutterBlue.scan(timeout: Duration(seconds: 4)).listen((_onScanResult));
                    }
                });

                if (startStop != null && motionSenor != null) {
                    await startSampling(startStop);
                    if (motionSenor.isNotifying == false) {
                        motionSenor.setNotifyValue(true);
                    }
                    motionSenor.value.listen((receiveData));
                }
            });
        }
    }


    /// Searches for the motion sensor in the devices supported services.
    /// This assumes that the device is an ESense device because it is called
    /// only in _connectToEsense()->_onScanResult().
    ///
    /// The global variables motionSensor and startStop are set here to the
    /// corresponding characteristics.
    ///
    /// returns: true if the motion sensor was found, false otherwise.
    /// Note that even if true is returned it is not 100% safe to assume
    /// that motionSensor and startStop are set!
    Future<bool> _initCharacteristics (BluetoothDevice device) async {
        List<BluetoothService> services = await device.discoverServices();
        bool serviceFound = false;
        services.forEach((service){
            if(service.uuid.toString().contains("0000ff06")) {
                serviceFound = true;
                service.characteristics.forEach((characteristic) {
                    if (characteristic.uuid.toString().contains("0000ff08")) {
                        motionSenor = characteristic;
                    } else if (characteristic.uuid.toString().contains("0000ff07")) {
                        startStop = characteristic;
                    }
                });
            }
        });
        return serviceFound;
    }


    /// Starts the sampling of the motion sensor by writing into the startStop
    /// characteristic.
    Future<void> startSampling (BluetoothCharacteristic startStop) async {
        await startStop.write([0x53, 0x17, 0x02, 0x01, 0x14]);
    }


    /// Receives daa from the earable and pre-selects it so that processData()
    /// can work on the accelerometer data.
    void receiveData(List<int> value) {
        if(value.length > 15){
            int yGyro = (value.elementAt(6) << 8).toSigned(16) + value.elementAt(7);

            if(dataList.length > 30) {
                dataList.removeAt(0);
            }

            dataList.add((yGyro));

            if(dataList.length > 20) {
                setState(() {
                    _connected = false;
                });
                processData(dataList.getRange(dataList.length - 20, dataList.length - 1));
            }
        }
    }


    /// Triggers for the dismiss/save gesture
    /// If movement to the left is detected, the article is dismissed
    /// If movement to the right is detected, the article is saved
    ///
    /// This uses dismissFirstArticle() and saveFirstArticle() to manipulate
    /// the article list and view
    void processData(Iterable<int> data) {
        if (detectMovement(data, true) == true) {
            dismissFirstArticle();
        } else if (detectMovement(data, false) == true) {
            saveFirstArticle();
        };
    }


    /// Detects head movement to the left or right. The Iterable data is the
    /// pre-selected sensor data, the bool left decides wether a left or right
    /// head movement should be detected.
    ///
    /// The sensor data must surpass a certain _threshold (global var.) to count
    /// as a movement so that not every small head movement counts as
    /// a dismiss/save action.
    ///
    /// return: true if movement has been detected, false otherwise.
    bool detectMovement(Iterable<int> data, bool left) {
        int count = 0;
        int countThreshold = 4;
        int sign = left ? 1 : -1;
        int countReset = 0;

        data.forEach((value){
            if (value * sign > 4500 - _threshold) {
                count++;
            }

            if (count >= countThreshold) {
                sign = sign * (-1);
                count = 0;
                countReset++;
            }
        });

        //TODO check if that is necessary of if it only detects a double movement
        if (countReset >= 2 ) {
            return true;
        }

        return false;
    }
}


