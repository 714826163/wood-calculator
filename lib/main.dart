import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main(List<String> args) {
  runApp(WoodCalculatorApp());
}

class WoodCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '木材计算器',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WoodCalculatorPage(),
    );
  }
}

class WoodItem {
  String id;
  TextEditingController lengthController;
  TextEditingController girthController;
  String lengthUnit;
  String girthUnit;
  double? volume;
  double? price;
  double? totalPrice;

  WoodItem({
    required this.id,
    required this.lengthController,
    required this.girthController,
    required this.lengthUnit,
    required this.girthUnit,
    this.volume,
    this.price,
    this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'length': lengthController.text,
      'girth': girthController.text,
      'lengthUnit': lengthUnit,
      'girthUnit': girthUnit,
      'volume': volume,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}

class BatchHistoryItem {
  String id;
  String time;
  int woodCount;
  double totalVolume;
  double grandTotalPrice;
  List<Map<String, dynamic>> woodDetails;

  BatchHistoryItem({
    required this.id,
    required this.time,
    required this.woodCount,
    required this.totalVolume,
    required this.grandTotalPrice,
    required this.woodDetails,
  });

  String toJson() {
    String detailsJson = woodDetails
        .map((detail) {
          return '${detail['length']}|${detail['girth']}|${detail['volume']}|${detail['price']}|${detail['totalPrice']}';
        })
        .join(';');
    return '$id|$time|$woodCount|$totalVolume|$grandTotalPrice|$detailsJson';
  }

  static BatchHistoryItem fromJson(String json) {
    final parts = json.split('|');
    final id = parts[0];
    final time = parts[1];
    final woodCount = int.parse(parts[2]);
    final totalVolume = double.parse(parts[3]);
    final grandTotalPrice = double.parse(parts[4]);
    final detailsJson = parts.sublist(5).join('|');
    final detailsList = detailsJson.split(';');
    final woodDetails = detailsList.map((detail) {
      final detailParts = detail.split('|');
      return {
        'length': detailParts[0],
        'girth': detailParts[1],
        'volume': double.parse(detailParts[2]),
        'price': double.parse(detailParts[3]),
        'totalPrice': double.parse(detailParts[4]),
      };
    }).toList();
    return BatchHistoryItem(
      id: id,
      time: time,
      woodCount: woodCount,
      totalVolume: totalVolume,
      grandTotalPrice: grandTotalPrice,
      woodDetails: woodDetails,
    );
  }
}

class BatchHistoryCard extends StatefulWidget {
  final BatchHistoryItem batchItem;

  const BatchHistoryCard({Key? key, required this.batchItem}) : super(key: key);

  @override
  _BatchHistoryCardState createState() => _BatchHistoryCardState();
}

class _BatchHistoryCardState extends State<BatchHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 批次摘要
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '批次计算',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('木材数量: ${widget.batchItem.woodCount} 根'),
                    Text('时间: ${widget.batchItem.time.substring(0, 19)}'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '总体积: ${widget.batchItem.totalVolume.toStringAsFixed(4)} 立方米',
                    ),
                    Text(
                      '总价格: ${widget.batchItem.grandTotalPrice.toStringAsFixed(2)} 元',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 展开的详情
          if (_isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 12),
                  Text('详细数据', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  ...widget.batchItem.woodDetails.asMap().entries.map((entry) {
                    int index = entry.key;
                    var detail = entry.value;
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '木材 ${index + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('长度: ${detail['length']}'),
                                Text('周长: ${detail['girth']}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '体积: ${detail['volume'].toStringAsFixed(4)} 立方米',
                                ),
                                Text(
                                  '价格: ${detail['totalPrice'].toStringAsFixed(2)} 元',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class WoodCalculatorPage extends StatefulWidget {
  @override
  _WoodCalculatorPageState createState() => _WoodCalculatorPageState();
}

class _WoodCalculatorPageState extends State<WoodCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  List<WoodItem> _woodItems = [];
  double _totalVolume = 0.0;
  double _grandTotalPrice = 0.0;
  List<BatchHistoryItem> _batchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBatchHistory();
    // 添加默认的木材项
    _addWoodItem();
  }

  Future<void> _loadBatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('batch_history');
    if (historyJson != null) {
      setState(() {
        _batchHistory = historyJson
            .map((json) => BatchHistoryItem.fromJson(json))
            .toList();
      });
    }
  }

  Future<void> _saveBatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _batchHistory.map((item) => item.toJson()).toList();
    await prefs.setStringList('batch_history', historyJson);
  }

  void _clearCurrentBatch() {
    setState(() {
      _woodItems.clear();
      _addWoodItem();
      _totalVolume = 0.0;
      _grandTotalPrice = 0.0;
    });
  }

  void _addWoodItem() {
    setState(() {
      _woodItems.add(
        WoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          lengthController: TextEditingController(),
          girthController: TextEditingController(),
          lengthUnit: '米',
          girthUnit: '厘米',
        ),
      );
    });
  }

  void _removeWoodItem(int index) {
    setState(() {
      _woodItems.removeAt(index);
      // 如果列表为空，添加一个默认项
      if (_woodItems.isEmpty) {
        _addWoodItem();
      }
    });
  }

  double _calculateVolume(double length, double girth) {
    // 计算直径（周长 / π）
    double diameter = girth / pi;
    // 计算半径
    double radius = diameter / 2;
    // 计算横截面积
    double area = pi * radius * radius / 10000; // 转换为平方米
    // 计算体积
    return area * length;
  }

  void _calculateBatch() {
    if (_formKey.currentState!.validate()) {
      double price = double.tryParse(_priceController.text) ?? 0.0;
      double totalVolume = 0.0;
      double grandTotalPrice = 0.0;

      // 计算每根木材
      for (var item in _woodItems) {
        double length = double.parse(item.lengthController.text);
        double girth = double.parse(item.girthController.text);

        // 单位转换
        if (item.lengthUnit == '厘米') {
          length /= 100;
        }
        if (item.girthUnit == '米') {
          girth *= 100;
        }

        // 计算体积和总价
        double volume = _calculateVolume(length, girth);
        double totalPrice = volume * price;

        // 更新木材项的计算结果
        item.volume = volume;
        item.price = price;
        item.totalPrice = totalPrice;

        // 累计总计
        totalVolume += volume;
        grandTotalPrice += totalPrice;
      }

      setState(() {
        _totalVolume = totalVolume;
        _grandTotalPrice = grandTotalPrice;

        // 添加到批量历史记录
        final batchItem = BatchHistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          time: DateTime.now().toString(),
          woodCount: _woodItems.length,
          totalVolume: totalVolume,
          grandTotalPrice: grandTotalPrice,
          woodDetails: _woodItems
              .map(
                (item) => {
                  'length': '${item.lengthController.text}${item.lengthUnit}',
                  'girth': '${item.girthController.text}${item.girthUnit}',
                  'volume': item.volume!,
                  'price': item.price!,
                  'totalPrice': item.totalPrice!,
                },
              )
              .toList(),
        );

        _batchHistory.insert(0, batchItem);

        // 限制历史记录数量
        if (_batchHistory.length > 10) {
          _batchHistory = _batchHistory.sublist(0, 10);
        }

        // 保存历史记录
        _saveBatchHistory();
      });
    }
  }

  void _clearBatchHistory() {
    setState(() {
      _batchHistory.clear();
      _saveBatchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('木材计算器')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '批量计算',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // 木材列表
              Column(
                children: List.generate(_woodItems.length, (index) {
                  final item = _woodItems[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '木材 ${index + 1}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => _removeWoodItem(index),
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // 长度输入
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.lengthController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: '长度',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入长度';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return '请输入有效的数值';
                                    }
                                    if (double.parse(value) <= 0) {
                                      return '长度必须大于0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              DropdownButton<String>(
                                value: item.lengthUnit,
                                onChanged: (value) {
                                  setState(() {
                                    item.lengthUnit = value!;
                                  });
                                },
                                items: ['米', '厘米'].map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // 周长输入
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.girthController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: '周长',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入周长';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return '请输入有效的数值';
                                    }
                                    if (double.parse(value) <= 0) {
                                      return '周长必须大于0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              DropdownButton<String>(
                                value: item.girthUnit,
                                onChanged: (value) {
                                  setState(() {
                                    item.girthUnit = value!;
                                  });
                                },
                                items: ['厘米', '米'].map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          // 计算结果
                          item.volume != null
                              ? Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '体积: ${item.volume!.toStringAsFixed(4)} 立方米',
                                      ),
                                      Text(
                                        '总价: ${item.totalPrice!.toStringAsFixed(2)} 元',
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // 添加木材按钮
              Center(
                child: TextButton.icon(
                  onPressed: _addWoodItem,
                  icon: Icon(Icons.add),
                  label: Text('添加木材'),
                ),
              ),

              SizedBox(height: 24),

              // 单价输入
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '单价（元/立方米）',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入单价';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的数值';
                  }
                  if (double.parse(value) < 0) {
                    return '单价不能为负数';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              // 计算按钮
              Center(
                child: ElevatedButton(
                  onPressed: _calculateBatch,
                  child: Text('批量计算'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // 总计结果
              _totalVolume > 0
                  ? Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.green, width: 2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '总计结果',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              '总木材体积: ${_totalVolume.toStringAsFixed(4)} 立方米',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '总价格: ${_grandTotalPrice.toStringAsFixed(2)} 元',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            SizedBox(height: 16),
                            // 清空当前批次按钮
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _clearCurrentBatch,
                                icon: Icon(Icons.clear),
                                label: Text('清空当前批次'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),

              SizedBox(height: 24),

              // 历史记录
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '批量计算历史',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: _clearBatchHistory, child: Text('清空')),
                ],
              ),

              SizedBox(height: 8),

              _batchHistory.isEmpty
                  ? Text('暂无历史记录')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _batchHistory.length,
                      itemBuilder: (context, index) {
                        final batchItem = _batchHistory[index];
                        return BatchHistoryCard(batchItem: batchItem);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
