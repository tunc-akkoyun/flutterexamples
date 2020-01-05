import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Get All with pagination
  static Future<List<Map<String, dynamic>>> fetchData(String collectionPath,
      String orderBy, int perPage, String lastDocumentId) async {
    try {
      var db = Firestore.instance;
      var result = List<Map<String, dynamic>>();

      DocumentSnapshot lastDoc;
      if (lastDocumentId.isNotEmpty) {
        lastDoc = await db.document("$collectionPath/$lastDocumentId").get();
      }

      Query query = db.collection(collectionPath);

      if (orderBy.isNotEmpty) {
        query = query.orderBy(orderBy);
      }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
      if (perPage > 0) {
        query = query.limit(perPage);
      }

      QuerySnapshot querySnapshots = await query.getDocuments();
      querySnapshots.documents.forEach((DocumentSnapshot snapshot) {
        Map<String, dynamic> map = Map.from(snapshot.data);
        map.addAll({'documentId': snapshot.documentID});
        result.add(map);
      });

      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Get by Document Id
  static Future<Map<String, dynamic>> getByDocumentId(
      String collectionPath, String documentId) async {
    try {
      var document = await Firestore.instance
          .document("$collectionPath/$documentId")
          .get();

      Map<String, dynamic> map = Map.from(document.data);
      map.addAll({
        'documentId': document.documentID,
      });

      return map;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Get by any field
  static Future<Map<String, dynamic>> getByAnyField(
      String collectionPath, String fieldName, String fieldValue) async {
    try {
      Query query = Firestore.instance
          .collection(collectionPath)
          .where(fieldName, isEqualTo: fieldValue)
          .limit(1);

      QuerySnapshot querySnapshots = await query.getDocuments();
      var result = querySnapshots?.documents?.first;
      if (result != null) {
        Map<String, dynamic> map = Map.from(result.data);
        map.addAll({
          'documentId': result.documentID,
        });
        return map;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Insert
  static Future<String> createData(
      String collectionPath, Map<String, dynamic> data) async {
    try {
      var db = Firestore.instance;
      var documentReference = await db.collection(collectionPath).add(data);
      return documentReference?.documentID ?? null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Update
  static Future<void> updateData(String collectionPath, String documentId,
      Map<String, dynamic> data) async {
    try {
      await Firestore.instance
          .document("$collectionPath/$documentId")
          .updateData(data);
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete
  static Future<void> deleteData(
      String collectionPath, String documentId) async {
    try {
      await Firestore.instance.document("$collectionPath/$documentId").delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
