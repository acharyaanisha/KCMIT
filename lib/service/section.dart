import 'package:flutter/material.dart';
import 'package:kcmit/service/utility.dart';

class Section extends StatelessWidget {
  final String title;
  final List<IconAndText> iconsAndTexts;
  final String? image;

  const Section({super.key, required this.iconsAndTexts, required this.title, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        // color: const Color(0xFFF3F5F8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 0.0,bottom: 15),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                color: Color(0xff000000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            itemCount: iconsAndTexts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 15.0,
              // crossAxisSpacing: .0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Utility.createCustomIconButton(
                iconsAndTexts[index].icon,
                iconsAndTexts[index].text,
                iconsAndTexts[index].screen,
                context: context,
                backgroundColor: iconsAndTexts[index].backgroundColor,
              );
            },
          ),
        ],
      ),
    );
  }
}
class IconAndText {
  final IconData icon;
  final String text;
  final Widget screen;
  final Color backgroundColor;

  IconAndText(this.icon, this.text, this.screen, this.backgroundColor);
}
