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
                      '总体积: ${widget.batchItem.totalVolume.toStringAsFixed(3)} 立方米',
                    ),
                    Text(
                      '总价格: ${widget.batchItem.grandTotalPrice.toStringAsFixed(3)} 元',
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
                                  '体积: ${detail['volume'].toStringAsFixed(3)} 立方米',
                                ),
                                Text(
                                  '价格: ${detail['totalPrice'].toStringAsFixed(3)} 元',
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
  bool _hasUnfinishedData = false;

  @override
  void initState() {
    super.initState();
    _loadBatchHistory();
    _loadUnfinishedData();
    // 添加默认的木材项（如果没有恢复的数据）
    if (_woodItems.isEmpty) {
      _addWoodItem();
    }
    // 添加单价控制器监听器
    _priceController.addListener(_saveUnfinishedData);
  }

  // 保存未完成的木材数据
  Future<void> _saveUnfinishedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存木材项数据
    List<String> woodItemsJson = [];
    for (var item in _woodItems) {
      woodItemsJson.add(
        '${item.id}|${item.lengthController.text}|${item.girthController.text}|${item.lengthUnit}|${item.girthUnit}',
      );
    }
    await prefs.setStringList('unfinished_wood_items', woodItemsJson);

    // 保存单价
    await prefs.setString('unfinished_price', _priceController.text);
  }

  // 加载未完成的木材数据
  Future<void> _loadUnfinishedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载木材项数据
    final woodItemsJson = prefs.getStringList('unfinished_wood_items');
    if (woodItemsJson != null && woodItemsJson.isNotEmpty) {
      List<WoodItem> loadedItems = [];
      bool hasValidData = false;

      for (var json in woodItemsJson) {
        final parts = json.split('|');
        TextEditingController lengthController = TextEditingController(
          text: parts[1],
        );
        TextEditingController girthController = TextEditingController(
          text: parts[2],
        );

        // 检查是否有有效数据
        if (parts[1].isNotEmpty || parts[2].isNotEmpty) {
          hasValidData = true;
        }

        // 添加控制器监听器
        lengthController.addListener(_saveUnfinishedData);
        girthController.addListener(_saveUnfinishedData);

        loadedItems.add(
          WoodItem(
            id: parts[0],
            lengthController: lengthController,
            girthController: girthController,
            lengthUnit: parts[3],
            girthUnit: parts[4],
          ),
        );
      }

      setState(() {
        _woodItems = loadedItems;
        // 只有当存在有效木材数据时才显示提示
        _hasUnfinishedData = hasValidData;
      });
    }

    // 加载单价
    final price = prefs.getString('unfinished_price');
    if (price != null) {
      _priceController.text = price;
    }
  }

  // 清除未完成的木材数据（计算完成后调用）
  Future<void> _clearUnfinishedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unfinished_wood_items');
    await prefs.remove('unfinished_price');
    setState(() {
      _hasUnfinishedData = false;
    });
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
    TextEditingController lengthController = TextEditingController();
    TextEditingController girthController = TextEditingController();

    // 添加控制器监听器
    lengthController.addListener(_saveUnfinishedData);
    girthController.addListener(_saveUnfinishedData);

    setState(() {
      _woodItems.add(
        WoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          lengthController: lengthController,
          girthController: girthController,
          lengthUnit: '米',
          girthUnit: '厘米',
        ),
      );
      // 保存数据
      _saveUnfinishedData();
    });
  }

  void _removeWoodItem(int index) {
    setState(() {
      _woodItems.removeAt(index);
      // 如果列表为空，添加一个默认项
      if (_woodItems.isEmpty) {
        _addWoodItem();
      }
      // 保存数据
      _saveUnfinishedData();
    });
  }

  double _calculateVolume(double length, double diameter) {
    // 用户输入的"周长"实际上是检尺径（直径D），直接使用
    // 使用GB/T 4814—2013《原木材积表》中的计算公式
    if (length >= 0.5 && length <= 1.9) {
      // 短原木（检尺长 0.5m ~ 1.9m）
      // 公式(1): V = 0.8 × L × (D + 0.5 × L)² ÷ 10000
      return 0.8 * length * pow(diameter + 0.5 * length, 2) / 10000;
    } else if (length >= 2.0 && length <= 10.0) {
      // 标准长度原木（检尺长 2.0m ~ 10.0m）
      if (diameter >= 4 && diameter <= 13) {
        // 小径原木
        // 公式(2): V = 0.7854 × L × (D + 0.45 × L + 0.2)² ÷ 10000
        return 0.7854 * length * pow(diameter + 0.45 * length + 0.2, 2) / 10000;
      } else if (diameter >= 14) {
        // 大径原木
        // 公式(3): V = 0.7854 × L × [D + 0.5 × L + 0.005 × L² + 0.000125 × L × (14 - L)² × (D - 10)]² ÷ 10000
        return 0.7854 *
            length *
            pow(
              diameter +
                  0.5 * length +
                  0.005 * pow(length, 2) +
                  0.000125 * length * pow(14 - length, 2) * (diameter - 10),
              2,
            ) /
            10000;
      } else {
        // 直径小于4cm的情况，使用简单圆柱体公式
        double radius = diameter / 2;
        double area = pi * radius * radius / 10000;
        return area * length;
      }
    } else if (length >= 10.2) {
      // 超长原木（检尺长 10.2m以上）
      // 公式(4): V = 0.8 × L × (D + 0.5 × L)² ÷ 10000
      return 0.8 * length * pow(diameter + 0.5 * length, 2) / 10000;
    } else {
      // 其他情况，使用简单圆柱体公式
      double radius = diameter / 2;
      double area = pi * radius * radius / 10000;
      return area * length;
    }
  }

  void _calculateBatch() {
    if (_formKey.currentState!.validate()) {
      double price = double.tryParse(_priceController.text) ?? 0.0;
      double totalVolume = 0.0;
      double grandTotalPrice = 0.0;

      // 计算每根木材
      for (var item in _woodItems) {
        double length = double.parse(item.lengthController.text);
        double diameter = double.parse(item.girthController.text);

        // 单位转换
        // L（检尺长）：保持为米
        // D（检尺径）：保持为厘米（标准要求）
        if (item.lengthUnit == '厘米') {
          length /= 100; // 将厘米转换为米
        }
        // 直径单位已经是厘米，不需要转换

        // 计算体积和总价
        double volume = _calculateVolume(length, diameter);
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

        // 清除未完成的数据
        _clearUnfinishedData();
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
              // 未完成操作提示
              if (_hasUnfinishedData)
                Card(
                  color: Colors.yellow[100],
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '检测到未完成的计算操作，是否继续编辑？',
                          style: TextStyle(color: Colors.black87),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 已经自动加载了数据，这里只需要关闭提示
                            setState(() {
                              _hasUnfinishedData = false;
                            });
                          },
                          child: Text('继续编辑'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                                    // 保存数据
                                    _saveUnfinishedData();
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
                                    // 保存数据
                                    _saveUnfinishedData();
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
                                        '体积: ${item.volume!.toStringAsFixed(3)} 立方米',
                                      ),
                                      Text(
                                        '总价: ${item.totalPrice!.toStringAsFixed(3)} 元',
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
                              '总木材体积: ${_totalVolume.toStringAsFixed(3)} 立方米',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '总价格: ${_grandTotalPrice.toStringAsFixed(3)} 元',
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
