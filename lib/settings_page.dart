import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

/// Settings page for customizing application preferences.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: appData.selectedColor == Colors.black ? Colors.grey[900] : null,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("About"),
                    content: const Text("Desuclock \n Version: 0.0.1"),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Theme Color'),
            trailing: ColorSelectionDropdown(),
          ),
          ListTile(
            title: const Text('Clock Style'),
            trailing: Switch(
              value: appData.isDigitalClock,
              onChanged: (value) {
                appData.toggleClockStyle();
              },
            ),
          ),
        ],
      ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}

/// Dropdown for selecting theme colors.
class ColorSelectionDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return DropdownButton<Color>(
      value: appData.selectedColor,
      items: const [
        DropdownMenuItem(
          value: Colors.red,
          child: Text('Red'),
        ),
        DropdownMenuItem(
          value: Colors.green,
          child: Text('Green'),
        ),
        DropdownMenuItem(
          value: Colors.blue,
          child: Text('Blue'),
        ),
        DropdownMenuItem(
          value: Colors.purple,
          child: Text('Purple'),
        ),
        DropdownMenuItem(
          value: Colors.amber,
          child: Text('Amber'),
        ),
        DropdownMenuItem(
          value: Colors.black,
          child: Text('Pure black'),
        ),
      ],
      onChanged: (Color? value) {
        if (value != null) {
          appData.setSelectedColor(value);
        }
      },
    );
  }
}