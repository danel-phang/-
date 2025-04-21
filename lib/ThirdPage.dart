import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Diy.dart';

class ProductItem {
  final String id;
  final String title;

  ProductItem({required this.id, required this.title});
}

class ThirdPage extends StatelessWidget {
  final List<ProductItem> products = [
    ProductItem(id: 'product1', title: '党史系列全切贴纸'),
    ProductItem(id: 'product2', title: '党史系列明信片'),
    ProductItem(id: 'product3', title: '"党风党纪"帆布包'),
    ProductItem(id: 'product4', title: '"廉"花扇'),
    ProductItem(id: 'product5', title: '"清廉"挂件'),
    ProductItem(id: 'product6', title: '"走进党史系列"集章折页'),
    ProductItem(id: 'product7', title: '"反四风"金属徽章'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiyPage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              bottomLeft: Radius.circular(12.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                              ),
                              child: Image.asset(
                                'assets/sale/myproduct.png', // Custom image path
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    child: const Center(
                                      child: Icon(
                                        Icons.create,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '我的DIY',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 200, 14, 14),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '创建您自己的定制产品',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProductTile(
                    productItem: products[index],
                    index: index,
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final ProductItem productItem;
  final int index;

  const ProductTile({
    super.key,
    required this.productItem,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                productItem: productItem,
                index: index,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Hero(
                tag: 'product_${productItem.id}',
                child: Image.asset(
                  'assets/sale/${productItem.id}.png',
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 0),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      productItem.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: Colors.orange.shade800,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final ProductItem productItem;
  final int index;

  const ProductDetailPage({
    Key? key,
    required this.productItem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text('商品详情'),

        // backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'product_${productItem.id}',
            child: FadeInImage(
              placeholder: const AssetImage('assets/placeholder.png'),
              image: AssetImage('assets/sale/${productItem.id}.png'),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 0),
              fadeInCurve: Curves.easeIn,
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productItem.title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '商品详情描述',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart,
                      color: Color.fromARGB(255, 221, 7, 7)),
                  label: const Text(
                    '加入购物车',
                    style: TextStyle(
                      color: Color.fromARGB(255, 221, 7, 7),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
