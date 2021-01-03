import 'package:flutter_app/controllers/article_persistence_controller.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {

  bool value = true;
  ArticlePersistenceController apc;


  SettingsView(this.apc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text("Settings")]
          ),
          centerTitle: true,
        ),
    body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Settings',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: 'Clear saved articles',
                subtitle: 'Deletes all saved articles from the disk',
                leading: Icon(Icons.delete_forever),
                onPressed: (BuildContext context) {
                  apc.clear();
                },
              ),
              SettingsTile.switchTile(
                title: 'Debugger',
                leading: Icon(Icons.bug_report),
                switchValue: value,
                onToggle: (bool value) {},
              ),
            ],
          ),
        ],
      )
    );
  }
}