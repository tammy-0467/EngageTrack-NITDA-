import 'package:flutter/material.dart';

class UserInfoWidget extends StatelessWidget {
  final String title;

  final Widget leading;
  final Widget trailing;

  const UserInfoWidget({
    Key? key,
    required this.title,
    required this.leading,
    required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(5),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.2 / 2,
      child: ListTile(
        title: Text(title),
        leading: leading,
        trailing: trailing,
      ),
    );
  }
}
