class Outlet {
  final String id;
  final String outletName;
  final int meja;
  final int useQris;
  final String merchantKey;

  const Outlet({
    required this.id,
    required this.outletName,
    required this.meja,
    required this.useQris,
    required this.merchantKey,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'].toString(),
      outletName: json['Outlet']['outlet_name'] ?? '',
      meja: json['meja'] ?? 0,
      useQris: json['Outlet']['use_qris'] ?? 0,
      merchantKey: json['Outlet']['merchant_key'] ?? '',
    );
  }
}
