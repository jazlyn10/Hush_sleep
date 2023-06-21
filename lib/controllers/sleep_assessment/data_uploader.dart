import 'package:get/get.dart';

class DataUploader extends GetxController{
  @override
  void onReady(){
    uploadData();
    super.onReady();
  }

  void uploadData(){
    print("Data is uploading");
  }

}