class MenuItem {
  final int menuItemID;
  final String itemName;
  final String itemDescription;
  final String price;
  final String imageURL;
  final String yelpID;

  MenuItem({
    required this.menuItemID,
    required this.itemName,
    required this.itemDescription,
    required this.price,
    required this.imageURL,
    required this.yelpID,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuItemID: json['menuItemID'] as int,
      itemName: json['itemName'] as String,
      itemDescription: json['itemDescription'] as String,
      price: json['price'] as String,
      imageURL: json['imageURL'] as String,
      yelpID: json['yelpID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemID': menuItemID,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'price': price,
      'imageURL': imageURL,
      'yelpID': yelpID,
    };
  }
}
