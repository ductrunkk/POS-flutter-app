class InvoiceModel {
  final int invoiceid;
  final int cashierid;
  final DateTime paymenttime;
  final double totalamount;

  InvoiceModel({
    required this.invoiceid,
    required this.cashierid,
    required this.paymenttime,
    required this.totalamount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceid: json['invoiceid'],
      cashierid: json['cashierid'],
      paymenttime: DateTime.parse(json['paymenttime']),
      totalamount: (json['totalamount'] as num).toDouble(),
    );
  }
}
