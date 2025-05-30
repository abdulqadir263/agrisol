
class Post{
  String id;
  String uId;
  String title;
  String description;
  String? image;

  Post(this.id, this.uId, this.title, this.description);


  static Post fromMap(Map<String, dynamic> map){
    Post p = Post(map['id'], map['uId'], map['title'], map['description']);
    p.image = map['image'];
    return p;
  }

  Map<String,dynamic> toMap(){
    return{
      'id' : id,
      'uId' : uId,
      'title' : title,
      'description' : description,
      'image': image,
    };
  }

}