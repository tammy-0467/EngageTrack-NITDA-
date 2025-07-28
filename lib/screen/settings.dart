import 'package:gam_project/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.lato(),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: screenHeight/30.64, horizontal: screenWidth /14.4), //25
        padding: EdgeInsets.symmetric(horizontal:  screenWidth /22.5, vertical: screenHeight/47.875 ), //16
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // dark mode
          Text("Dark Mode", style: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSurface,),),

          //Switch toggle
          CupertinoSwitch(
            value:
            Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
            onChanged:
                (value) =>
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme(),
          ),
        ],
      ),
      ),
    );
  }
}
