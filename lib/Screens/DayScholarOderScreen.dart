import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:ami_student/services/api_service.dart';

// Your Brand Colors
const Color primaryColor = Color(0xFFFADD73);
const Color secondaryDark = Color(0xFF669447);
const Color background = Color(0xFFF8FAFC);
const Color cardColor = Colors.white;
const Color textDark = Color(0xFF1E293B);

class DayScholarOrderScreen extends StatefulWidget {
  final String mealType;
  final double price;
  const DayScholarOrderScreen(
      {super.key, required this.mealType, required this.price});

  @override
  State<DayScholarOrderScreen> createState() => _DayScholarOrderScreenState();
}

class _DayScholarOrderScreenState extends State<DayScholarOrderScreen> {
  final ApiService _apiService = ApiService();
  final CFPaymentGatewayService cfPaymentGatewayService =
      CFPaymentGatewayService();

  bool isLoading = false;
  String? generatedToken;

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(webCallbackSuccess, webCallbackError);
  }

  void webCallbackSuccess(String orderId) async {
    setState(() => isLoading = true);
    try {
      final res =
          await _apiService.verifyDayScholarPayment(orderId, widget.mealType);
      if (res['success'] == true) {
        setState(() {
          generatedToken = res['tokenNumber'];
          isLoading = false;
        });
        Get.snackbar("Success", "Token generated successfully!",
            backgroundColor: secondaryDark, colorText: Colors.white);
      } else {
        Get.snackbar("Error", res['message'] ?? "Verification failed");
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void webCallbackError(errorResponse, String orderId) {
    setState(() => isLoading = false);
    Get.snackbar("Failed", "Payment cancelled or failed");
  }

  void startCheckout() async {
    setState(() => isLoading = true);
    try {
      final res = await _apiService.createDayScholarOrder(widget.mealType);
      if (res['success'] == true) {
        var session = CFSessionBuilder()
            .setEnvironment(
                CFEnvironment.SANDBOX) // Change to PRODUCTION for live
            .setOrderId(res['orderId'])
            .setPaymentSessionId(res['paymentSessionId'])
            .build();

        var cfDropCheckout =
            CFDropCheckoutPaymentBuilder().setSession(session!).build();
        cfPaymentGatewayService.doPayment(cfDropCheckout);
      } else {
        Get.snackbar("Error", res['message']);
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("Error", "Network error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double gst = widget.price * 0.02;
    double total = widget.price + gst;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: textDark),
        title: Text(
          "Checkout - ${widget.mealType}",
          style: GoogleFonts.poppins(
              color: textDark, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: generatedToken != null
              ? Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: textDark.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "🎉 ${widget.mealType.toUpperCase()} TOKEN",
                            style: GoogleFonts.poppins(
                                color: textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          generatedToken!,
                          style: GoogleFonts.poppins(
                              color: secondaryDark,
                              fontSize: 48,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Show this token at the collection counter.",
                          style: GoogleFonts.poppins(
                              color: Colors.grey[600], fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle,
                                color: secondaryDark, size: 18),
                            const SizedBox(width: 8),
                            Text("Payment Verified",
                                style: GoogleFonts.poppins(
                                    color: secondaryDark,
                                    fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Summary",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: textDark.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${widget.mealType} Plate Price",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[700])),
                              Text("₹${widget.price.toStringAsFixed(2)}",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: textDark)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("GST (2%)",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[700])),
                              Text("₹${gst.toStringAsFixed(2)}",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: textDark)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Payable",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                      fontSize: 16)),
                              Text("₹${total.toStringAsFixed(2)}",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: secondaryDark,
                                      fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: textDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isLoading ? null : startCheckout,
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: textDark, strokeWidth: 2.5))
                            : Text(
                                "Pay ₹${total.toStringAsFixed(2)} via Cashfree",
                                style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
