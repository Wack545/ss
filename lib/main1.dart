import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// คลาสหลักของแอป
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TryRunPage(),
    );
  }
}

// หน้าทดลอง Widget ทั้งหมด
class TryRunPage extends StatefulWidget {
  const TryRunPage({super.key});

  @override
  State<TryRunPage> createState() => _TryRunPageState();
}

class _TryRunPageState extends State<TryRunPage> {
  bool isOn = false;
  String? phone;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('หน้าแรกนะ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleSpacing: 20,
        toolbarHeight: 100,
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),

      // เนื้อหาภายในหน้า
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // Text
            const Text(
              'ทดสอบหน้าแรก',
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // TextField
            const TextField(
              decoration: InputDecoration(
                labelText: 'กรอกข้อความ',
                border: OutlineInputBorder(),
                hintText: 'กรอกข้อความที่นี่',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            // Image
            Image.network(
              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
              width: 400,
              height: 300,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 6),

            // Switch
            Switch(
              value: isOn,
              onChanged: (value) {
                setState(() {
                  isOn = value;
                });
              },
            ),

            Text(isOn ? 'เปิด' : 'ปิด'),

            const SizedBox(height: 6),

            // OutlinedButton
            OutlinedButton(
              onPressed: () {
                print('กด OutlinedButton');
              },
              child: const Text('Outlined Button'),
            ),

            const SizedBox(height: 6),

            // ElevatedButton
            ElevatedButton(
              onPressed: () {
                print('กด ElevatedButton');
              },
              child: const Text('Elevated Button'),
            ),

            const SizedBox(height: 6),

            // DropdownButton
            DropdownButton<String>(
              value: phone,
              hint: const Text('กรุณาเลือกเบอร์ติดต่อ'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('เบอร์ 1')),
                DropdownMenuItem(value: '2', child: Text('เบอร์ 2')),
                DropdownMenuItem(value: '3', child: Text('เบอร์ 3')),
              ],
              onChanged: (value) {
                setState(() {
                  phone = value;
                });
              },
            ),

            const SizedBox(height: 6),

            // Checkbox
            Checkbox(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
            ),

            Text(
              isChecked ? 'เลือกแล้ว' : 'ยังไม่เลือก',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            // TextField อีกตัว
            const TextField(
              decoration: InputDecoration(
                labelText: 'กรอกข้อความ',
                border: OutlineInputBorder(),
                hintText: 'กรอกข้อความที่นี่',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 6),

            // Container
            Container(
              width: 100,
              height: 100,
              color: Colors.red,
              alignment: Alignment.center,
              child: const Text(
                'Hello',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 6),

            // TextFormField
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'กรอกข้อความ',
                border: OutlineInputBorder(),
                hintText: 'กรอกข้อความที่นี่',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 6),

            // ListView.builder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('รายการที่ ${index + 99}'),
                );
              },
            ),

            const SizedBox(height: 6),

            // Row และ Icon
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 30, color: Colors.black),
                SizedBox(width: 33),
                Icon(Icons.person, size: 30, color: Colors.black),
                SizedBox(width: 33),
                Icon(Icons.settings, size: 30, color: Colors.black),
                SizedBox(width: 33),
                Icon(Icons.settings, size: 30, color: Colors.black),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
