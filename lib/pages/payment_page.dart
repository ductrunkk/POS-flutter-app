import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';
import '../helpers/date_helper.dart';
import '../helpers/pdf_helper.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Obx(() {
        final inv = controller.invoice.value;
        if (inv == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice # ${inv.invoiceid}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Cashier ID: ${inv.cashierid}'),
              Text(
                'Paid at: ${Formatters.dateTime.format(inv.paymenttime)}',
              ),
              const Divider(height: 32),
              Text('Items:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: controller.orderDetails.length,
                  itemBuilder: (_, i) {
                    final d = controller.orderDetails[i];

                    return ListTile(
                      title: Text(d.dishname),
                      subtitle: Text('${d.quantity} x \$${d.unitprice}'),
                      trailing: Text(
                        '\$ ${(d.quantity * d.unitprice).toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 32),
              Text('Total: \$${inv.totalamount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final inv = controller.invoice.value;
                    final details = controller.orderDetails;
                    await generateInvoicePDF(inv!, details);
                  },
                  child: const Text('PAY NOW'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
