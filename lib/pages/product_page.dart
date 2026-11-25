
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ApiService api = ApiService();
  final TextEditingController searchController =
      TextEditingController();

  List<Product> products = [];

  bool isLoading = false;
  bool isSaving = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    // โหลดสินค้าทั้งหมดเมื่อเปิดหน้า
    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET: โหลดรายการสินค้า
  Future<void> loadProducts({String keyword = ''}) async {
    if (!mounted || isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final result = await api.getProducts(
        keyword: keyword,
      );

      if (!mounted) return;

      setState(() {
        products = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        hasError = true;
      });

      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // แสดงข้อความแจ้งเตือน
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // สร้างช่องกรอกข้อมูล
  Widget buildField(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(
                decimal: true,
              )
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required &&
              (value == null || value.trim().isEmpty)) {
            return 'กรุณากรอก$label';
          }

          if (number) {
            final price = double.tryParse(value ?? '');

            if (price == null || price < 0) {
              return 'กรุณากรอกราคาให้ถูกต้อง';
            }
          }

          return null;
        },
      ),
    );
  }

  // POST / PUT: เพิ่มและแก้ไขสินค้า
  Future<void> openForm({Product? product}) async {
    if (isSaving) return;

    final formKey = GlobalKey<FormState>();

    final articleController =
        TextEditingController(text: product?.articleId ?? '');

    final barcodeController =
        TextEditingController(text: product?.barcode ?? '');

    final nameController =
        TextEditingController(text: product?.productName ?? '');

    final priceController =
        TextEditingController(
          text: product?.price.toString() ?? '',
        );

    final remarkController =
        TextEditingController(text: product?.remark ?? '');

    final unitController =
        TextEditingController(text: product?.unitCode ?? '');

    bool active = product?.isActive ?? true;

    try {
      final result = await showDialog<Product>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  product == null ? 'เพิ่มสินค้า' : 'แก้ไขสินค้า',
                ),
                content: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildField(
                            articleController,
                            'Article ID',
                          ),
                          buildField(
                            barcodeController,
                            'Barcode',
                          ),
                          buildField(
                            nameController,
                            'ชื่อสินค้า',
                            required: true,
                          ),
                          buildField(
                            priceController,
                            'ราคา',
                            required: true,
                            number: true,
                          ),
                          buildField(
                            remarkController,
                            'หมายเหตุ',
                          ),
                          buildField(
                            unitController,
                            'หน่วยสินค้า',
                          ),
                          SwitchListTile(
                            title: const Text('เปิดใช้งานสินค้า'),
                            value: active,
                            onChanged: (value) {
                              setDialogState(() {
                                active = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('ยกเลิก'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final newProduct = Product(
                        id: product?.id ?? '',
                        articleId: articleController.text.trim(),
                        barcode: barcodeController.text.trim(),
                        productName: nameController.text.trim(),
                        isActive: active,
                        price: double.parse(priceController.text),
                        remark: remarkController.text.trim(),
                        unitCode: unitController.text.trim(),
                        createdAt: product?.createdAt ?? '',
                        updatedAt: product?.updatedAt ?? '',
                      );

                      Navigator.pop(
                        dialogContext,
                        newProduct,
                      );
                    },
                    child: const Text('บันทึก'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || result == null) return;

      setState(() {
        isSaving = true;
      });

      if (product == null) {
        await api.addProduct(result);
      } else {
        await api.updateProduct(result);
      }

      if (!mounted) return;

      showMessage(
        product == null
            ? 'เพิ่มสินค้าสำเร็จ'
            : 'อัปเดตสินค้าสำเร็จ',
      );

      await loadProducts(
        keyword: searchController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        showMessage(e.toString());
      }
    } finally {
      articleController.dispose();
      barcodeController.dispose();
      nameController.dispose();
      priceController.dispose();
      remarkController.dispose();
      unitController.dispose();

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // DELETE: ลบสินค้า
  Future<void> removeProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text(
            'ต้องการลบ ${product.productName} หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('ลบสินค้า'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    try {
      await api.deleteProduct(product.id);

      if (!mounted) return;

      showMessage('ลบสินค้าสำเร็จ');

      await loadProducts(
        keyword: searchController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString());
    }
  }

  // แสดงรายละเอียดสินค้า
  void showDetail(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('รายละเอียดสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: ${product.id}'),
                const Divider(),
                Text('Article ID: ${product.articleId}'),
                Text('Barcode: ${product.barcode}'),
                Text('ชื่อสินค้า: ${product.productName}'),
                Text('ราคา: ${product.price.toStringAsFixed(2)} บาท'),
                Text('หมายเหตุ: ${product.remark}'),
                Text('หน่วย: ${product.unitCode}'),
                Text(
                  'สถานะ: ${product.isActive ? "ใช้งาน" : "ปิดใช้งาน"}',
                ),
                const Divider(),
                Text('สร้างเมื่อ: ${product.createdAt}'),
                Text('อัปเดตเมื่อ: ${product.updatedAt}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  // UI หลัก
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบจัดการสินค้า'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () {
                    loadProducts(
                      keyword: searchController.text.trim(),
                    );
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Column(
        children: [
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onSubmitted: (value) {
                loadProducts(keyword: value.trim());
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาสินค้า...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    loadProducts();
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // แสดงจำนวนสินค้า
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'รายการสินค้าทั้งหมด (${products.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // รายการสินค้า
          Expanded(
            child: hasError && products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('ไม่สามารถโหลดสินค้าได้'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => loadProducts(
                            keyword: searchController.text.trim(),
                          ),
                          child: const Text('ลองอีกครั้ง'),
                        ),
                      ],
                    ),
                  )
                : products.isEmpty && !isLoading
                    ? const Center(
                        child: Text('ไม่พบข้อมูลสินค้า'),
                      )
                    : RefreshIndicator(
                        onRefresh: () => loadProducts(
                          keyword: searchController.text.trim(),
                        ),
                        child: ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.shopping_bag),
                                ),
                                title: Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Barcode: ${product.barcode}\n'
                                  'ราคา: ${product.price.toStringAsFixed(2)} บาท\n'
                                  'หน่วย: ${product.unitCode}',
                                ),
                                isThreeLine: true,
                                onTap: () => showDetail(product),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      openForm(product: product);
                                    } else if (value == 'delete') {
                                      removeProduct(product);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('แก้ไข'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('ลบ'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: isSaving
            ? null
            : () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
