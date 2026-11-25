
class Product {
  final String id;
  final String articleId;
  final String barcode;
  final String productName;
  final bool isActive;
  final double price;
  final String remark;
  final String unitCode;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.articleId,
    required this.barcode,
    required this.productName,
    required this.isActive,
    required this.price,
    required this.remark,
    required this.unitCode,
    required this.createdAt,
    required this.updatedAt,
  });

  // รับข้อมูล JSON จาก API
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      articleId: json['article_id']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      isActive: json['is_active'] == true,
      price: double.tryParse(
        json['price']?.toString() ?? '0',
      ) ?? 0,
      remark: json['remark']?.toString() ?? '',
      unitCode: json['unit_code']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  // ส่งข้อมูล JSON ไป API
  Map<String, dynamic> toJson() {
    return {
      'article_id': articleId,
      'barcode': barcode,
      'product_name': productName,
      'is_active': isActive,
      'price': price,
      'remark': remark,
      'unit_code': unitCode,
    };
  }
}
