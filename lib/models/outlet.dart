class Outlet {
  final String id;
  final String outletName;
  final int meja;

  const Outlet({
    required this.id,
    required this.outletName,
    required this.meja,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'].toString(),
      outletName: json['Outlet']['outlet_name'] ?? '',
      meja: json['meja'] ?? 0,
    );
  }
}
