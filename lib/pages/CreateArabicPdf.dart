// CreateArabicPdf


import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' show AssetImage, Rect, Size;
import 'mobile.dart' if (dart.library.html) 'web.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';


// const PdfColor lightGreen = PdfColor.fromInt(0xffcdf1e7);

Future<void> createPDFArabe() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final Size pageSize = page.getClientSize();
  var arabicFont = Font.ttf(await rootBundle.load("assets/fonts/arabic.ttf"));

    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(0, 0, 100, 100));
    page.graphics.drawString(
        'Commune de  MANZEL ABDERRAHMAN \n Tel (+216) 72 570 125/ (+216) 72 571 295 \n Fax (+216) 72 570 125 \n communemenzelabderrahmen@gmail.com \n Rue El Mongi Slim 7035 menzel abdel rahmen',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(150, 100, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
  
        "Ce document est votre décharge de réclamation ".toString(),
      PdfTrueTypeFont(File('Arial.ttf').readAsBytesSync(), 18),
        bounds: Rect.fromLTWH(30, 200, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Monsieur/madame ".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-100, 230, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "اماني الغربي votre réclation de type  type est bien enregistrée "
            .toString(),
PdfTrueTypeFont(File('Arial.ttf').readAsBytesSync(), 18),
        bounds: Rect.fromLTWH(0, 320, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Vous pouvez suivre votre réclamation a travers ce numéro 12345678 "
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(0, 400, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));


    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'امانيالغربي.pdf');
    // NumRec = "";
}
Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
// Future<void> generateAndPrintArabicPdf({String? details,String? bookNum,String? replay,String? date,String? subject,List<String>?items,}) async {
//   final Document pdf = Document();

//   var arabicFont = Font.ttf(await rootBundle.load("assets/fonts/arabic.ttf"));


//   // final profileImage = MemoryImage(
//   //   (await rootBundle.load('assets/profile.jpg')).buffer.asUint8List(),
//   // );



//   pdf.addPage(Page(
//       theme: ThemeData.withFont(
//         base: arabicFont,
//       ),
//       pageFormat: PdfPageFormat.roll80,
//       build: (Context context) {
//         return Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     // width: 100,
//                       height: 100,
//                       // child: Image('assets/images/commune.jpg'),
//                     ),
//                   Container(
//                     height: 20,
//                   ),
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text(
//                                     details!, style: const TextStyle(
//                                   fontSize: 10,
//                                 ))
//                             )
//                         ),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text('التفاصيل الخاصه بالمراسلة رقم : ', style: const TextStyle(
//                                   fontSize: 8,
//                                 ))
//                             )
//                         ),
//                       ]
//                   ),
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text(
//                                     bookNum!, style: TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text('رقم الكتاب : ', style: TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),

//                         Text('      ',),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text(
//                                     replay!, style: TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text('ردا علي / الحاق : ', style: const TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),
//                       ]
//                   ),
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text(
//                                     date!, style: const TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text('تاريخ الارسال : ', style: const TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),

//                         Text('      ',),

//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text(
//                                     subject!, style: const TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text('الموضوع : ', style: const TextStyle(
//                                   fontSize: 6,
//                                 ))
//                             )
//                         ),
//                       ]
//                   ),

//                   Container(
//                     margin: EdgeInsets.fromLTRB(22, 5, 22, 5),
//                     child: Directionality(
//                       textDirection: TextDirection.rtl,
//                       child: Table.fromTextArray(
//                         headerStyle: TextStyle(fontSize: 6),headerAlignment: Alignment.center,
//                         headers: <dynamic>['حالة الاطلاع','ملاحظات','الاجراء', 'الي' ,'تاريخ الارسال', 'من','م'],
//                         cellAlignment: Alignment.center,
//                         cellStyle: TextStyle(fontSize: 4),
//                         data:
//                         <List<dynamic>>[
//                           items!,items,items
//                           // <dynamic>['34/44','الحمد لله','لاجراء اللازم','ادارة الحاسب', '10/11' ,'الدعم الفني', '١' ],
//                         ],
//                       ),
//                     ),
//                   ),
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text(
//                                     '  نقدا  ',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                     ))
//                             )
//                         ),
//                         Directionality(
//                             textDirection: TextDirection.rtl,
//                             child: Center(
//                                 child: Text('طريقة الدفع : ', style: TextStyle(
//                                   fontSize: 10,
//                                 ))
//                             )
//                         ),
//                       ]
//                   ),
//                 ]
//             )
//         );
//       }
//   ));
//   final String dir = (await getApplicationDocumentsDirectory()).path;
//   final String path = '$dir/1.pdf';
//   final File file = File(path);
//   //await file.writeAsBytes(pdf.save());
//   await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
// }