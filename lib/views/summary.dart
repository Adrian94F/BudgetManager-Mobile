import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../tools/formatters.dart';

class SummaryScreen extends StatefulWidget {
  final int? currentMonth;

  const SummaryScreen({Key? key, required this.currentMonth}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant SummaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      _fetchData();
    }
  }

  void _fetchData() {
    setState(() {
      _data = _authService.get("get-summary${widget.currentMonth == null ? '' : '/?month_id=${widget.currentMonth}'}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("Error: no data!"));
        }

        final data = snapshot.data!;
        final groups = data['groups'] as List<dynamic>;

        return Column(
          children: [
            _buildMonthHeader(data['dates']),
            _buildChartPlaceholder(),
            Expanded(child: _buildSummaryList(groups, context)),
          ],
        );
      },
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(64.0),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade200
          : Colors.grey.shade900,
      child: Center(
        child: Text(
          "chart",
          style: TextStyle(
              fontSize: 24.0,
              color: Theme.of(context).scaffoldBackgroundColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(String dates) {
    return Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0, vertical: 4.0),
        alignment: Alignment.centerLeft,
        child: Text(
          dates,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).primaryColor,
          ),
        )
    );
  }

  Widget _buildSummaryList(List<dynamic> groups, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupTitle(group['name'], context),
            ..._buildGroupFields(group['fields']),
            if (index < groups.length - 1) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildGroupTitle(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  List<Widget> _buildGroupFields(List<dynamic> fields) {
    return fields.map((field) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field['name'],
              style: const TextStyle(fontSize: 16.0),
            ),
            _buildFieldValue(field),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFieldValue(Map<String, dynamic> field) {
    if (!field.containsKey('type')) {
      return Text(
        Formatters.integerFormatter.format(field['value']),
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      );
    }

    switch (field['type']) {
      case 'currency':
        return Text(
          Formatters.currencyFormatter.format(field['value']),
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
      case 'percent':
        return Text(
          "${Formatters.integerFormatter.format(field['value'])}%",
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
      default:
        return const SizedBox();
    }
  }
}
