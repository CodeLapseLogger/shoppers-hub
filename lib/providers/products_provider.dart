import 'package:flutter/material.dart';

import './product_provider.dart';

// Provider class with added capability of notifying changes to listeners in the widget tree, through the mixin ChangeNotifier.
// It is the central data storage holding all the product data. The behind the scenes data channels are established through
// the mixin that handles the data communication. Also, a copy of the data is sent to avoid data changes in multiple places,
// since data by default is passed by reference in Dart. The copy is to avoid changes in multiple places and inconsistent
// data being served by this provider to the listener requests.

class ProductsProvider with ChangeNotifier {
  List<ProductProvider> _dummyProducts = [
    // The '_' is to signify that the list is to be private and not accesible outside this class.
    ProductProvider(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    ProductProvider(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    ProductProvider(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    ProductProvider(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
    ProductProvider(
      id: 'p5',
      title: 'Nike Shoes',
      description: 'Breatheble uppers and cushioned inners - Get your pair today !',
      price: 79.99,
      imageUrl:
          'https://c.static-nike.com/a/images/t_PDP_1280_v1/f_auto/uwjw39b1xdsbtmfnxjqm/tanjun-shoe-MkTmejeq.jpg',
    ),
  ];



  void addProduct(ProductProvider newProduct) {
    _dummyProducts.add(newProduct);
    notifyListeners();
  }

  // Method to render a copy of the products to the client caller outside this class.
  List<ProductProvider> get products {
    return [
      ..._dummyProducts
    ]; // Returning a copy of the _dummyProducts, by creating a new list and adding its elements
    // with a spread operator.
  }

  // Method to render a copy of a product with matching input product id
  ProductProvider getProductById(String id) {
    return [..._dummyProducts].firstWhere((product) {
      return product.id ==
          id; // test to match input id with the current product id
    });
  }

  // Method to return a copy of favorite product list
  List<ProductProvider> get favoriteProducts{
    return _dummyProducts.where((product){
       return product.isFavorite; // test to know if the current product is a marked favorite or not.
    }).toList();
  }


  // Update existing product
  void updateProduct(String existingProdId, ProductProvider updatedProductItem){
      
      // Get the index of existing product with the given id.
      int existingItemIdx = _dummyProducts.indexWhere((product){
          return product.id == existingProdId;
      });

      // Replace the existing product entry at the given index with the updated product entry.
      _dummyProducts.removeAt(existingItemIdx); // First remove
      _dummyProducts.insert(existingItemIdx, updatedProductItem); // Then insert at the same index

  }

  // Method to remove a product with given id
  void deleteProductById(String id){
    _dummyProducts.removeWhere((product){
        return product.id == id;
    });

    notifyListeners();
  }

}
