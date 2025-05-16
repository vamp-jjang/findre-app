import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final RangeValues? currentPriceRange;
  
  const FilterScreen({super.key, this.currentPriceRange});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Price range values
  late RangeValues _priceRange;
  
  @override
  void initState() {
    super.initState();
    // Initialize with a price range that includes all possible property values
    // This ensures all properties appear without filtering initially
    _priceRange = widget.currentPriceRange ?? const RangeValues(0, 50000000);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _priceRange),
            child: const Text('Save Search'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
        backgroundColor: const Color(0xFF2D2F3E),
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // For Sale button
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D2F3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('For Sale'),
          ),
        ),
        
        // Price Range section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    'PRICE RANGE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_priceRange.start.toInt()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('—'),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_priceRange.end.toInt()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.purple,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Colors.white,
                  overlayColor: Colors.purple.withOpacity(0.3),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 50000000,
                  divisions: 1000,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 50000000);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reset All Filters'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _priceRange);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2F3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Show Results'),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}