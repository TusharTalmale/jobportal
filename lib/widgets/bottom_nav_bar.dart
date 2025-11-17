import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Color.fromRGBO(0, 0, 0, 0.08),
        //     blurRadius: 20,
        //     offset: Offset(0, -5),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 0),
          _navItem(Icons.wifi_protected_setup_sharp, 1),

          // Center Search FAB
          GestureDetector(
            onTap: () => widget.onTap(2),
            child: _fab(widget.currentIndex == 2),
          ),

          _navItem(Icons.chat_bubble_outline, 3),
          _navItem(Icons.bookmark_border, 4),
        ],
      ),
    );
  }

  // -------- Bottom Navigation Icon --------
  Widget _navItem(IconData icon, int index) {
    bool isSelected = widget.currentIndex == index;

    return IconButton(
      icon: Icon(
        icon,
        size: 27,
        color: isSelected
            ? const Color(0xFF130160)     // active color
            : const Color(0xFFAAA6B9),     // inactive color
      ),
      onPressed: () => widget.onTap(index),
    );
  }

  // -------- Center Floating Search Button --------
  Widget _fab(bool isSelected) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: const Color(0xff2e236c),
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(
                color: const Color(0xFF4E3FDF).withOpacity(0.5),
                width: 5,
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 35, 108, 0.25),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.search, size: 30, color: Colors.white),
    );
  }
}
