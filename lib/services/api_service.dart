
import 'package:dio/dio.dart';
import '../models/product.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-internal-uat.dohome.technology/dodee',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // GET: ดึงรายการสินค้าทั้งหมดหรือค้นหาด้วย Keyword
  Future<List<Product>> getProducts({
    String keyword = '',
  }) async {
    try {
      final response = await dio.get(
        '/v1/learn-product',
        queryParameters: {
          if (keyword.trim().isNotEmpty)
            'keyword': keyword.trim(),
        },
      );

      dynamic result = response.data;

      // ตรวจสอบรูปแบบ JSON ที่ได้รับ
      while (result is Map) {
        if (result['data'] is List) {
          result = result['data'];
          break;
        }

        if (result['products'] is List) {
          result = result['products'];
          break;
        }

        if (result['items'] is List) {
          result = result['items'];
          break;
        }

        if (result['results'] is List) {
          result = result['results'];
          break;
        }

        if (result['data'] is Map) {
          result = result['data'];
          continue;
        }

        // กรณี API ส่งสินค้ากลับมาเพียงรายการเดียว
        if (result.containsKey('product_name')) {
          result = [result];
          break;
        }

        throw Exception('ไม่พบรายการสินค้าใน Response');
      }

      if (result is! List) {
        throw Exception('รูปแบบข้อมูลสินค้าไม่ถูกต้อง');
      }

      return result.map((item) {
        return Product.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

    } on DioException catch (e) {
      throw Exception(
        'GET Error: ${e.response?.data ?? e.message}',
      );
    }
  }

  // POST: เพิ่มสินค้า
  Future<void> addProduct(Product product) async {
    try {
      await dio.post(
        '/v1/learn-product',
        data: product.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        'POST Error: ${e.response?.data ?? e.message}',
      );
    }
  }

  // PUT: อัปเดตสินค้า
  Future<void> updateProduct(Product product) async {
    try {
      await dio.put(
        '/v1/learn-product/${product.id}',
        data: product.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        'PUT Error: ${e.response?.data ?? e.message}',
      );
    }
  }

  // DELETE: ลบสินค้า
  Future<void> deleteProduct(String id) async {
    try {
      await dio.delete(
        '/v1/learn-product/$id',
      );
    } on DioException catch (e) {
      throw Exception(
        'DELETE Error: ${e.response?.data ?? e.message}',
      );
    }
  }
}
