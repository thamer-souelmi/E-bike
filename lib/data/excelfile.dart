import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class Excelfile {
Future<void> saveDeviceDataToExcel(List<String> groupedBytes) async {
  // Request storage permissions
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    print('Storage permission not granted');
    return;
  }

  // Create a new Excel document
  var excel = Excel.createExcel();

  // Select the default sheet or create a new one
  Sheet sheetObject = excel['Sheet1'];

  // Add data to the sheet
  for (int i = 0; i < groupedBytes.length; i++) {
    sheetObject.cell(CellIndex.indexByString("A${i + 1}")).value = groupedBytes[i];
  }

  // Save the file
  var directory = await getExternalStorageDirectory();
  String filePath = "${directory!.path}/device_data.xlsx";
  var fileBytes = excel.save();
  File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);

  print('Excel file saved at $filePath');
}
}