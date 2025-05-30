
import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class MediaRepository{

  late Cloudinary cloundinary;

  MediaRepository(){
      cloundinary = Cloudinary.full (
      apiKey: '789549317331418',
      apiSecret: 'gc4i7_k7v8eZLBlX3JzS8yeZmRM',
      cloudName: 'dybx88bzo',
    );
}

  Future<CloudinaryResponse> uploadImg(String path){
     return cloundinary.uploadResource(
        CloudinaryUploadResource(
          filePath: path,
          resourceType:  CloudinaryResourceType.image
        )
    );
  }

}