
class Post{
  String id;
  String uId;
  String title;
  String description;

  Post(this.id, this.uId, this.title, this.description);


  static Post fromMap(Map<String, dynamic> map){
    return Post(map['id'], map['uId'], map['title'], map['description']);
  }

  Map<String,dynamic> toMap(){
    return{
      'id' : id,
      'uId' : uId,
      'title' : title,
      'description' : description,
    };
  }

}