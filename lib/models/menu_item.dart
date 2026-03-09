/// Menu item model for the preset food items grid.
///
/// Each item has a name, price, and an icon for display in the Add Order screen.
library;

import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final double price;
  final IconData icon;

  const MenuItem({
    required this.name,
    required this.price,
    required this.icon,
  });
}

/// Preset food items available in QuickQueue Pro.
/// These are displayed as a grid in the Add Order screen.
class MenuItems {
  static const List<MenuItem> items = [
    MenuItem(name: 'Burger', price: 120, icon: Icons.lunch_dining),
    MenuItem(name: 'Pizza', price: 250, icon: Icons.local_pizza),
    MenuItem(name: 'Fries', price: 80, icon: Icons.takeout_dining),
    MenuItem(name: 'Sandwich', price: 100, icon: Icons.bakery_dining),
    MenuItem(name: 'Noodles', price: 150, icon: Icons.ramen_dining),
    MenuItem(name: 'Taco', price: 110, icon: Icons.set_meal),
    MenuItem(name: 'Hot Dog', price: 90, icon: Icons.fastfood),
    MenuItem(name: 'Wrap', price: 130, icon: Icons.breakfast_dining),
    MenuItem(name: 'Momos', price: 100, icon: Icons.egg_alt),
    MenuItem(name: 'Shawarma', price: 160, icon: Icons.kebab_dining),
    MenuItem(name: 'Cold Drink', price: 40, icon: Icons.local_drink),
    MenuItem(name: 'Juice', price: 60, icon: Icons.emoji_food_beverage),
    MenuItem(name: 'Coffee', price: 70, icon: Icons.coffee),
    MenuItem(name: 'Ice Cream', price: 80, icon: Icons.icecream),
    MenuItem(name: 'Biryani', price: 200, icon: Icons.rice_bowl),
    MenuItem(name: 'Salad', price: 90, icon: Icons.eco),
  ];
}
