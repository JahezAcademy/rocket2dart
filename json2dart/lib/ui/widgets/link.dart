

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Links extends StatelessWidget {
  final String link, title;
  final IconData icon;
  Links(this.link, this.icon, this.title);
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final TextStyle stl = TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.brown);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(link),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.brown,
              size: 45.0,
            ),
            Text(
              title,
              style: stl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
