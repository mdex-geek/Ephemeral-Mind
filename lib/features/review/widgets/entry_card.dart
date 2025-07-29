import 'package:flutter/material.dart';
import '../data/entry_model.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final int index;
  final void Function(int) onDelete;
  final void Function(int) onSave;


  const EntryCard({required this.entry, required this.index,required this.onDelete,required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: entry.color.withAlpha(39),
                  child: Text(
                    entry.author.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(color: entry.color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(entry.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(entry.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  key: ValueKey(entry.isSaved),
                  onPressed: ()=> onSave(index) ,
                  icon:  Icon(
                    entry.isSaved ? Icons.bookmark:Icons.bookmark_border,
                    color: entry.isSaved?Colors.blue:Colors.grey,
                  ),
                  label: const Text('Preserve'),
                ),
                const SizedBox(width: 8),
                // delete
                OutlinedButton.icon(
                  onPressed: (){
                     onDelete(index);
                  },
                  
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 

