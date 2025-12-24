import 'dart:io';
import 'dart:math';

void main() {
  final file = File('fashion_fusion_full_system.dart');
  final buffer = StringBuffer();

  buffer.writeln("import 'dart:math';");
  buffer.writeln("");

  buffer.writeln("""
class Outfit {
  String id;
  String color;
  String style;
  String fabric;
  List<String> tags;
  Outfit(this.id,this.color,this.style,this.fabric,this.tags);
}
""");

  for (int i = 0; i < 40; i++) {
    buffer.writeln(generateBM25(i));
    buffer.writeln(generateTFIDF(i));
    buffer.writeln(generateCosine(i));
    buffer.writeln(generateFuzzy(i));
    buffer.writeln(generateSuggestion(i));
    buffer.writeln(generateVirtualTryOn(i));
    buffer.writeln(generateColorHunt(i));
    buffer.writeln(generateFashionGenerator(i));
    buffer.writeln(generateShopping(i));
  }

  buffer.writeln(generateMainApp());

  file.writeAsStringSync(buffer.toString());
  print("✅ fashion_fusion_full_system.dart generated successfully");
}

String generateBM25(int i) {
  return """
class BM25Ranker$i {
  double rank(Outfit o, Map<String,String> p) {
    double s = 0;
    if(o.color==p['color']) s+=2.0;
    if(o.style==p['style']) s+=1.5;
    if(o.fabric==p['fabric']) s+=1.0;
    return s;
  }
}
""";
}

String generateTFIDF(int i) {
  return """
class TFIDFEngine$i {
  double score(Outfit o, List<String> q) {
    int m = o.tags.where((t)=>q.contains(t)).length;
    return m/(q.isEmpty?1:q.length);
  }
}
""";
}

String generateCosine(int i) {
  return """
class CosineSimilarity$i {
  double compute(List<String>a,List<String>b){
    int c=a.where((x)=>b.contains(x)).length;
    return c/sqrt((a.length*b.length)+1);
  }
}
""";
}

String generateFuzzy(int i) {
  return """
class FuzzySearch$i {
  double match(String t,List<String> tags){
    return tags.any((x)=>x.contains(t))?1.0:0.4;
  }
}
""";
}

String generateSuggestion(int i) {
  return """
class SuggestionSystem$i {
  final BM25Ranker$i bm25=BM25Ranker$i();
  final TFIDFEngine$i tfidf=TFIDFEngine$i();
  final CosineSimilarity$i cosine=CosineSimilarity$i();
  final FuzzySearch$i fuzzy=FuzzySearch$i();

  double rank(Outfit o,Map<String,String> p,List<String> q){
    return bm25.rank(o,p)
    + tfidf.score(o,q)
    + cosine.compute(o.tags,q)
    + fuzzy.match(q.first,o.tags);
  }
}
""";
}

String generateVirtualTryOn(int i) {
  return """
class VirtualTryOn$i {
  void apply(Outfit o){
    print("Virtual Try-On applied for \${o.id}");
  }
}
""";
}

String generateColorHunt(int i) {
  return """
class ColorHunt$i {
  List<String> suggest(String color){
    return ["shade1","shade2","shade3"];
  }
}
""";
}

String generateFashionGenerator(int i) {
  return """
class AIFashionGenerator$i {
  Outfit generate(String prompt){
    return Outfit(
      "AI-$i",
      "black",
      "casual",
      "cotton",
      ["modern","street","trendy"]
    );
  }
}
""";
}

String generateShopping(int i) {
  return """
class ShoppingModule$i {
  void order(Outfit o){
    print("Order placed for \${o.id}");
  }
}
""";
}

String generateMainApp() {
  return """
void main(){
  final outfit=Outfit(
    "OUTFIT-001",
    "black",
    "casual",
    "cotton",
    ["street","modern","minimal"]
  );

  final prefs={
    "color":"black",
    "style":"casual",
    "fabric":"cotton"
  };

  final query=["street","modern"];

  final s=SuggestionSystem0();
  final score=s.rank(outfit,prefs,query);

  VirtualTryOn0().apply(outfit);
  ColorHunt0().suggest(outfit.color);
  final ai=AIFashionGenerator0().generate("black casual outfit");
  ShoppingModule0().order(ai);

  print("Final Hybrid IR Score: \$score");
}
""";
}
