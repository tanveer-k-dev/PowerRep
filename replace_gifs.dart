import 'dart:io';

void main() async {
  final file = File('lib/services/mock_data_service.dart');
  
  // Read the file
  String content = await file.readAsString();
  
  // Replace all occurrences
  content = content.replaceAll(
    "'gifUrl': gifUrl,",
    "'gifUrl': getRandomGifUrl(),"
  );
  
  // Write back
  await file.writeAsString(content);
  
  print('✓ Successfully updated all gifUrl references!');
  print('Total exercises now use random GIF URLs.');
}
